//
//  AppDelegate.m
//  ResourceBox
//
//  Created by 龚宇 on 21/02/02.
//

#import "AppDelegate.h"

#import "RBExceptionManager.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

#pragma mark - UIApplicationDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
    
    [self setupLogger];
    
    [[RBSettingManager defaultManager] updateAppDelegate:self];
    
    [SVProgressHUD setMinimumDismissTimeInterval:1.0f];
    [SVProgressHUD setMaximumDismissTimeInterval:1.0f];
    
    return YES;
}
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    return YES;
}

#pragma mark - UISceneSession lifecycle


- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}


- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
}

#pragma mark - Setup
- (void)setupLogger {
    // 在系统上保持一周的日志文件
    DDLogFileManagerDefault *logFileManager = [[DDLogFileManagerDefault alloc] initWithLogsDirectory:[RBSettingManager defaultManager].documentPath];
    DDFileLogger *fileLogger = [[DDFileLogger alloc] initWithLogFileManager:logFileManager];
    fileLogger.rollingFrequency = 60 * 60 * 24 * 7;
    fileLogger.logFileManager.maximumNumberOfLogFiles = 3;
    fileLogger.maximumFileSize = 10 * 1024 * 1024;
    [DDLog addLogger:fileLogger];
    
    // RELEASE 的时候不需要添加 console 日志，只保留文件日志
#ifdef DEBUG
    [DDLog addLogger:[DDOSLogger sharedInstance]]; // console 日志
#endif
}


@end
