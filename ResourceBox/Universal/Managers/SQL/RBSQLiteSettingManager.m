//
//  RBSQLiteSettingManager.m
//  MyUniqueBox
//
//  Created by 龚宇 on 20/09/29.
//  Copyright © 2020 龚宇. All rights reserved.
//

#import "RBSQLiteSettingManager.h"

#import "RBSQLiteHeader.h"

@implementation RBSQLiteSettingManager

// 备份数据库文件
+ (void)backupDatabase {
    [[RBLogManager defaultManager] addDefaultLogWithFormat:@"备份数据库文件, 流程开始"];
    
    NSArray *sqlites = @[RBSQLiteFileName];
    for (NSInteger i = 0; i < sqlites.count; i++) {
        NSString *sqlitePath = sqlites[i];
        NSString *sqliteName = sqlitePath.stringByDeletingPathExtension;
        NSString *sqliteFilePath = [[RBSettingManager defaultManager] pathOfContentInDatabasesFolder:sqlitePath];
        if (![RBFileManager fileExistsAtPath:sqliteFilePath]) {
            [[RBLogManager defaultManager] addWarningLogWithFormat:@"%@ 文件不存在", sqliteFilePath];
            return;
        }
        
        // 删除过往的备份文件
        NSArray *sqliteFilePaths = [RBFileManager filePathsInFolder:[RBSettingManager defaultManager].databasesFolderPath extensions:@[@"sqlite"]];
        for (NSString *filePath in sqliteFilePaths) {
            if ([filePath.lastPathComponent hasPrefix:[NSString stringWithFormat:@"%@_", sqliteName]]) {
//                NSError *error;
//                BOOL success = [RBFileManager trashItemAtURL:[NSURL fileURLWithPath:filePath] resultingItemURL:nil error:&error];
//                if (success) {
//                    [[RBLogManager defaultManager] addDefaultLogWithFormat:@"旧备份文件: %@, 删除成功", filePath];
//                } else {
//                    [[RBLogManager defaultManager] addErrorLogWithFormat:@"旧备份文件: %@, 删除失败: %@", filePath, [error localizedDescription]];
//                }
            }
        }
        
        // 复制数据库文件
        NSString *dateString = [[NSDate date] stringWithFormat:RBTimeFormatCompactyMd];
        NSString *destFilePath = [[RBSettingManager defaultManager] pathOfContentInDatabasesFolder:[NSString stringWithFormat:@"%@_%@.sqlite", sqliteName, dateString]];
        
        NSError *error;
        BOOL success = [RBFileManager copyItemFromPath:sqliteFilePath toPath:destFilePath error:&error];
        if (success) {
            [[RBLogManager defaultManager] addDefaultLogWithFormat:@"数据库文件: %@, 备份成功", sqliteFilePath];
            [[RBLogManager defaultManager] addDefaultLogWithFormat:@"备份文件: %@", destFilePath];
        } else {
            [[RBLogManager defaultManager] addErrorLogWithFormat:@"备份文件: %@,  备份失败: %@", destFilePath, [error localizedDescription]];
        }
    }
    
    
    [[RBLogManager defaultManager] addDefaultLogWithFormat:@"备份数据库文件, 流程结束"];
}
// 还原数据库文件
+ (void)restoreDatebase {
    [[RBLogManager defaultManager] addDefaultLogWithFormat:@"还原数据库文件, 流程开始"];
    
    NSArray *sqlites = @[RBSQLiteFileName];
    for (NSInteger i = 0; i < sqlites.count; i++) {
        NSString *sqlitePath = sqlites[i];
        NSString *sqliteName = sqlitePath.stringByDeletingPathExtension;
        
        // 先查找备份数据库文件是否存在
        NSArray *sqliteFilePaths = [RBFileManager filePathsInFolder:[RBSettingManager defaultManager].databasesFolderPath extensions:@[@"sqlite"]];
        sqliteFilePaths = [sqliteFilePaths bk_select:^BOOL(NSString *obj) {
            return [obj.lastPathComponent hasPrefix:[NSString stringWithFormat:@"%@_", sqliteName]];
        }];
        if (sqliteFilePaths.count == 0) {
            [[RBLogManager defaultManager] addWarningLogWithFormat:@"没有数据库: %@ 的备份文件", sqliteName];
            return;
        }
        
        // 再查找原数据库文件是否存在，存在的话就删除
        NSString *sqliteFilePath = [[RBSettingManager defaultManager] pathOfContentInDatabasesFolder:sqlitePath];
        if ([RBFileManager fileExistsAtPath:sqliteFilePath]) {
//            NSError *error;
//            BOOL success = [RBFileManager trashItemAtURL:[NSURL fileURLWithPath:sqliteFilePath] resultingItemURL:nil error:&error];
//            if (success) {
//                [[RBLogManager defaultManager] addDefaultLogWithFormat:@"数据库文件: %@, 删除成功", sqliteFilePath];
//            } else {
//                [[RBLogManager defaultManager] addErrorLogWithFormat:@"数据库文件: %@, 删除失败: %@", sqliteFilePath, [error localizedDescription]];
//                
//                [[RBLogManager defaultManager] addDefaultLogWithFormat:@"还原数据库文件, 流程结束"];
//                return;
//            }
        }
        
        // 还原备份数据库文件
        sqliteFilePaths = [sqliteFilePaths sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"self" ascending:NO]]];
        NSString *backupSqliteFilePath = sqliteFilePaths.firstObject;
        NSError *error;
        BOOL success = [RBFileManager copyItemFromPath:backupSqliteFilePath toPath:sqliteFilePath error:&error];
        if (success) {
            [[RBLogManager defaultManager] addDefaultLogWithFormat:@"数据库文件: %@, 还原成功", backupSqliteFilePath];
        } else {
            [[RBLogManager defaultManager] addErrorLogWithFormat:@"数据库文件: %@, 还原失败: %@", backupSqliteFilePath, [error localizedDescription]];
        }
    }
    
    [[RBLogManager defaultManager] addDefaultLogWithFormat:@"还原数据库文件, 流程结束"];
}
// 去除数据库中重复的内容
+ (void)removeDuplicates {
    [[RBLogManager defaultManager] addDefaultLogWithFormat:@"去除数据库中重复的内容：已经准备就绪"];
    
//    [[MRBSQLiteFMDBManager defaultDBManager] removeDuplicateLinksFromDatabase];
//    [[MRBSQLiteFMDBManager defaultDBManager] removeDuplicateImagesFromDatabase];
    
    [[RBLogManager defaultManager] addDefaultLogWithFormat:@"去除数据库中重复的内容：流程已经结束"];
    
    [[RBLogManager defaultManager] addDefaultLogWithFormat:@"即将开始备份数据库"];
    [RBSQLiteSettingManager backupDatabase];
}

@end
