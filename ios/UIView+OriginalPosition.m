#import "UIView+OriginalPosition.h"
#import <objc/runtime.h>

@implementation UIView (OriginalPosition)

static char kOriginalPositionKey;

- (void)setOriginalPosition:(CGPoint)originalPosition {
    objc_setAssociatedObject(self, &kOriginalPositionKey, [NSValue valueWithCGPoint:originalPosition], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGPoint)originalPosition {
    NSValue *value = objc_getAssociatedObject(self, &kOriginalPositionKey);
    return [value CGPointValue];
}

@end
