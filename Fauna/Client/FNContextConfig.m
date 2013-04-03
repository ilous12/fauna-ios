//
// FNContextConfig.m
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

#import "FNContextConfig.h"

@implementation FNContextConfig

- (id)initWithMaxWifiAge:(NSTimeInterval)wifiAge maxWWANAge:(NSTimeInterval)wwanAge timeout:(NSTimeInterval)timeout fallbackOnError:(BOOL)fallback {
  self = [super init];
  if (self) {
    _maxWifiAge = wifiAge;
    _maxWWANAge = wwanAge;
    _requestTimeout = timeout;
    _fallbackOnError = fallback;
  }

  return self;
}

+ (instancetype)configWithMaxWifiAge:(NSTimeInterval)wifiAge maxWWANAge:(NSTimeInterval)wwanAge timeout:(NSTimeInterval)timeout fallbackOnError:(BOOL)fallback {
  return [[self alloc] initWithMaxWifiAge:wifiAge maxWWANAge:wwanAge timeout:timeout fallbackOnError:fallback];
}

- (instancetype)withMaxAge:(NSTimeInterval)age {
  return [FNContextConfig configWithMaxWifiAge:age
                                    maxWWANAge:age
                                       timeout:self.requestTimeout
                               fallbackOnError:self.fallbackOnError];
}

- (instancetype)withMaxWifiAge:(NSTimeInterval)wifiAge {
  return [FNContextConfig configWithMaxWifiAge:wifiAge
                                    maxWWANAge:self.maxWWANAge
                                       timeout:self.requestTimeout
                               fallbackOnError:self.fallbackOnError];
}

- (instancetype)withMaxWWANAge:(NSTimeInterval)wwanAge {
  return [FNContextConfig configWithMaxWifiAge:self.maxWifiAge
                                    maxWWANAge:wwanAge
                                       timeout:self.requestTimeout
                               fallbackOnError:self.fallbackOnError];
}

- (instancetype)withTimeout:(NSTimeInterval)timeout {
  return [FNContextConfig configWithMaxWifiAge:self.maxWifiAge
                                    maxWWANAge:self.maxWWANAge
                                       timeout:timeout
                               fallbackOnError:self.fallbackOnError];
}

- (instancetype)withFallbackOnError:(BOOL)fallback {
  return [FNContextConfig configWithMaxWifiAge:self.maxWifiAge
                                    maxWWANAge:self.maxWWANAge
                                       timeout:self.requestTimeout
                               fallbackOnError:fallback];
}

- (NSTimeInterval)maxAgeForReachabilityStatus:(FNReachabilityStatus)status {
  return status == FNReachabilityWWAN ? self.maxWWANAge : self.maxWifiAge;
}

@end
