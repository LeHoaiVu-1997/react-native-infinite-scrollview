#import "InfiniteScrollviewView.h"
#import "UIView+OriginalPosition.h"

#if RCT_NEW_ARCH_ENABLED
#import <react/renderer/components/InfiniteScrollviewViewSpec/ComponentDescriptors.h>
#import <react/renderer/components/InfiniteScrollviewViewSpec/EventEmitters.h>
#import <react/renderer/components/InfiniteScrollviewViewSpec/Props.h>
#import <react/renderer/components/InfiniteScrollviewViewSpec/RCTComponentViewHelpers.h>
#import <react/renderer/graphics/Color.h>
#import "RCTFabricComponentsPlugins.h"

using namespace facebook::react;

@interface InfiniteScrollviewView () <RCTInfiniteScrollviewViewViewProtocol>
#else
@interface InfiniteScrollviewView ()
#endif

// Properties for scroll continuously
@property (nonatomic) BOOL isContinuouslyScroll;
@property (nonatomic) CGFloat distanceIntervalX;
@property (nonatomic) CGFloat distanceIntervalY;
@property (nonatomic) unsigned int durationInterval;
// Properties for touch scrolling
@property (nonatomic) CGPoint lastPoint;
// Properties for method scrolling animation
@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, assign) CGFloat targetDistanceX;
@property (nonatomic, assign) CGFloat targetDistanceY;
@property (nonatomic, assign) CGFloat accumulatedDistanceX;
@property (nonatomic, assign) CGFloat accumulatedDistanceY;
@property (nonatomic, assign) NSTimeInterval duration;
@property (nonatomic, assign) NSTimeInterval elapsedTime;
// React native forwarding properties
@property (nonatomic) BOOL disableTouch;
@property (nonatomic) NSString* lockDirection;
@property (nonatomic, assign) CGFloat spacingVertical;
@property (nonatomic, assign) CGFloat spacingHorizontal;

@end

@implementation InfiniteScrollviewView

#if RCT_NEW_ARCH_ENABLED
+ (ComponentDescriptorProvider)componentDescriptorProvider
{
  return concreteComponentDescriptorProvider<InfiniteScrollviewViewComponentDescriptor>();
}

Class<RCTComponentViewProtocol> InfiniteScrollviewViewCls(void)
{
  return InfiniteScrollviewView.class;
}

CGColorRef CGColorFromSharedColor(SharedColor const &sharedColor) {
  if (!sharedColor) {
    return nil;
  }

  const auto color = *sharedColor;
  CGFloat r = ((color >> 16) & 0xFF) / 255.0;
  CGFloat g = ((color >> 8) & 0xFF) / 255.0;
  CGFloat b = (color & 0xFF) / 255.0;
  CGFloat a = ((color >> 24) & 0xFF) / 255.0;

  return [UIColor colorWithRed:r green:g blue:b alpha:a].CGColor;
}
#endif

- (instancetype)initWithFrame:(CGRect)frame
{
  if (self = [super initWithFrame:frame]) {
    #if RCT_NEW_ARCH_ENABLED
    static const auto defaultProps = std::make_shared<const InfiniteScrollviewViewProps>();
    _props = defaultProps;
    #endif
    self.clipsToBounds = YES;
    _isContinuouslyScroll = NO;
    _distanceIntervalX = 0;
    _distanceIntervalY = 0;
    _durationInterval = 1000;
    _disableTouch = NO;
    _lockDirection = nil;
    _spacingVertical = 0;
    _spacingHorizontal = 0;
  }
  
  return self;
}

- (void)layoutSubviews {
  [super layoutSubviews];
  for (UIView *subview in self.subviews) {
    subview.originalPosition = subview.frame.origin;
  }
}

- (void)resetSubviews {
  for (UIView *subview in self.subviews) {
    subview.frame = CGRectOffset(subview.frame, subview.originalPosition.x - subview.frame.origin.x, subview.originalPosition.y - subview.frame.origin.y);
  }
  [self setNeedsDisplay];
}

