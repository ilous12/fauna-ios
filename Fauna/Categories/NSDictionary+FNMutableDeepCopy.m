//
// NSDictionary+FNMutableDeepCopy.m
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
