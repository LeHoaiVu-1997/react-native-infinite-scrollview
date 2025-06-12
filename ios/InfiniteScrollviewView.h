#import <UIKit/UIKit.h>

#ifndef InfiniteScrollviewViewNativeComponent_h
#define InfiniteScrollviewViewNativeComponent_h

#if RCT_NEW_ARCH_ENABLED

#import <React/RCTViewComponentView.h>

@interface InfiniteScrollviewView : RCTViewComponentView

#else

@interface InfiniteScrollviewView : UIView
NS_ASSUME_NONNULL_BEGIN
- (void)reset;
- (void)stopScrolling:(BOOL)reset;
- (void)scrollDistances:(float)distanceX distanceY:(float)distanceY durationMs:(NSInteger)durationMs;
- (void)scrollContinuously:(float)distanceX distanceY:(float)distanceY;
NS_ASSUME_NONNULL_END
#endif

@end

#endif /* InfiniteScrollviewViewNativeComponent_h */
