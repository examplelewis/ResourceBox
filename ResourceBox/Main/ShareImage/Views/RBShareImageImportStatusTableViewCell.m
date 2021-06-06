//
//  RBShareImageImportStatusTableViewCell.m
//  ResourceBox
//
//  Created by 龚宇 on 2021/6/6.
//

#import "RBShareImageImportStatusTableViewCell.h"

@interface RBShareImageImportStatusTableViewCell ()

@property (weak, nonatomic) IBOutlet UITextView *textView;

@end

@implementation RBShareImageImportStatusTableViewCell

@synthesize textViewText = _textViewText;

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - Getter
- (NSString *)textViewText {
    _textViewText = self.textView.text;
    
    return _textViewText;
}

#pragma mark - Setter
- (void)setTextViewText:(NSString *)textViewText {
    _textViewText = textViewText;
    
    self.textView.text = textViewText;
}
- (void)setCanEditTextView:(BOOL)canEditTextView {
    _canEditTextView = canEditTextView;
    
    self.textView.editable = canEditTextView;
}

@end
