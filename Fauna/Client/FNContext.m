//
// FNContext.m
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

#import "FNContext.h"
#import "FNContextConfig.h"
#import "FNFuture.h"
#import "FNError.h"
#import "FNClient.h"
#import "FNNetworkStatus.h"
#import "FNCache.h"
#import "FNSQLiteCache.h"
#import "FNNullCache.h"
#import "NSString+FNStringExtensions.h"
#import "NSDictionary+FNFunctionalEnumeration.h"

NSString * const FNFutureScopeContextKey = @"FNContext";

static NSString * const FNContextSignedInUserTokenKey = @"org.fauna.FNContext.signedInUserToken";

static FNContext *_defaultContext;

static FNContext *_signedInUserContext;

static FNContextConfig *_defaultConfig;

static FNContextConfig *DefaultDefaultConfig() {
  static FNContextConfig *config;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    config = [FNContextConfig configWithMaxWifiAge:15 maxWWANAge:15 timeout:240 fallbackOnError:NO];
  });

  return config;
}

static NSUInteger _defaultCacheSize = 1 * 1024 * 1024;

@interface FNContext ()

@property (nonatomic, readonly) FNContextConfig *config;

@end

@implementation FNContext

#pragma mark lifecycle

- (id)initWithClient:(FNClient *)client cache:(FNCache *)cache config:(FNContextConfig *)config {
  self = [super init];
  if (self) {
    _client = client;
    _cache = cache;
    _config = config;
  }
  return self;
}

- (id)initWithClient:(FNClient *)client {
  FNContextConfig *config = FNContext.defaultConfig ?: DefaultDefaultConfig();
  FNCache *cache = FNContext.defaultCacheSize > 0 ?
    [FNSQLiteCache cacheWithName:[client getAuthHash] maxSize:FNContext.defaultCacheSize] :
    [FNNullCache new];
  return [self initWithClient:client cache:cache config:config];
}

- (id)initWithKey:(NSString*)keyString {
  return [self initWithClient:[[FNClient alloc] initWithKey:keyString]];
}

- (id)initWithKey:(NSString *)keyString asUser:(NSString *)userRef {
  return [self initWithClient:[[FNClient alloc] initWithKey:keyString asUser:userRef]];
}

- (id)initWithPublisherEmail:(NSString *)email password:(NSString *)password {
  return [self initWithClient:[[FNClient alloc] initWithPublisherEmail:email password:password]];
}

+ (instancetype)contextWithKey:(NSString *)keyString {
  return [[self alloc] initWithKey:keyString];
}

+ (instancetype)contextWithKey:(NSString *)keyString asUser:(NSString *)userRef {
  return [[self alloc] initWithKey:keyString asUser:userRef];
}

+ (instancetype)contextWithPublisherEmail:(NSString *)email password:(NSString *)password {
  return [[self alloc] initWithPublisherEmail:email password:password];
}

#pragma mark Public methods

- (instancetype)asUser:(NSString *)userRef {
  return [[self.class alloc] initWithClient:[self.client asUser:userRef]];
}

+ (FNContext *)defaultContext {
  return _defaultContext;
}

+ (void)setDefaultContext:(FNContext *)context {
  _defaultContext = context;
}

+ (FNContext *)signedInUserContext {
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

  @synchronized (self) {
    if (!_signedInUserContext) {
      NSString *token = [defaults objectForKey:FNContextSignedInUserTokenKey];
      _signedInUserContext = token ? (id)[FNContext contextWithKey:token] : (id)[NSNull null];
    }

    return (id)_signedInUserContext == (id)[NSNull null] ? nil : _signedInUserContext;
  }
}

+ (void)setSignedInUserToken:(NSString *)token {
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

  @synchronized (self) {
    if (token) {
      [defaults setObject:token forKey:FNContextSignedInUserTokenKey];
    } else {
      [defaults removeObjectForKey:FNContextSignedInUserTokenKey];
    }

    _signedInUserContext = nil;
  }
}

+ (void)setSignedInUserContext:(FNContext *)ctx {
  @synchronized (self) {
    _signedInUserContext = ctx;
  }
}

+ (FNContextConfig *)defaultConfig {
  return _defaultConfig;
}