#pragma mark - Fabric props update
#if RCT_NEW_ARCH_ENABLED
- (void)updateProps:(Props::Shared const &)props oldProps:(Props::Shared const &)oldProps
{
  const auto &oldViewProps = *std::static_pointer_cast<InfiniteScrollviewViewProps const>(_props);
  const auto &newViewProps = *std::static_pointer_cast<InfiniteScrollviewViewProps const>(props);
  
  if (oldViewProps.lockDirection != newViewProps.lockDirection) {
    self.lockDirection = [[NSString alloc] initWithUTF8String: newViewProps.lockDirection.c_str()];
  }
  
  if (oldViewProps.disableTouch != newViewProps.disableTouch) {
    self.disableTouch = newViewProps.disableTouch;
  }
  
  if (oldViewProps.spacingVertical != newViewProps.spacingVertical) {
    self.spacingVertical = newViewProps.spacingVertical;
    [self setNeedsDisplay];
  }
  
  if (oldViewProps.spacingHorizontal != newViewProps.spacingHorizontal) {
    self.spacingHorizontal = newViewProps.spacingHorizontal;
    [self setNeedsDisplay];
  }
  
  if (oldViewProps.backgroundColor != newViewProps.backgroundColor) {
    self.layer.backgroundColor = CGColorFromSharedColor(newViewProps.backgroundColor);
    [self setNeedsDisplay];
  }
  
  [super updateProps:props oldProps:oldProps];
}
#endif

#pragma mark - Legacy setter
#if !RCT_NEW_ARCH_ENABLED

- (void)setLockDirection:(NSString *)lockDirection {
  _lockDirection = lockDirection;
}

- (void)setDisableTouch:(BOOL)disableTouch{
  _disableTouch = disableTouch;
}

- (void)setSpacingVertical:(id)spacingVertical {
  _spacingVertical = ([spacingVertical isKindOfClass:[NSNumber class]] && [spacingVertical intValue] > 0) ? [spacingVertical intValue] : 0;
  [self setNeedsDisplay];
}

- (void)setSpacingHorizontal:(id)spacingHorizontal {
  _spacingHorizontal = ([spacingHorizontal isKindOfClass:[NSNumber class]] && [spacingHorizontal intValue] > 0) ? [spacingHorizontal intValue] : 0;
  [self setNeedsDisplay];
}

#endif

#pragma mark - Ref methods handling
#if RCT_NEW_ARCH_ENABLED
- (void)handleCommand:(const NSString *)commandName args:(const NSArray *)args {
  if ([commandName isEqualToString:@"reset"]) {
    [self reset];
  } else if ([commandName isEqualToString:@"stopScrolling"]) {
    BOOL reset = [(NSNumber *)args[0] boolValue];
    [self stopScrolling:reset];
  } else if ([commandName isEqualToString:@"scrollContinuously"]) {
    float distanceX = [(NSNumber *)args[0] floatValue];
    float distanceY = [(NSString *)args[1] floatValue];
    [self scrollContinuously:distanceX distanceY:distanceY];
  } else if ([commandName isEqualToString:@"scrollDistances"]) {
    float distanceX = [(NSNumber *)args[0] floatValue];
    float distanceY = [(NSString *)args[1] floatValue];
    NSInteger durationMs = [(NSNumber *)args[2] integerValue];
    [self scrollDistances:distanceX distanceY:distanceY durationMs:durationMs];
  }
}
#endif

- (void)reset {
  [self resetSubviews];
}

- (void)stopScrolling:(BOOL)reset {
  [self cancelTranslation];
  if (reset) {
    [self resetSubviews];
  }
}

- (void)scrollContinuously:(float)distanceX distanceY:(float)distanceY {
  self.isContinuouslyScroll = YES;
  self.distanceIntervalX = distanceX;
  self.distanceIntervalY = distanceY;
  [self handleMethodScrollContinuously];
}

- (void)scrollDistances:(float)distanceX distanceY:(float)distanceY durationMs:(NSInteger)durationMs{
  self.isContinuouslyScroll = NO;
  [self handleMethodScrollDistances:distanceX distanceY:distanceY durationMs:(unsigned int)durationMs];
}

#pragma mark - Method Scroll Handling

