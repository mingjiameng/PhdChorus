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
#define ATTENDANCE_TABLE_ZONE @"table_zone"
#define ATTENDANCE_TABLE_WEEKDAY @"table_weekday"
#define ATTENDANCE_TABLE_TYPE @"table_type"

#define MEMBER_INFO_KEY_NAME @"name"
#define MEMBER_INFO_KEY_STAGE @"stage"
#define MEMBER_INFO_KEY_ZONE @"zone"

static NSString * _Nonnull ZivAttendanceZoneIdentifireYanqi = @"雁栖湖";
static NSString * _Nonnull ZivAttendanceZoneIdentifireZhongguancun = @"中关村";

static NSString * _Nonnull ZivChorusPartS = @"S";
static NSString * _Nonnull ZivChorusPartA = @"A";
static NSString * _Nonnull ZivChorusPartT = @"T";
static NSString * _Nonnull ZivChorusPartB = @"B";

static NSString * _Nonnull ZivAttendanceTypeDapai = @"大排";
static NSString * _Nonnull ZivAttendanceTypeXiaopai = @"小排";
static NSString * _Nonnull ZivAttendanceTypeShengyueke = @"声乐课";
static NSString * _Nonnull ZivAttendanceTypeZhouriwan = @"周日晚";

@interface ZivDBManager : NSObject

@property (nonatomic, nonnull, strong, readonly) NSMutableDictionary *member_info_db;

+ (nonnull ZivDBManager *)shareDatabaseManager;


- (BOOL)createAttendanceTableInDate:(nonnull NSString *)date atZone:(nonnull NSString *)zone withType:(nonnull NSString *)type;
- (BOOL)editAttendanceTable:(nonnull NSString *)oldAttendanceTableName inDate:(nonnull NSString *)date atZone:(nonnull NSString *)zone withType:(nonnull NSString *)type;
- (nonnull NSArray<NSString *> *)attendanceTableList;

- (BOOL)attendanceTable:(nonnull NSString *)attendanceTableName someoneSignUp:(nonnull NSString *)name inPart:(nonnull NSString *)part;
- (BOOL)attendanceTable:(nonnull NSString *)attendanceTableName someoneAskForLeve:(nonnull NSString *)name inPart:(nonnull NSString *)part;
- (BOOL)attendanceTable:(nonnull NSString *)attendanceTableName setSomeoneAbsent:(nonnull NSString *)name inPart:(nonnull NSString *)part;

- (NSInteger)numberOfMemberInPart:(nonnull NSString *)part;
- (nonnull NSArray *)partList;
- (nonnull NSArray *)satbPartList;
- (nonnull NSDictionary *)member_info;
- (nullable NSArray*)memberNameListOfPart:(nonnull NSString *)part;
- (nonnull NSArray *)zoneList;
- (nonnull NSArray *)attendanceTypeList;
- (nullable NSString *)personalInfoDescriptionOfMember:(nonnull NSString *)name inPart:(nonnull NSString *)part;

// name－姓名 part－声部 stage-届数 zone-所在园区
- (BOOL)registerName:(nonnull NSString *)name toPart:(nonnull NSString *)part withStage:(nonnull NSString *)stage andZone:(nonnull NSString *)zone;

- (BOOL)nameExist:(nonnull NSString *)name inPart:(nonnull NSString *)part;
- (BOOL)deleteMemberInfo:(nonnull NSString *)name fromPart:(nonnull NSString *)part;

- (nonnull NSDictionary *)attendanceTableByName:(nonnull NSString *)attendanceTableName;
- (nullable NSURL *)publicUrlForAttendanceTable:(nonnull NSString *)attendanceTableName;
- (void)saveFile;

- (BOOL)mergeAttendanceTableToLocalDatabase:(nonnull NSData *)attendanceTableData;

- (BOOL)removeName:(nonnull NSArray *)nameList inPart:(nonnull NSString *)part FromAttendanceTable:(nonnull NSString *)attendanceTableName;
- (BOOL)deleteAttendanceTable:(nonnull NSString *)attendanceTableName;

- (void)updateDatabaseVersion;
- (nonnull NSString *)shareAttendanceTable:(nonnull NSArray *)attendancetableNameArray;

@end
