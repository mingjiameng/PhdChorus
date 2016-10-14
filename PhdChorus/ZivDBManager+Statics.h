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

// 蓝色字－声部名（T1、T2） 黑色字－中关村 灰色字－雁栖湖 字号－14
- (nonnull NSAttributedString *)part:(nonnull NSString *)part attendanceNameListInAttendanceTable:(nonnull NSString *)tableName;
- (nonnull NSAttributedString *)part:(nonnull NSString *)part askForLeaveNameListInAttendanceTable:(nonnull NSString *)tableName;
- (nonnull NSAttributedString *)part:(nonnull NSString *)part absenceNameListInAttendanceTable:(nonnull NSString *)tableName;

- (nullable NSString *)exportAttendanceTableOfPart:(nonnull NSString *)part from:(nonnull NSString *)startTime to:(nonnull NSString *)endTime;




- (nullable NSArray <NSString *> *)part:(nonnull NSString *)part attendanceStaticByName:(nonnull NSString *)name from:(nonnull NSString *)startTime to:(nonnull NSString *)endTime;
- (nullable NSArray <NSString *> *)part:(nonnull NSString *)part last3WeekAttendanceStaticByName:(nonnull NSString *)name;

@end
