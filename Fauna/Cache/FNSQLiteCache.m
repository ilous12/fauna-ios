//
// FNSQLiteCache.m
//
// Copyright (c) 2013 Fauna, Inc.
//
// Licensed under the Mozilla Public License, Version 2.0 (the "License"); you may
// not use this file except in compliance with the License. You may obtain a
// copy of the License at
//
// http://mozilla.org/MPL/2.0/
//
// Unless required by applicable law or agreed to in writing, software distributed
// under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.
//

#import "FNSQLiteCache.h"
#import "FNFuture.h"
#import "FNResource.h"
#import "FNSQLiteConnectionThread.h"
#import "FNSQLiteConnection.h"
#import <sqlite3.h>

#define CacheVersion 2
#define CacheCleanupPageSize 100
#define CacheCleanupCheckOdds 100
#define CacheCleanupThreshold 0.8
#define CacheCleanupRepeatThreshold 1.0
#define CacheCleanupVacuumThreshold 1.2

static NSString * const ResourcesDDL = @"\
CREATE TABLE IF NOT EXISTS resources ( \
  id INTEGER PRIMARY KEY NOT NULL, \
  data BLOB, \
  timestamp INTEGER NOT NULL, \
  deleted INTEGER NOT NULL DEFAULT 0 \
)";

static NSString * const ResourceAliasesDDL = @"\
CREATE TABLE IF NOT EXISTS resource_aliases ( \
  alias TEXT PRIMARY KEY NOT NULL, \
  resource_id INTEGER NOT NULL, \
  derived INTEGER NOT NULL \
)";

static NSString * const ResourcesByTimestamp = @"CREATE INDEX IF NOT EXISTS by_timestamp on resources (timestamp ASC)";

static NSString * const ResourceAliasesByResourceID = @"CREATE INDEX IF NOT EXISTS by_resource_id on resource_aliases (resource_id ASC)";


@interface FNSQLiteCache ()

@property (nonatomic, readonly) NSUInteger maxSize;
@property (nonatomic, readonly) NSString *filepath;
@property (nonatomic, readonly) FNSQLiteConnectionThread *connection;

@end

@implementation FNSQLiteCache

#pragma mark lifecycle

- (id)initWithSQLitePath:(NSString *)path maxSize:(NSUInteger)maxSize {
  if(self = [super init]) {
    _maxSize = maxSize;
    _filepath = path;
    _connection = [[FNSQLiteConnectionThread alloc] initWithSQLitePath:path];

    [self createOrUpdateTables];
  }
  return self;
}

