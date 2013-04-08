//
// FNUser.m
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
#import "FNError.h"
#import "NSString+FNStringExtensions.h"
#import "FNClient.h"
#import "FNUser.h"

@interface FNContext ()

+ (FNContext *)signedInUserContext;

+ (void)setSignedInUserToken:(NSString *)token;

@end

@implementation FNUser

+ (NSString *)faunaClass {
  return @"users";
}

+ (FNFuture *)changeSelfPassword:(NSString *)password newPassword:(NSString *)newPassword confirmation:(NSString *)confirmation {
  NSDictionary *params = @{
    @"password": password,
    @"new_password": newPassword,
    @"new_password_confirmation": confirmation
  };

  return [FNContext put:@"users/self/config/password" parameters:params].done;
}

+ (FNFuture *)isEmailPresent:(NSString *)email {
  NSString *path = [NSString stringWithFormat:@"users/email/%@/presence", [email urlEscapedWithEncoding:NSUTF8StringEncoding]];
  return [[FNContext get:path parameters:@{}] transform:^(FNFuture *result) {
    if (!result.isError) {
      return [FNFuture value:@YES];
    } else if (result.isError && result.error.isFNNotFound) {
      return [FNFuture value:@NO];
    } else {
      return result;
    }
  }];
}

+ (FNFuture *)tokenForEmail:(NSString *)email password:(NSString *)password {
  return [[FNContext post:@"tokens" parameters:@{@"email": email, @"password": password}] map:^(FNResponse *res){
    return res.resource[@"token"];
  }];
}

+ (FNFuture *)tokenForUniqueID:(NSString *)uniqueID password:(NSString *)password {
  return [[FNContext post:@"tokens" parameters:@{@"unique_id": uniqueID, @"password": password}] map:^(FNResponse *res){
    return res.resource[@"token"];
  }];
}

+ (FNFuture *)tokenForRef:(NSString *)ref password:(NSString *)password {
  return [[FNContext post:@"tokens" parameters:@{@"ref": ref, @"password": password}] map:^(FNResponse *res){
    return res.resource[@"token"];
  }];
}

+ (FNFuture *)contextForEmail:(NSString *)email password:(NSString *)password {
  return [[self tokenForEmail:email password:password] map:^(NSString *token) {
            return [FNContext contextWithKey:token];
          }];
}

+ (FNFuture *)contextForUniqueID:(NSString *)uniqueID password:(NSString *)password {
  return [[self tokenForUniqueID:uniqueID password:password] map:^(NSString *token) {
            return [FNContext contextWithKey:token];
          }];
}

+ (FNFuture *)contextForRef:(NSString *)ref password:(NSString *)password {
  return [[self tokenForRef:ref password:password] map:^(NSString *token) {
    return [FNContext contextWithKey:token];
  }];
}

+ (FNContext *)signedInContext {
  return FNContext.signedInUserContext;
}

+ (BOOL)isSignedIn {
  return self.signedInContext != nil;
}

+ (FNFuture *)signInWithEmail:(NSString *)email password:(NSString *)password {
  return [[self tokenForEmail:email password:password] map:^id(NSString *token) {
    FNContext.signedInUserToken = token;
    return nil;
  }];
}

+ (FNFuture *)signInWithUniqueID:(NSString *)uniqueID password:(NSString *)password {
  return [[self tokenForUniqueID:uniqueID password:password] map:^id(NSString *token) {
    FNContext.signedInUserToken = token;
    return nil;
  }];
}

+ (FNFuture *)signInWithRef:(NSString *)ref password:(NSString *)password {
  return [[self tokenForRef:ref password:password] map:^id(NSString *token) {
    FNContext.signedInUserToken = token;
    return nil;
  }];
}

+ (void)signOut {
FNContext.signedInUserToken = nil;
}

- (void)setEmail:(NSString *)email {
  self.dictionary[@"email"] = email;
}

- (void)setPassword:(NSString *)password {
  self.dictionary[@"password"] = password;
}

- (FNFuture *)config {
  return [FNResource get:[self.ref stringByAppendingString:@"/config"]];
}

@end
