//
//  FNTimestamp.h
//  Fauna
//
//  Created by Matt Freels on 3/28/13.
//  Copyright (c) 2013 Fauna. All rights reserved.
//

typedef int64_t FNTimestamp;
FOUNDATION_EXPORT FNTimestamp const FNTimestampMax;
FOUNDATION_EXPORT FNTimestamp const FNTimestampMin;
FOUNDATION_EXPORT FNTimestamp const FNFirst;
FOUNDATION_EXPORT FNTimestamp const FNLast;

FNTimestamp FNNow();

NSDate * FNTimestampToNSDate(FNTimestamp ts);
FNTimestamp FNTimestampFromNSDate(NSDate *date);
NSNumber * FNTimestampToNSNumber(FNTimestamp ts);
FNTimestamp FNTimestampFromNSNumber(NSNumber *number);
FNTimestamp FNTimestampAddInterval(FNTimestamp ts, NSTimeInterval);
FNTimestamp FNTimestampSubtractInterval(FNTimestamp ts, NSTimeInterval);
