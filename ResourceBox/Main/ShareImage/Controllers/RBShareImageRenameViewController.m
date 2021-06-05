//
//  RBShareImageRenameViewController.m
//  ResourceBox
//
//  Created by 龚宇 on 21/02/10.
//

#import "RBShareImageRenameViewController.h"

#import "RBShareTextModel.h"

@interface RBShareImageRenameViewController () <UITextViewDelegate>

@property (strong, nonatomic) IBOutlet UITextView *textView;
@property (strong, nonatomic) IBOutlet UILabel *label;

@property (nonatomic, copy) NSString *input;
@property (nonatomic, copy) NSString *output;

@end

@implementation RBShareImageRenameViewController

#pragma mark - Lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUIAndData];
    
    [self generate];
}

#pragma mark - Configure
- (void)setupUIAndData {
    // Data
    self.input = [UIPasteboard generalPasteboard].string;
    
    // UI
    self.textView.text = self.input;
}

#pragma mark - Generate
- (void)generate {
    self.output = [RBShareTextModel folderNameWithText:self.input];
    self.label.text = self.output;
}

#pragma mark - Action
- (IBAction)actionButtonDidPress:(UIButton *)sender {
    [self generate];
}
- (IBAction)confirmButtonDidPress:(UIButton *)sender {
    if ([self.output isEqualToString:@""]) {
        [SVProgressHUD showInfoWithStatus:@"输入内容有变更，请点击结果按钮"];
        return;
    }
    
    if ([self.delegate respondsToSelector:@selector(didConfirmNewFolderName:index:)]) {
        [self.delegate didConfirmNewFolderName:[self.output copy] index:self.index];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}
- (IBAction)jumpButtonDidPress:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:RBShareImageNeedShowImageFilesNotification object:@(self.index)];
    }];
}

#pragma mark - UITextViewDelegate
- (void)textViewDidChange:(UITextView *)textView { // 在该代理方法中实现实时监听uitextview的输入
    self.input = textView.text;
    
    self.output = @"";
    self.label.text = @"输入内容有变更，请点击结果按钮";

}

@end
