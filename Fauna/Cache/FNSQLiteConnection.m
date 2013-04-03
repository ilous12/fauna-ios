//
// FNSQLiteConnection.m
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

#import <sqlite3.h>
#import "FNError.h"
#import "FNSQLiteConnection.h"

typedef int SQLITE_STATUS;

static NSError * SQLiteError(int status, const char *msg) {
  return [NSError errorWithDomain:@"org.fauna.FNCache" code:3 userInfo:@{
          @"sqlite_status_code": @(status),
          @"sqlite_error_message": [NSString stringWithCString:msg encoding:NSUTF8StringEncoding]
          }];
}

@interface FNSQLiteConnection ()

@property (nonatomic, readonly) sqlite3 *database;

@end

@implementation FNSQLiteConnection

- (id)initWithSQLitePath:(NSString *)path {
  if(self = [super init]) {
    SQLITE_STATUS status = sqlite3_open([path fileSystemRepresentation], &_database);
    if(status != SQLITE_OK) {
      const char *errMsg;
      if (_database) {
        errMsg = sqlite3_errmsg(_database);
      } else {
        errMsg = "Database handle could not be allocated.";
      }

      NSLog(@"FNSQLite: Unable to open database %@ (%i): %s", path, status, errMsg);
      return nil;
    }

    _isClosed = NO;
  }

  return self;
}

- (void)dealloc {
  [self close];
}

#pragma mark Public methods

- (BOOL)withTransaction:(BOOL(^)(void))block {
  NSError __autoreleasing *err;

  [self execute:@"BEGIN" error:&err];

  if (block()) {
    [self execute:@"COMMIT" error:&err];
    return YES;
  } else {
    [self execute:@"ROLLBACK" error:&err];
    return NO;
  }
}

static SQLITE_STATUS step(sqlite3_stmt *stmt) {
  int status = sqlite3_step(stmt);

  if (status == SQLITE_BUSY || status == SQLITE_LOCKED) {
    // TODO: Backoff
    // [self performSelector:@selector(executeNextStep:) withObject:(__bridge id)stmt afterDelay:.005];
    usleep(5000);
    return step(stmt);
  } else {
    return status;
  }
}

static int BindParameters(sqlite3_stmt *stmt, NSArray *parameters) {
  if (parameters.count == 0) return SQLITE_OK;

  int status;
  int count = sqlite3_bind_parameter_count(stmt);

  if (count != parameters.count) {
    @throw @"Bind count does not equal parameter count.";
  }

  for (int i = 0; i < count; i++) {
    id p = parameters[i];

    if (p == nil || [p isKindOfClass:[NSNull class]]) {
      status = sqlite3_bind_null(stmt, i + 1);
    } else if ([p isKindOfClass:[NSString class]]) {
      status = sqlite3_bind_text(stmt, i + 1, [p UTF8String], -1, SQLITE_TRANSIENT);
    } else if ([p isKindOfClass:[NSData class]]) {
      status = sqlite3_bind_blob(stmt, i + 1, [p bytes], [p length], SQLITE_TRANSIENT);
    } else if ([p isKindOfClass:[NSNumber class]]) {
      const char *t = [p objCType];
      if (strcmp(t, @encode(float)) == 0 || strcmp(t, @encode(double)) == 0) {
        status = sqlite3_bind_double(stmt, i + 1, [p doubleValue]);
      } else {
        status = sqlite3_bind_int64(stmt, i + 1, [p longLongValue]);
      }
    } else {
      @throw [NSString stringWithFormat:@"Unrecognized parameter type. Expected NSString, NSData, NSNumber, or NSNull. Got %@", [p class]];
    }

    if (status != SQLITE_OK) return status;
  }

  return status;
}

- (NSArray *)select:(NSString *)sql error:(NSError *__autoreleasing *)error {
  return [self select:sql parameters:@[] error:error];
}

- (NSArray *)select:(NSString *)sql parameters:(NSArray *)parameters error:(NSError * __autoreleasing *)error {
  NSAssert(!self.isClosed, @"Database is closed.");

  sqlite3_stmt *stmt;
  int status = sqlite3_prepare_v2(self.database, [sql UTF8String], -1, &stmt, NULL);

  if (status != SQLITE_OK) {
    *error = SQLiteError(status, sqlite3_errmsg(self.database));
    return nil;
  }

  status = BindParameters(stmt, parameters);

  if (status != SQLITE_OK) {
    sqlite3_finalize(stmt);
    *error = SQLiteError(status, sqlite3_errmsg(self.database));
    return nil;
  }

  status = step(stmt);

  NSMutableArray *result = [NSMutableArray new];

  if (status == SQLITE_ROW) {
    int cols = sqlite3_column_count(stmt);

    do {
      NSMutableArray *row = [[NSMutableArray alloc] initWithCapacity:cols];

      for(int i = 0; i < cols; i++) {
        switch (sqlite3_column_type(stmt, i)) {
          case SQLITE_INTEGER:
            [row addObject:@(sqlite3_column_int64(stmt, i))];
            break;
          case SQLITE_FLOAT:
            [row addObject:@(sqlite3_column_double(stmt, i))];
            break;
          case SQLITE_TEXT:
            [row addObject:[NSString stringWithCString:(const char *)sqlite3_column_text(stmt, i)
                                              encoding:NSUTF8StringEncoding]];
            break;
          case SQLITE_BLOB:
            [row addObject:[NSData dataWithBytes:sqlite3_column_blob(stmt, i)
                                          length:sqlite3_column_bytes(stmt, i)]];
            break;
        }
      }

      [result addObject:row];
      
      status = step(stmt);
    } while (status == SQLITE_ROW);
  }

  status = sqlite3_finalize(stmt);

  if (status == SQLITE_DONE || status == SQLITE_OK) {
    return result;
  } else {
    *error = SQLiteError(status, sqlite3_errmsg(self.database));
    return nil;
  }
}

- (BOOL)execute:(NSString *)sql error:(NSError *__autoreleasing *)error {
  return [self execute:sql parameters:@[] error:error];
}

- (BOOL)execute:(NSString *)sql parameters:(NSArray *)parameters error:(NSError * __autoreleasing *)error {
  NSAssert(!self.isClosed, @"Database is closed.");

  sqlite3_stmt *stmt;
  int status = sqlite3_prepare_v2(self.database, [sql UTF8String], -1, &stmt, NULL);

  if (status != SQLITE_OK) {
    *error = SQLiteError(status, sqlite3_errmsg(self.database));
    return nil;
  }

  status = BindParameters(stmt, parameters);

  if (status != SQLITE_OK) {
    sqlite3_finalize(stmt);
    *error = SQLiteError(status, sqlite3_errmsg(self.database));
    return nil;
  }

  status = step(stmt);

  sqlite3_finalize(stmt);

  if (status == SQLITE_DONE || status == SQLITE_ROW || status == SQLITE_OK) {
    return YES;
  } else {
    *error = SQLiteError(status, sqlite3_errmsg(self.database));
    return NO;
  }
}

- (int)rowsChanged {
  return sqlite3_changes(self.database);
}

- (int64_t)lastRowID {
  return sqlite3_last_insert_rowid(self.database);
}

- (NSString *)lastErrorMessage {
  const char *msg = sqlite3_errmsg(self.database);
  return msg == NULL ? nil : [NSString stringWithCString:msg encoding:NSUTF8StringEncoding];
}

- (void)close {
  _isClosed = YES;
  sqlite3_close(self.database);
}

@end
