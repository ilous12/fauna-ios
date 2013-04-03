//
// FNContextTest.m
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

@interface FNContextTest : GHAsyncTestCase { }
@end

@interface FNContext ()

+ (FNContext *)currentOrRaise;

@end

@implementation FNContextTest

- (void)testUsesDefaultContext {
  [self prepare];

  FNContext.defaultContext = TestPublisherContext();

  [[FNContext get:@"users" parameters:@{}] onSuccess:^(id value) {
    [self notify:kGHUnitWaitStatusSuccess forSelector:@selector(testUsesDefaultContext)];
  }];

  [self waitForStatus:kGHUnitWaitStatusSuccess timeout:2.0];

  FNContext.defaultContext = nil;
}

- (void)testUsesScopedContext {
  [self prepare];

  [TestPublisherContext() performInContext:^{
    [[FNContext get:@"users" parameters:@{}] onSuccess:^(id value) {
      [self notify:kGHUnitWaitStatusSuccess forSelector:@selector(testUsesScopedContext)];
    }];
  }];

  [self waitForStatus:kGHUnitWaitStatusSuccess timeout:2.0];
}

- (void)testStacksScopedContexts {
  [self prepare];

  FNContext *clientCtx = TestClientContext();
  FNContext *publisherCtx = TestPublisherContext();
  FNContext *pwContext = TestPublisherPasswordContext();

  FNContext.defaultContext = clientCtx;

  FNFuture *result = [[FNContext get:@"users" parameters:@{}] rescue:^(NSError *error) {
    return [publisherCtx inContext:^{
      FNFuture *res1 = [FNContext get:@"users/sets" parameters:@{}];

      FNFuture *resFail = [FNContext get:@"keys/publisher" parameters:@{}];
      [resFail onSuccess:^(id value) {
        [self notify:kGHUnitWaitStatusFailure forSelector:@selector(testStacksScopedContexts)];
      }];

      FNFuture *res2 = [resFail rescue:^(NSError *error) {
        return [pwContext inContext:^{
          return [FNContext get:@"keys/publisher" parameters:@{}];
        }];
      }];

      if (![FNContext.currentContext isEqual:publisherCtx]) {
        [self notify:kGHUnitWaitStatusFailure forSelector:@selector(testStacksScopedContexts)];
      }

      FNFuture *res3 = [FNContext get:@"classes" parameters:@{}];

      return [res1 flatMap:^(id sets) {
        return [res2 flatMap:^(id keys) {
          return [res3 map:^(id classes) {
            return @"yay!";
          }];
        }];
      }];
    }];
  }];

  [result onSuccess:^(id value) {
    if ([value isEqual:@"yay!"]) {
      [self notify:kGHUnitWaitStatusSuccess forSelector:@selector(testStacksScopedContexts)];
    }
  }];

  [self waitForStatus:kGHUnitWaitStatusSuccess timeout:3.0];

  FNContext.defaultContext = nil;
}

- (void)testRaisesOnNoContext {
  [self prepare];

  FNContext.defaultContext = nil;

  @try {
    [FNContext get:@"users" parameters:@{}];
    GHFail(@"Did not throw any exception");
  } @catch (NSException *e) {
    GHAssertEqualStrings(e.name, FNContextNotDefined().name, @"Did not throw FNContextNotDefined");
  }
}

@end
