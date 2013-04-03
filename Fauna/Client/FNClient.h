//
// FNClient.h
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

@class FNFuture;

typedef enum {
  FNReachabilityOffline,
  FNReachabilityWifi,
  FNReachabilityWWAN
} FNReachabilityStatus;

FOUNDATION_EXPORT NSString * const FaunaAPIHost;
FOUNDATION_EXPORT NSString * const FaunaAPIBaseURL;
FOUNDATION_EXPORT NSString * const FaunaAPIVersion;

@interface FNResponse : NSObject

@property (nonatomic, readonly) NSDictionary *resource;
@property (nonatomic, readonly) NSDictionary *references;

- (id)initWithResource:(NSDictionary *)resource references:(NSDictionary *)references;

@end

@interface FNClient : NSObject

@property (nonatomic) NSString *traceID;

@property (nonatomic) BOOL logHTTPTraffic;

/*!
 Initializes the Client with the given key or user token.
 @param keyString key or user token
 */
- (id)initWithKey:(NSString *)keyString;

/*!
 Initializes the Client with the given publisher key, masquerading as a specific user.
 @param keyString a publisher key
 @param userRef the ref of the user to masquerade as (e.g. 'users/123')
 */
- (id)initWithKey:(NSString *)keyString asUser:(NSString *)userRef;

/*!
 Initializes the Client with the publisher's email and password.
 @param email the publisher's email
 @param password the publisher's password
 */
- (id)initWithPublisherEmail:(NSString *)email password:(NSString *)password;

- (NSString*) getAuthHash;

/*!
 Returns a new Client that masquerades as a specific user. Only valid if this Client was initialized with a publisher key.
 @param userRef the ref of the user to masquerade as (e.g. 'users/123')
 */
- (instancetype)asUser:(NSString *)userRef;

/*!
 Returns the reachability status of the client
 */
- (FNReachabilityStatus)reachabilityStatus;

/*!
 Perform a GET request of a specified resource.
 @param path the path of the resource
 @param parameters a Dictionary of query parameters to send with the request
 @param timeout request timeout
 */
- (FNFuture *)get:(NSString *)path parameters:(NSDictionary *)parameters timeout:(NSTimeInterval)timeout;

/*!
 Perform a POST request with the specified resource.
 @param path the path of the resource
 @param parameters a Dictionary of parameters to send with the request.
 @param timeout request timeout
 */
- (FNFuture *)post:(NSString *)path parameters:(NSDictionary *)parameters timeout:(NSTimeInterval)timeout;

/*!
 Perform a PUT request with the specified resource.
 @param path the path of the resource
 @param parameters a Dictionary of parameters to send with the request.
 @param timeout request timeout
 */
- (FNFuture *)put:(NSString *)path parameters:(NSDictionary *)parameters timeout:(NSTimeInterval)timeout;

/*!
 Perform a DELETE request with the specified resource.
 @param path the path of the resource
 @param parameters a Dictionary of parameters to send with the request.
 @param timeout request timeout
 */
- (FNFuture *)delete:(NSString *)path parameters:(NSDictionary *)parameters timeout:(NSTimeInterval)timeout;

#pragma mark equality

- (BOOL)isEqualToClient:(FNClient *)client;

@end
