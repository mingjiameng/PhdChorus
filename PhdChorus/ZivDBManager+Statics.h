//
//  ZivDBManager+Statics.h
//  PhdChorusCommunity
//
//  Created by 梁志鹏 on 16/9/23.
//  Copyright © 2016年 PhdChorus. All rights reserved.
//

#import "ZivDBManager.h"

@interface ZivDBManager (Statics)

// part = S | A | T | B
- (void)part:(nonnull NSString *)part memberCountOfHighPart:(nonnull NSInteger *)highPartCount andLowPart:(nonnull NSInteger *)lowPartCount;
- (void)part:(nonnull NSString *)part memberCountOfZhongguancun:(nonnull NSInteger *)zhongguancunCount andYanqi:(nonnull NSInteger *)yanqiCount;
- (void)part:(nonnull NSString *)part absenceCountOfHighPart:(nonnull NSInteger *)highPartCount andLowPart:(nonnull NSInteger *)lowPartCount inAttendanceTable:(nonnull NSString *)tableName;
- (void)part:(nonnull NSString *)part attendanceCountOfHighPart:(nonnull NSInteger *)highPartCount andLowPart:(nonnull NSInteger *)lowPartCount inAttendanceTable:(nonnull NSString *)tableName;
- (void)part:(nonnull NSString *)part attendanceCountOfZhongguancun:(nonnull NSInteger *)zhongguancunCount andYanqi:(nonnull NSInteger *)yanqiCount inAttendanceTable:(nonnull NSString *)tableName;

- (nullable NSString *)exportAttendanceTableOfPart:(nonnull NSString *)part from:(nonnull NSString *)startTime to:(nonnull NSString *)endTime;

@end
