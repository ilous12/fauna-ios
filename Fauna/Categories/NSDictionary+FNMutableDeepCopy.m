//
//  NSDictionary+FNMutableDeepCopy.m
//  Fauna
//
//  Created by Matt Freels on 4/3/13.
//  Copyright (c) 2013 Fauna. All rights reserved.
//

#import "NSDictionary+FNMutableDeepCopy.h"
#import "NSArray+FNMutableDeepCopy.h"

@implementation NSDictionary (FNMutableDeepCopy)

- (NSMutableDictionary *)mutableDeepCopy {
  NSMutableDictionary *rv = [NSMutableDictionary dictionaryWithCapacity:self.count];

  [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
    if ([obj isKindOfClass:[NSDictionary class]]) {
      rv[key] = [obj mutableDeepCopy];
    } else if ([obj isKindOfClass:[NSArray class]]) {
      rv[key] = [obj mutableDeepCopy];
    } else if ([obj respondsToSelector:@selector(mutableCopyWithZone:)]) {
      rv[key] = [obj mutableCopy];
    } else {
      rv[key] = obj;
    }
  }];

  return rv;
}

@end
