//
//  ZivDBManager+Statics.h
//  PhdChorusCommunity
//
//  Created by 梁志鹏 on 16/9/23.
//  Copyright © 2016年 PhdChorus. All rights reserved.
//

#import "ZivDBManager.h"

@interface ZivDBManager (Statics)

- (nullable NSString *)exportAttendanceTableOfPart:(nonnull NSString *)part from:(nonnull NSString *)startTime to:(nonnull NSString *)endTime;

@end
