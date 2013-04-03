//
//  NSArray+FNMutableDeepCopy.m
//  Fauna
//
//  Created by Matt Freels on 4/3/13.
//  Copyright (c) 2013 Fauna. All rights reserved.
//

#import "NSArray+FNMutableDeepCopy.h"
#import "NSDictionary+FNMutableDeepCopy.h"

@implementation NSArray (FNMutableDeepCopy)

- (NSMutableArray *)mutableDeepCopy {
  NSMutableArray *rv = [NSMutableArray arrayWithCapacity:self.count];

  for (id obj in self) {
    if ([obj isKindOfClass:[NSDictionary class]]) {
      [rv addObject:[obj mutableDeepCopy]];
    } else if ([obj isKindOfClass:[NSArray class]]) {
      [rv addObject:[obj mutableDeepCopy]];
    } else if ([obj respondsToSelector:@selector(mutableCopyWithZone:)]) {
      [rv addObject:[obj mutableCopy]];
    } else {
      [rv addObject:obj];
    }
  }

  return rv;
}

@end
