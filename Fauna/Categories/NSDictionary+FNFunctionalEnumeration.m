//
//  NSDictionary+FNFunctionalEnumeration.m
//  Fauna
//
//  Created by Matt Freels on 4/2/13.
//  Copyright (c) 2013 Fauna. All rights reserved.
//

#import "NSDictionary+FNFunctionalEnumeration.h"

@implementation NSDictionary (FNFunctionalEnumeration)

- (NSArray *)map:(id (^)(id key, id value))block {
  NSMutableArray *rv = [NSMutableArray arrayWithCapacity:self.count];

  [self enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL *stop) {
    [rv addObject:block(key, value)];
  }];

  return rv;
}

@end
