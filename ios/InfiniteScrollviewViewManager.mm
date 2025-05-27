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

RCT_EXPORT_VIEW_PROPERTY(color, NSString)
RCT_EXPORT_VIEW_PROPERTY(test, BOOL)

RCT_EXPORT_METHOD(doSomething:(nonnull NSNumber *)reactTag) {
  RCTUIManager *uiManager = [self.bridge moduleForClass:[RCTUIManager class]];
  [uiManager addUIBlock:^(RCTUIManager *uiManager, NSDictionary<NSNumber *, UIView *> *viewRegistry) {
    InfiniteScrollviewView *view = (InfiniteScrollviewView *)viewRegistry[reactTag];
    if (view) {
      [view doSomething];
    } else {
      NSLog(@"View not found for reactTag: %@", reactTag);
    }
  }];
}

RCT_EXPORT_METHOD(setValue:(nonnull NSNumber *)reactTag value:(NSString*)value) {
  RCTUIManager *uiManager = [self.bridge moduleForClass:[RCTUIManager class]];
  [uiManager addUIBlock:^(RCTUIManager *uiManager, NSDictionary<NSNumber *, UIView *> *viewRegistry) {
    InfiniteScrollviewView *view = (InfiniteScrollviewView *)viewRegistry[reactTag];
    if (view) {
      [view setValue:value];
    } else {
      NSLog(@"View not found for reactTag: %@", reactTag);
    }
  }];
}


@end
