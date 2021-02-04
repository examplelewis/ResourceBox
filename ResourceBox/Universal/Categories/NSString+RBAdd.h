//
//  NSString+RBAdd.h
//  MyUniqueBox
//
//  Created by 龚宇 on 20/09/13.
//  Copyright © 2020 龚宇. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (RBAdd)

- (BOOL)isNotEmpty;

- (NSString *)md5Middle;
- (NSString *)md5Middle8;

#pragma mark - Export
- (void)exportToPath:(NSString *)path;
- (void)exportToPath:(NSString *)path behavior:(RBFileOpertaionBehavior)behavior;

@end

NS_ASSUME_NONNULL_END
