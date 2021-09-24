//
//  RBSettingManager.m
//  MyUniqueBox
//
//  Created by 龚宇 on 20/09/13.
//  Copyright © 2020 龚宇. All rights reserved.
//

#import "RBSettingManager.h"

@implementation RBSettingManager

#pragma mark - Lifecycle
+ (instancetype)defaultManager {
    static RBSettingManager *defaultManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultManager = [[self alloc] init];
    });
    
    return defaultManager;
}
- (instancetype)init {
    self = [super init];
    if (self) {
        _homePath = NSHomeDirectory();
        _documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
        _libraryPath = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES).firstObject;
        _cachesPath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
        _applicationSupportPath = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES).firstObject;
        _preferencePath = NSSearchPathForDirectoriesInDomains(NSPreferencePanesDirectory, NSUserDomainMask, YES).firstObject;
        _temPath = NSTemporaryDirectory();
        
        _databasesFolderPath = [_documentPath stringByAppendingPathComponent:@"~Databases"];
        _preferenceFilePath = [self pathOfContentInDocumentFolder:@"RBPreference.plist"];
        
        [RBFileManager createFolderAtPath:self.databasesFolderPath];
        
        [self updatePreferences];
    }
    
    return self;
}

#pragma mark - Configure
- (void)updateAppDelegate:(AppDelegate *)appDelegate {
    _appDelegate = appDelegate;
}
- (void)updateViewController:(ViewController *)viewController {
    _viewController = viewController;
    _navigationController = viewController.navigationController;
}
- (void)updatePreferences {
    NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:[self pathOfContentInDocumentFolder:@"RBPreference.plist"]];
    
    _mimeImageTypes = [[prefs valueForKeyPath:@"MIMEType.ImageTypes"] copy];
    _mimeVideoTypes = [[prefs valueForKeyPath:@"MIMEType.VideoTypes"] copy];
    _mimeImageAndVideoTypes = [self.mimeImageTypes arrayByAddingObjectsFromArray:self.mimeVideoTypes];
}

#pragma mark - Types
- (BOOL)isImageAtFilePath:(NSString *)filePath {
    BOOL isImage = NO;
    for (NSString *extension in self.mimeImageTypes) {
        isImage = [filePath.pathExtension caseInsensitiveCompare:extension];
        if (isImage) {
            break;
        }
    }
    
    return isImage;
}
- (BOOL)isVideoAtFilePath:(NSString *)filePath {
    BOOL isVideo = NO;
    for (NSString *extension in self.mimeVideoTypes) {
        isVideo = [filePath.pathExtension caseInsensitiveCompare:extension];
        if (isVideo) {
            break;
        }
    }
    
    return isVideo;
}

#pragma mark - Paths
- (NSString *)pathOfContentInDocumentFolder:(NSString *)component {
    return [self.documentPath stringByAppendingPathComponent:component];
}
- (NSString *)pathOfContentInDatabasesFolder:(NSString *)component {
    return [self.databasesFolderPath stringByAppendingPathComponent:component];
}

@end
