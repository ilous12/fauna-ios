//
// FNInstance.h
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

#import <Foundation/Foundation.h>
#import "FNResource.h"

@class FNEventSet;
@class FNCustomEventSet;

@interface FNInstance : FNResource

- (FNFuture *)destroy;

@end

@interface FNInstance (StandardFields)

/*!
 (uniqueID) The resource's unique id if present, or nil.
 */
@property (nonatomic) NSString *uniqueID;

/*!
 (data) The custom data dictionary for the resource.
 */
@property (nonatomic) NSMutableDictionary *data;

/*!
 (references) The custom references dictionary for the resource.
 */
@property (nonatomic) NSMutableDictionary *references;

/*!
 Returns a custom event set for the resource
 */
- (FNCustomEventSet *)eventSet:(NSString *)name;

/*
 Returns the set of all resources for this class;
 */
+ (FNEventSet *)all;

/*!
 Returns a future containing @YES if an instance exists with the given unique ID, or @NO otherwise.
 @param uniqueID the unique ID to test
 */
+ (FNFuture *)isUniqueIDPresent:(NSString *)uniqueID;

@end
