//
//  NSObject+BlockObservation.m
//  Version 1.0
//
//  Andy Matuschak
//  andy@andymatuschak.org
//  Public domain because I love you. Let me know how you use it.
//

#import "NSObject+FNBlockObservation.h"
#import <dispatch/dispatch.h>
#import <objc/runtime.h>

static NSInteger FNObserverTrampolineContext = 1;
static NSInteger FNObserverMapKey = 1;
static dispatch_queue_t FNObserverMutationQueue = NULL;

static dispatch_queue_t FNObserverMutationQueueCreatingIfNecessary() {
  static dispatch_once_t queueCreationPredicate = 0;
  dispatch_once(&queueCreationPredicate, ^{
    FNObserverMutationQueue = dispatch_queue_create("org.fauna.observerMutationQueue", 0);
  });
  return FNObserverMutationQueue;
}

@interface FNObserverTrampoline : NSObject {
  __weak id observee;
  NSString *keyPath;
  FNBlockTask task;
  NSOperationQueue *queue;
  dispatch_once_t cancellationPredicate;
}

- (FNObserverTrampoline *)initObservingObject:(id)obj keyPath:(NSString *)keyPath onQueue:(NSOperationQueue *)queue task:(FNBlockTask)task;
- (void)cancelObservation;
@end

@implementation FNObserverTrampoline

- (FNObserverTrampoline *)initObservingObject:(id)obj keyPath:(NSString *)newKeyPath onQueue:(NSOperationQueue *)newQueue task:(FNBlockTask)newTask {
  if (!(self = [super init])) return nil;
  task = [newTask copy];
  keyPath = [newKeyPath copy];
  queue = newQueue;
  observee = obj;
  cancellationPredicate = 0;
  [observee addObserver:self forKeyPath:keyPath options:0 context:&FNObserverTrampolineContext];
  return self;
}

- (void)observeValueForKeyPath:(NSString *)aKeyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
  if (context == &FNObserverTrampolineContext) {
    if (queue)
      [queue addOperationWithBlock:^{ task(object, change); }];
    else
      task(object, change);
  }
}

- (void)cancelObservation {
  dispatch_once(&cancellationPredicate, ^{
    [observee removeObserver:self forKeyPath:keyPath];
    observee = nil;
  });
}

- (void)dealloc {
  [self cancelObservation];
}

@end

@implementation NSObject (FNBlockObservation)

- (FNBlockToken *)addObserverForKeyPath:(NSString *)keyPath task:(FNBlockTask)task {
  return [self addObserverForKeyPath:keyPath onQueue:nil task:task];
}

- (FNBlockToken *)addObserverForKeyPath:(NSString *)keyPath onQueue:(NSOperationQueue *)queue task:(FNBlockTask)task {
  FNBlockToken *token = [[NSProcessInfo processInfo] globallyUniqueString];
  dispatch_sync(FNObserverMutationQueueCreatingIfNecessary(), ^{
    NSMutableDictionary *dict = objc_getAssociatedObject(self, &FNObserverMapKey);
    if (!dict) {
      dict = [NSMutableDictionary new];
      objc_setAssociatedObject(self, &FNObserverMapKey, dict, OBJC_ASSOCIATION_RETAIN);
    }
    FNObserverTrampoline *trampoline = [[FNObserverTrampoline alloc] initObservingObject:self keyPath:keyPath onQueue:queue task:task];
    [dict setObject:trampoline forKey:token];
  });
  return token;
}

- (void)removeObserverWithBlockToken:(FNBlockToken *)token {
  dispatch_sync(FNObserverMutationQueueCreatingIfNecessary(), ^{
    NSMutableDictionary *observationDictionary = objc_getAssociatedObject(self, &FNObserverMapKey);
    FNObserverTrampoline *trampoline = [observationDictionary objectForKey:token];
    if (!trampoline) {
      NSLog(@"[NSObject(FNBlockObservation) removeObserverWithBlockToken]: Ignoring attempt to remove non-existent observer on %@ for token %@.", self, token);
      return;
    }
    [trampoline cancelObservation];
    [observationDictionary removeObjectForKey:token];

    // Due to a bug in the obj-c runtime, this dictionary does not get cleaned up on release when running without GC.
    if ([observationDictionary count] == 0)
      objc_setAssociatedObject(self, &FNObserverMapKey, nil, OBJC_ASSOCIATION_RETAIN);
  });
}

@end
