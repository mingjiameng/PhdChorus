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
- (void)part:(nonnull NSString *)part memberCountOfHighPart:(nonnull int *)highPartCount andLowPart:(nonnull int *)lowPartCount;
- (void)part:(nonnull NSString *)part memberCountOfZhongguancun:(nonnull int *)zhongguancunCount andYanqi:(nonnull int *)yanqiCount;
- (void)part:(nonnull NSString *)part absenceCountOfHighPart:(nonnull int *)highPartCount andLowPart:(nonnull int *)lowPartCount inAttendanceTable:(nonnull NSString *)tableName;
- (void)part:(nonnull NSString *)part attendanceCountOfHighPart:(nonnull int *)highPartCount andLowPart:(nonnull int *)lowPartCount inAttendanceTable:(nonnull NSString *)tableName;
- (void)part:(nonnull NSString *)part attendanceCountOfZhongguancun:(nonnull int *)zhongguancunCount andYanqi:(nonnull int *)yanqiCount inAttendanceTable:(nonnull NSString *)tableName;

- (nullable NSString *)exportAttendanceTableOfPart:(nonnull NSString *)part from:(nonnull NSString *)startTime to:(nonnull NSString *)endTime;

@end
