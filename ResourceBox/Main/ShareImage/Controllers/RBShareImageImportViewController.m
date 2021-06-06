//
//  RBShareImageImportViewController.m
//  ResourceBox
//
//  Created by 龚宇 on 2021/6/6.
//

#import "RBShareImageImportViewController.h"

#import <PhotosUI/PhotosUI.h>
#import <MobileCoreServices/MobileCoreServices.h>

#import "RBShareTextModel.h"
#import "RBShareImageImportStatusTableViewCell.h"
#import "RBSQLiteManager.h"

@interface RBShareImageImportViewController () <UITableViewDataSource, UITableViewDelegate, PHPickerViewControllerDelegate>

@property (nonatomic, strong) UIBarButtonItem *imageBBI;
@property (nonatomic, strong) UIBarButtonItem *videoBBI;
@property (nonatomic, strong) UIBarButtonItem *doneBBI;

@property (nonatomic, copy) NSString *tempFolderPath;
@property (nonatomic, copy) NSArray *headers;
@property (nonatomic, copy) NSArray<NSString *> *filePaths;
@property (nonatomic, copy) NSString *statusText;
@property (nonatomic, copy) NSString *folderName;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation RBShareImageImportViewController

#pragma mark - Lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Import";
    
    [self setupBarButtonItems];
    [self setupNavigationBar];
    [self setupUIAndData];
}
- (void)dealloc {
    [RBFileManager removeFilePath:self.tempFolderPath];
}

#pragma mark - Configure
- (void)setupBarButtonItems {
    self.doneBBI = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(doneBarButtonItemPressed:)];
    
    self.imageBBI = [[UIBarButtonItem alloc] initWithTitle:@"图片" style:UIBarButtonItemStylePlain target:self action:@selector(imageBarButtonItemPressed:)];
    
    self.videoBBI = [[UIBarButtonItem alloc] initWithTitle:@"视频" style:UIBarButtonItemStylePlain target:self action:@selector(videoBarButtonItemPressed:)];
}
- (void)setupNavigationBar {
    self.navigationItem.rightBarButtonItems = @[self.doneBBI, self.imageBBI, self.videoBBI];
}
- (void)setupUIAndData {
    // Data
    self.headers = @[@"链接", @"文字", @"资源"];
    self.filePaths = @[];
    self.statusText = @"";
    self.folderName = @"";
    
    // Files
    [RBFileManager createFolderAtPath:self.tempFolderPath];
    
    // UI
    [self setupTableView];
}
- (void)setupTableView {
    [self.tableView registerNib:[UINib nibWithNibName:@"RBShareImageImportStatusTableViewCell" bundle:nil] forCellReuseIdentifier:@"statusCell"];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.headers.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    } else if (section == 1) {
        return 3;
    } else if (section == 2) {
        return self.filePaths.count;
    }
    
    return 0;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"linkCell"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"linkCell"];
        }
        
        cell.textLabel.text = self.link;
        
        return cell;
    } else if (indexPath.section == 1) {
        if (indexPath.row == 1) {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"statusRenameCell"];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"statusRenameCell"];
            }
            
            cell.textLabel.text = @"重新生成文件夹名";
            
            return cell;
        } else {
            RBShareImageImportStatusTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"statusCell"];
            cell.canEditTextView = indexPath.row == 0;
            if (indexPath.row == 0) {
                cell.textViewText = self.statusText;
            } else {
                cell.textViewText = self.folderName;
            }
            
            return cell;
        }
    } else if (indexPath.section == 2) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"imageCell"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"imageCell"];
        }
        
        cell.textLabel.text = self.filePaths[indexPath.row].lastPathComponent;
        cell.detailTextLabel.text = [RBFileManager fileSizeDescriptionAtPath:self.filePaths[indexPath.row]];
        
        return cell;
    }
    
    return nil;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.headers[section];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        if (indexPath.row != 1) {
            return 88.0f;
        }
    }
    
    return 44.0f;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0) {
        // do nothing...
    } else if (indexPath.section == 1) {
        if (indexPath.row == 1) {
            RBShareImageImportStatusTableViewCell *cell = (RBShareImageImportStatusTableViewCell *)[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
            
            self.statusText = cell.textViewText;
            self.folderName = [RBShareTextModel folderNameWithText:cell.textViewText];
            
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
        }
    }
}

