//
//  RBWeiboStatus.m
//  ResourceBox
//
//  Created by 龚宇 on 2021/6/6.
//

#import "RBWeiboStatus.h"

@interface RBWeiboStatus ()

@property(nonatomic, copy) NSString *initialDateString;

@property (nonatomic, copy) NSArray<NSString *> *links;
@property (nonatomic, copy) NSString *noLinkText; // 没有链接的Text
@property (nonatomic, copy) NSString *noEmojiText; // 没有Emoji的Text
@property (nonatomic, copy) NSString *noUsernameText; // 没有Username的Text
@property (nonatomic, assign) BOOL hasUsername;
@property (nonatomic, copy) NSArray<NSString *> *tags;
@property (nonatomic, copy) NSString *noTagText; // 没有标签的Text

@end

@implementation RBWeiboStatus

#pragma mark - Configure
- (void)setupData {
    self.initialDateString = [[NSDate date] stringWithFormat:RBTimeFormatyMdHmsSCompact];
    
    self.links = @[];
    self.tags = @[];
}

#pragma mark - Depart
- (void)departText {
    self.noLinkText = self.initialText.copy;
    [self departLinks];
    
    self.noEmojiText = self.noLinkText.copy;
    [self departEmojis];
    
    self.noUsernameText = self.noEmojiText.copy;
    [self departUsername];
    
    self.noTagText = self.noUsernameText.copy;
    [self departTags];
}
/// 去除文字中的链接
- (void)departLinks {
    NSError *error = nil;
    NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:&error];
    NSArray<NSTextCheckingResult *> *results = [detector matchesInString:self.initialText options:0 range:NSMakeRange(0, self.initialText.length)];
    NSArray<NSDictionary *> *linkInfos = [results bk_map:^NSDictionary *(NSTextCheckingResult *obj) {
        return @{@"location": @(obj.range.location), @"result": obj};
    }];
    linkInfos = [linkInfos sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"location" ascending:NO]]]; // 根据locatio降序排列
    
    // 移除链接文字
    for (NSInteger i = 0; i < linkInfos.count; i++) {
        NSDictionary *linkInfo = linkInfos[i];
        NSTextCheckingResult *linkResult = linkInfo[@"result"];
        
        self.links = [self.links arrayByAddingObject:[self.noLinkText substringWithRange:linkResult.range]];
        self.noLinkText = [self.noLinkText stringByReplacingCharactersInRange:linkResult.range withString:@" "];
    }
}
/// 去除Emoji
- (void)departEmojis {
    self.noEmojiText = [self.noEmojiText removeEmoji];
}
/// 分离Username
- (void)departUsername {
    NSError *error;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"@[\\S]+:" options:NSRegularExpressionCaseInsensitive error:&error];
    NSArray *results = [regex matchesInString:self.noUsernameText options:0 range:NSMakeRange(0, self.noUsernameText.length)];
    if (results.count == 0) {
        self.hasUsername = NO;
        self.username = @"[未找到用户名]";
        return;
    }
    
    // 此时username包含@和:
    NSString *username = [self.noUsernameText substringWithRange:((NSTextCheckingResult *)results[0]).range];
    if (username.length <= 2) {
        self.hasUsername = NO;
        self.username = @"[未找到用户名]";
        return;
    }
    
    self.hasUsername = YES;
    self.username = [username substringWithRange:NSMakeRange(1, username.length - 2)];
    
    self.noUsernameText = [self.noUsernameText substringFromIndex:username.length];
    // 去除字符串前和字符串后的空格
    if ([self.noUsernameText hasPrefix:@" "]) {
        self.noUsernameText = [self.noUsernameText substringFromIndex:1];
    }
    if ([self.noUsernameText hasSuffix:@" "]) {
        self.noUsernameText = [self.noUsernameText substringToIndex:self.noUsernameText.length - 1];
    }
}
/// 分离标签
- (void)departTags {
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"#[^#]+#" options:NSRegularExpressionCaseInsensitive error:&error];
    NSArray<NSTextCheckingResult *> *results = [regex matchesInString:self.noTagText options:0 range:NSMakeRange(0, self.noTagText.length)];
    NSArray<NSDictionary *> *tagInfos = [results bk_map:^NSDictionary *(NSTextCheckingResult *obj) {
        return @{@"location": @(obj.range.location), @"result": obj};
    }];
    tagInfos = [tagInfos sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"location" ascending:NO]]]; // 根据locatio降序排列
    
    // 移除标签文字
    for (NSInteger i = 0; i < tagInfos.count; i++) {
        NSDictionary *tagInfo = tagInfos[i];
        NSTextCheckingResult *tagResult = tagInfo[@"result"];
        
        // 此时tag包含前后两个#
        NSString *tag = [self.noTagText substringWithRange:tagResult.range];
        if (tag.length <= 2) {
            continue;
        }
        
        self.tags = [self.tags arrayByAddingObject:[tag substringWithRange:NSMakeRange(1, tag.length - 2)]];
        self.noTagText = [self.noTagText stringByReplacingCharactersInRange:tagResult.range withString:@" "];
    }
}
/// 生成文件夹名
- (void)generateFolderName {
    // 1、先添加用户昵称
    self.folderName = [NSString stringWithFormat:@"%@+", self.username];

    // 2、添加标签以及文字
    if (self.tags.count == 0) {
        // 2.1、没有标签的话，截取前100个文字
        if (self.noTagText.length <= 100) {
            self.folderName = [self.folderName stringByAppendingFormat:@"[无标签]+%@+", self.noTagText];
        } else {
            self.folderName = [self.folderName stringByAppendingFormat:@"[无标签]+%@+", [self.noTagText substringToIndex:100]];
        }
    } else {
        // 2.2.1、有标签的话，先添加所有标签
        self.folderName = [self.folderName stringByAppendingFormat:@"%@+", [self.tags componentsJoinedByString:@"+"]];
        
        // 2.2.2、再添加前100个文字
        if (self.noTagText.length <= 100) {
            self.folderName = [self.folderName stringByAppendingFormat:@"%@+", self.noTagText];
        } else {
            self.folderName = [self.folderName stringByAppendingFormat:@"%@+", [self.noTagText substringToIndex:100]];
        }
    }

    // 3、添加微博发布时间
    self.folderName = [self.folderName stringByAppendingFormat:@"%@", self.initialDateString];

    // 4、防止有 OneDrive 禁止出现的字符
    self.folderName = [self.folderName stringByReplacingOccurrencesOfString:@"*" withString:@" "];
    self.folderName = [self.folderName stringByReplacingOccurrencesOfString:@"?" withString:@" "];
    self.folderName = [self.folderName stringByReplacingOccurrencesOfString:@"\\" withString:@" "];
    self.folderName = [self.folderName stringByReplacingOccurrencesOfString:@"\"" withString:@" "];
    self.folderName = [self.folderName stringByReplacingOccurrencesOfString:@"“" withString:@" "];
    self.folderName = [self.folderName stringByReplacingOccurrencesOfString:@"”" withString:@" "];
    self.folderName = [self.folderName stringByReplacingOccurrencesOfString:@"<" withString:@" "];
    self.folderName = [self.folderName stringByReplacingOccurrencesOfString:@">" withString:@" "];
    self.folderName = [self.folderName stringByReplacingOccurrencesOfString:@"|" withString:@" "];
    self.folderName = [self.folderName stringByReplacingOccurrencesOfString:@"/" withString:@" "];
    self.folderName = [self.folderName stringByReplacingOccurrencesOfString:@":" withString:@" "];
    self.folderName = [self.folderName stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
    
    // 5、防止出现 特殊字符
    self.folderName = [self.folderName stringByReplacingOccurrencesOfString:@"🪆" withString:@" "];
    self.folderName = [self.folderName stringByReplacingOccurrencesOfString:@"🪝" withString:@" "];
    self.folderName = [self.folderName stringByReplacingOccurrencesOfString:@"🪰" withString:@" "];
    self.folderName = [self.folderName stringByReplacingOccurrencesOfString:@"🧛‍♀️" withString:@" "];
    self.folderName = [self.folderName stringByReplacingOccurrencesOfString:@"⭐" withString:@" "];
    
    // 6、长度超过100的文件夹无法保存在Synology NAS中，因此截取超过100长度的文件夹名称
    if (self.folderName.length >= 98) {
        NSString *timeString = [self.folderName substringFromIndex:self.folderName.length - 17];
        self.folderName = [self.folderName substringToIndex:self.folderName.length - 18];
        self.folderName = [self.folderName substringToIndex:79];
        self.folderName = [self.folderName stringByAppendingFormat:@"+%@", timeString];
    }
}

#pragma mark - Setter
- (void)setInitialText:(NSString *)initialText {
    _initialText = initialText.copy;
    
    [self setupData];
    [self departText];
    [self generateFolderName];
}
- (void)setStatusID:(NSString *)statusID {
    _statusID = statusID.copy;
    
    if ([self.statusID integerValue] == 0) {
        _statusID = @"0";
    }
}
- (void)setUserID:(NSString *)userID {
    _userID = userID.copy;
    
    if ([self.userID integerValue] == 0) {
        _userID = @"0";
    }
}

@end
