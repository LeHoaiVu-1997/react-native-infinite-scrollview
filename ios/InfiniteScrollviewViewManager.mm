#import <React/RCTViewManager.h>
#import <React/RCTUIManager.h>
#import "RCTBridge.h"
#import "InfiniteScrollviewView.h"

@interface InfiniteScrollviewViewManager : RCTViewManager
@end

@implementation InfiniteScrollviewViewManager

RCT_EXPORT_MODULE(InfiniteScrollviewView)

- (UIView *)view
{
  return [[InfiniteScrollviewView alloc] init];
}

#if !RCT_NEW_ARCH_ENABLED

RCT_EXPORT_VIEW_PROPERTY(lockDirection, NSString)
RCT_EXPORT_VIEW_PROPERTY(disableTouch, BOOL)
RCT_EXPORT_VIEW_PROPERTY(spacingHorizontal, NSNumber)
RCT_EXPORT_VIEW_PROPERTY(spacingVertical, NSNumber)
RCT_EXPORT_VIEW_PROPERTY(backgroundColor, UIColor)

RCT_EXPORT_METHOD(reset:(nonnull NSNumber *)reactTag) {
  RCTUIManager *uiManager = [self.bridge moduleForClass:[RCTUIManager class]];
  [uiManager addUIBlock:^(RCTUIManager *uiManager, NSDictionary<NSNumber *, UIView *> *viewRegistry) {
    InfiniteScrollviewView *view = (InfiniteScrollviewView *)viewRegistry[reactTag];
    if (view) {
      [view reset];
    } else {
      NSLog(@"View not found for reactTag: %@", reactTag);
    }
  }];
}

RCT_EXPORT_METHOD(stopScrolling:(nonnull NSNumber *)reactTag reset:(BOOL)reset) {
  RCTUIManager *uiManager = [self.bridge moduleForClass:[RCTUIManager class]];
  [uiManager addUIBlock:^(RCTUIManager *uiManager, NSDictionary<NSNumber *, UIView *> *viewRegistry) {
    InfiniteScrollviewView *view = (InfiniteScrollviewView *)viewRegistry[reactTag];
    if (view) {
      [view stopScrolling:reset];
    } else {
      NSLog(@"View not found for reactTag: %@", reactTag);
    }
  }];
}

RCT_EXPORT_METHOD(scrollContinuously:(nonnull NSNumber *)reactTag
                  distanceX:(nonnull NSNumber *)distanceX
                  distanceY:(nonnull NSNumber *)distanceY) {
  RCTUIManager *uiManager = [self.bridge moduleForClass:[RCTUIManager class]];
  [uiManager addUIBlock:^(RCTUIManager *uiManager, NSDictionary<NSNumber *, UIView *> *viewRegistry) {
    InfiniteScrollviewView *view = (InfiniteScrollviewView *)viewRegistry[reactTag];
    if (view) {
      [view scrollContinuously:[distanceX floatValue] distanceY:[distanceY floatValue]];
    } else {
      NSLog(@"View not found for reactTag: %@", reactTag);
    }
  }];
}

RCT_EXPORT_METHOD(scrollDistances:(nonnull NSNumber *)reactTag
                  distanceX:(nonnull NSNumber *)distanceX
                  distanceY:(nonnull NSNumber *)distanceY
                  durationMs:(nonnull NSNumber *)durationMs) {
  RCTUIManager *uiManager = [self.bridge moduleForClass:[RCTUIManager class]];
  [uiManager addUIBlock:^(RCTUIManager *uiManager, NSDictionary<NSNumber *, UIView *> *viewRegistry) {
    InfiniteScrollviewView *view = (InfiniteScrollviewView *)viewRegistry[reactTag];
    if (view) {
      [view scrollDistances:[distanceX floatValue] distanceY:[distanceY floatValue] durationMs:[durationMs intValue]];
    } else {
      NSLog(@"View not found for reactTag: %@", reactTag);
    }
  }];
}

#endif

@end
