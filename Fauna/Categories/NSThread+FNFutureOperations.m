//
// NSThread+FNFutureOperations.m
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

#import "FNMutableFuture.h"
#import "NSThread+FNFutureOperations.h"

@interface FNBlockAction : NSObject

@property (nonatomic, strong) id(^block)(void);
@property (nonatomic) FNMutableFuture *future;

- (void)run;

@end

@implementation FNBlockAction

- (void)run {
  id rv = self.block();

  if ([rv isKindOfClass:[NSError class]]) {
    [self.future updateError:rv];
  } else {
    [self.future update:rv];
  }
}

@end

@implementation NSThread (FNFutureOperations)

- (FNFuture *)performBlock:(id (^)(void))block modes:(NSArray *)modes {
  FNBlockAction *action = [FNBlockAction new];
  action.block = block;
  action.future = [FNMutableFuture new];

  [action performSelector:@selector(run) onThread:self withObject:nil waitUntilDone:NO modes:modes];

  return action.future;
}

- (FNFuture *)performBlock:(id (^)(void))block {
  FNBlockAction *action = [FNBlockAction new];
  action.block = block;
  action.future = [FNMutableFuture new];

  [action performSelector:@selector(run) onThread:self withObject:nil waitUntilDone:NO];

  return action.future;
}

@end
