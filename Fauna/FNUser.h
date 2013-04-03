//
// FNUser.h
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

#import "FNInstance.h"

@class FNFuture;

@interface FNUser : FNInstance

/*!
 Retrieve the current user, if applicable to the current context.
 */
+ (FNFuture *)getSelf;

/*!
 Retrieve the current user's configuration resource, if applicable to the current context.
 */
+ (FNFuture *)getSelfConfig;

/*!
 Change the current user's password.
 */
+ (FNFuture *)changeSelfPassword:(NSString *)oldPassword newPassword:(NSString *)newPassword confirmation:(NSString *)confirmation;

/*!
 Returns an authentication token for a user identified by email and password. The token may be used to construct an a FNContext to make requests on behalf of the user.
 @param email the user's email
 @param password the user's password
 */
+ (FNFuture *)tokenForEmail:(NSString *)email password:(NSString *)password;

/*!
 Returns an authentication token for a user identified by a unique_id and password. The token may be used to construct an an FNContext to make requests on behalf of the user.
 @param uniqueID the user's unique_id
 @param password the user's password
 */
+ (FNFuture *)tokenForUniqueID:(NSString *)uniqueID password:(NSString *)password;

/*!
 Returns an authentication token for a user identified by a ref and password. The token may be used to construct an an FNContext to make requests on behalf of the user.
 @param ref the user's ref
 @param password the user's password
 */
+ (FNFuture *)tokenForRef:(NSString *)ref password:(NSString *)password;

/*!
 Returns an authentication context for a user identified by email and password.
 @param email the user's email
 @param password the user's password
 */
+ (FNFuture *)contextForEmail:(NSString *)email password:(NSString *)password;

/*!
 Returns an authentication token for a user identified by a unique_id and password.
 @param uniqueID the user's unique_id
 @param password the user's password
 */
+ (FNFuture *)contextForUniqueID:(NSString *)uniqueID password:(NSString *)password;

/*!
 Returns an authentication token for a user identified by a ref and password.
 @param ref the user's ref
 @param password the user's password
 */
+ (FNFuture *)contextForRef:(NSString *)ref password:(NSString *)password;

/*!
 Returns a future containing @YES if a user exists with the given email, or @NO otherwise.
 @param email the email to test
 */
+ (FNFuture *)emailPresence:(NSString *)email;

/*!
 Set a new user's email. Set on a new user in order to create with an email address.
 @param email the user's email
 */
- (void)setEmail:(NSString *)email;

/*!
 Set a new user's password. Set on a new user in order to create with a password.
 @param password the user's password
 */
- (void)setPassword:(NSString *)password;

/*!
 Retrieve the user's configuration.
 */
- (FNFuture *)config;

@end
