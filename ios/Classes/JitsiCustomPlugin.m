#import "JitsiCustomPlugin.h"
#if __has_include(<jitsi_custom/jitsi_custom-Swift.h>)
#import <jitsi_custom/jitsi_custom-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "jitsi_custom-Swift.h"
#endif

@implementation JitsiCustomPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftJitsiCustomPlugin registerWithRegistrar:registrar];
}
@end
