#import <React/RCTViewManager.h>
#import <React/RCTUIManager.h>
#import "RCTBridge.h"

@interface InfiniteScrollviewViewManager : RCTViewManager
@end

@implementation InfiniteScrollviewViewManager

RCT_EXPORT_MODULE(InfiniteScrollviewView)

- (UIView *)view
{
  return [[UIView alloc] init];
}

RCT_EXPORT_VIEW_PROPERTY(color, NSString)

@end
