//
//  RBShareViewController.m
//  RBShareExtension
//
//  Created by 龚宇 on 21/02/04.
//

#import "RBShareViewController.h"

#import <MobileCoreServices/MobileCoreServices.h>
#import "RBShareTextModel.h"

static NSInteger const maxTimerCountDown = 30;

@interface RBShareViewController ()

@property (nonatomic, copy) NSArray *imageFilePaths;
@property (nonatomic, copy) NSString *text;
@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, assign) NSInteger loadCount;
@property (nonatomic, assign) BOOL loadSuccess;

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) NSInteger countDown;

@property (strong, nonatomic) IBOutlet UIButton *closeButton;

@property (strong, nonatomic) IBOutlet UIView *contentView;
@property (strong, nonatomic) IBOutlet UITextView *statusTextView;
@property (strong, nonatomic) IBOutlet UILabel *imageNumsLabel;

@property (strong, nonatomic) IBOutlet UIView *waitingView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *indicator;
@property (strong, nonatomic) IBOutlet UILabel *waitingLabel;

@end

@implementation RBShareViewController

#pragma mark - Lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUIAndData];
    
    @weakify(self);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @strongify(self);
        [self readItemsAtIndex:0];
    });
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.indicator startAnimating];
    [self startTimer];
}

#pragma mark - Configure
- (void)setupUIAndData {
    // UI
    self.contentView.hidden = YES;
    self.waitingView.hidden = NO;
    
    // Data
    self.imageFilePaths = @[];
    self.loadCount = 0;
    self.startDate = [NSDate date];
    
    [RBFileManager createFolderAtPath:[RBFileManager shareExtensionShareImagesGroupContainerFolderPath]];
}

#pragma mark - Read
- (void)readItemsAtIndex:(NSInteger)index {
    NSExtensionItem *item = (NSExtensionItem *)self.extensionContext.inputItems.firstObject;
    if (index >= item.attachments.count) {
        [self finishReadItems];
        return;
    }
    
    NSItemProvider *provider = (NSItemProvider *)item.attachments[index];
//    NSLog(@"%@", provider.registeredTypeIdentifiers);
    
    @weakify(self);
    if ([provider hasItemConformingToTypeIdentifier:@"public.plain-text"]) {
        [provider loadItemForTypeIdentifier:@"public.plain-text" options:nil completionHandler:^(NSString *text, NSError *error) {
            @strongify(self);
            
            self.text = text;
            [self readItemsAtIndex:index + 1];
        }];
    }
    if ([provider hasItemConformingToTypeIdentifier:@"public.image"]) {
        // 尽量遵循原图片尺寸、格式
        [provider loadItemForTypeIdentifier:(NSString *)kUTTypeImage options:nil completionHandler:^(NSData *data, NSError *error) {
            if (data) {
                @strongify(self);
                
                [self processData:data atIndex:index];
                
                // 经试验暂时不需要延迟
                // 手动等待0.5秒，等data释放了之后再进行下一次操作，减少因为内存消耗超过120MB而Crash的可能
                // [NSThread sleepForTimeInterval:0.5f];
                
                [self readItemsAtIndex:index + 1];
            } else if (error.code == -1200) {
                // -1200 的错误出现意味着，转换成Data失败，需要直接显示成Image
                [provider loadItemForTypeIdentifier:(NSString *)kUTTypeImage options:nil completionHandler:^(UIImage *image, NSError *error) {
                    @strongify(self);
                    
                    if (image) {
                        [self processData:UIImageJPEGRepresentation(image, 0.95f) atIndex:index];
                    }
                    
                    // 经试验暂时不需要延迟
                    // 手动等待0.5秒，等data释放了之后再进行下一次操作，减少因为内存消耗超过120MB而Crash的可能
                    // [NSThread sleepForTimeInterval:0.5f];
                    
                    [self readItemsAtIndex:index + 1];
                }];
            } else {
                [self readItemsAtIndex:index + 1];
            }
        }];
    }
    if ([provider hasItemConformingToTypeIdentifier:@"public.url"]) {
        [self readItemsAtIndex:index + 1];
    }
}
- (void)processData:(NSData *)data atIndex:(NSInteger)index {
    NSString *fileNamePrefix = [NSString stringWithFormat:@"%@", self.startDate];
    NSString *fileNameSuffix = [NSString stringWithFormat:@"%@", [self.startDate dateByAddingTimeInterval:index + 100]];
    NSString *fileNameAndExt = [NSString stringWithFormat:@"%@%@.%@", fileNamePrefix.md5String.md5Middle, fileNameSuffix.md5String.md5Middle, [self extensionForImageData:data]];
    
    NSString *imageFilePath = [RBFileManager shareExtensionFilePathForShareImageWithName:fileNameAndExt];
//    NSLog(@"imageFilePath: %@", imageFilePath);
    [data writeToFile:imageFilePath atomically:YES];
    
    self.imageFilePaths = [self.imageFilePaths arrayByAddingObject:imageFilePath];
}
- (void)finishReadItems {
    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self);
        
        [self resetTimer];
        [self stopReading];
        [self processInfo];
    });
}
- (void)stopReading {
    self.loadSuccess = YES;
    
    [self.indicator stopAnimating];
    self.waitingView.hidden = YES;
    self.contentView.hidden = NO;
    
    self.statusTextView.text = self.text;
    self.imageNumsLabel.text = [NSString stringWithFormat:@"%ld 条 items\n%ld 条 itemsProvider\n%d 条 public.plain-text\n%ld 条 public.image", self.extensionContext.inputItems.count, ((NSExtensionItem *)self.extensionContext.inputItems.firstObject).attachments.count, self.text ? 1 : 0, self.imageFilePaths.count];
}

