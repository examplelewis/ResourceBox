//
//  RBSettingManager.h
//  MyUniqueBox
//
//  Created by 龚宇 on 20/09/13.
//  Copyright © 2020 龚宇. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AppDelegate.h"
#import "ViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface RBSettingManager : NSObject

@property (nonatomic, strong, readonly) AppDelegate *appDelegate;
//@property (nonatomic, strong, readonly) UIWindow *keyWindow;
@property (nonatomic, strong, readonly) UINavigationController *navigationController;
@property (nonatomic, strong, readonly) ViewController *viewController;

@property (nonatomic, strong, readonly) NSArray *mimeImageTypes;
@property (nonatomic, strong, readonly) NSArray *mimeVideoTypes;
@property (nonatomic, strong, readonly) NSArray *mimeImageAndVideoTypes;


@property (nonatomic, strong, readonly) NSString *homePath;
@property (nonatomic, strong, readonly) NSString *documentPath;
@property (nonatomic, strong, readonly) NSString *libraryPath;
@property (nonatomic, strong, readonly) NSString *cachesPath;
@property (nonatomic, strong, readonly) NSString *applicationSupportPath;
@property (nonatomic, strong, readonly) NSString *preferencePath;
@property (nonatomic, strong, readonly) NSString *temPath;

@property (nonatomic, strong, readonly) NSString *databasesFolderPath;
@property (nonatomic, strong, readonly) NSString *preferenceFilePath;

#pragma mark - Lifecycle
+ (instancetype)defaultManager;

#pragma mark - Configure
- (void)updateAppDelegate:(AppDelegate *)appDelegate;
- (void)updateViewController:(ViewController *)viewController;

#pragma mark - Types
- (BOOL)isImageAtFilePath:(NSString *)filePath;
- (BOOL)isVideoAtFilePath:(NSString *)filePath;

#pragma mark - Paths
- (NSString *)pathOfContentInDocumentFolder:(NSString *)component;
- (NSString *)pathOfContentInDatabasesFolder:(NSString *)component;

@end

NS_ASSUME_NONNULL_END
