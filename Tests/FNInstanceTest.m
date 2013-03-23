//
// FNInstanceTest.m
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

#import "FNMessage.h"

@interface FNInstanceTest : GHAsyncTestCase { }
@end

@implementation FNInstanceTest

- (void)testCreate {
  [self prepare];

  [FNResource registerClass:[FNMessage class]];

  FNInstance *inst = [FNMessage new];

  [TestPublisherContext() performInContext:^{
    [[inst save] onSuccess:^(FNInstance *value) {
      if ([value isKindOfClass:[FNMessage class]] &&
          value.ref &&
          [value.faunaClass isEqual:@"classes/messages"]) {
        [self notify:kGHUnitWaitStatusSuccess forSelector:@selector(testCreate)];
      }
    }];
  }];

  [self waitForStatus:kGHUnitWaitStatusSuccess timeout:2.0];
}

@end