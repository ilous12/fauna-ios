//
// FNResource.h
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
#import "FNTimestamp.h"

@class FNFuture;

@interface FNResource : NSObject

/*!
 Resolves a FNResource subclass for the given Fauna class string.
 @param className the name of the class
 */
+ (Class)classForFaunaClass:(NSString *)className;

/*!
 Registers a subclass of FNResource to handle resources for the given Fauna class.
 @param class the subclass of FNResource. Must have a defined +faunaClass
 */
+ (void)registerClass:(Class)class;

/*!
 Resets the clobal class registry to the default state and then registers the given classes.
 @param array of classes to register. Must conform to the requirements of +registerClass, above.
 */
+ (void)registerClasses:(NSArray *)classes;

/*!
 Resets the global class registry to the default state.
 */
+ (void)resetDefaultClasses;

# pragma mark lifecycle

/*!
 Initializes a newly allocated resource with the given Fauna class.
 */
- (id)initWithClass:(NSString *)faunaClass;

/*!
 Initializes a newly allocatd resource with the given JSON dictionary.
 @param dictionary Dictionary representation of the JSON for the Resource
 */
- (id)initWithDictionary:(NSDictionary *)dictionary;

- (id)initWithMutableDictionary:(NSDictionary *)dictionary;

- (instancetype)deepCopy;

#pragma mark Class methods

/*!
 Returns the Fauna class name for this type of resource.
 */
+ (NSString *)faunaClass;

/*!
 Retrieves a Resource for the given ref.
 @param ref Resource ref.
 */
+ (FNFuture *)get:(NSString *)ref;

/*!
 Returns a deserialized resource for the given JSON dictionary.
 @param dictionary Dictionary representation of the JSON structure for the Resoure
 */
+ (FNResource *)resourceWithDictionary:(NSDictionary *)dictionary;

#pragma mark Persistence

/*!
 Save the resource, creating it if necessary. This does *not* update the existing resource.
 Returns a FNFuture of the saved resource.
 */
- (FNFuture *)save;

#pragma mark Fields

/*!
 (ref) Ref string for the resource.
 */
@property (nonatomic, readonly) NSString *ref;

/*!
 (faunaClass) Fauna class name for the resource
 */
@property (nonatomic, readonly) NSString *faunaClass;

/*!
 (timestamp) FNTimestamp of the last time the resource was updated.
 */
@property (nonatomic) FNTimestamp timestamp;

/*!
 (uniqueID) The resource's unique id if present, or nil.
 */
//@property (nonatomic) NSString *uniqueID;

/*!
 (data) The custom data dictionary for the resource.
 */
//@property (nonatomic) NSMutableDictionary *data;

/*!
 (references) The custom references dictionary for the resource.
 */
//@property (nonatomic) NSMutableDictionary *references;

/*!
 (isDeleted) A BOOL indicating whether the resource is deleted or not.
 */
@property (nonatomic, readonly) BOOL isDeleted;

/*!
 Returns the internal JSON dictionary for the Resource
 */
@property (nonatomic, readonly) NSMutableDictionary *dictionary;

@end
