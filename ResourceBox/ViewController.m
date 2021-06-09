//
//  ViewController.m
//  ResourceBox
//
//  Created by 龚宇 on 21/02/02.
//

#import "ViewController.h"

#import "RBShareImageListViewController.h"
#import "RBShareImageImportViewController.h"
#import "RBSQLiteManager.h"

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
        @[@"查询已抓取的图片"],
        @[@"清空 文件夹"]
    ];
    self.headerData = @[
        @"图片添加",
        @"图片查看",
        @"图片操作"
    ];
    
    // UI
}

#pragma mark - Navigate
- (void)_navigateToImport {
    NSArray *inputs = [UIPasteboard generalPasteboard].strings;
    if (inputs.count == 2) {
        [self _navigateToImportDirectlyWithInputs:inputs];
    } else {
        [self _navigateToImportIndirectly];
    }
}
- (void)_navigateToImportDirectlyWithInputs:(NSArray *)inputs {
    NSString *inputStatus = inputs.firstObject;
    NSString *link = inputs.lastObject;
    
    if (![link.lowercaseString hasPrefix:@"https://m.weibo.cn/"] && ![link.lowercaseString hasPrefix:@"http://m.weibo.cn/"]) {
        [SVProgressHUD showInfoWithStatus:@"输入的不是微博链接"];
        return;
    }
    
    if ([link.lastPathComponent integerValue] == 0) {
        [SVProgressHUD showInfoWithStatus:@"输入的微博链接有误"];
        return;
    }
    
    if ([[RBSQLiteManager defaultManager] isWeiboStatusExistsWithStatusId:link.lastPathComponent]) {
        // 如果剪贴板上的微博内容已经存储，那么弹出手动输入框
        [self _navigateToImportIndirectly];
        // 延迟0.25秒，等UIAlertController显示后再显示SVProgressHUD
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [SVProgressHUD showInfoWithStatus:@"输入的微博已存储"];
        });
        
        return;
    }

    RBShareImageImportViewController *vc = [[RBShareImageImportViewController alloc] initWithNibName:@"RBShareImageImportViewController" bundle:nil];
    vc.link = link;
    vc.inputStatus = inputStatus;
    
    [[RBSettingManager defaultManager].navigationController pushViewController:vc animated:YES];
}
- (void)_navigateToImportIndirectly {
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"提示" message:@"请输入微博链接" preferredStyle:UIAlertControllerStyleAlert];
    [ac addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"微博链接";
    }];
    
    [ac addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        if (ac.textFields.count == 0) {
            [SVProgressHUD showErrorWithStatus:@"UIAlertController 内部出错"];
            return;
        }
        
        NSString *inputLink = ((UITextField *)ac.textFields.firstObject).text;
        if ([inputLink.lastPathComponent integerValue] == 0) {
            [SVProgressHUD showInfoWithStatus:@"输入的微博链接有误"];
            return;
        }
        
        if ([[RBSQLiteManager defaultManager] isWeiboStatusExistsWithStatusId:inputLink.lastPathComponent]) {
            [SVProgressHUD showInfoWithStatus:@"输入的微博已存储"];
            return;
        }
        
        RBShareImageImportViewController *vc = [[RBShareImageImportViewController alloc] initWithNibName:@"RBShareImageImportViewController" bundle:nil];
        vc.link = inputLink;
        
        [[RBSettingManager defaultManager].navigationController pushViewController:vc animated:YES];
    }]];
    [ac addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];

    [self presentViewController:ac animated:true completion:nil];
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
        [self _navigateToImport];
    } else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            RBShareImageListViewController *vc = [[RBShareImageListViewController alloc] initWithNibName:@"RBShareImageListViewController" bundle:nil];
            [[RBSettingManager defaultManager].navigationController pushViewController:vc animated:YES];
        }
    } else if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"是否清理文件夹内所有图片" message:@"此操作不可恢复" preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *cancelAA = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
            UIAlertAction *confirmAA = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [RBFileManager removeFilePath:[[RBSettingManager defaultManager] pathOfContentInDocumentFolder:RBShareImagesFolderName]];
                [SVProgressHUD showSuccessWithStatus:@"已全部完成"];
            }];
            [ac addAction:cancelAA];
            [ac addAction:confirmAA];
            
            [[RBSettingManager defaultManager].navigationController.visibleViewController presentViewController:ac animated:YES completion:nil];
        }
    }
}

@end
