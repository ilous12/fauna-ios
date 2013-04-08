//
// FNContext.h
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
@class FNClient;
@class FNCache;
@class FNContextConfig;

/*!
 Fauna API Context
 */
@interface FNContext : NSObject

#pragma mark properties
@property (nonatomic, readonly) FNClient *client;
@property (nonatomic, readonly) FNCache *cache;
#pragma mark lifecycle

/*!
 Initializes the Context with the given key or user token.
 @param keyString key or user token
 */
- (id)initWithKey:(NSString *)keyString;

/*!
 Initializes the Context with the given publisher key, masquerading as a specific user.
 @param keyString a publisher key
 @param userRef the ref of the user to masquerade as (e.g. 'users/123').
 */
- (id)initWithKey:(NSString *)keyString asUser:(NSString *)userRef;

/*!
 Initializes the Context with the publisher's email and password.
 @param email the publisher's email
 @param password the publisher's password
 */
- (id)initWithPublisherEmail:(NSString *)email password:(NSString *)password;

/*!
 Returns a new Context with the given key or user token.
 @param keyString key or user token
 */
+ (instancetype)contextWithKey:(NSString *)keyString;

/*!
 Returns a new Context with the given publisher key, masquerading as a specific user.
 @param keyString a publisher key
 @param userRef the ref of the user to masquerade as (e.g. 'users/123').
 */
+ (instancetype)contextWithKey:(NSString *)keyString asUser:(NSString *)userRef;

/*!
 Returns a new Context with the publisher's email and password.
 @param email the publisher's email
 @param password the publisher's password
 */
+ (instancetype)contextWithPublisherEmail:(NSString *)email password:(NSString *)password;

#pragma mark user masquerading

/*!
 Returns a new Context that masquerades as a specific user. Only valid if this Context was initialized with a publisher key.
 @param userRef the ref of the user to masquerade as (e.g. 'users/123')
 */
- (instancetype)asUser:(NSString *)userRef;

#pragma mark default configuration

/*!
 Returns the default context configuration new Contexts are created with.
 */
+ (FNContextConfig *)defaultConfig;

/*!
 Sets the default context configuration.
 */
+ (void)setDefaultConfig:(FNContextConfig *)config;

/*!
 Returns the default cache size new Context's caches are created with.
 */
+ (NSUInteger)defaultCacheSize;

/*!
 Sets the default cache size
 */
+ (void)setDefaultCacheSize:(NSUInteger)cacheSize;

#pragma mark context management

/*!
 Returns the default FNContext for the Application.
 */
+ (FNContext *)defaultContext;

/*!
 Sets the default FNContext for the Application.
 */
+ (void)setDefaultContext:(FNContext *)context;

/*!
 Returns the innermost active FNContext, falling back to defaultContext if none is available.
 */
+ (FNContext *)currentContext;

/*!
 Runs a code block in the current context, returning the result of the block.
 @param block The block to be executed in the context.
 */
- (id)inContext:(id (^)(void))block;

/*!
 Runs a code block in the current context.
 @param block The block to be executed in the context.
 */
- (void)performInContext:(void (^)(void))block;

#pragma mark http methods

+ (FNFuture *)get:(NSString *)path parameters:(NSDictionary *)parameters;

+ (FNFuture *)post:(NSString *)path parameters:(NSDictionary *)parameters;

+ (FNFuture *)put:(NSString *)path parameters:(NSDictionary *)parameters;

+ (FNFuture *)delete:(NSString *)path parameters:(NSDictionary *)parameters;


+ (FNFuture *)getResource:(NSString *)path;

+ (FNFuture *)postResource:(NSString *)path parameters:(NSDictionary *)parameters;

+ (FNFuture *)putResource:(NSString *)path parameters:(NSDictionary *)parameters;

+ (FNFuture *)deleteResource:(NSString *)path;


+ (FNFuture *)getEventsPage:(NSString *)path parameters:(NSDictionary *)parameters;

+ (FNFuture *)getCreatesPage:(NSString *)path parameters:(NSDictionary *)parameters;

+ (FNFuture *)getUpdatesPage:(NSString *)path parameters:(NSDictionary *)parameters;

+ (FNFuture *)addToSet:(NSString *)path resource:(NSString *)resource;

+ (FNFuture *)removeFromSet:(NSString *)path resource:(NSString *)resource;


#pragma mark debugging

- (void)setLogHTTPTraffic:(BOOL)log;

#pragma mark equality

- (BOOL)isEquivalentToContext:(FNContext *)context;

@end
