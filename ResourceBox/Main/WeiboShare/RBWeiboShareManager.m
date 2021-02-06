//
//  RBWeiboShareManager.m
//  ResourceBox
//
//  Created by 龚宇 on 21/02/06.
//

#import "RBWeiboShareManager.h"
#import "RBWeiboShareFetchResultViewController.h"

@implementation RBWeiboShareManager

+ (void)cellDidPressAtIndex:(NSInteger)index {
    switch (index) {
        case 0: {
            RBWeiboShareFetchResultViewController *vc = [[RBWeiboShareFetchResultViewController alloc] initWithNibName:@"RBWeiboShareFetchResultViewController" bundle:nil];
            vc.behavior = RBWeiboShareFetchResultBehaviorSourceWeibo | RBWeiboShareFetchResultBehaviorContainerGroup;
            [[RBSettingManager defaultManager].viewController.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 1: {
            RBWeiboShareFetchResultViewController *vc = [[RBWeiboShareFetchResultViewController alloc] initWithNibName:@"RBWeiboShareFetchResultViewController" bundle:nil];
            vc.behavior = RBWeiboShareFetchResultBehaviorSourceWeibo | RBWeiboShareFetchResultBehaviorContainerApp;
            [[RBSettingManager defaultManager].viewController.navigationController pushViewController:vc animated:YES];
        }
            break;
        default:
            break;
    }
}

@end