- (void)removeAnimation {
  [self.displayLink invalidate];
  self.displayLink = nil;
  self.accumulatedDistanceX = 0;
  self.accumulatedDistanceY = 0;
  self.elapsedTime = 0;
}

- (void)cancelTranslation {
  [self removeAnimation];
  self.isContinuouslyScroll = NO;
  self.distanceIntervalX = 0;
  self.distanceIntervalY = 0;
  self.duration = 0;
}

- (void)handleTranslationCompletion {
  if (self.isContinuouslyScroll == YES) {
    [self handleMethodScrollContinuously];
  }
}

- (void)handleMethodScrollContinuously {
  if (self.distanceIntervalX == 0 && self.distanceIntervalY == 0) {
    [self cancelTranslation];
    return;
  }
  [self removeAnimation];
  [self animatingTranslate:self.distanceIntervalX distanceY:self.distanceIntervalY durationMs:self.durationInterval];
}

- (void)handleMethodScrollDistances:(CGFloat)distanceX distanceY:(CGFloat)distanceY durationMs:(unsigned int)durationMs{
  [self cancelTranslation];
  [self animatingTranslate:distanceX distanceY:distanceY durationMs:durationMs];
}

- (void)animatingTranslate:(CGFloat)distanceX distanceY:(CGFloat)distanceY durationMs:(unsigned int)durationMs {
  self.targetDistanceX = self.bounds.size.width * distanceX;
  self.targetDistanceY = self.bounds.size.height * distanceY;
  self.duration = durationMs/1000.0;
 
  self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateTranslation)];
  [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

// Called each frame
- (void)updateTranslation {
  NSTimeInterval frameDuration = self.displayLink.duration;
  self.elapsedTime += frameDuration;
  
  CGFloat progress = self.elapsedTime / self.duration;
  if (progress >= 1.0) {
      progress = 1.0;
  }
  
  CGFloat incrementalDistanceX = (self.targetDistanceX * progress) - self.accumulatedDistanceX;
  CGFloat incrementalDistanceY = (self.targetDistanceY * progress) - self.accumulatedDistanceY;

  self.accumulatedDistanceX += incrementalDistanceX;
  self.accumulatedDistanceY += incrementalDistanceY;
  
  for (UIView *subview in self.subviews) {
      subview.frame = CGRectOffset(subview.frame, incrementalDistanceX, incrementalDistanceY);
  }
  
  [self setNeedsDisplay];
    
  if (progress >= 1.0) {
    [self.displayLink invalidate];
    self.displayLink = nil;
    [self handleTranslationCompletion];
  }
}

#pragma mark - Touch Handling

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
  if (self.disableTouch == YES) {
    return;
  }
  UITouch *touch = [touches anyObject];
  self.lastPoint = [touch locationInView:self];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
  if (self.disableTouch == YES) {
    return;
  }
  UITouch *touch = [touches anyObject];
  CGPoint currentPoint = [touch locationInView:self];
  CGPoint delta = CGPointMake(currentPoint.x - self.lastPoint.x, currentPoint.y - self.lastPoint.y);
  self.lastPoint = currentPoint;
  
  if (self.lockDirection == nil) {
    [self handleTouchScroll:delta];
  } else {
    if ([self.lockDirection isEqualToString:@"ver"]) {
      [self handleTouchScrollVertically:delta.y];
    } else {
      [self handleTouchScrollHorizontally:delta.x];
    }
  }
}

#pragma mark - Touch Scroll Handling

- (void)handleTouchScrollHorizontally:(CGFloat)deltaX {
  for (UIView *subview in self.subviews) {
      subview.frame = CGRectOffset(subview.frame, deltaX, 0);
  }
  [self setNeedsDisplay];
}

- (void)handleTouchScrollVertically:(CGFloat)deltaY {
  for (UIView *subview in self.subviews) {
      subview.frame = CGRectOffset(subview.frame, 0, deltaY);
  }
  [self setNeedsDisplay];
}

- (void)handleTouchScroll:(CGPoint)delta{
  for (UIView *subview in self.subviews) {
    subview.frame = CGRectOffset(subview.frame, delta.x, delta.y);
  }
  [self setNeedsDisplay];
}

