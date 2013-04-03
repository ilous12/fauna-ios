//
// FNSQLiteCacheTest.m
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

#import <GHUnitIOS/GHUnit.h>
#import <Fauna/FNSQLiteCache.h>
#import <Fauna/FNFuture.h>

#define MaxCacheSize 1 * 1024 * 1024

@interface FNSQLiteCacheTest : GHAsyncTestCase { }
@end

@implementation FNSQLiteCacheTest

- (void)testPersistentPutAndGet {
  [self prepare];

  NSString *testFilename = TestUniqueID();

  FNSQLiteCache *cache = [FNSQLiteCache cacheWithName:testFilename maxSize:MaxCacheSize];
  NSDictionary *dict = @{@"ref":@"tests/sup", @"test": @"sup"};

  [[cache setObject:dict extraPaths:@[@"other/sup"] timestamp:FNNow()] onSuccess:^(id blah) {
    FNSQLiteCache *otherCache = [FNSQLiteCache cacheWithName:testFilename maxSize:MaxCacheSize];

    FNFuture *rv1 = [[otherCache objectForPath:@"tests/sup" after:FNNow() - 500000] map:^(NSDictionary *rv) {
      return @([rv[@"test"] isEqualToString:@"sup"]);
    }];

    FNFuture *rv2 = [[otherCache objectForPath:@"other/sup" after:FNNow() - 500000] map:^(NSDictionary *rv) {
      return @([rv[@"test"] isEqualToString:@"sup"]);
    }];

    [rv1 onSuccess:^(NSNumber *b1) {
      [rv2 onSuccess:^(NSNumber *b2) {
        if (b1.boolValue && b2.boolValue) {
          [self notify:kGHUnitWaitStatusSuccess forSelector:@selector(testPersistentPutAndGet)];
        }
      }];
    }];
  }];

  [self waitForStatus:kGHUnitWaitStatusSuccess timeout:1.0];
}

//- (void)testUpdateIfNewer {
//  [self prepare];
//  NSString *testKey = @"testKey";
//  FNSQLiteCache *cache = [FNSQLiteCache volatileCache];
//  NSDate *now = [NSDate date];
//  FNTimestamp originalTime = FNTimestampFromNSDate(now);
//  FNTimestamp newerTime = FNTimestampFromNSDate([now dateByAddingTimeInterval:60]);
//
//  NSDictionary *newDict = @{@"test2": @"sup"};
//  NSDictionary *dict = @{@"test": @"sup"};
//  FNFuture* updateFuture = [[cache setObject:dict forKey:testKey at:originalTime] flatMap:^(id wtf) {
//    return [cache updateIfNewer:newDict forKey:testKey date:newerTime];
//  }];
//
//  [updateFuture flatMap:^(id wtf) {
//    FNFuture *rv = [cache valueForKey:testKey];
//    [rv onSuccess:^(NSDictionary *rv) {
//      if ([rv[@"test2"] isEqualToString:@"sup"]) {
//        [self notify:kGHUnitWaitStatusSuccess forSelector:@selector(testUpdateIfNewer)];
//      }
//    }];
//
//    return rv;
//  }];
//
//  [self waitForStatus:kGHUnitWaitStatusSuccess timeout:1.0];
//}
@end
