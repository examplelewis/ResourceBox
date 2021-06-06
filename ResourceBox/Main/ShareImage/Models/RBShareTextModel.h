//
//  RBShareTextModel.h
//  RBShareExtension
//
//  Created by 龚宇 on 21/02/06.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RBShareTextModel : NSObject

@property (nonatomic, copy, readonly) NSString *userName;
@property (nonatomic, copy, readonly) NSString *text;
@property (nonatomic, copy, readonly) NSString *dateString;

- (instancetype)initWithText:(NSString *)text;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

+ (NSString *)folderNameWithText:(NSString *)text;
+ (NSString *)folderNameWithModel:(RBShareTextModel *)model;

@end

NS_ASSUME_NONNULL_END
