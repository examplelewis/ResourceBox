//
//  RBShareTextModel.m
//  RBShareExtension
//
//  Created by 龚宇 on 21/02/06.
//

#import "RBShareTextModel.h"

@implementation RBShareTextModel

- (instancetype)initWithText:(NSString *)text {
    self = [super init];
    if (self) {
        // 去除文字中的链接
        NSError *linkError = nil;
        NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:&linkError];
        NSArray<NSTextCheckingResult *> *linkResults = [detector matchesInString:text options:0 range:NSMakeRange(0, text.length)];
        NSArray<NSDictionary *> *links = [linkResults bk_map:^NSDictionary *(NSTextCheckingResult *obj) {
            return @{@"location": @(obj.range.location), @"result": obj};
        }];
        // 倒序去处
        links = [links sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"location" ascending:NO]]];
        for (NSInteger i = 0; i < links.count; i++) {
            NSDictionary *linkDict = links[i];
            NSTextCheckingResult *tcResult = linkDict[@"result"];
            text = [text stringByReplacingCharactersInRange:tcResult.range withString:@" "];
        }
        // 去除Emoji
        text = [text removeEmoji];
        
        _userName = @"[未找到用户名]";
        _text = text;
        _dateString = [[NSDate date] stringWithFormat:RBTimeFormatyMdHmsSCompact];
        
        NSError *error;
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"@[\\S]+:" options:NSRegularExpressionCaseInsensitive error:&error];
        NSArray *results = [regex matchesInString:text options:0 range:NSMakeRange(0, text.length)];
        if (results.count > 0) {
            NSString *realText = text; // 可能有转发微博的情况，realText就是不包含转发的文字
            NSTextCheckingResult *lastResult = (NSTextCheckingResult *)results.lastObject;
            if (lastResult.range.location != 0) {
                realText = [text substringFromIndex:lastResult.range.location];
            }
            
            _userName = [text substringWithRange:lastResult.range];
            if (_userName.length > 2) {
                _userName = [_userName substringWithRange:NSMakeRange(1, _userName.length - 2)];
            }
            _text = [realText substringFromIndex:_userName.length + 2];
            if ([_text hasPrefix:@" "]) {
                _text = [_text substringFromIndex:1];
            }
            if ([_text hasSuffix:@" "]) {
                _text = [_text substringToIndex:_text.length - 1];
            }
        }
    }
    
    return self;
}

+ (NSString *)folderNameWithText:(NSString *)text {
    RBShareTextModel *model = [[RBShareTextModel alloc] initWithText:text];
    
    // 1、先添加用户昵称
    NSString *folderName = [NSString stringWithFormat:@"%@+", model.userName];

    // 2、添加标签以及文字
    NSError *atError;
    NSRegularExpression *atRegex = [NSRegularExpression regularExpressionWithPattern:@"#[^#]+#" options:NSRegularExpressionCaseInsensitive error:&atError];
    NSArray *atResults = [atRegex matchesInString:model.text options:0 range:NSMakeRange(0, model.text.length)];
    if (atError) {
        [[RBLogManager defaultManager] addErrorLogWithFormat:@"正则解析微博文字中的标签出错，原因：%@", atError.localizedDescription];
    }
    if (atResults.count == 0) {
        // 2.1、没有标签的话，截取前100个文字
        if (model.text.length <= 100) {
            folderName = [folderName stringByAppendingFormat:@"[无标签]+%@+", model.text];
        } else {
            folderName = [folderName stringByAppendingFormat:@"[无标签]+%@+", [model.text substringToIndex:100]];
        }
    } else {
        // 2.2.1、有标签的话，先添加所有标签
        for (NSInteger i = 0; i < atResults.count; i++) {
            NSTextCheckingResult *result = atResults[i];
            NSString *hashtag = [model.text substringWithRange:result.range];
            hashtag = [hashtag stringByReplacingOccurrencesOfString:@"#" withString:@""];
            folderName = [folderName stringByAppendingFormat:@"%@+", hashtag];
        }

        // 2.2.2、再添加前30个文字
        NSString *noTagText = model.text;
        for (NSInteger i = atResults.count - 1; i >= 0; i--) {
            NSTextCheckingResult *result = atResults[i];
            noTagText = [noTagText stringByReplacingCharactersInRange:result.range withString:@""];
        }
        
        if (noTagText.length <= 30) {
            folderName = [folderName stringByAppendingFormat:@"%@+", noTagText];
        } else {
            folderName = [folderName stringByAppendingFormat:@"%@+", [noTagText substringToIndex:30]];
        }
    }

    // 3、添加微博发布时间
    // 根据微博内容生成文件夹的名称 时没有时间，因此把最后一个加号去掉
    if (model.dateString.isNotEmpty) {
        folderName = [folderName stringByAppendingFormat:@"%@", model.dateString];
    } else {
        folderName = [folderName substringToIndex:folderName.length - 1];
    }

    // 4、防止有 OneDrive禁止出现的字符
    folderName = [folderName stringByReplacingOccurrencesOfString:@"*" withString:@" "];
    folderName = [folderName stringByReplacingOccurrencesOfString:@"?" withString:@" "];
    folderName = [folderName stringByReplacingOccurrencesOfString:@"\\" withString:@" "];
    folderName = [folderName stringByReplacingOccurrencesOfString:@"\"" withString:@" "];
    folderName = [folderName stringByReplacingOccurrencesOfString:@"“" withString:@" "];
    folderName = [folderName stringByReplacingOccurrencesOfString:@"”" withString:@" "];
    folderName = [folderName stringByReplacingOccurrencesOfString:@"<" withString:@" "];
    folderName = [folderName stringByReplacingOccurrencesOfString:@">" withString:@" "];
    folderName = [folderName stringByReplacingOccurrencesOfString:@"|" withString:@" "];
    folderName = [folderName stringByReplacingOccurrencesOfString:@"/" withString:@" "];
    folderName = [folderName stringByReplacingOccurrencesOfString:@":" withString:@" "];
    folderName = [folderName stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
    
    // 5、防止出现 特殊字符
    folderName = [folderName stringByReplacingOccurrencesOfString:@"🪆" withString:@" "];
    folderName = [folderName stringByReplacingOccurrencesOfString:@"🪝" withString:@" "];
    
    // 6、长度超过100的文件夹无法保存在Synology NAS中，因此截取超过100长度的文件夹名称
    if (folderName.length >= 98) {
        NSString *timeString = [folderName substringFromIndex:folderName.length - 17];
        folderName = [folderName substringToIndex:folderName.length - 18];
        folderName = [folderName substringToIndex:79];
        folderName = [folderName stringByAppendingFormat:@"+%@", timeString];
    }

    return folderName;
}

@end
