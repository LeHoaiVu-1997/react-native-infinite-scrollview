#import <React/RCTViewComponentView.h>
#import <UIKit/UIKit.h>

#ifndef InfiniteScrollviewViewNativeComponent_h
#define InfiniteScrollviewViewNativeComponent_h

NS_ASSUME_NONNULL_BEGIN

@interface InfiniteScrollviewView : RCTViewComponentView

#if !RCT_NEW_ARCH_ENABLED
- (void)reset;
- (void)stopScrolling:(BOOL)reset;
- (void)scrollDistances:(float)distanceX distanceY:(float)distanceY durationMs:(NSInteger)durationMs;
- (void)scrollContinuously:(float)distanceX distanceY:(float)distanceY;
#endif

@end

NS_ASSUME_NONNULL_END

#endif /* InfiniteScrollviewViewNativeComponent_h */
