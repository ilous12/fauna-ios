//
// FNContextConfig.h
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
#import "FNClient.h"

@interface FNContextConfig : NSObject

@property (nonatomic, readonly) NSTimeInterval maxWifiAge;
@property (nonatomic, readonly) NSTimeInterval maxWWANAge;
@property (nonatomic, readonly) NSTimeInterval requestTimeout;
@property (nonatomic, readonly) BOOL fallbackOnError;

- (id)initWithMaxWifiAge:(NSTimeInterval)wifiAge maxWWANAge:(NSTimeInterval)wwanAge timeout:(NSTimeInterval)timeout fallbackOnError:(BOOL)fallback;

+ (instancetype)configWithMaxWifiAge:(NSTimeInterval)wifiAge maxWWANAge:(NSTimeInterval)wwanAge timeout:(NSTimeInterval)timeout fallbackOnError:(BOOL)fallback;

- (instancetype)withMaxAge:(NSTimeInterval)age;

- (instancetype)withMaxWifiAge:(NSTimeInterval)wifiAge;

- (instancetype)withMaxWWANAge:(NSTimeInterval)wwanAge;

- (instancetype)withTimeout:(NSTimeInterval)timeout;

- (instancetype)withFallbackOnError:(BOOL)fallback;

- (NSTimeInterval)maxAgeForReachabilityStatus:(FNReachabilityStatus)status;

@end
