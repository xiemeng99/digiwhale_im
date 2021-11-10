#import "AppDelegate.h"
#import "GeneratedPluginRegistrant.h"
#import <NIMSDK/NIMSDK.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  [GeneratedPluginRegistrant registerWithRegistry:self];
    [self initNimSdk];
  // Override point for customization after application launch.
  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

-(void)initNimSdk{
    //推荐在程序启动的时候初始化 NIMSDK
         //网易云信sdk初始化
         NSString *appKey        = @"535e5e2452730350b447432a743f2a5d";
         NIMSDKOption *option    = [NIMSDKOption optionWithAppKey:appKey];
         option.apnsCername      = @"IM01.mobileprovision";
//         option.apnsCername      = @"Athena_Atn_Development";
         [[NIMSDK sharedSDK] registerWithOption:option];
         [NIMSDKConfig sharedConfig].shouldSyncUnreadCount = YES;
    [NIMSDKConfig sharedConfig].teamReceiptEnabled = YES;
    
}

@end
