//
// FNError.h
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

FOUNDATION_EXPORT NSString * const FNErrorDomain;

FOUNDATION_EXPORT NSInteger const FNErrorOperationCancelledCode;
FOUNDATION_EXPORT NSInteger const FNErrorRequestTimeoutCode;
FOUNDATION_EXPORT NSInteger const FNErrorBadRequestCode;
FOUNDATION_EXPORT NSInteger const FNErrorUnauthorizedCode;
FOUNDATION_EXPORT NSInteger const FNErrorNotFoundCode;
FOUNDATION_EXPORT NSInteger const FNErrorInternalServerErrorCode;

NSError * FNOperationCancelled();

NSError * FNRequestTimeout();

NSError * FNBadRequest(NSString *error, NSDictionary *paramErrors);

NSError * FNUnauthorized();

NSError * FNNotFound();

NSError * FNInternalServerError();

NSException * FNContextNotDefined();

NSException * FNInvalidResource(NSString *format, ...);

NSException * FNInvalidResourceClass(NSString *format, ...);

@interface NSError (FNError)

- (BOOL)isFNError;

- (BOOL)isFNOperationCancelled;

- (BOOL)isFNRequestTimeout;

- (BOOL)isFNBadRequest;

- (BOOL)isFNUnauthorized;

- (BOOL)isFNNotFound;

- (BOOL)isFNInternalServerError;

@end
