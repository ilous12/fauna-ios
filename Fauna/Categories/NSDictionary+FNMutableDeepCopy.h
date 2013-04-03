//
//  NSDictionary+FNMutableDeepCopy.h
//  Fauna
//
//  Created by Matt Freels on 4/3/13.
//  Copyright (c) 2013 Fauna. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (FNMutableDeepCopy)

- (NSMutableDictionary *)mutableDeepCopy;

@end
