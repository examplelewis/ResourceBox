//
//  RBShareImageImportStatusTableViewCell.h
//  ResourceBox
//
//  Created by 龚宇 on 2021/6/6.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RBShareImageImportStatusTableViewCell : UITableViewCell

@property (nonatomic, assign) BOOL canEditTextView;
@property (nonatomic, strong) NSString *textViewText;

@end

NS_ASSUME_NONNULL_END