+ (void)setDefaultConfig:(FNContextConfig *)config {
  _defaultConfig = config;
}

+ (NSUInteger)defaultCacheSize {
  return _defaultCacheSize;
}

+ (void)setDefaultCacheSize:(NSUInteger)cacheSize {
  _defaultCacheSize = cacheSize;
}

+ (FNContext *)currentContext {
  return self.scopedContext ?: self.signedInUserContext ?: self.defaultContext;
}

- (id)inContext:(id (^)(void))block {
  FNContext *prev = self.class.scopedContext;
  self.class.scopedContext = self;
  @try {
    return block();
  } @finally {
    self.class.scopedContext = prev;
  }
}

- (void)performInContext:(void (^)(void))block {
  FNContext *prev = self.class.scopedContext;
  self.class.scopedContext = self;
  @try {
    block();
  } @finally {
    self.class.scopedContext = prev;
  }
}

- (void)setLogHTTPTraffic:(BOOL)log {
  self.client.logHTTPTraffic = log;
}

#pragma mark equality

- (BOOL)isEquivalentToContext:(FNContext *)context {
  return self == context || (context && [self.client isEqualToClient:context.client]);
}

#pragma mark HTTP methods

+ (FNFuture *)get:(NSString *)path parameters:(NSDictionary *)parameters {
  FNContext *ctx = self.currentOrRaise;
  return [ctx.client get:path parameters:parameters timeout:ctx.config.requestTimeout];
}

+ (FNFuture *)post:(NSString *)path parameters:(NSDictionary *)parameters {
  FNContext *ctx = self.currentOrRaise;
  return [ctx.client post:path parameters:parameters timeout:ctx.config.requestTimeout];
}

+ (FNFuture *)put:(NSString *)path parameters:(NSDictionary *)parameters {
  FNContext *ctx = self.currentOrRaise;
  return [ctx.client put:path parameters:parameters timeout:ctx.config.requestTimeout];
}

+ (FNFuture *)delete:(NSString *)path parameters:(NSDictionary *)parameters {
  FNContext *ctx = self.currentOrRaise;
  return [ctx.client delete:path parameters:parameters timeout:ctx.config.requestTimeout];
}

#pragma mark caching helpers

static FNFuture * CacheReferences(FNCache *cache, FNTimestamp time, FNFuture *response) {
  return [response flatMap:^(FNResponse *res) {
    return [FNFutureJoin([res.references map:^(NSString *ref, NSDictionary *resource) {
      return [cache setObject:resource extraPaths:@[] timestamp:time];
    }]) map_:^{
      return res;
    }];
  }];
}

static FNFuture * CacheResourceResponse(FNCache *cache, NSArray *paths, FNTimestamp time, FNFuture *response) {
  return [[CacheReferences(cache, time, response) flatMap:^(FNResponse *res) {
    return [[cache setObject:res.resource extraPaths:paths timestamp:time] map_:^{ return res.resource; }];
  }] rescue:^(NSError *error) {
    if (error.isFNNotFound) {
      return paths.count > 0 ? [cache removeObjectForPath:paths[0] timestamp:time].done : [FNFuture value:nil];
    } else {
      return [FNFuture error:error];
    }
  }];
}

static FNFuture * CacheEventsPageResponse(FNCache *cache, FNTimestamp time, FNFuture *response) {
  return CacheReferences(cache, time, response);
}

static FNFuture * CacheCreatesPageResponse(FNCache *cache, FNTimestamp time, FNFuture *response) {
  return CacheReferences(cache, time, response);
}

static FNFuture * CacheUpdatesPageResponse(FNCache *cache, FNTimestamp time, FNFuture *response) {
  return CacheReferences(cache, time, response);
}

#pragma mark caching Resource methods

