//
//  FNSQLiteConnection.h
//  Fauna
//
//  Created by Matt Freels on 3/28/13.
//  Copyright (c) 2013 Fauna. All rights reserved.
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
