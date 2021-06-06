//
//  RBFileManager.h
//  MyComicView
//
//  Created by 龚宇 on 16/08/03.
//  Copyright © 2016年 gongyuTest. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * _Nonnull const RBShareImagesFolderName;

@interface RBFileManager : NSObject

NS_ASSUME_NONNULL_BEGIN

#pragma mark - Create
+ (BOOL)createFolderAtPath:(NSString *)folderPath;

#pragma mark - Move
+ (void)moveItemFromPath:(NSString *)fromPath toPath:(NSString *)toPath;
+ (void)moveItemFromURL:(NSURL *)fromURL toURL:(NSURL *)toURL;
+ (void)moveItemFromPath:(NSString *)fromPath toPath:(NSString *)toPath error:(NSError **)error;
+ (void)moveItemFromURL:(NSURL *)fromURL toURL:(NSURL *)toURL error:(NSError **)error;

#pragma mark - Copy
+ (void)copyItemFromPath:(NSString *)fromPath toPath:(NSString *)toPath;
+ (void)copyItemFromURL:(NSURL *)fromURL toURL:(NSURL *)toURL;
+ (BOOL)copyItemFromPath:(NSString *)fromPath toPath:(NSString *)toPath error:(NSError **)error;
+ (BOOL)copyItemFromURL:(NSURL *)fromURL toURL:(NSURL *)toURL error:(NSError **)error;

#pragma mark - Remove
+ (BOOL)removeFilePath:(NSString *)filePath;
+ (BOOL)removeFileURL:(NSURL *)fileURL;

#pragma mark - File Path
+ (NSArray<NSString *> *)filePathsInFolder:(NSString *)folderPath;
+ (NSArray<NSString *> *)filePathsInFolder:(NSString *)folderPath extensions:(NSArray<NSString *> *)extensions;
+ (NSArray<NSString *> *)filePathsInFolder:(NSString *)folderPath withoutExtensions:(NSArray<NSString *> *)extensions;
+ (NSArray<NSString *> *)folderPathsInFolder:(NSString *)folderPath;
+ (NSArray<NSString *> *)contentPathsInFolder:(NSString *)folderPath;

+ (NSArray<NSString *> *)allFilePathsInFolder:(NSString *)folderPath;
+ (NSArray<NSString *> *)allFilePathsInFolder:(NSString *)folderPath extensions:(NSArray<NSString *> *)extensions;
+ (NSArray<NSString *> *)allFilePathsInFolder:(NSString *)folderPath withoutExtensions:(NSArray<NSString *> *)extensions;
+ (NSArray<NSString *> *)allFolderPathsInFolder:(NSString *)folderPath;
+ (NSArray<NSString *> *)allContentPathsInFolder:(NSString *)folderPath;

#pragma mark - Attributes
+ (NSDictionary *)allAttributesOfItemAtPath:(NSString *)path;
+ (id)attribute:(NSString *)attribute ofItemAtPath:(NSString *)path;
+ (unsigned long long)fileSizeAtPath:(NSString *)path;
+ (unsigned long long)folderSizeAtPath:(NSString *)path;
+ (NSString *)fileSizeDescriptionAtPath:(NSString *)path;
+ (NSString *)folderSizeDescriptionAtPath:(NSString *)path;
+ (NSString *)sizeDescriptionFromSize:(unsigned long long)size;

#pragma mark - Check
+ (BOOL)fileExistsAtPath:(NSString *)contentPath;
+ (BOOL)contentIsFolderAtPath:(NSString *)contentPath;
+ (BOOL)isEmptyFolderAtPath:(NSString *)folderPath;

#pragma mark - Tool
+ (NSURL *)fileURLFromFilePath:(NSString *)filePath;
+ (NSString *)filePathFromFileURL:(NSURL *)fileURL;
+ (NSArray<NSURL *> *)fileURLsFromFilePaths:(NSArray<NSString *> *)filePaths;
+ (NSArray<NSString *> *)filePathsFromFileURLs:(NSArray<NSURL *> *)fileURLs;
+ (BOOL)fileShouldIgnore:(NSString *)fileName;
+ (NSArray<NSString *> *)filterReturnedContents:(NSArray<NSString *> *)contents;
+ (NSString *)removeSeparatorInPathComponentsAtContentPath:(NSString *)contentPath;

@end

NS_ASSUME_NONNULL_END
