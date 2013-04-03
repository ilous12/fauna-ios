//
// FNTimestamp.h
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
