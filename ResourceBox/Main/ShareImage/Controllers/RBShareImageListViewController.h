//
//  RBShareImageListViewController.h
//  ResourceBox
//
//  Created by 龚宇 on 21/02/06.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, RBShareImageSource) {
    RBShareImageSourceNone      = 0,
    RBShareImageSourceWeibo     = 1 << 0,
};

@interface RBShareImageListViewController : UIViewController

//@property (nonatomic, assign) RBShareImageSource source;

@end

NS_ASSUME_NONNULL_END
