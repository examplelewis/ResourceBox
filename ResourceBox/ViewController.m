//
//  ViewController.m
//  ResourceBox
//
//  Created by 龚宇 on 21/02/02.
//

#import "ViewController.h"

#import "RBShareImageListViewController.h"
#import "RBShareTextModel.h"

@interface ViewController () <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, copy) NSArray<NSArray *> *listData;
@property (nonatomic, copy) NSArray<NSString *> *headerData;

@end

@implementation ViewController

#pragma mark - Lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[RBSettingManager defaultManager] updateViewController:self];
    
    self.title = @"列表";
    
    [self setupUIAndData];
}

#pragma mark - Configure
- (void)setupUIAndData {
    // Data
    self.listData = @[
        @[@"导入图片"],
        @[@"查询已抓取的图片数量(Group)", @"查询已抓取的图片数量(App)"],
        @[@"Group 移动至 App", @"清空 文件夹"]
    ];
    self.headerData = @[
        @"图片添加",
        @"图片查看",
        @"图片操作"
    ];
    
    // UI
}

#pragma mark - File Ops
- (void)moveImageFilesToAppContainer {
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
- (void)cleanImageFolder {
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

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.listData.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.listData[section] count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    cell.textLabel.text = self.listData[indexPath.section][indexPath.row];
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.headerData[section];
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0) {
        
    } else if (indexPath.section == 1) {
        RBShareImageListViewController *vc = [[RBShareImageListViewController alloc] initWithNibName:@"RBShareImageListViewController" bundle:nil];
        if (indexPath.row == 0) {
            vc.behavior = RBShareImageFetchResultBehaviorSourceWeibo | RBShareImageFetchResultBehaviorContainerGroup;
        } else if (indexPath.row == 1) {
            vc.behavior = RBShareImageFetchResultBehaviorSourceWeibo | RBShareImageFetchResultBehaviorContainerApp;
        }
        
        [[RBSettingManager defaultManager].navigationController pushViewController:vc animated:YES];
    } else if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            [self moveImageFilesToAppContainer];
        } else if (indexPath.row == 1) {
            [self cleanImageFolder];
        }
    }
}

@end
