//
// FNEventSet.m
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

#import "FNFuture.h"
#import "FNContext.h"
#import "FNEventSet.h"
#import "NSArray+FNFunctionalEnumeration.h"

@interface FNEventSet ()

@property (nonatomic, readonly) NSString *path;

- (NSMutableDictionary *)baseParams;

- (NSDictionary *)paramsWithBefore:(FNTimestamp)before after:(FNTimestamp)after count:(NSInteger)count;

- (FNFuture *)mappedToPage:(FNFuture *)dictFuture;

@end

@implementation FNEventSet

#pragma mark lifecycle

- (id)initWithRef:(NSString *)ref {
  self = [super init];
  if (self) {
    _path = ref;
  }
  return self;
}

+ (FNEventSet *)eventSetWithRef:(NSString *)ref {
  return [[self alloc] initWithRef:ref];
}

#pragma mark Public methods

- (NSString *)ref {
  return self.path;
}

- (FNFuture *)pageBefore:(FNTimestamp)before {
  return [self pageBefore:before count:-1];
}

- (FNFuture *)pageBefore:(FNTimestamp)before count:(NSInteger)count {
  return [self eventsPageBefore:before after:-1 count:count];
}

- (FNFuture *)pageAfter:(FNTimestamp)after {
  return [self pageAfter:after count:-1];
}

- (FNFuture *)pageAfter:(FNTimestamp)after count:(NSInteger)count {
  return [self eventsPageBefore:-1 after:after count:count];
}

- (FNFuture *)createsBefore:(FNTimestamp)before {
  return [self createsBefore:before count:-1];
}

- (FNFuture *)createsBefore:(FNTimestamp)before count:(NSInteger)count {
  return [self createsBefore:before after:-1 count:count];
}

- (FNFuture *)createsAfter:(FNTimestamp)after {
  return [self createsAfter:after count:-1];
}

- (FNFuture *)createsAfter:(FNTimestamp)after count:(NSInteger)count {
  return [self createsBefore:-1 after:after count:count];
}

- (FNFuture *)updatesBefore:(FNTimestamp)before {
  return [self updatesBefore:before count:-1];
}

- (FNFuture *)updatesBefore:(FNTimestamp)before count:(NSInteger)count {
  return [self updatesBefore:before after:-1 count:count];
}

- (FNFuture *)updatesAfter:(FNTimestamp)after {
  return [self updatesAfter:after count:-1];
}

- (FNFuture *)updatesAfter:(FNTimestamp)after count:(NSInteger)count {
  return [self updatesBefore:-1 after:after count:count];
}

#pragma mark Private methods

- (NSMutableDictionary *)baseParams {
  return [NSMutableDictionary new];
}

- (NSDictionary *)paramsWithBefore:(FNTimestamp)before after:(FNTimestamp)after count:(NSInteger)count {
  NSMutableDictionary *params = self.baseParams;

  if (before > -1) params[@"before"] = FNTimestampToNSNumber(before);
  if (after > -1) params[@"after"] = FNTimestampToNSNumber(after);
  if (count > -1) params[@"size"] = @(count);

  return params;
}

- (FNFuture *)mappedToPage:(FNFuture *)dictFuture {
  return [dictFuture map:^(NSDictionary *dict){
    return [FNEventSetPage resourceWithDictionary:dict];
  }];
}

- (FNFuture *)eventsPageBefore:(FNTimestamp)before after:(FNTimestamp)after count:(NSInteger)count {
  return [self mappedToPage:[FNContext getEventsPage:self.path parameters:[self paramsWithBefore:before after:after count:count]]];
}

- (FNFuture *)createsBefore:(FNTimestamp)before after:(FNTimestamp)after count:(NSInteger)count {
  return [self mappedToPage:[FNContext getCreatesPage:self.path parameters:[self paramsWithBefore:before after:after count:count]]];
}

- (FNFuture *)updatesBefore:(FNTimestamp)before after:(FNTimestamp)after count:(NSInteger)count {
  return [self mappedToPage:[FNContext getUpdatesPage:self.path parameters:[self paramsWithBefore:before after:after count:count]]];
}

@end

@implementation FNQueryEventSet

- (id)initWithQueryFunction:(NSString *)function parameters:(NSArray *)parameters {
  self = [super init];
  if (self) {
    _function = function;
    _parameters = parameters;
    _query = self.generateQuery;
  }
  return self;
}

- (NSString *)path {
  return @"query";
}

-(NSString *)ref {
  return [NSString stringWithFormat:@"query?query=%@", self.query];
}

#pragma mark Private methods

- (NSString *)generateQuery {
  NSMutableArray *ps = [NSMutableArray arrayWithCapacity:self.parameters.count + 1];

  for (id param in self.parameters) {
    if ([param isKindOfClass:[FNQueryEventSet class]]) {
      [ps addObject:((FNQueryEventSet *)param).query];
    } else if ([param isKindOfClass:[FNEventSet class]]) {
      [ps addObject:[NSString stringWithFormat:@"'%@'", ((FNEventSet *)param).path]];
    } else {
      [ps addObject:[NSString stringWithFormat:@"'%@'", param]];
    }
  }

  return [NSString stringWithFormat:@"%@(%@)", self.function, [ps componentsJoinedByString:@","]];
}

- (NSMutableDictionary *)baseParams {
  return [NSMutableDictionary dictionaryWithObject:self.query forKey:@"query"];
}

@end

@implementation FNCustomEventSet

- (FNFuture *)add:(FNResource *)resource {
  return [self addRef:resource.ref];
}

- (FNFuture *)addRef:(NSString *)ref {
  return [FNContext addToSet:self.path resource:ref];
}

- (FNFuture *)remove:(FNResource *)resource {
  return [self removeRef:resource.ref];
}

- (FNFuture *)removeRef:(NSString *)ref {
  return [FNContext removeFromSet:self.path resource:ref];
}

@end

@interface FNEventSetPage () {
  NSArray *_events;
}
@end

@implementation FNEventSetPage

- (NSInteger)creates {
  return ((NSNumber *)self.dictionary[@"creates"]).integerValue;
}

- (NSInteger)updates {
  return ((NSNumber *)self.dictionary[@"updates"]).integerValue;
}

- (NSInteger)deletes {
  return ((NSNumber *)self.dictionary[@"deletes"]).integerValue;
}

- (FNTimestamp)before {
  return FNTimestampFromNSNumber(self.dictionary[@"before"]);
}

- (FNTimestamp)after {
  return FNTimestampFromNSNumber(self.dictionary[@"after"]);
}

- (NSArray *)events {
  if (!_events) {
    _events = [((NSArray *)self.dictionary[@"events"]) map:^(NSDictionary *dict){
      return [[FNEvent alloc] initWithDictionary:dict];
    }];
  }

  return _events;
}

- (FNFuture *)resources {
  return FNFutureSequence([self.events map:^(FNEvent *ev){
    return ev.resource;
  }]);
}

@end

@implementation FNEvent

- (id)initWithDictionary:(NSDictionary *)dictionary {
  self = [super init];
  if (self) {
    _action = dictionary[@"action"];
    _ref = dictionary[@"resource"];
    _eventSetRef = dictionary[@"set"];
    _timestamp = FNTimestampFromNSNumber(dictionary[@"ts"]);
  }
  return self;
}

- (FNEventSet *)eventSet {
  return [FNEventSet eventSetWithRef:self.eventSetRef];
}

- (FNFuture *)resource {
  return [FNResource get:self.ref];
}

@end
