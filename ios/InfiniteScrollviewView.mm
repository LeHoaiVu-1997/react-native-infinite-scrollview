#import "InfiniteScrollviewView.h"

#import <react/renderer/components/InfiniteScrollviewViewSpec/ComponentDescriptors.h>
#import <react/renderer/components/InfiniteScrollviewViewSpec/EventEmitters.h>
#import <react/renderer/components/InfiniteScrollviewViewSpec/Props.h>
#import <react/renderer/components/InfiniteScrollviewViewSpec/RCTComponentViewHelpers.h>

#import "RCTFabricComponentsPlugins.h"

using namespace facebook::react;

@interface InfiniteScrollviewView () <RCTInfiniteScrollviewViewViewProtocol>

@end

@implementation InfiniteScrollviewView {
  UIView * _view;
}

+ (ComponentDescriptorProvider)componentDescriptorProvider
{
  return concreteComponentDescriptorProvider<InfiniteScrollviewViewComponentDescriptor>();
}

- (instancetype)initWithFrame:(CGRect)frame
{
  if (self = [super initWithFrame:frame]) {
    static const auto defaultProps = std::make_shared<const InfiniteScrollviewViewProps>();
    _props = defaultProps;
    
    _view = [[UIView alloc] init];
    
    self.contentView = _view;
  }
  
  return self;
}

- (void)updateProps:(Props::Shared const &)props oldProps:(Props::Shared const &)oldProps
{
  const auto &oldViewProps = *std::static_pointer_cast<InfiniteScrollviewViewProps const>(_props);
  const auto &newViewProps = *std::static_pointer_cast<InfiniteScrollviewViewProps const>(props);
  
  if (oldViewProps.color != newViewProps.color) {
    NSString * colorToConvert = [[NSString alloc] initWithUTF8String: newViewProps.color.c_str()];
    [_view setBackgroundColor:[self hexStringToColor:colorToConvert]];
  }
  
  if (oldViewProps.test != newViewProps.test) {
    NSLog(@"prop test change to: %d", newViewProps.test);
  }
  
  [super updateProps:props oldProps:oldProps];
}

#pragma mark - Legacy setter
- (void)setColor:(NSString *)color {
  NSLog(@"prop color change to: %@", color);
  [_view setBackgroundColor:[self hexStringToColor:color]];
}

- (void)setTest:(BOOL)test {
  NSLog(@"test prop from old arch: %d", test);
}

#pragma mark - Alert

- (UIViewController *)topViewController {
  UIViewController *rootViewController = UIApplication.sharedApplication.delegate.window.rootViewController;
  while (rootViewController.presentedViewController) {
    rootViewController = rootViewController.presentedViewController;
  }
  return rootViewController;
}

- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message {
  dispatch_async(dispatch_get_main_queue(), ^{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK"
                                                 style:UIAlertActionStyleDefault
                                               handler:nil];
    [alert addAction:ok];
    
    UIViewController *rootVC = [self topViewController];
    if (rootVC != nil) {
      [rootVC presentViewController:alert animated:YES completion:nil];
    }
  });
}

#pragma mark - Ref methods handling

- (void)handleCommand:(const NSString *)commandName args:(const NSArray *)args {
  if ([commandName isEqualToString:@"doSomething"]) {
    [self doSomething];
  } else if ([commandName isEqualToString:@"setValue"]) {
    NSString *value = (NSString *)args[0];
    [self setValue:value];
  }
}

- (void)doSomething {
  NSLog(@"do something");
  [self showAlertWithTitle:@"Alert" message:@"Do something method called"];
}

- (void)setValue:(NSString *)color {
  NSLog(@"set value %@", color);
  NSString *message = [NSString stringWithFormat:@"Set value method called with value: %@", color];
  [self showAlertWithTitle:@"Alert" message:message];
}

#pragma mark - Others

Class<RCTComponentViewProtocol> InfiniteScrollviewViewCls(void)
{
  return InfiniteScrollviewView.class;
}

- hexStringToColor:(NSString *)stringToConvert
{
  NSString *noHashString = [stringToConvert stringByReplacingOccurrencesOfString:@"#" withString:@""];
  NSScanner *stringScanner = [NSScanner scannerWithString:noHashString];
  
  unsigned hex;
  if (![stringScanner scanHexInt:&hex]) return nil;
  int r = (hex >> 16) & 0xFF;
  int g = (hex >> 8) & 0xFF;
  int b = (hex) & 0xFF;
  
  return [UIColor colorWithRed:r / 255.0f green:g / 255.0f blue:b / 255.0f alpha:1.0f];
}

@end
