//
// FNSQLiteCache.h
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

#import <sqlite3.h>
#import "FNError.h"
#import "FNFuture.h"
#import "FNSQLiteConnection.h"
#import "NSThread+FNFutureOperations.h"
#import "FNSQLiteConnectionThread.h"

@interface FNSQLiteConnectionThread ()

@property (nonatomic, readonly) FNSQLiteConnection *connection;
@property (nonatomic, readonly) NSThread *thread;

@end

@implementation FNSQLiteConnectionThread

#pragma mark lifecycle

- (id)initWithSQLitePath:(NSString *)path {
  if(self = [super init]) {
    _connection = [[FNSQLiteConnection alloc] initWithSQLitePath:path];
    _thread = [[NSThread alloc] initWithTarget:self selector:@selector(threadLoop) object:nil];
    [_thread start];
  }

  return self;
}

#pragma mark Public methods

- (void)close {
  [self.thread performBlock:^id{
    [self.connection close];
    return nil;
  }];
}

#pragma mark Private methods


- (void)threadLoop {
  while (!self.connection.isClosed) {
    @autoreleasepool {
      [[NSRunLoop currentRunLoop] run];
    }
  }
}

- (FNFuture *)withConnection:(id(^)(FNSQLiteConnection *db))block {
  if (!self.connection.isClosed) {
    return [self.thread performBlock:^{
      if (!self.connection.isClosed) {
        return block(self.connection);
      } else {
        return [NSError errorWithDomain:@"blah" code:42 userInfo:@{@"msg": @"thread has been cancelled"}];
      }
    }];
  } else {
    return [FNFuture error:[NSError errorWithDomain:@"blah" code:42 userInfo:@{@"msg": @"thread has been cancelled"}]];
  }
}

@end