- (id)initWithName:(NSString *)name maxSize:(NSUInteger)maxSize {
  NSArray *searchPaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
  NSString *cachePath = [searchPaths objectAtIndex:0];
  NSString *databasePath = [cachePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-cache.db", name]];

  return [self initWithSQLitePath:databasePath maxSize:maxSize];
}

- (void)dealloc {
  [self close];
}

#pragma mark Class methods

+ (instancetype)cacheWithName:(NSString *)name maxSize:(NSUInteger)maxSize {
  return [[FNSQLiteCache alloc] initWithName:name maxSize:maxSize];
}

#pragma mark Public methods

- (long long)fileSize {
  return [[[NSFileManager defaultManager] attributesOfItemAtPath:self.filepath error:nil][NSFileSize] longLongValue];
}

- (void)close {
  [self.connection close];
}

#pragma mark FNCache

- (FNFuture *)objectForPath:(NSString *)path after:(FNTimestamp)after {
  return [self.connection withConnection:^id(FNSQLiteConnection *db) {
    NSError __autoreleasing *err;

    NSArray *res = [db select:@"SELECT r.data, r.deleted FROM resources AS r \
                                JOIN resource_aliases as a on r.id = a.resource_id \
                                WHERE a.alias = ? AND r.timestamp >= ?"
                   parameters:@[path, FNTimestampToNSNumber(after)]
                        error:&err];

    if (!res) {
      NSLog(@"cache read error: %@", err);
      return CacheReadError();
    } else if (res.count == 0) {
      return nil;
    } else {
      NSNumber *deleted = res[0][1];
      return deleted.boolValue ? FNCacheTombstone : [NSKeyedUnarchiver unarchiveObjectWithData:res[0][0]];
    }
  }];
}

- (FNFuture *)setObject:(NSDictionary *)value extraPaths:(NSArray *)extraPaths timestamp:(FNTimestamp)timestamp {
  NSParameterAssert(value[@"ref"]);

  NSString *ref = value[@"ref"];
  NSString *uniqueID = value[@"unique_id"];
  NSData *data = [NSKeyedArchiver archivedDataWithRootObject:value];
  NSNumber *ts = FNTimestampToNSNumber(timestamp);

  NSMutableArray *derivedPaths = [NSMutableArray new];

  [derivedPaths addObject:ref];

  if (uniqueID) {
    NSParameterAssert(value[@"class"]);
    [derivedPaths addObject:[value[@"class"] stringByAppendingFormat:@"/%@", uniqueID]];
  }

  FNFuture *rv = [self.connection withConnection:^(FNSQLiteConnection *db) {
    BOOL success = [db withTransaction:^{
      NSArray *prev = [db select:@"SELECT resource_id FROM resource_aliases WHERE alias = ?" parameters:@[ref] error:NULL];
      NSNumber *resID = (prev && prev.count > 0) ? prev[0][0] : nil;

      if (resID) {
        if (![db execute:@"DELETE FROM resource_aliases WHERE resource_id = ? AND derived = 1" parameters:@[resID] error:NULL]) return NO;
        if (![db execute:@"UPDATE resources SET data = ?, timestamp = ?, deleted = 0 WHERE id = ?" parameters:@[data, ts, resID] error:NULL]) return NO;
      } else {
        if (![db execute:@"INSERT INTO resources (data, timestamp) VALUES (?, ?)" parameters:@[data, ts] error:NULL]) return NO;
        resID = @(db.lastRowID);
      }

      for (NSString *path in extraPaths) {
        if (![db execute:@"REPLACE INTO resource_aliases (alias, resource_id, derived) VALUES (?, ?, 0)" parameters:@[path, resID] error:NULL]) return NO;
      }

      for (NSString *path in derivedPaths) {
        if (![db execute:@"REPLACE INTO resource_aliases (alias, resource_id, derived) VALUES (?, ?, 1)" parameters:@[path, resID] error:NULL]) return NO;
      }

      return YES;
    }];

    return success ? nil : CacheWriteError();
  }];

  [self checkCleanupTables];

  return rv;
}

- (FNFuture *)removeObjectForPath:(NSString *)path timestamp:(FNTimestamp)timestamp {
  NSNumber *ts = FNTimestampToNSNumber(timestamp);

  FNFuture *rv = [self.connection withConnection:^(FNSQLiteConnection *db) {
    BOOL success = [db withTransaction:^{
      NSArray *prev = [db select:@"SELECT resource_id FROM resource_aliases WHERE alias = ?" parameters:@[path] error:NULL];
      NSNumber *resID = (prev && prev.count > 0) ? prev[0][0] : nil;

      if (resID) {
        if (![db execute:@"UPDATE resources SET data = NULL, timestamp = ?, deleted = 1 WHERE id = ?" parameters:@[ts, resID] error:NULL]) return NO;
      } else {
        if (![db execute:@"INSERT INTO resources (timestamp, deleted) VALUES (?, 1)" parameters:@[FNTimestampToNSNumber(FNNow())] error:NULL]) return NO;
        if (![db execute:@"INSERT INTO resource_aliases (alias, resource_id, derived) VALUES (?, ?, 0)" parameters:@[path, @(db.lastRowID)] error:NULL]) return NO;
      }

      return YES;
    }];

    return success ? nil : CacheWriteError();
  }];

  [self checkCleanupTables];

  return rv;
}

#pragma mark Private methods

- (BOOL)createOrUpdateTables {
  // Creates the Resources table.
  FNFuture *rv = [self.connection withConnection:^id(FNSQLiteConnection *db) {
    NSError __autoreleasing *err;
    if (![db execute:@"CREATE TABLE IF NOT EXISTS version (version INTEGER NOT NULL)" error:&err]) return err;

    NSArray *versions = [db select:@"SELECT version from version limit 1" error:&err];
    NSNumber *version = (versions && versions.count > 0) ? versions[0][0] : nil;

    if (!versions) return err;

    if (!version || version.intValue != CacheVersion) {

      NSLog(@"Initializing new cache tables.");

      if (![db execute:@"DELETE FROM version" error:&err]) return err;
      if (![db execute:@"DROP TABLE IF EXISTS resources" error:&err]) return err;
      if (![db execute:@"DROP TABLE IF EXISTS resource_aliases" error:&err]) return err;
      if (![db execute:ResourcesDDL error:&err]) return err;
      if (![db execute:ResourceAliasesDDL error:&err]) return err;
      if (![db execute:ResourcesByTimestamp error:&err]) return err;
      if (![db execute:ResourceAliasesByResourceID error:&err]) return err;

      if (![db execute:@"INSERT INTO version (version) VALUES (?)" parameters:@[@(CacheVersion)] error:&err]) return err;
    }

    return nil;
  }];

  [rv wait];

  if (rv.isError) {
    NSLog(@"Cache initialization failed: %@", rv.error);
    return NO;
  } else {
    return YES;
  }
}

- (void)checkCleanupTables {
  if (arc4random() % CacheCleanupCheckOdds == 0) [self cleanupTables];
}

- (void)cleanupTables {
  if (self.fileSize > self.maxSize * CacheCleanupThreshold) {
    FNFuture *rv = [self.connection withConnection:^id(FNSQLiteConnection *db) {
      NSError __autoreleasing *err;
      NSArray *rows = [db select:@"SELECT id FROM resources ORDER BY timestamp ASC LIMIT ?" parameters:@[@(CacheCleanupPageSize)] error:&err];
      if (!rows) return err;

      for (NSArray *resID in rows) {
        if (![db execute:@"DELETE FROM resource_aliases WHERE resource_id = ?" parameters:resID error:&err]) return err;
        if (![db execute:@"DELETE FROM resources WHERE id = ?" parameters:resID error:&err]) return err;
      }

      if (self.fileSize > self.maxSize * CacheCleanupVacuumThreshold) {
        if (![db execute:@"VACUUM" error:&err]) return err;
      }

      return nil;
    }];

    [rv onSuccess:^(id value) {
      if (self.fileSize > self.maxSize * CacheCleanupRepeatThreshold) {
        [self cleanupTables];
      }
    } onError:^(NSError *error) {
      NSLog(@"Error cleaning up cache tables: %@", error);
    }];
  }
}

@end
