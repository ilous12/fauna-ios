//
// FNPublisher.h
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

@class FNFuture;
@class FNCustomEventSet;

@interface FNPublisher : FNResource

/*!
 Retrieve the publisher resource.
 */
+ (FNFuture *)get;

/*!
 Retrieve the publisher config.
 */
+ (FNFuture *)getConfig;

@end

@interface FNPublisher (StandardFields)

/*!
 (data) The custom data dictionary for the resource.
 */
@property (nonatomic) NSMutableDictionary *data;

/*!
 Returns a custom event set for the resource
 */
- (FNCustomEventSet *)eventSet:(NSString *)name;

@end
