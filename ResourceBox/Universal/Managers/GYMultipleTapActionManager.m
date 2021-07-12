//
//  GYMultipleTapActionManager.m
//  PhotoLibrary
//
//  Created by 龚宇 on 2021/7/11.
//

#import "GYMultipleTapActionManager.h"

static NSTimeInterval const kMaxTimeInterval = 3.0f;

@interface GYMultipleTapAction ()

@property (nonatomic, assign) NSInteger count;
@property (nonatomic, assign) NSTimeInterval timeInterval;
@property (nonatomic, copy) NSString *eventName;
@property (nonatomic, copy) NSString *actionName;

@end

@implementation GYMultipleTapAction

#pragma mark - Lifecycle
+ (instancetype)tapActionWithCount:(NSInteger)count timeInterval:(NSTimeInterval)timeInterval eventName:(NSString *)eventName actionName:(NSString *)actionName {
    return [[GYMultipleTapAction alloc] initWithCount:count timeInterval:timeInterval eventName:eventName actionName:actionName];
}
- (instancetype)initWithCount:(NSInteger)count timeInterval:(NSTimeInterval)timeInterval eventName:(NSString *)eventName actionName:(NSString *)actionName {
    self = [super init];
    if (self) {
        self.count = count;
        self.timeInterval = (timeInterval > kMaxTimeInterval) ? kMaxTimeInterval : timeInterval;
        self.eventName = eventName;
        self.actionName = actionName;
    }
    
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"在%.2f秒内触发%ld次 %@\n即可执行操作: %@", self.timeInterval, self.count, self.eventName, self.actionName];
}

@end

@interface GYMultipleTapActionManager ()

@property (nonatomic, strong) GYMultipleTapAction *tapAction;

@property (nonatomic, strong) NSMutableArray<NSDate *> *tapDates;

@end

@implementation GYMultipleTapActionManager

#pragma mark - Lifecycle
- (instancetype)initWithTapAction:(GYMultipleTapAction *)tapAction {
    self = [super init];
    if (self) {
        self.tapAction = tapAction;
        self.tapDates = [NSMutableArray array];
    }
    
    return self;
}

- (void)triggerTap {
    NSDate *currentDate = [NSDate date];
    if (self.tapDates.count == 0) {
        [self.tapDates addObject:currentDate];
        return;
    }
    
    NSTimeInterval timeInterval = [currentDate timeIntervalSinceDate:self.tapDates.lastObject];
    if (timeInterval <= self.tapAction.timeInterval) {
        if (self.tapDates.count == self.tapAction.count - 1) {
            [self _reset];
            [self _triggerAction];
        } else {
            [self.tapDates addObject:currentDate];
        }
        
        return;
    }
    
    [self _reset];
    if (timeInterval <= kMaxTimeInterval) {
        [self _showInfo];
    }
}
- (void)_reset {
    [self.tapDates removeAllObjects];
}
- (void)_showInfo {
    [SVProgressHUD showInfoWithStatus:self.tapAction.description];
}

- (void)_triggerAction {
    if ([self.delegate respondsToSelector:@selector(tapManager:didTriggerTapAction:)]) {
        [self.delegate tapManager:self didTriggerTapAction:self.tapAction];
    }
}

@end