#pragma mark - Draw Handling

- (void)drawRect:(CGRect)rect {
  [super drawRect:rect];
  CGContextRef context = UIGraphicsGetCurrentContext();
  #if RCT_NEW_ARCH_ENABLED
  CGContextClearRect(context, rect);
  if (self.layer.backgroundColor) {
    CGContextSetFillColorWithColor(context, self.layer.backgroundColor);
    CGContextFillRect(context, rect);
  }
  #endif
  [self handleDrawAndClipMirrors:context];
  [self rePositioning];
}

- (void)rePositioning {
  CGFloat parentWidth = self.bounds.size.width;
  CGFloat parentHeight = self.bounds.size.height;
  
  for (UIView *subview in self.subviews) {
    CGFloat subviewLeft = CGRectGetMinX(subview.frame);
    CGFloat subviewTop = CGRectGetMinY(subview.frame);
    CGFloat subviewRight = CGRectGetMaxX(subview.frame);
    CGFloat subviewBottom = CGRectGetMaxY(subview.frame);
    if (subviewLeft < -self.spacingHorizontal && subviewRight < -self.spacingHorizontal) {
      subview.frame = CGRectOffset(subview.frame, self.spacingHorizontal + (parentWidth > subview.frame.size.width ? parentWidth : subview.frame.size.width), 0);
    } else if (subviewRight - self.spacingHorizontal > parentWidth && subviewLeft - self.spacingHorizontal > parentWidth) {
      subview.frame = CGRectOffset(subview.frame, -self.spacingHorizontal + (parentWidth > subview.frame.size.width ? -parentWidth : -subview.frame.size.width), 0);
    }
    
    if (subviewTop < -self.spacingVertical && subviewBottom < -self.spacingVertical) {
      subview.frame = CGRectOffset(subview.frame, 0, self.spacingVertical + (parentHeight > subview.frame.size.height ? parentHeight : subview.frame.size.height));
    } else if (subviewBottom - self.spacingVertical > parentHeight && subviewTop - self.spacingVertical > parentHeight) {
      subview.frame = CGRectOffset(subview.frame, 0, -self.spacingVertical + (parentHeight > subview.frame.size.height ? -parentHeight : -subview.frame.size.height));
    }
  }
}

