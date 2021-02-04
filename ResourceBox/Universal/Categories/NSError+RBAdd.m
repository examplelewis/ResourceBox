//
//  NSError+RBAdd.m
//  MyUniqueBox
//
//  Created by 龚宇 on 20/09/26.
//  Copyright © 2020 龚宇. All rights reserved.
//

#import "NSError+RBAdd.h"

@implementation NSError (RBAdd)

- (NSString *)downloadUrl {
    NSString *url = self.userInfo[NSURLErrorFailingURLStringErrorKey];
    if (url.isNotEmpty) {
        return url;
    }
    
    url = self.userInfo[@"NSErrorFailingURLKey"];
    if (url.isNotEmpty) {
        return url;
    }
    
    url = self.userInfo[@"NSErrorFailingURLStringKey"];
    if (url.isNotEmpty) {
        return url;
    }
    
    return @"";
}
- (RBErrorType)downloadErrorType {
    NSLog(@"error code: %ld", self.code);
    if ([self.localizedDescription containsString:@"The network connection was lost."] || [self.localizedDescription containsString:@"The request timed out."]) {
        return RBErrorTypeDownloadConnectionLost;
    } else {
        return RBErrorTypeDownloadOther;
    }
}

@end
