//
//  NSObject+BlockObservation.h
//  Version 1.0
//
//  Andy Matuschak
//  andy@andymatuschak.org
//  Public domain because I love you. Let me know how you use it.
//

#import <Foundation/Foundation.h>

typedef NSString FNBlockToken;
typedef void (^FNBlockTask)(id obj, NSDictionary *change);

@interface NSObject (FNBlockObservation)
- (FNBlockToken *)addObserverForKeyPath:(NSString *)keyPath task:(FNBlockTask)task;
- (FNBlockToken *)addObserverForKeyPath:(NSString *)keyPath onQueue:(NSOperationQueue *)queue task:(FNBlockTask)task;
- (void)removeObserverWithBlockToken:(FNBlockToken *)token;
@end