- (void)handleDrawAndClipMirrors:(CGContextRef)context {
  CGFloat parentWidth = self.bounds.size.width;
  CGFloat parentHeight = self.bounds.size.height;
  for (UIView *subview in self.subviews) {
    CGFloat subviewLeft = CGRectGetMinX(subview.frame);
    CGFloat subviewTop = CGRectGetMinY(subview.frame);
    CGFloat subviewRight = CGRectGetMaxX(subview.frame);
    CGFloat subviewBottom = CGRectGetMaxY(subview.frame);
    
    unsigned int hasMirrorHorizontal = 0;
    unsigned int hasMirrorVertical = 0;
    if (subviewLeft < -self.spacingHorizontal && subviewRight + self.spacingHorizontal < parentWidth) {
      hasMirrorHorizontal = 2;
    } else if (subviewRight - self.spacingHorizontal > parentWidth && subviewLeft > self.spacingHorizontal) {
      hasMirrorHorizontal = 1;
    }
    if (subviewTop < -self.spacingVertical && subviewBottom + self.spacingVertical < parentHeight) {
      hasMirrorVertical = 2;
    } else if (subviewBottom - self.spacingVertical > parentHeight && subviewTop > self.spacingVertical) {
      hasMirrorVertical = 1;
    }
    
    unsigned int subviewOriginCase = hasMirrorHorizontal * 10 + hasMirrorVertical;
    switch (subviewOriginCase) {
      case 1:
        [self drawWhenOriginBottom:context origin:subview
                       parentWidth:parentWidth parentHeight:parentHeight
                       subviewLeft:subviewLeft subviewTop:subviewTop
                      subviewRight:subviewRight subviewBottom:subviewBottom
        ];
        break;
      case 2:
        [self drawWhenOriginTop:context origin:subview
                    parentWidth:parentWidth parentHeight:parentHeight
                    subviewLeft:subviewLeft subviewTop:subviewTop
                   subviewRight:subviewRight subviewBottom:subviewBottom
        ];
        break;
      case 10:
        [self drawWhenOriginRight:context origin:subview
                      parentWidth:parentWidth parentHeight:parentHeight
                      subviewLeft:subviewLeft subviewTop:subviewTop
                     subviewRight:subviewRight subviewBottom:subviewBottom
        ];
        break;
      case 11:
        [self drawWhenOriginRightBottom:context origin:subview
                            parentWidth:parentWidth parentHeight:parentHeight
                            subviewLeft:subviewLeft subviewTop:subviewTop
                           subviewRight:subviewRight subviewBottom:subviewBottom
        ];
        break;
      case 12:
        [self drawWhenOriginRightTop:context origin:subview
                         parentWidth:parentWidth parentHeight:parentHeight
                         subviewLeft:subviewLeft subviewTop:subviewTop
                        subviewRight:subviewRight subviewBottom:subviewBottom
        ];
        break;
      case 20:
        [self drawWhenOriginLeft:context origin:subview
                     parentWidth:parentWidth parentHeight:parentHeight
                     subviewLeft:subviewLeft subviewTop:subviewTop
                    subviewRight:subviewRight subviewBottom:subviewBottom
        ];
        break;
      case 21:
        [self drawWhenOriginLeftBottom:context origin:subview
                           parentWidth:parentWidth parentHeight:parentHeight
                           subviewLeft:subviewLeft subviewTop:subviewTop
                          subviewRight:subviewRight subviewBottom:subviewBottom
        ];
        break;
      case 22:
        [self drawWhenOriginLeftTop:context origin:subview
                        parentWidth:parentWidth parentHeight:parentHeight
                        subviewLeft:subviewLeft subviewTop:subviewTop
                       subviewRight:subviewRight subviewBottom:subviewBottom
        ];
        break;
      case 0:
      default:
        break;
    }
  }
}

- (void)drawMirrorClip:(CGContextRef)context forView:(UIView*)view withRect:(CGRect)rect translateX:(CGFloat)translateX translateY:(CGFloat)translateY {
  CGContextSaveGState(context);
  CGContextTranslateCTM(context, translateX, translateY);
  CGContextClipToRect(context, rect);
  [view.layer renderInContext:context];
  CGContextRestoreGState(context);
}

- (void)drawWhenOriginLeft:(CGContextRef)context origin:(UIView *)subview
               parentWidth:(CGFloat)parentWidth parentHeight:(CGFloat)parentHeight
               subviewLeft:(CGFloat)subviewLeft subviewTop:(CGFloat)subviewTop
              subviewRight:(CGFloat)subviewRight subviewBottom:(CGFloat)subviewBottom {
  
  CGFloat partOutOfBounds = subview.frame.size.width > parentWidth ? parentWidth - subviewRight - self.spacingHorizontal : fabs(subviewLeft + self.spacingHorizontal);
  [self drawMirrorClip:context forView:subview withRect:CGRectMake(0, 0, partOutOfBounds, subview.frame.size.height)
      translateX:parentWidth - partOutOfBounds translateY:subview.frame.origin.y];
}

- (void)drawWhenOriginTop:(CGContextRef)context origin:(UIView *)subview
              parentWidth:(CGFloat)parentWidth parentHeight:(CGFloat)parentHeight
              subviewLeft:(CGFloat)subviewLeft subviewTop:(CGFloat)subviewTop
             subviewRight:(CGFloat)subviewRight subviewBottom:(CGFloat)subviewBottom {
  
  CGFloat partOutOfBounds = subview.frame.size.height > parentHeight ? parentHeight - subviewBottom - self.spacingVertical : fabs(subviewTop + self.spacingVertical);
  [self drawMirrorClip:context forView:subview withRect:CGRectMake(0, 0, subview.frame.size.width, partOutOfBounds)
      translateX:subview.frame.origin.x translateY:parentHeight - partOutOfBounds];
}

