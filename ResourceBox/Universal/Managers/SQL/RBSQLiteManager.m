//
//  RBSQLiteManager.m
//  MyUniqueBox
//
//  Created by 龚宇 on 20/09/29.
//  Copyright © 2020 龚宇. All rights reserved.
//

#import "RBSQLiteManager.h"
#import <fmdb/FMDB.h>

#import "RBSQLiteHeader.h"

@interface RBSQLiteManager ()

@property (strong) FMDatabaseQueue *queue;
@property (strong) FMDatabaseQueue *pixivUtilQueue;

@end

@implementation RBSQLiteManager

#pragma mark - Lifecycle
+ (instancetype)defaultManager {
    static RBSQLiteManager *defaultManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultManager = [[self alloc] init];
        defaultManager.queue = [FMDatabaseQueue databaseQueueWithPath:[[RBSettingManager defaultManager] pathOfContentInDatabasesFolder:RBSQLiteFileName]];
    });
    
    return defaultManager;
}

#pragma mark - WeiboStatus
- (BOOL)isWeiboStatusExistsWithStatusId:(NSString *)statusId {
    NSMutableArray *result = [NSMutableArray array];
    [self.queue inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet *rs = [db executeQuery:@"select * from PLWeiboStatuses where weibo_id = ?", statusId];
        while ([rs next]) {
            [result addObject:[rs stringForColumn:@"weibo_id"]];
        }
        
        [rs close];
    }];
    
    return result.count != 0;
}
- (void)insertWeiboStatuses:(NSArray<RBWeiboStatus *> *)statuses {
    for (RBWeiboStatus *status in statuses) {
        [self.queue inDatabase:^(FMDatabase * _Nonnull db) {
            NSString *update = @"INSERT INTO PLWeiboStatuses (id, weibo_id, author_id, author_name, text, publish_time, fetch_time) values(?, ?, ?, ?, ?, ?, ?)";
            NSArray *arguments = @[[NSNull null], status.statusID, status.userID, status.username, status.initialText, @"0000-00-00 00:00:00", [[NSDate date] stringWithFormat:@"yyyy-MM-dd HH:mm:ss"]];
            
            BOOL success = [db executeUpdate:update withArgumentsInArray:arguments];
            if (!success) {
                NSString *errorDesc = [NSString stringWithFormat:@"往数据表: PLWeiboStatuses 中插入数据时发生错误：%@", [db lastErrorMessage]];
                
                [SVProgressHUD showErrorWithStatus:errorDesc];
                [[RBLogManager defaultManager] addErrorLogWithFormat:@"%@", errorDesc];
                [[RBLogManager defaultManager] addErrorLogWithFormat:@"插入的数据：%@", status];
            }
        }];
        
        for (NSString *imgURL in status.imageUrls) {
            [self.queue inDatabase:^(FMDatabase * _Nonnull db) {
                NSString *update = @"INSERT INTO PLWeiboImages (id, weibo_id, image_url) values(?, ?, ?)";
                NSArray *arguments = @[[NSNull null], status.statusID, imgURL];
                
                BOOL success = [db executeUpdate:update withArgumentsInArray:arguments];
                if (!success) {
                    NSString *errorDesc = [NSString stringWithFormat:@"往数据表: PLWeiboImages 中插入数据时发生错误：%@", [db lastErrorMessage]];
                    
                    [SVProgressHUD showErrorWithStatus:errorDesc];
                    [[RBLogManager defaultManager] addErrorLogWithFormat:@"%@", errorDesc];
                    [[RBLogManager defaultManager] addErrorLogWithFormat:@"插入的数据：%@", imgURL];
                }
            }];
        }
    }
}

@end
