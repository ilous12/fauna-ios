//
// FNMutableFuture.h
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
#import "FNFuture.h"

@interface FNMutableFuture : FNFuture

/*!
 Complete the future with a successful result.
 */
- (void)update:(id)value;

/*!
 Complete the future with a failure result.
 */
- (BOOL)updateIfEmpty:(id)value;

/*!
 Complete the future with a successful result if it has not been completed already.
 */
- (void)updateError:(NSError *)error;

/*!
 Complete the future with a failure result if it has not been completed already.
 */
- (BOOL)updateErrorIfEmpty:(NSError *)error;

@end
