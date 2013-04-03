//
//  NSDictionary+FNFunctionalEnumeration.h
//  Fauna
//
//  Created by Matt Freels on 4/2/13.
//  Copyright (c) 2013 Fauna. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (FNFunctionalEnumeration)

- (NSArray *)map:(id (^)(id key, id value))block;

@end
