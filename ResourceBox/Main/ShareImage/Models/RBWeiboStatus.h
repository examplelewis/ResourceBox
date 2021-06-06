//
//  RBWeiboStatus.h
//  ResourceBox
//
//  Created by 龚宇 on 2021/6/6.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RBWeiboStatus : NSObject

@property (nonatomic, copy) NSString *statusID;
@property (nonatomic, copy) NSString *userID;
@property (nonatomic, copy) NSString *userName;
@property (nonatomic, copy) NSString *text;
@property (nonatomic, copy) NSArray<NSString *> *imageUrls;

@end

NS_ASSUME_NONNULL_END