- (void)drawWhenOriginRight:(CGContextRef)context origin:(UIView *)subview
                parentWidth:(CGFloat)parentWidth parentHeight:(CGFloat)parentHeight
                subviewLeft:(CGFloat)subviewLeft subviewTop:(CGFloat)subviewTop
               subviewRight:(CGFloat)subviewRight subviewBottom:(CGFloat)subviewBottom {
  
  CGFloat partOutOfBounds = subview.frame.size.width > parentWidth ? subviewLeft - self.spacingHorizontal : subviewRight - parentWidth - self.spacingHorizontal;
  [self drawMirrorClip:context forView:subview withRect:CGRectMake(subview.frame.size.width - partOutOfBounds, 0, partOutOfBounds, subview.frame.size.height)
      translateX:-subview.frame.size.width + partOutOfBounds translateY:subview.frame.origin.y];
}

- (void)drawWhenOriginBottom:(CGContextRef)context origin:(UIView *)subview
                 parentWidth:(CGFloat)parentWidth parentHeight:(CGFloat)parentHeight
                 subviewLeft:(CGFloat)subviewLeft subviewTop:(CGFloat)subviewTop
                subviewRight:(CGFloat)subviewRight subviewBottom:(CGFloat)subviewBottom {
  
  CGFloat partOutOfBounds = subview.frame.size.height > parentHeight ? subviewTop - self.spacingVertical : subviewBottom - parentHeight - self.spacingVertical;
  [self drawMirrorClip:context forView:subview withRect:CGRectMake(0, subview.frame.size.height - partOutOfBounds, subview.frame.size.width, partOutOfBounds)
      translateX:subview.frame.origin.x translateY:-subview.frame.size.height + partOutOfBounds];
}

- (void)drawWhenOriginLeftTop:(CGContextRef)context origin:(UIView *)subview
                  parentWidth:(CGFloat)parentWidth parentHeight:(CGFloat)parentHeight
                  subviewLeft:(CGFloat)subviewLeft subviewTop:(CGFloat)subviewTop
                 subviewRight:(CGFloat)subviewRight subviewBottom:(CGFloat)subviewBottom {
  
  [self drawWhenOriginLeft:context origin:subview
               parentWidth:parentWidth parentHeight:parentHeight
               subviewLeft:subviewLeft subviewTop:subviewTop
              subviewRight:subviewRight subviewBottom:subviewBottom
  ];
  [self drawWhenOriginTop:context origin:subview
              parentWidth:parentWidth parentHeight:parentHeight
              subviewLeft:subviewLeft subviewTop:subviewTop
             subviewRight:subviewRight subviewBottom:subviewBottom
  ];
  CGFloat partOutOfBoundsHor = subview.frame.size.width > parentWidth ? parentWidth - subviewRight - self.spacingHorizontal : fabs(subviewLeft + self.spacingHorizontal);
  CGFloat partOutOfBoundsVer = subview.frame.size.height > parentHeight ? parentHeight - subviewBottom - self.spacingVertical : fabs(subviewTop + self.spacingVertical);
  [self drawMirrorClip:context forView:subview withRect:CGRectMake(0, 0, partOutOfBoundsHor, partOutOfBoundsVer)
            translateX:parentWidth - partOutOfBoundsHor translateY:parentHeight - partOutOfBoundsVer];
}

- (void)drawWhenOriginLeftBottom:(CGContextRef)context origin:(UIView *)subview
                     parentWidth:(CGFloat)parentWidth parentHeight:(CGFloat)parentHeight
                     subviewLeft:(CGFloat)subviewLeft subviewTop:(CGFloat)subviewTop
                    subviewRight:(CGFloat)subviewRight subviewBottom:(CGFloat)subviewBottom {
  
  [self drawWhenOriginLeft:context origin:subview
               parentWidth:parentWidth parentHeight:parentHeight
               subviewLeft:subviewLeft subviewTop:subviewTop
              subviewRight:subviewRight subviewBottom:subviewBottom
  ];
  [self drawWhenOriginBottom:context origin:subview
                 parentWidth:parentWidth parentHeight:parentHeight
                 subviewLeft:subviewLeft subviewTop:subviewTop
                subviewRight:subviewRight subviewBottom:subviewBottom
  ];
  CGFloat partOutOfBoundsHor = subview.frame.size.width > parentWidth ? parentWidth - subviewRight - self.spacingHorizontal : fabs(subviewLeft + self.spacingHorizontal);
  CGFloat partOutOfBoundsVer = subview.frame.size.height > parentHeight ? subviewTop - self.spacingVertical : subviewBottom - parentHeight - self.spacingVertical;
  [self drawMirrorClip:context forView:subview withRect:CGRectMake(0, subview.frame.size.height - partOutOfBoundsVer, partOutOfBoundsHor, partOutOfBoundsVer)
            translateX:parentWidth - partOutOfBoundsHor translateY:-subview.frame.size.height + partOutOfBoundsVer];
}

