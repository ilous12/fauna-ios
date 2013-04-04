//
// FNUserTest.m
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

@interface FNUserTest : GHAsyncTestCase { }
@end

@implementation FNUserTest

- (void)testCreate {
  [self prepare];

  [TestPublisherContext() performInContext:^{
    FNUser *user = [FNUser new];
    user.uniqueID = TestUniqueID();

    [[user save] onSuccess:^(FNUser *user) {
      if ([user isKindOfClass:[FNUser class]] && user.ref) {
        [self notify:kGHUnitWaitStatusSuccess forSelector:@selector(testCreate)];
      }
    }];
  }];

  [self waitForStatus:kGHUnitWaitStatusSuccess timeout:2.0];
}

- (void)testSignIn {
  [self prepare];

  FNContext.defaultContext = TestClientContext();

  FNUser *user = [FNUser new];
  user.uniqueID = TestUniqueID();
  user.password = @"sekrit";

  [[user save] onSuccess:^(FNUser *user) {
    [[FNUser signInWithUniqueID:user.uniqueID password:@"sekrit"] onSuccess:^(id __unused _) {
      [[FNUser get:@"users/self"] onSuccess:^(FNUser *selfUser) {
        if ([user.ref isEqualToString:selfUser.ref]) {
          [FNUser signOut];
          FNContext.defaultContext = nil;
          [self notify:kGHUnitWaitStatusSuccess forSelector:@selector(testSignIn)];
        }
      }];
    }];
  }];

  [self waitForStatus:kGHUnitWaitStatusSuccess timeout:2.0];
}

// - (void)testSelf {
//   [self prepare];

//   [TestClientContext() performInContext:^{
//     FNUser *user = [FNUser new];
//     user.uniqueID = TestUniqueID();
//     user.password = @"sekrit";

//     [[[[user save] flatMap:^(FNUser *user) {
//       return [FNUser contextForUniqueID:user.uniqueID password:@"sekrit"];
//     }] flatMap:^(FNContext *ctx) {
//       return [ctx inContext:^{
//         return [FNUser getSelf];
//       }];
//     }] onSuccess:^(FNUser *selfUser) {
//       if ([selfUser.uniqueID isEqualToString:user.uniqueID]) {
//         [self notify:kGHUnitWaitStatusSuccess forSelector:@selector(testSelf)];
//       }
//     }];
//   }];

//   [self waitForStatus:kGHUnitWaitStatusSuccess timeout:2.0];
// }

// - (void)testConfig {
//   [self prepare];

//   [TestClientContext() performInContext:^{
//     FNUser *user = [FNUser new];
//     NSString *email = TestUniqueEmail();
//     user.email = email;
//     user.password = @"sekrit";

//     [[[[user save] flatMap:^(FNUser *user) {
//       return [FNUser contextForEmail:email password:@"sekrit"];
//     }] flatMap:^(FNContext *ctx) {
//       return [ctx inContext:^{
//         return [FNUser getSelfConfig];
//       }];
//     }] onSuccess:^(FNResource *config) {
//       if ([config.dictionary[@"email"] isEqualToString:email]) {
//         [self notify:kGHUnitWaitStatusSuccess forSelector:@selector(testConfig)];
//       }
//     }];
//   }];

//   [self waitForStatus:kGHUnitWaitStatusSuccess timeout:2.0];
// }

@end
