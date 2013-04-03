//
// FNSQLiteConnection.h
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

#import <sqlite3.h>

@class FNFuture;

@interface FNSQLiteConnection : NSObject

@property (readonly) BOOL isClosed;

- (id)initWithSQLitePath:(NSString *)path;

- (BOOL)withTransaction:(BOOL(^)(void))block;

- (NSArray *)select:(NSString *)sql parameters:(NSArray *)parameters error:(NSError * __autoreleasing *)error;

- (NSArray *)select:(NSString *)sql error:(NSError * __autoreleasing *)error;

- (BOOL)execute:(NSString *)sql parameters:(NSArray *)parameters error:(NSError * __autoreleasing *)error;

- (BOOL)execute:(NSString *)sql error:(NSError * __autoreleasing *)error;

- (int)rowsChanged;

- (int64_t)lastRowID;

- (NSString *)lastErrorMessage;

- (void)close;

@end
