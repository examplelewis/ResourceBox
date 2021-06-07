//
//  RBWeiboStatus.h
//  ResourceBox
//
//  Created by 龚宇 on 2021/6/6.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RBWeiboStatus : NSObject

@property (nonatomic, copy) NSString *initialText; // 初始化的Text
@property (nonatomic, copy) NSString *username; // 用户名

@property (nonatomic, copy) NSString *statusID;
@property (nonatomic, copy) NSString *userID;
@property (nonatomic, copy) NSArray<NSString *> *imageUrls;

@property (nonatomic, copy) NSString *folderName; // 文件夹名

@end

NS_ASSUME_NONNULL_END
