//
//  FNTimestamp.m
//  Fauna
//
//  Created by Matt Freels on 3/28/13.
//  Copyright (c) 2013 Fauna. All rights reserved.
//

#import "FNTimestamp.h"

#define MICROS 1000000.0

FNTimestamp const FNTimestampMax = INT64_MAX;
FNTimestamp const FNTimestampMin = 0;
FNTimestamp const FNFirst = FNTimestampMin;
FNTimestamp const FNLast = FNTimestampMax;

FNTimestamp FNNow() {
  return FNTimestampFromNSDate([NSDate date]);
}

NSDate * FNTimestampToNSDate(FNTimestamp ts) {
  return [NSDate dateWithTimeIntervalSince1970:ts / MICROS];
}

FNTimestamp FNTimestampFromNSDate(NSDate *date) {
  return date.timeIntervalSince1970 * MICROS;
}

NSNumber * FNTimestampToNSNumber(FNTimestamp ts) {
  return @(ts);
}

FNTimestamp FNTimestampFromNSNumber(NSNumber *number) {
  return number.longLongValue;
}

FNTimestamp FNTimestampAddInterval(FNTimestamp ts, NSTimeInterval interval) {
  return ts + (interval * MICROS);
}

FNTimestamp FNTimestampSubtractInterval(FNTimestamp ts, NSTimeInterval interval) {
  return ts - (interval * MICROS);
}
