//
// FNNetworkStatus.m
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

#import <libkern/OSAtomic.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import "FNNetworkStatus.h"

static FNReachabilityStatus _status = 1;
static SCNetworkReachabilityRef reachabilityRef = NULL;

@interface FNNetworkStatus ()

+ (void)updateReachability:(SCNetworkReachabilityFlags)flags;

@end

static void FNNetworkStatusCallback(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void *info) {
  [FNNetworkStatus updateReachability:flags];
}

@implementation FNNetworkStatus

+ (void)start {
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    LOG(@"FNNetworkStatus started.");

    reachabilityRef = SCNetworkReachabilityCreateWithName(NULL, [FaunaAPIHost UTF8String]);

    SCNetworkReachabilityContext ctx = {0, NULL, NULL, NULL, NULL};
    if (!SCNetworkReachabilitySetCallback(reachabilityRef, FNNetworkStatusCallback, &ctx)) {
      @throw @"Failed to start Network Status listener.";
    }

    if (!SCNetworkReachabilityScheduleWithRunLoop(reachabilityRef, CFRunLoopGetMain(), kCFRunLoopCommonModes)) {
      @throw @"Failed to start Network Status listener.";
    }
  });
}

+ (FNReachabilityStatus)status {
  return _status;
}

+ (BOOL)isOnline {
  return _status != FNReachabilityOffline;
}

+ (BOOL)isWWAN {
  return _status == FNReachabilityWWAN;
}

+ (void)updateReachability:(SCNetworkReachabilityFlags)flags {
  int prev = _status;
  int status = FNReachabilityOffline;

  LOG(@"Network Reachability flags: %c%c %c%c%c%c%c%c%c\n",
      (flags & kSCNetworkReachabilityFlagsIsWWAN)				  ? 'W' : '-',
      (flags & kSCNetworkReachabilityFlagsReachable)            ? 'R' : '-',

      (flags & kSCNetworkReachabilityFlagsTransientConnection)  ? 't' : '-',
      (flags & kSCNetworkReachabilityFlagsConnectionRequired)   ? 'c' : '-',
      (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic)  ? 'C' : '-',
      (flags & kSCNetworkReachabilityFlagsInterventionRequired) ? 'i' : '-',
      (flags & kSCNetworkReachabilityFlagsConnectionOnDemand)   ? 'D' : '-',
      (flags & kSCNetworkReachabilityFlagsIsLocalAddress)       ? 'l' : '-',
      (flags & kSCNetworkReachabilityFlagsIsDirect)             ? 'd' : '-'
      );

  if (flags & kSCNetworkReachabilityFlagsReachable) {
    if (!(flags & kSCNetworkReachabilityFlagsConnectionRequired)) {
      status = FNReachabilityWifi;
    }

    if (flags & (kSCNetworkReachabilityFlagsConnectionOnDemand | kSCNetworkReachabilityFlagsConnectionOnTraffic)) {
      if (!(flags & kSCNetworkReachabilityFlagsInterventionRequired)) {
        status = FNReachabilityWifi;
      }
    }

    if (flags & kSCNetworkReachabilityFlagsIsWWAN) {
      status = FNReachabilityWWAN;
    }
  }

  if (prev != status) {
    [self willChangeValueForKey:@"status"];
    if (prev == FNReachabilityOffline || status == FNReachabilityOffline) [self willChangeValueForKey:@"isOnline"];
    if (prev == FNReachabilityWWAN || status == FNReachabilityWWAN) [self willChangeValueForKey:@"isWWAN"];
    _status = status;
    OSMemoryBarrier();
    [self didChangeValueForKey:@"status"];
    if (prev == FNReachabilityOffline || status == FNReachabilityOffline) [self didChangeValueForKey:@"isOnline"];
    if (prev == FNReachabilityWWAN || status == FNReachabilityWWAN) [self didChangeValueForKey:@"isWWAN"];

    LOG(@"Network Reachability: %@", status == FNReachabilityOffline ? @"Offline" : (status == FNReachabilityWifi ? @"Wifi" : @"WWAN"));
  }
}

@end
