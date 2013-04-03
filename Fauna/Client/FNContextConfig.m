//
//  FNContextConfig.m
//  Fauna
//
//  Created by Matt Freels on 3/28/13.
//  Copyright (c) 2013 Fauna. All rights reserved.
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
