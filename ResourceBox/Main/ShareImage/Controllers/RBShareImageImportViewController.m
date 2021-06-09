//
//  RBShareImageImportViewController.m
//  ResourceBox
//
//  Created by 龚宇 on 2021/6/6.
//

#import "RBShareImageImportViewController.h"

#import <PhotosUI/PhotosUI.h>
#import <MobileCoreServices/MobileCoreServices.h>

#import "RBShareImageImportStatusTableViewCell.h"
#import "RBSQLiteManager.h"

@interface RBShareImageImportViewController () <UITableViewDataSource, UITableViewDelegate, PHPickerViewControllerDelegate>

@property (nonatomic, copy) NSString *tempFolderPath;
@property (nonatomic, copy) NSArray *headers;
@property (nonatomic, copy) NSArray<NSString *> *filePaths;

@property (nonatomic, strong) RBWeiboStatus *status;
//@property (nonatomic, copy) NSString *statusText;
//@property (nonatomic, copy) NSString *statusID;
//@property (nonatomic, copy) NSString *statusUserID;
//@property (nonatomic, copy) NSString *folderName;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation RBShareImageImportViewController

#pragma mark - Lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Import";
    
    [self setupNavigationBar];
    [self setupUIAndData];
}
- (void)dealloc {
    [RBFileManager removeFilePath:self.tempFolderPath];
}

#pragma mark - Configure
- (void)setupNavigationBar {
    UIBarButtonItem *doneBBI = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(doneBarButtonItemPressed:)];
    UIBarButtonItem *imageBBI = [[UIBarButtonItem alloc] initWithTitle:@"图片" style:UIBarButtonItemStylePlain target:self action:@selector(imageBarButtonItemPressed:)];
    UIBarButtonItem *videoBBI = [[UIBarButtonItem alloc] initWithTitle:@"视频" style:UIBarButtonItemStylePlain target:self action:@selector(videoBarButtonItemPressed:)];
    UIBarButtonItem *livePhotoBBI = [[UIBarButtonItem alloc] initWithTitle:@"Live" style:UIBarButtonItemStylePlain target:self action:@selector(livePhotoBarButtonItemPressed:)];
    
    self.navigationItem.rightBarButtonItems = @[doneBBI, imageBBI, videoBBI, livePhotoBBI];
}
- (void)setupUIAndData {
    // Data
    self.headers = @[@"链接", @"信息", @"文字", @"资源"];
    self.filePaths = @[];
    
    self.status = [RBWeiboStatus new];
    if (self.inputStatus.isNotEmpty) {
        self.status.initialText = self.inputStatus;
    }
    self.status.statusID = self.link.lastPathComponent;
    self.status.userID = self.link.stringByDeletingLastPathComponent.lastPathComponent;
    
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
        return 2;
    } else if (section == 2) {
        return 3;
    } else if (section == 3) {
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
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"infoCell"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"infoCell"];
        }
        
        if (indexPath.row == 0) {
            cell.textLabel.text = @"微博ID";
            cell.detailTextLabel.text = self.status.statusID;
        } else if (indexPath.row == 1) {
            cell.textLabel.text = @"微博用户ID";
            cell.detailTextLabel.text = self.status.userID;
        }
        
        return cell;
    } else if (indexPath.section == 2) {
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
                cell.textViewText = self.status.initialText;
            } else {
                cell.textViewText = self.status.folderName;
            }
            
            return cell;
        }
    } else if (indexPath.section == 3) {
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
    if (indexPath.section == 2) {
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
            if (!cell.textViewText.isNotEmpty) {
                [SVProgressHUD showInfoWithStatus:@"请输入微博内容"];
                return;
            }
            
            self.status.initialText = cell.textViewText;
            
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
        }
    }
}