#pragma mark - PHPickerViewControllerDelegate
- (void)picker:(PHPickerViewController *)picker didFinishPicking:(NSArray<PHPickerResult *> *)results {
    BOOL isImage = [picker.configuration.filter isEqual:[PHPickerFilter imagesFilter]];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    if (isImage) {
        for (NSInteger i = 0; i < results.count; i++) {
            @weakify(self);
            PHPickerResult *result = results[i];
            if ([result.itemProvider hasItemConformingToTypeIdentifier:@"public.image"]) {
                // 尽量遵循原图片尺寸、格式
                [result.itemProvider loadItemForTypeIdentifier:(NSString *)kUTTypeImage options:nil completionHandler:^(NSData *data, NSError *error) {
                    if (data) {
                        @strongify(self);
                        [self processImageData:data atIndex:i];
                    } else if (error.code == -1200) {
                        // -1200 的错误出现意味着，转换成Data失败，需要直接显示成Image
                        [result.itemProvider loadItemForTypeIdentifier:(NSString *)kUTTypeImage options:nil completionHandler:^(UIImage *image, NSError *error) {
                            if (image) {
                                @strongify(self);
                                [self processImageData:UIImageJPEGRepresentation(image, 0.95f) atIndex:i];
                            }
                        }];
                    }
                }];
            }
        }
    } else {
        
    }
}

- (void)processImageData:(NSData *)data atIndex:(NSInteger)index {
    NSString *fileNameSuffix = [NSString stringWithFormat:@"%@ %ld", self.tempFolderPath, index];
    NSString *fileNameAndExt = [NSString stringWithFormat:@"%@%@.jpg", self.tempFolderPath.md5String.md5Middle, fileNameSuffix.md5String.md5Middle];
    NSString *imageFilePath = [self.tempFolderPath stringByAppendingPathComponent:fileNameAndExt];
//    NSLog(@"imageFilePath: %@", imageFilePath);
    
    [data writeToFile:imageFilePath atomically:YES];
    
    self.filePaths = [self.filePaths arrayByAddingObject:imageFilePath];
    
    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self);
        [self.tableView reloadData];
    });
}

#pragma mark - Actions
- (void)imageBarButtonItemPressed:(UIBarButtonItem *)sender {
    PHPickerConfiguration *config = [[PHPickerConfiguration alloc] init];
    config.selectionLimit = 18;
    config.filter = [PHPickerFilter imagesFilter];

    PHPickerViewController *pickerViewController = [[PHPickerViewController alloc] initWithConfiguration:config];
    pickerViewController.delegate = self;
    [self presentViewController:pickerViewController animated:YES completion:nil];
}
- (void)videoBarButtonItemPressed:(UIBarButtonItem *)sender {
    PHPickerConfiguration *config = [[PHPickerConfiguration alloc] init];
    config.selectionLimit = 18;
    config.filter = [PHPickerFilter videosFilter];

    PHPickerViewController *pickerViewController = [[PHPickerViewController alloc] initWithConfiguration:config];
    pickerViewController.delegate = self;
    [self presentViewController:pickerViewController animated:YES completion:nil];
}
- (void)doneBarButtonItemPressed:(UIBarButtonItem *)sender {
    if (self.folderName.length == 0) {
        [SVProgressHUD showInfoWithStatus:@"需要文件夹名"];
        return;
    }
    if (self.filePaths.count == 0) {
        [SVProgressHUD showInfoWithStatus:@"需要选择图片"];
        return;
    }
    NSArray *folderNameComponents = [self.folderName componentsSeparatedByString:@"+"];
    if (folderNameComponents.count == 0) {
        [SVProgressHUD showInfoWithStatus:@"文件名格式有误"];
        return;
    }
    
    NSString *rootFolderPath = [[RBSettingManager defaultManager] pathOfContentInDocumentFolder:@"ShareImage"];
    NSString *folderPath = [rootFolderPath stringByAppendingPathComponent:self.folderName];
    
    [RBFileManager createFolderAtPath:folderPath];
    for (NSInteger i = 0; i < self.filePaths.count; i++) {
        NSString *originFilePath = self.filePaths[i];
        NSString *targetFilePath = [folderPath stringByAppendingPathComponent:originFilePath.lastPathComponent];
        
        [RBFileManager moveItemFromPath:originFilePath toPath:targetFilePath];
    }
    
    RBWeiboStatus *status = [RBWeiboStatus new];
    status.idStr = self.link.lastPathComponent;
    status.text = self.statusText;
    status.userName = folderNameComponents.firstObject;
    status.imageUrls = self.filePaths;
    // 数据库
    [[RBSQLiteManager defaultManager] insertWeiboStatuses:@[status]];
    
    // Done
    [SVProgressHUD showSuccessWithStatus:@"添加成功"];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Getter
- (NSString *)tempFolderPath {
    if (!_tempFolderPath) {
        NSString *path = [[RBSettingManager defaultManager] pathOfContentInDocumentFolder:@"Temp/Current"];
        _tempFolderPath = path.copy;
        NSInteger i = 2;
        
        while ([RBFileManager fileExistsAtPath:_tempFolderPath]) {
            _tempFolderPath = [path stringByAppendingFormat:@" %ld", i];
            i += 1;
        }
    }
    
    return _tempFolderPath;
}

@end