- (void)drawWhenOriginRightTop:(CGContextRef)context origin:(UIView *)subview
                   parentWidth:(CGFloat)parentWidth parentHeight:(CGFloat)parentHeight
                   subviewLeft:(CGFloat)subviewLeft subviewTop:(CGFloat)subviewTop
                  subviewRight:(CGFloat)subviewRight subviewBottom:(CGFloat)subviewBottom {
  
  [self drawWhenOriginRight:context origin:subview
                parentWidth:parentWidth parentHeight:parentHeight
                subviewLeft:subviewLeft subviewTop:subviewTop
               subviewRight:subviewRight subviewBottom:subviewBottom
  ];
  [self drawWhenOriginTop:context origin:subview
              parentWidth:parentWidth parentHeight:parentHeight
              subviewLeft:subviewLeft subviewTop:subviewTop
             subviewRight:subviewRight subviewBottom:subviewBottom
  ];
  CGFloat partOutOfBoundsHor = subview.frame.size.width > parentWidth ? subviewLeft - self.spacingHorizontal : subviewRight - parentWidth - self.spacingHorizontal;
  CGFloat partOutOfBoundsVer = subview.frame.size.height > parentHeight ? parentHeight - subviewBottom - self.spacingVertical : fabs(subviewTop + self.spacingVertical);
  [self drawMirrorClip:context forView:subview withRect:CGRectMake(subview.frame.size.width - partOutOfBoundsHor, 0, partOutOfBoundsHor, partOutOfBoundsVer)
            translateX:-subview.frame.size.width + partOutOfBoundsHor translateY:parentHeight - partOutOfBoundsVer];
}

- (void)drawWhenOriginRightBottom:(CGContextRef)context origin:(UIView *)subview
                      parentWidth:(CGFloat)parentWidth parentHeight:(CGFloat)parentHeight
                      subviewLeft:(CGFloat)subviewLeft subviewTop:(CGFloat)subviewTop
                     subviewRight:(CGFloat)subviewRight subviewBottom:(CGFloat)subviewBottom {
 
  [self drawWhenOriginRight:context origin:subview
                parentWidth:parentWidth parentHeight:parentHeight
                subviewLeft:subviewLeft subviewTop:subviewTop
               subviewRight:subviewRight subviewBottom:subviewBottom
  ];
  [self drawWhenOriginBottom:context origin:subview
                 parentWidth:parentWidth parentHeight:parentHeight
                 subviewLeft:subviewLeft subviewTop:subviewTop
                subviewRight:subviewRight subviewBottom:subviewBottom
  ];
  CGFloat partOutOfBoundsHor = subview.frame.size.width > parentWidth ? subviewLeft - self.spacingHorizontal : subviewRight - parentWidth - self.spacingHorizontal;
  CGFloat partOutOfBoundsVer = subview.frame.size.height > parentHeight ? subviewTop - self.spacingVertical : subviewBottom - parentHeight - self.spacingVertical;
  [self drawMirrorClip:context forView:subview
              withRect:CGRectMake(subview.frame.size.width - partOutOfBoundsHor, subview.frame.size.height - partOutOfBoundsVer, partOutOfBoundsHor, partOutOfBoundsVer)
            translateX:-subview.frame.size.width + partOutOfBoundsHor translateY:-subview.frame.size.height + partOutOfBoundsVer];
}

@end