#pragma mark - PHPickerViewControllerDelegate
- (void)picker:(PHPickerViewController *)picker didFinishPicking:(NSArray<PHPickerResult *> *)results {
    BOOL isImage = [picker.configuration.filter isEqual:[PHPickerFilter imagesFilter]];
    BOOL isVideo = [picker.configuration.filter isEqual:[PHPickerFilter videosFilter]];
    BOOL isLivePhoto = [picker.configuration.filter isEqual:[PHPickerFilter livePhotosFilter]];
    
    NSInteger filePathsCount = self.filePaths.count; // 如果多次加图片，那么图片名称可能重复，因为把Index带进去生成名字的，所以Index需要不重复
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    if (isImage) {
        for (NSInteger i = 0; i < results.count; i++) {
            @weakify(self);
            PHPickerResult *result = results[i];
            [result.itemProvider loadItemForTypeIdentifier:(NSString *)kUTTypeImage options:nil completionHandler:^(NSData *data, NSError *error) {
                // 尽量遵循原图片尺寸、格式
                if (data) {
                    @strongify(self);
                    [self processImageData:data atIndex:i];
                } else if (error.code == -1000 || error.code == -1200) {
                    [result.itemProvider loadObjectOfClass:[UIImage class] completionHandler:^(__kindof id<NSItemProviderReading>  _Nullable object, NSError * _Nullable error) {
                        if ([object isKindOfClass:[UIImage class]]) {
                            @strongify(self);
                            [self processImageData:UIImageJPEGRepresentation((UIImage *)object, 0.95f) atIndex:filePathsCount + i];
                        }
                    }];
                    
//                    // -1200 的错误出现意味着，转换成Data失败，需要直接显示成Image
//                    [result.itemProvider loadItemForTypeIdentifier:(NSString *)kUTTypeImage options:nil completionHandler:^(UIImage *image, NSError *error) {}];
                } else {
                    [SVProgressHUD showInfoWithStatus:@"图片读取失败，请重试一次。若依然失败，请分批添加"];
                }
            }];
        }
    }
    
    if (isVideo) {
        for (NSInteger i = 0; i < results.count; i++) {
            @weakify(self);
            PHPickerResult *result = results[i];
            if ([result.itemProvider hasItemConformingToTypeIdentifier:@"public.mpeg-4"]) {
                [result.itemProvider loadFileRepresentationForTypeIdentifier:@"public.mpeg-4" completionHandler:^(NSURL * _Nullable url, NSError * _Nullable error) {
                    @strongify(self);
                    [self processVideoURL:url atIndex:filePathsCount + i];
                }];
            }
        }
    }
    
    if (isLivePhoto) {
        for (NSInteger i = 0; i < results.count; i++) {
            @weakify(self);
            PHPickerResult *result = results[i];
            [result.itemProvider loadObjectOfClass:[PHLivePhoto class] completionHandler:^(__kindof id<NSItemProviderReading>  _Nullable object, NSError * _Nullable error) {
                if ([object isKindOfClass:[PHLivePhoto class]]) {
                    @strongify(self);
                    [self processLivePhoto:(PHLivePhoto *)object atIndex:filePathsCount + i];
                }
            }];
        }
    }
}

