//
// FNTimestamp.m
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