+ (FNFuture *)getResource:(NSString *)path {
  FNContext *ctx = self.currentOrRaise;
  FNTimestamp now = FNNow();
  NSTimeInterval maxAge = [ctx.config maxAgeForReachabilityStatus:ctx.client.reachabilityStatus];
  FNTimestamp threshold = FNTimestampSubtractInterval(now, maxAge);

  return [[ctx.cache objectForPath:path after:threshold] flatMap:^(id value) {
    if (value) {
      return [FNFuture value:(value == FNCacheTombstone ? nil : value)];
    } else {
      return [CacheResourceResponse(ctx.cache, @[path], now, [self get:path parameters:@{}]) rescue:^(NSError *error){
        if (ctx.config.fallbackOnError && (error.isFNRequestTimeout || error.isFNInternalServerError)) {
          return [[ctx.cache objectForPath:path after:FNFirst] flatMap:^(id value){
            return value ? [FNFuture value:(value == FNCacheTombstone ? nil : value)] : [FNFuture error:error];
          }];
        } else {
          return [FNFuture error:error];
        }
      }];
    }
  }];
}

+ (FNFuture *)postResource:(NSString *)path parameters:(NSDictionary *)parameters {
  FNContext *ctx = self.currentOrRaise;
  return CacheResourceResponse(ctx.cache, @[], FNNow(), [self post:path parameters:parameters]);
}

+ (FNFuture *)putResource:(NSString *)path parameters:(NSDictionary *)parameters {
  FNContext *ctx = self.currentOrRaise;
  return CacheResourceResponse(ctx.cache, @[path], FNNow(), [self put:path parameters:parameters]);
}

+ (FNFuture *)deleteResource:(NSString *)path {
  FNContext *ctx = self.currentOrRaise;
  return [[self delete:path parameters:@{}] flatMap:^(FNResponse *res) {
    return [[ctx.cache removeObjectForPath:path timestamp:FNNow()] map_:^{ return res.resource; }];
  }];
}

#pragma mark caching Set methods

+ (FNFuture *)getEventsPage:(NSString *)path parameters:(NSDictionary *)parameters {
  FNContext *ctx = self.currentOrRaise;
  FNFuture *get = [self get:path parameters:parameters];
  return [CacheEventsPageResponse(ctx.cache, FNNow(), get) map:^(FNResponse *res){
    return res.resource;
  }];
}

+ (FNFuture *)getCreatesPage:(NSString *)path parameters:(NSDictionary *)parameters {
  FNContext *ctx = self.currentOrRaise;
  FNFuture *get = [self get:[path stringByAppendingString:@"/creates"] parameters:parameters];
  return [CacheCreatesPageResponse(ctx.cache, FNNow(), get) map:^(FNResponse *res){
    return res.resource;
  }];
}

+ (FNFuture *)getUpdatesPage:(NSString *)path parameters:(NSDictionary *)parameters {
  FNContext *ctx = self.currentOrRaise;
  FNFuture *get = [self get:[path stringByAppendingString:@"/updates"] parameters:parameters];
  return [CacheUpdatesPageResponse(ctx.cache, FNNow(), get) map:^(FNResponse *res){
    return res.resource;
  }];
}

+ (FNFuture *)addToSet:(NSString *)path resource:(NSString *)resource {
  FNContext *ctx = self.currentOrRaise;
  FNFuture *add = [self post:path parameters:@{@"resource": resource}];
  return [CacheEventsPageResponse(ctx.cache, FNNow(), add) map:^(FNResponse *res){
    return res.resource;
  }];
}

+ (FNFuture *)removeFromSet:(NSString *)path resource:(NSString *)resource {
  FNContext *ctx = self.currentOrRaise;
  FNFuture *remove = [self delete:path parameters:@{@"resource": resource}];
  return [CacheEventsPageResponse(ctx.cache, FNNow(), remove) map:^(FNResponse *res){
    return res.resource;
  }];
}

#pragma mark Private methods

+ (FNContext *)currentOrRaise {
  FNContext *ctx = self.currentContext;
  if (!ctx) @throw FNContextNotDefined();
  return ctx;
}

+ (FNContext *)scopedContext {
  return FNFuture.currentScope[FNFutureScopeContextKey];
}

+ (void)setScopedContext:(FNContext *)ctx {
  NSMutableDictionary *scope = FNFuture.currentScope;

  if (ctx) {
    scope[FNFutureScopeContextKey] = ctx;
  } else {
    [scope removeObjectForKey:FNFutureScopeContextKey];
  }
}

@end
