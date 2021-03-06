//
// FNEventSet.h
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

#import <Foundation/Foundation.h>
#import "FNResource.h"

@class FNFuture;

@class FNEventSet;

@class FNQueryEventSet;

#define FNJoin(base, ...) ([[FNQueryEventSet alloc] initWithQueryFunction:@"join" parameters:@[(base), ##__VA_ARGS__ ]])

#define FNIntersection(first, ...) ([[FNQueryEventSet alloc] initWithQueryFunction:@"intersection" parameters:@[(first), ##__VA_ARGS__ ]])

#define FNUnion(first, ...) ([[FNQueryEventSet alloc] initWithQueryFunction:@"union" parameters:@[(first), ##__VA_ARGS__ ]])

#define FNDifference(first, ...) ([[FNQueryEventSet alloc] initWithQueryFunction:@"difference" parameters:@[(first), ##__VA_ARGS__ ]])

@interface FNEventSet : NSObject

@property (nonatomic, readonly) NSString *ref;

#pragma mark lifecycle

- (id)initWithRef:(NSString *)ref;

+ (instancetype)eventSetWithRef:(NSString *)ref;

#pragma mark Public methods

- (FNFuture *)pageBefore:(FNTimestamp)before;

- (FNFuture *)pageBefore:(FNTimestamp)before count:(NSInteger)count;

- (FNFuture *)pageAfter:(FNTimestamp)after;

- (FNFuture *)pageAfter:(FNTimestamp)after count:(NSInteger)count;

- (FNFuture *)createsBefore:(FNTimestamp)before;

- (FNFuture *)createsBefore:(FNTimestamp)before count:(NSInteger)count;

- (FNFuture *)createsAfter:(FNTimestamp)after;

- (FNFuture *)createsAfter:(FNTimestamp)after count:(NSInteger)count;

- (FNFuture *)updatesBefore:(FNTimestamp)before;

- (FNFuture *)updatesBefore:(FNTimestamp)before count:(NSInteger)count;

- (FNFuture *)updatesAfter:(FNTimestamp)after;

- (FNFuture *)updatesAfter:(FNTimestamp)after count:(NSInteger)count;

@end

@interface FNQueryEventSet : FNEventSet

@property (nonatomic, readonly) NSString *function;

@property (nonatomic, readonly) NSArray *parameters;

@property (nonatomic, readonly) NSString *query;

- (id)initWithQueryFunction:(NSString *)function parameters:(NSArray *)parameters;

@end

@interface FNCustomEventSet : FNEventSet

- (FNFuture *)add:(FNResource *)resource;

- (FNFuture *)addRef:(NSString *)ref;

- (FNFuture *)remove:(FNResource *)resource;

- (FNFuture *)removeRef:(NSString *)ref;

@end

@interface FNEventSetPage : FNResource

- (NSInteger)creates;

- (NSInteger)updates;

- (NSInteger)deletes;

- (FNTimestamp)after;

- (FNTimestamp)before;

- (NSArray *)events;

- (FNFuture *)resources;

@end


@interface FNEvent : NSObject

- initWithDictionary:(NSDictionary *)dictionary;

@property (nonatomic, readonly) NSString *ref;
@property (nonatomic, readonly) FNTimestamp timestamp;
@property (nonatomic, readonly) NSString *eventSetRef;
@property (nonatomic, readonly) NSString *action;

- (FNEventSet *)eventSet;

- (FNFuture *)resource;

@end
