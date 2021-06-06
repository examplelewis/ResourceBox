//
//  RBSQLiteManager.h
//  MyUniqueBox
//
//  Created by 龚宇 on 20/09/29.
//  Copyright © 2020 龚宇. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RBWeiboStatus.h"

NS_ASSUME_NONNULL_BEGIN

@interface RBSQLiteManager : NSObject

#pragma mark - Lifecycle
+ (instancetype)defaultManager;

#pragma mark - WeiboStatus
- (BOOL)isWeiboStatusExistsWithStatusId:(NSString *)statusId;
- (void)insertWeiboStatuses:(NSArray<RBWeiboStatus *> *)statuses;

@end

NS_ASSUME_NONNULL_END
