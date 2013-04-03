//
//  FNContextConfig.h
//  Fauna
//
//  Created by Matt Freels on 3/28/13.
//  Copyright (c) 2013 Fauna. All rights reserved.
//

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
