//
// FNCache.m
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

#import "FNCache.h"
#import "FNFuture.h"

NSString * const FNCacheTombstone = @"org.fauna.FNCache.Tombstone";

NSError * CacheReadError() {
  return [NSError errorWithDomain:@"org.fauna.FNCache" code:1 userInfo:@{@"msg":@"Cache read failed."}];
}

NSError * CacheWriteError() {
  return [NSError errorWithDomain:@"org.fauna.FNCache" code:2 userInfo:@{@"msg": @"Cache write failed"}];
}

@implementation FNCache

- (FNFuture *)setObject:(NSDictionary *)value extraPaths:(NSArray *)paths timestamp:(FNTimestamp)timestamp {
  @throw @"not implemented";
}

- (FNFuture *)removeObjectForPath:(NSString *)path timestamp:(FNTimestamp)timestamp {
  @throw @"not implemented";
}

- (FNFuture *)objectForPath:(NSString *)path after:(FNTimestamp)after {
  @throw @"not implemented";
}

@end

