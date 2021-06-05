//
//  ViewController.m
//  ResourceBox
//
//  Created by 龚宇 on 21/02/02.
//

#import "ViewController.h"
#import "RBShareImageManager.h"

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
        @[@"查询已抓取的图片数量(Group)", @"查询已抓取的图片数量(App)", @"Group 移动至 App", @"清空 文件夹"],
        @[@"导入图片"]
    ];
    self.headerData = @[
        @"图片分享",
        @"图片操作"
    ];
    
    // UI
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
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [RBShareImageManager cellDidPressAtIndexPath:indexPath];
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.headerData[section];
}

@end
