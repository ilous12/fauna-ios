//
//  FNNullCache.m
//  Fauna
//
//  Created by Matt Freels on 4/2/13.
//  Copyright (c) 2013 Fauna. All rights reserved.
//

#import "FNFuture.h"
#import "FNNullCache.h"

@implementation FNNullCache

- (FNFuture *)setObject:(NSDictionary *)value extraPaths:(NSArray *)paths timestamp:(FNTimestamp)timestamp {
  return [FNFuture value:nil];
}

- (FNFuture *)removeObjectForPath:(NSString *)path timestamp:(FNTimestamp)timestamp {
  return [FNFuture value:nil];
}

- (FNFuture *)objectForPath:(NSString *)path after:(FNTimestamp)after {
  return [FNFuture value:nil];
}

@end
