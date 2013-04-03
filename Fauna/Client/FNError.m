//
// FNError.m
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

#import "FNError.h"

NSString * const FNErrorDomain = @"org.fauna";

NSInteger const FNErrorOperationCancelledCode = 0;
NSInteger const FNErrorRequestTimeoutCode = 1;
NSInteger const FNErrorBadRequestCode = 400;
NSInteger const FNErrorUnauthorizedCode = 401;
NSInteger const FNErrorNotFoundCode = 404;
NSInteger const FNErrorInternalServerErrorCode = 500;

NSError * FNOperationCancelled() {
  return [NSError errorWithDomain:FNErrorDomain
                             code:FNErrorOperationCancelledCode
                         userInfo:@{}];
}

NSError * FNRequestTimeout() {
  return [NSError errorWithDomain:FNErrorDomain
                             code:FNErrorRequestTimeoutCode
                         userInfo:@{}];
}

NSError * FNBadRequest(NSString *error, NSDictionary *paramErrors) {
  return [NSError errorWithDomain:FNErrorDomain
                             code:FNErrorBadRequestCode
                         userInfo:@{ @"description": error, @"parameter_errors": (paramErrors ? paramErrors : @{}) }];
}

NSError * FNUnauthorized() {
  return [NSError errorWithDomain:FNErrorDomain
                             code:FNErrorUnauthorizedCode
                         userInfo:@{}];
}

NSError * FNNotFound() {
  return [NSError errorWithDomain:FNErrorDomain
                             code:FNErrorNotFoundCode
                         userInfo:@{}];
}

NSError * FNInternalServerError() {
  return [NSError errorWithDomain:FNErrorDomain
                             code:FNErrorInternalServerErrorCode
                         userInfo:@{}];
}

NSException * FNContextNotDefined() {
  return [NSException exceptionWithName:@"FNContextNotDefined" reason:@"No default or scoped context defined." userInfo:@{}];
}

NSException * FNInvalidResource(NSString *format, ...) {
  va_list args;
  va_start(args, format);
  NSString *reason = [NSString stringWithFormat:format, args];
  va_end(args);
  return [NSException exceptionWithName:@"FNInvalidResource" reason:reason userInfo:@{}];
}

NSException * FNInvalidResourceClass(NSString *format, ...) {
  va_list args;
  va_start(args, format);
  NSString *reason = [NSString stringWithFormat:format, args];
  va_end(args);
  return [NSException exceptionWithName:@"FNInvalidResourceClass" reason:reason userInfo:@{}];
}

@implementation NSError (FNError)

- (BOOL)isFNError {
  return self.domain == FNErrorDomain;
}

- (BOOL)isFNOperationCancelled {
  return self.isFNError && self.code == FNErrorOperationCancelledCode;
}

- (BOOL)isFNRequestTimeout {
  return self.isFNError && self.code == FNErrorRequestTimeoutCode;
}

- (BOOL)isFNBadRequest {
  return self.isFNError && self.code == FNErrorBadRequestCode;
}

- (BOOL)isFNUnauthorized {
  return self.isFNError && self.code == FNErrorUnauthorizedCode;
}

- (BOOL)isFNNotFound {
  return self.isFNError && self.code == FNErrorNotFoundCode;
}

- (BOOL)isFNInternalServerError {
  return self.isFNError && self.code == FNErrorInternalServerErrorCode;
}

@end