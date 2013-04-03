//
// FNClientTest.m
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

#import <Fauna/FNClient.h>

@interface FNClientTest : GHAsyncTestCase { }
@end

@implementation FNClientTest

- (void)testGet {
  [self prepare];

  FNClient *client = [[FNClient alloc] initWithKey:FAUNA_TEST_PUBLISHER_KEY];
  //client.logHTTPTraffic = YES;

  [[client get:@"users" parameters:@{} timeout:60] onSuccess:^(id value) {
    if ([value isKindOfClass:[FNResponse class]]) {
      [self notify:kGHUnitWaitStatusSuccess forSelector:@selector(testGet)];
    }
  }];

  [self waitForStatus:kGHUnitWaitStatusSuccess timeout:2.0];
}

@end
