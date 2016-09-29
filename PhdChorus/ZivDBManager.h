//
//  ZivDBManager.h
//  PhdChorusCommunity
//
//  Created by 梁志鹏 on 16/9/21.
//  Copyright © 2016年 PhdChorus. All rights reserved.
//

#import <Foundation/Foundation.h>

// 以下是attendance_table中的键
#define ATTENDANCE_TABLE_NAME @"attendance_table_name"
#define ATTENDANCE_TABLE_ATTENDANCE_LIST @"attendance_list"
#define ATTENDANCE_TABLE_ASK_FOR_LEAVE_LIST @"ask_for_leave_list"
#define ATTENDANCE_TABLE_IS_FORMAL_ATTENDANCE @"is_formal_attendance"
#define ATTENDANCE_TABLE_DATE @"table_date"

#define MEMBER_INFO_KEY_NAME @"name"
#define MEMBER_INFO_KEY_STAGE @"stage"
#define MEMBER_INFO_KEY_ZONE @"zone"

static  NSString * _Nonnull yanqi_zone = @"雁栖湖";
static NSString * _Nonnull zhongguancun_zon = @"中关村";

@interface ZivDBManager : NSObject

@property (nonatomic, nonnull, strong, readonly) NSMutableDictionary *register_record_db;
@property (nonatomic, nonnull, strong, readonly) NSMutableDictionary *ask_for_leave_db;
@property (nonatomic, nonnull, strong, readonly) NSMutableDictionary *member_info_db;
@property (nonatomic, nonnull, strong, readonly) NSArray *partList;
@property (nonatomic, nonnull, strong, readonly) NSArray *zoneList;


+ (nonnull ZivDBManager *)shareDatabaseManager;


- (BOOL)createAttendanceTable:(nonnull NSString *)attendanceTableName inDate:(nonnull NSString *)attendanceTableDate withDescription:(BOOL)isFormalAttendance;
- (nonnull NSArray<NSString *> *)attendanceTableList;

- (BOOL)attendAt:(nonnull NSString *)attendanceTableName inPart:(nonnull NSString *)part withName:(nonnull NSString *)name;
- (BOOL)askForLeaveInAttendanceTable:(nonnull  NSString *)date Part:(nonnull NSString *)part Name:(nonnull NSString *)name Reason:(nonnull NSString *)reason;


- (NSInteger)numberOfMemberInPart:(nonnull NSString *)part;
- (nonnull NSArray *)partList;
- (nonnull NSDictionary *)member_info;
// name－姓名 part－声部 stage-届数 zone-所在园区
- (BOOL)registerName:(nonnull NSString *)name toPart:(nonnull NSString *)part withStage:(nonnull NSString *)stage andZone:(nonnull NSString *)zone;

- (BOOL)nameExist:(nonnull NSString *)name inPart:(nonnull NSString *)part;
- (BOOL)deleteMemberInfo:(nonnull NSString *)name fromPart:(nonnull NSString *)part;

- (nonnull NSDictionary *)attendanceTableByName:(nonnull NSString *)attendanceTableName;
- (nullable NSURL *)publicUrlForAttendanceTable:(nonnull NSString *)attendanceTableName;
- (void)saveFile;

- (BOOL)mergeAttendanceTableToLocalDatabase:(nonnull NSData *)attendanceTableData;

- (BOOL)removeName:(nonnull NSArray *)nameList inPart:(nonnull NSString *)part FromAttendanceTable:(nonnull NSString *)attendanceTableName;

@end
