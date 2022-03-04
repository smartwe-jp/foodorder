#import "AppsetPlugin.h"
#if __has_include(<appset/appset-Swift.h>)
#import <appset/appset-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "appset-Swift.h"
#endif

@implementation AppsetPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftAppsetPlugin registerWithRegistrar:registrar];
}
@end