#pragma mark - Process
- (void)processInfo {
    NSString *folderName = [RBShareTextModel folderNameWithText:self.text];
    NSString *folderPath = [[RBFileManager shareExtensionShareImagesGroupContainerFolderPath] stringByAppendingPathComponent:folderName];
    [RBFileManager createFolderAtPath:folderPath];
    
    for (NSInteger i = 0; i < self.imageFilePaths.count; i++) {
        NSString *originPath = self.imageFilePaths[i];
        NSString *destPath = [folderPath stringByAppendingPathComponent:originPath.lastPathComponent];
        [RBFileManager moveItemFromPath:originPath toPath:destPath];
        
        [[RBLogManager defaultManager] addDefaultLogWithFormat:@"移动前: %@", originPath];
        [[RBLogManager defaultManager] addDefaultLogWithFormat:@"移动后: %@", destPath];
    }
    
    self.imageNumsLabel.text = [NSString stringWithFormat:@"%ld 条 items\n%ld 条 itemsProvider\n%d 条 public.plain-text\n%ld 条 public.image\n\n目标文件夹: %@\n\n共移动%ld条图片至目标文件夹", self.extensionContext.inputItems.count, ((NSExtensionItem *)self.extensionContext.inputItems.firstObject).attachments.count, self.text ? 1 : 0, self.imageFilePaths.count, folderName, [RBFileManager filePathsInFolder:folderPath].count];
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

#pragma mark - Timer
- (void)startTimer {
    self.countDown = maxTimerCountDown;
    self.timer = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(timerClicked:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}
- (void)timerClicked:(NSTimer *)sender {
    if (self.countDown < 1) {
        if (!self.loadSuccess) {
            [self resetTimer];
            [self stopReading];
            [self processInfo];
        }
    } else {
        self.countDown -= 1;
        self.waitingLabel.text = [NSString stringWithFormat:@"正在读取，稍等片刻(%02ld)", self.countDown];
    }
}
- (void)resetTimer {
    self.countDown = maxTimerCountDown;
    self.waitingLabel.text = [NSString stringWithFormat:@"正在读取，稍等片刻(%02ld)", self.countDown];
    [self.timer invalidate];
    self.timer = nil;
}

#pragma mark - IBAction
- (IBAction)closeButtonDidPress:(UIButton *)sender {
    [self.extensionContext completeRequestReturningItems:@[] completionHandler:nil];
}

@end
