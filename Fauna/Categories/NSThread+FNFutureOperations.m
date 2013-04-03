//
//  NSThread+FNFutureOperations.m
//  Fauna
//
//  Created by Matt Freels on 3/28/13.
//  Copyright (c) 2013 Fauna. All rights reserved.
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