#pragma mark - File Processes
- (void)processImageData:(NSData *)data atIndex:(NSInteger)index {
    NSString *fileNameSuffix = [NSString stringWithFormat:@"%@ %ld", self.tempFolderPath, index];
    NSString *fileNameAndExt = [NSString stringWithFormat:@"%@%@.%@", self.tempFolderPath.md5String.md5Middle, fileNameSuffix.md5String.md5Middle, [self extensionForImageData:data]];
    NSString *imageFilePath = [self.tempFolderPath stringByAppendingPathComponent:fileNameAndExt];
//    NSLog(@"imageFilePath: %@", imageFilePath);
    
    [data writeToFile:imageFilePath atomically:YES];
    
    self.filePaths = [self.filePaths arrayByAddingObject:imageFilePath];
    self.headers = @[@"链接", @"信息", @"文字", [NSString stringWithFormat:@"资源(%ld)(%@)", self.filePaths.count, [RBFileManager folderSizeDescriptionAtPath:self.tempFolderPath]]];
    
    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self);
        [self.tableView reloadData];
    });
}
- (void)processVideoURL:(NSURL *)fileURL atIndex:(NSInteger)index {
    NSString *fileNameSuffix = [NSString stringWithFormat:@"%@ %ld", self.tempFolderPath, index];
    NSString *fileNameAndExt = [NSString stringWithFormat:@"%@%@.mp4", self.tempFolderPath.md5String.md5Middle, fileNameSuffix.md5String.md5Middle];
    NSString *videoFilePath = [self.tempFolderPath stringByAppendingPathComponent:fileNameAndExt];
    
    NSString *originFilePath = [fileURL.absoluteString stringByReplacingOccurrencesOfString:@"file://" withString:@""];
    [RBFileManager copyItemFromPath:originFilePath toPath:videoFilePath];
    
    self.filePaths = [self.filePaths arrayByAddingObject:videoFilePath];
    self.headers = @[@"链接", @"信息", @"文字", [NSString stringWithFormat:@"资源(%ld)(%@)", self.filePaths.count, [RBFileManager folderSizeDescriptionAtPath:self.tempFolderPath]]];
    
    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self);
        [self.tableView reloadData];
    });
}
- (void)processLivePhoto:(PHLivePhoto *)livePhoto atIndex:(NSInteger)index {
    // 只存视频
    NSArray<PHAssetResource *> *assetResources = [PHAssetResource assetResourcesForLivePhoto:livePhoto];
    NSArray<PHAssetResource *> *videoResources = [assetResources filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"%K = %@", @"type", @(PHAssetResourceTypePairedVideo)]];
    if (videoResources.count > 0) {
        NSString *fileNameSuffix = [NSString stringWithFormat:@"%@ %ld", self.tempFolderPath, index];
        NSString *fileNameAndExt = [NSString stringWithFormat:@"%@%@.mov", self.tempFolderPath.md5String.md5Middle, fileNameSuffix.md5String.md5Middle];
        NSString *filePath = [self.tempFolderPath stringByAppendingPathComponent:fileNameAndExt];
        [self _saveAssetResource:videoResources.firstObject toFilePath:filePath];
    }
}
- (void)_saveAssetResource:(PHAssetResource *)assetResource toFilePath:(NSString *)filePath {
    @weakify(self);
    [[PHAssetResourceManager defaultManager] writeDataForAssetResource:assetResource toFile:[NSURL fileURLWithPath:filePath] options:nil completionHandler:^(NSError * _Nullable error) {
        if (!error) {
            @strongify(self);
            
            self.filePaths = [self.filePaths arrayByAddingObject:filePath];
            self.headers = @[@"链接", @"信息", @"文字", [NSString stringWithFormat:@"资源(%ld)(%@)", self.filePaths.count, [RBFileManager folderSizeDescriptionAtPath:self.tempFolderPath]]];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                @strongify(self);
                [self.tableView reloadData];
            });
        } else {
            [SVProgressHUD showInfoWithStatus:@"读取LivePhoto出错，请重试"];
        }
    }];
}

#pragma mark - Tools
- (NSString *)extensionForImageData:(NSData *)data {
    uint8_t c;
    [data getBytes:&c length:1];

    switch (c) {
        case 0xFF:
            return @"jpeg";
        case 0x89:
            return @"png";
        case 0x47:
            return @"gif";
        case 0x49:
        case 0x4D:
            return @"tiff";
    }
    
    return @"jpeg";
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
- (void)livePhotoBarButtonItemPressed:(UIBarButtonItem *)sender {
    PHPickerConfiguration *config = [[PHPickerConfiguration alloc] init];
    config.selectionLimit = 18;
    config.filter = [PHPickerFilter livePhotosFilter];

    PHPickerViewController *pickerViewController = [[PHPickerViewController alloc] initWithConfiguration:config];
    pickerViewController.delegate = self;
    [self presentViewController:pickerViewController animated:YES completion:nil];
}
- (void)doneBarButtonItemPressed:(UIBarButtonItem *)sender {
    if (self.status.folderName.length == 0) {
        [SVProgressHUD showInfoWithStatus:@"需要文件夹名"];
        return;
    }
    if (self.filePaths.count == 0) {
        [SVProgressHUD showInfoWithStatus:@"需要选择图片"];
        return;
    }
    
    // 移动文件到对应的文件夹中
    NSString *rootFolderPath = [[RBSettingManager defaultManager] pathOfContentInDocumentFolder:RBShareImagesFolderName];
    NSString *folderPath = [rootFolderPath stringByAppendingPathComponent:self.status.folderName];
    [RBFileManager createFolderAtPath:folderPath];
    for (NSInteger i = 0; i < self.filePaths.count; i++) {
        NSString *originFilePath = self.filePaths[i];
        NSString *targetFilePath = [folderPath stringByAppendingPathComponent:originFilePath.lastPathComponent];
        
        [RBFileManager moveItemFromPath:originFilePath toPath:targetFilePath];
    }
    // 赋值imageUrls
    self.status.imageUrls = self.filePaths;
    // 写入数据库
    [[RBSQLiteManager defaultManager] insertWeiboStatuses:@[self.status]];
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
