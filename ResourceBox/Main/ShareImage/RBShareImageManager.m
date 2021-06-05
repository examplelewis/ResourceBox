//
//  RBShareImageManager.m
//  ResourceBox
//
//  Created by 龚宇 on 21/02/06.
//

#import "RBShareImageManager.h"

#import "RBShareImageListViewController.h"
#import "RBShareTextModel.h"

@implementation RBShareImageManager

+ (void)cellDidPressAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0: {
                RBShareImageListViewController *vc = [[RBShareImageListViewController alloc] initWithNibName:@"RBShareImageListViewController" bundle:nil];
                vc.behavior = RBShareImageFetchResultBehaviorSourceWeibo | RBShareImageFetchResultBehaviorContainerGroup;
                [[RBSettingManager defaultManager].navigationController pushViewController:vc animated:YES];
            }
                break;
            case 1: {
                RBShareImageListViewController *vc = [[RBShareImageListViewController alloc] initWithNibName:@"RBShareImageListViewController" bundle:nil];
                vc.behavior = RBShareImageFetchResultBehaviorSourceWeibo | RBShareImageFetchResultBehaviorContainerApp;
                [[RBSettingManager defaultManager].navigationController pushViewController:vc animated:YES];
            }
                break;
            case 2: {
                [RBShareImageManager moveImageFilesToAppContainer];
            }
                break;
            case 3: {
                [RBShareImageManager cleanImageFolder];
            }
                break;
            default:
                break;
        }
    } else if (indexPath.section == 1) {
        switch (indexPath.row) {
            case 0: {
                
            }
                break;
            default:
                break;
        }
    }
}

+ (void)moveImageFilesToAppContainer {
    [RBFileManager createFolderAtPath:[RBFileManager shareExtensionShareImagesAppContainerFolderPath]];
    
    NSArray *contentPaths = [RBFileManager contentPathsInFolder:[RBFileManager shareExtensionShareImagesGroupContainerFolderPath]];
    for (NSInteger i = 0; i < contentPaths.count; i++) {
        NSString *contentPath = contentPaths[i];
        // 文件夹名前带RBFileShareExtensionOrderedFolderNamePrefix就忽略，不允许移动
        if ([contentPath.lastPathComponent hasPrefix:RBFileShareExtensionOrderedFolderNamePrefix]) {
            continue;
        }
        
        NSString *destPath = [[RBFileManager shareExtensionShareImagesAppContainerFolderPath] stringByAppendingPathComponent:contentPath.lastPathComponent];
        [RBFileManager moveItemFromPath:contentPath toPath:destPath];
        
        [[RBLogManager defaultManager] addDefaultLogWithFormat:@"移动前: %@", contentPath];
        [[RBLogManager defaultManager] addDefaultLogWithFormat:@"移动后: %@", destPath];
    }
    
    [SVProgressHUD showSuccessWithStatus:@"已全部完成"];
}

+ (void)cleanImageFolder {
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"是否清理文件夹内所有图片" message:@"此操作不可恢复" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAA = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *confirmAA = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [RBFileManager removeFilePath:[RBFileManager shareExtensionShareImagesAppContainerFolderPath]];
        [SVProgressHUD showSuccessWithStatus:@"已全部完成"];
    }];
    [ac addAction:cancelAA];
    [ac addAction:confirmAA];
    
    [[RBSettingManager defaultManager].navigationController.visibleViewController presentViewController:ac animated:YES completion:nil];
}

@end
