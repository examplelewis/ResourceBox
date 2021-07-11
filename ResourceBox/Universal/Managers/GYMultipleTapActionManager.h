//
//  GYMultipleTapActionManager.h
//  PhotoLibrary
//
//  Created by 龚宇 on 2021/7/11.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GYMultipleTapAction : NSObject

#pragma mark - Lifecycle
+ (instancetype)tapActionWithCount:(NSInteger)count timeInterval:(NSTimeInterval)timeInterval eventName:(NSString *)eventName actionName:(NSString *)actionName;

@end

@class GYMultipleTapActionManager;
@protocol GYMultipleTapActionManagerDelegate <NSObject>

- (void)tapManager:(GYMultipleTapActionManager *)tapManager didTriggerTapAction:(GYMultipleTapAction *)tapAction;

@end

@interface GYMultipleTapActionManager : NSObject

@property (nonatomic, weak) id<GYMultipleTapActionManagerDelegate> delegate;

#pragma mark - Lifecycle
- (instancetype)initWithTapAction:(GYMultipleTapAction *)tapAction;

- (void)triggerTap;

@end

NS_ASSUME_NONNULL_END
