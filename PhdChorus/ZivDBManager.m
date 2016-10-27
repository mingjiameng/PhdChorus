//
//  ZivDBManager.m
//  PhdChorusCommunity
//
//  Created by 梁志鹏 on 16/9/21.
//  Copyright © 2016年 PhdChorus. All rights reserved.
//


/*
 // 数据库设计——人员信息
 member_info = { @"T1" : { @"江文宇" : { @"name" : @"江文宇"
                                        @"stage" : @"23",
                                        @"zone" : @"中关村" },
 
                           ...
 
                 },
 
                 ...
 }
 */

/*
 // 数据库设计——签到记录
 attendance_table_list = {@"20160913大排", @"20160916小排", ...}
 // 每次签到对应于一个json签到文件，文件后缀为phdrg
    @"20160913大排" : {
        @"table_name" : @"20160921大排", // 签到表名
        @"table_date" : @"20160921" // 签到日期
        @"is_formal_attendance" : @"0", // 是否大排
        @"zone" : @"雁栖湖", // 签到表区域
        @"attendance_type" : @"大排" // 大排、小排、声乐课、周日晚
        @"T2" : { @"attendance_list" : set{@"梁志鹏", ...},
                  @"ask_for_leave_list" : set{@"罗成", ...} },
        ...
    },
    
    ...

*/

#import "ZivDBManager.h"
#import "zkeySandboxHelper.h"
#import "SHARED_MICRO.h"

#define ATTENDANCE_TABLE @"attendance_table"
#define PUBLIC_ATTENDANCE_TABLE_FILE_EXTENSION @"pdf"
#define ATTENDANCE_TABLE_FILE_EXTENSION @"phdrg"

#define ATTENDANCE_RECORD_DB_FILE_NAME @"attendance_record_db.phd"
#define ATTENDANCE_RECORD_TABLE_LIST @"resgister_record_table_list"
#define MEMBER_INFO_DB @"member_info_db"

#define UPDATED_VERSION @"update_to"

@interface ZivDBManager()

@property (nonatomic, nonnull, strong) NSMutableArray *attendance_table_list;
@property (nonatomic, nonnull, strong) NSMutableDictionary *member_info_db;
@property (nonatomic, strong) NSMutableDictionary *currentAttendanceTable;
@property (nonatomic, strong) NSArray *partList;
@property (nonatomic, strong) NSArray *zoneList;
@property (nonatomic, strong) NSArray *attendanceTypeList;

@end



@implementation ZivDBManager

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        [self initializeTheDatabase];
    }
    
    return self;
}


- (void)initializeTheDatabase
{
    NSString *path = [ZivDBManager pathOfDatabaseFile];
    
    if (![zkeySandboxHelper fileExitAtPath:path]) {
        _attendance_table_list = [NSMutableArray array];
        _member_info_db = [NSMutableDictionary dictionary];
        for (NSString *part in self.partList) {
            [_member_info_db setObject:[NSMutableDictionary dictionary] forKey:part];
        }
        
    } else {
        NSMutableData *data = [[NSMutableData alloc] initWithContentsOfFile:path];
        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
        _attendance_table_list = [unarchiver decodeObjectForKey:ATTENDANCE_RECORD_TABLE_LIST];
        _member_info_db = [unarchiver decodeObjectForKey:MEMBER_INFO_DB];
        [unarchiver finishDecoding];
        
    }
    
    return;
}

+ (ZivDBManager *)shareDatabaseManager
{
    static ZivDBManager *dbManager;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        dbManager = [[ZivDBManager alloc] init];
    });
    
    return dbManager;
}

- (BOOL)createAttendanceTableInDate:(NSString *)date atZone:(NSString *)zone withType:(NSString *)type
{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyyMMdd"];
    NSDate *calenderDate = [dateFormat dateFromString:date];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *comps = [calendar components:NSCalendarUnitWeekday fromDate:calenderDate];
    NSString *weekdayString = @"周三";
    // 从周日开始算起 周日＝1
    if (comps.weekday == 1) {
        weekdayString = @"周日";
    } else if (comps.weekday == 7) {
        weekdayString = @"周六";
    } else if (comps.weekday == 4) {
        weekdayString = @"周三";
    }
    
    NSString *attendanceTableName = [NSString stringWithFormat:@"%@%@%@%@", date, weekdayString, zone, type];
    
    NSString *currentTableName = [self getTheNameOfTheCurrentAttendanceTable];
    if (currentTableName != nil && ([currentTableName compare:attendanceTableName] == NSOrderedSame)) {
        return NO;
    }
    
    NSString *path = [self pathOfAttendanceTableFile:attendanceTableName];
    
    NSLog(@"create Attendance table - check whether the table exist:%@", attendanceTableName);
    
    if (![zkeySandboxHelper fileExitAtPath:path]) {
        
        NSLog(@"creating file...");
        
        [self saveCurrentAttendanceTable];
        
        [self.attendance_table_list addObject:attendanceTableName];
        self.currentAttendanceTable = [self newAttendanceTable:attendanceTableName inDate:date andWeekday:weekdayString atZone:zone withType:type];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:REFRESH_ATTENDANCE_TABLE_LIST_NOTIFICATION object:nil];
        
        return YES;
    }
    
    return NO;
}

- (BOOL)editAttendanceTable:(NSString *)oldAttendanceTableName inDate:(NSString *)date atZone:(NSString *)zone withType:(NSString *)type
{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyyMMdd"];
    NSDate *calenderDate = [dateFormat dateFromString:date];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *comps = [calendar components:NSCalendarUnitWeekday fromDate:calenderDate];
    NSString *weekdayString = @"周三";
    // 从周日开始算起 周日＝1
    if (comps.weekday == 1) {
        weekdayString = @"周日";
    } else if (comps.weekday == 7) {
        weekdayString = @"周六";
    } else if (comps.weekday == 4) {
        weekdayString = @"周三";
    }
    
    NSString *attendanceTableName = [NSString stringWithFormat:@"%@%@%@%@", date, weekdayString, zone, type];
    
    if ([attendanceTableName isEqualToString:oldAttendanceTableName]) {
        // 无修改
        return YES;
    }
    
    NSInteger index = 0;
    for (index = 0; index < self.attendance_table_list.count; ++index) {
        NSString *tableName = [self.attendance_table_list objectAtIndex:index];
        if ([tableName isEqualToString:attendanceTableName]) {
            // 签到表已存在
            return NO;
        }
        
        if ([tableName isEqualToString:oldAttendanceTableName]) {
            break;
        }
    }
    
    if (![self switchToAttendanceTable:oldAttendanceTableName]) {
        return NO;
    }
    
    NSMutableDictionary *newTable = self.currentAttendanceTable;
    [newTable setObject:attendanceTableName forKey:ATTENDANCE_TABLE_NAME];
    [newTable setObject:type forKey:ATTENDANCE_TABLE_TYPE];
    [newTable setObject:date forKey:ATTENDANCE_TABLE_DATE];
    [newTable setObject:zone forKey:ATTENDANCE_TABLE_ZONE];
    [newTable setObject:weekdayString forKey:ATTENDANCE_TABLE_WEEKDAY];
    
    if (![self saveCurrentAttendanceTable]) {
        return NO;
    }
    
    [self.attendance_table_list replaceObjectAtIndex:index withObject:attendanceTableName];
    [[NSNotificationCenter defaultCenter] postNotificationName:REFRESH_ATTENDANCE_TABLE_LIST_NOTIFICATION object:nil];
    
    [zkeySandboxHelper deleteFileAtPath:[self pathOfAttendanceTableFile:oldAttendanceTableName]];
    
    return YES;
}

- (nonnull NSMutableDictionary *)newAttendanceTable:(nonnull NSString *)attendanceTableName inDate:(NSString *)date andWeekday:(NSString *)weekdayString atZone:(NSString *)zone withType:(NSString *)type
{
    NSMutableDictionary *newTable = [NSMutableDictionary dictionary];
    [newTable setObject:attendanceTableName forKey:ATTENDANCE_TABLE_NAME];
    [newTable setObject:type forKey:ATTENDANCE_TABLE_TYPE];
    [newTable setObject:date forKey:ATTENDANCE_TABLE_DATE];
    [newTable setObject:zone forKey:ATTENDANCE_TABLE_ZONE];
    [newTable setObject:weekdayString forKey:ATTENDANCE_TABLE_WEEKDAY];
    
    for (NSString *part in self.partList) {
        NSMutableDictionary *part_info = [NSMutableDictionary dictionary];
        [part_info setObject:[NSMutableSet set] forKey:ATTENDANCE_TABLE_ATTENDANCE_LIST];
        [part_info setObject:[NSMutableSet set] forKey:ATTENDANCE_TABLE_ASK_FOR_LEAVE_LIST];
        
        [newTable setObject:part_info forKey:part];
    }
    
    return newTable;
}

- (NSArray<NSString *> *)attendanceTableList
{
    NSArray *tableList = [self.attendance_table_list sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [obj1 compare:obj2 options:0];
    }];
    
    return tableList;
}

- (BOOL)attendanceTable:(NSString *)attendanceTableName someoneSignUp:(NSString *)name inPart:(NSString *)part
{
    //NSLog(@"db manipulation attendance table:%@ part:%@ name:%@", attendanceTableName, part, name);
    
    if (![self nameExist:name inPart:part]) {
        return NO;
    }
    
    if (![self switchToAttendanceTable:attendanceTableName]) {
        return NO;
    }

    NSMutableDictionary *part_info = [self.currentAttendanceTable objectForKey:part];
    
    NSMutableSet *part_attendance_list = [part_info objectForKey:ATTENDANCE_TABLE_ATTENDANCE_LIST];
    [part_attendance_list addObject:name];
    
    NSMutableSet *part_ask_for_leave_list = [part_info objectForKey:ATTENDANCE_TABLE_ASK_FOR_LEAVE_LIST];
    [part_ask_for_leave_list removeObject:name];
    
    //NSLog(@"attendance table:%@", self.currentAttendanceTable);
    
    return YES;
}

- (BOOL)attendanceTable:(NSString *)attendanceTableName someoneAskForLeve:(nonnull NSString *)name inPart:(nonnull NSString *)part
{
    //NSLog(@"db manipulation regist: date:%@ part:%@ name:%@", date, part, name);
    
    if (![self nameExist:name inPart:part]) {
        return NO;
    }
    
    if (![self switchToAttendanceTable:attendanceTableName]) {
        return NO;
    }
    
    NSMutableDictionary *part_info = [self.currentAttendanceTable objectForKey:part];
    
    NSMutableSet *part_ask_for_leave_list = [part_info objectForKey:ATTENDANCE_TABLE_ASK_FOR_LEAVE_LIST];
    [part_ask_for_leave_list addObject:name];
    
    NSMutableSet *part_attendance_list = [part_info objectForKey:ATTENDANCE_TABLE_ATTENDANCE_LIST];
    [part_attendance_list removeObject:name];
    
    //NSLog(@"ask for leave table:%@", self.currentAttendanceTable);
    
    return YES;
}

- (BOOL)attendanceTable:(NSString *)attendanceTableName setSomeoneAbsent:(NSString *)name inPart:(NSString *)part
{
    if (![self nameExist:name inPart:part]) {
        return NO;
    }
    
    if (![self switchToAttendanceTable:attendanceTableName]) {
        return NO;
    }
    
    NSMutableDictionary *part_info = [self.currentAttendanceTable objectForKey:part];
    
    NSMutableSet *part_ask_for_leave_list = [part_info objectForKey:ATTENDANCE_TABLE_ASK_FOR_LEAVE_LIST];
    [part_ask_for_leave_list removeObject:name];
    
    NSMutableSet *part_attendance_list = [part_info objectForKey:ATTENDANCE_TABLE_ATTENDANCE_LIST];
    [part_attendance_list removeObject:name];
    
    return YES;
}

- (BOOL)registerName:(nonnull NSString *)name toPart:(nonnull NSString *)part withStage:(nonnull NSString *)stage andZone:(nonnull NSString *)zone
{
    NSMutableDictionary *part_info = [self.member_info_db objectForKey:part];
    [part_info setObject:@{@"name" : name,
                           @"part" : part,
                           @"stage": stage,
                           @"zone" : zone} forKey:name];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:ADD_CONTACT_NOTIFICATION object:nil];
    
    return YES;
}

// 外部传入的数据合并到本地
- (BOOL)mergeAttendanceTableToLocalDatabase:(NSData *)attendanceTableData
{
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:attendanceTableData];
    NSArray *table_list = [unarchiver decodeObjectForKey:ATTENDANCE_TABLE];
    NSMutableDictionary *memberInfo = [unarchiver decodeObjectForKey:MEMBER_INFO_DB];
    
    if (![self mergeMemberInfoDB:memberInfo]) {
        return NO;
    }
    
    for (NSMutableDictionary *table in table_list) {
        if (![self mergeAttendanceTable:table]) {
            return NO;
        }
    }
    
    return YES;
}

- (BOOL)mergeAttendanceTable:(NSMutableDictionary *)attendanceTable
{
    if (![self saveCurrentAttendanceTable]) {
        return NO;
    }
    
    NSMutableDictionary *table01 = attendanceTable;
    NSString *attendanceTableName = [table01 objectForKey:ATTENDANCE_TABLE_NAME];
    NSString *attendanceType = [table01 objectForKey:ATTENDANCE_TABLE_TYPE];
    NSString *attendanceTableDate = [table01 objectForKey:ATTENDANCE_TABLE_DATE];
    NSString *attendanceTableZone = [table01 objectForKey:ATTENDANCE_TABLE_ZONE];
    //NSLog(@"begin merge file:%@", tableName01);
    
    if (![self attendanceTableExist:attendanceTableName]) {
        // 本地没有这个日期的签到表，直接将接受到的签到表存到本地
        if (![self createAttendanceTableInDate:attendanceTableDate atZone:attendanceTableZone withType:attendanceType]) {
            return NO;
        };
        
    } else {
        // 本地有这个日期的签到表，暴力合并
        if (![self switchToAttendanceTable:attendanceTableName]) {
            return NO;
        }
        
    }
    
    NSMutableDictionary *table02 = self.currentAttendanceTable;
    
    if (table02 == nil) {
        return NO;
    }
    
    for (NSString *part in self.partList) {
        NSDictionary *part_info01 = [table01 objectForKey:part];
        NSMutableDictionary *part_info02 = [table02 objectForKey:part];
        
        NSSet *part_attendance01_set = [part_info01 objectForKey:ATTENDANCE_TABLE_ATTENDANCE_LIST];
        NSMutableSet *part_attendance02_set = [part_info02 objectForKey:ATTENDANCE_TABLE_ATTENDANCE_LIST];
        [part_attendance02_set unionSet:part_attendance01_set];
        
        NSSet *part_leave01_set = [part_info01 objectForKey:ATTENDANCE_TABLE_ASK_FOR_LEAVE_LIST];
        NSMutableSet *part_leave02_set = [part_info02 objectForKey:ATTENDANCE_TABLE_ASK_FOR_LEAVE_LIST];
        [part_leave02_set unionSet:part_leave01_set];
    }
    
    self.currentAttendanceTable = table02;
    
    return YES;
}

- (BOOL)mergeMemberInfoDB:(NSMutableDictionary *)memberInfoDB
{
    for (NSString *part in self.partList) {
        NSDictionary *part_info01 = [memberInfoDB objectForKey:part];
        NSMutableDictionary *part_info02 = [self.member_info_db objectForKey:part];
        for (NSString *name in part_info01.allKeys) {
            if ([part_info02 objectForKey:name] == nil) {
                [part_info02 setObject:[part_info01 objectForKey:name] forKey:name];
            }
        }
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:ADD_CONTACT_NOTIFICATION object:nil];
    
    return YES;
}

- (BOOL)nameExist:(NSString *)name inPart:(NSString *)part
{
    NSDictionary *part_info = [self.member_info_db objectForKey:part];
    
    if (part_info == nil) {
        NSLog(@"part %@ do not exist", part);
        return NO;
    }
    
    if (![part_info objectForKey:name]) {
        NSLog(@"%@ do not exist in %@", name, part);
        return NO;
    }
    
    return YES;
}

- (nonnull NSDictionary *)member_info;
{
    return self.member_info_db;
}

- (NSArray *)partList
{
    if (!_partList) {
        _partList = CHORUS_PART_LIST;
    }
    
    return _partList;
}

- (NSArray *)memberNameListOfPart:(NSString *)part
{
    NSDictionary *part_info = [self.member_info_db objectForKey:part];
    if (part_info == nil) {
        return @[];
    }
    
    return [part_info allKeys];
}

- (NSArray *)zoneList
{
    if (!_zoneList) {
        _zoneList = @[ZivAttendanceZoneIdentifireYanqi, ZivAttendanceZoneIdentifireZhongguancun];
    }
    
    return _zoneList;
}

- (NSArray *)attendanceTypeList
{
    if (!_attendanceTypeList) {
        _attendanceTypeList = @[ZivAttendanceTypeDapai, ZivAttendanceTypeXiaopai, ZivAttendanceTypeShengyueke, ZivAttendanceTypeZhouriwan];
    }
    
    return _attendanceTypeList;
}

- (NSString *)personalInfoDescriptionOfMember:(NSString *)name inPart:(NSString *)part
{
    NSDictionary *part_info = [self.member_info_db objectForKey:part];
    NSDictionary *personal_info = [part_info objectForKey:name];
    NSString *zone = [personal_info objectForKey:MEMBER_INFO_KEY_ZONE];
    NSString *stage = [personal_info objectForKey:MEMBER_INFO_KEY_STAGE];
    
    NSString *description = [NSString stringWithFormat:@"%@ · %@届%@", zone, stage, part];
    return description;
}

+ (NSString *)pathOfDatabaseFile
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = [paths firstObject];
    
    return [docDir stringByAppendingPathComponent:ATTENDANCE_RECORD_DB_FILE_NAME];
}

- (NSURL *)publicUrlForAttendanceTable:(NSString *)attendanceTableName
{
    NSMutableDictionary *table = [self getAttendanceTable:attendanceTableName];
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:table forKey:ATTENDANCE_TABLE];
    [archiver encodeObject:self.member_info_db forKey:MEMBER_INFO_DB];
    [archiver finishEncoding];
    
    NSString *path = [[zkeySandboxHelper pathOfTmp] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", attendanceTableName, PUBLIC_ATTENDANCE_TABLE_FILE_EXTENSION]];
    
    if (![data writeToFile:path atomically:YES]) {
        return nil;
    }
    
    return [NSURL fileURLWithPath:path];
}

- (nonnull NSString *)getTheNameOfTheCurrentAttendanceTable
{
    if (self.currentAttendanceTable == nil) {
        return nil;
    }
    
    return [self.currentAttendanceTable objectForKey:ATTENDANCE_TABLE_NAME];
}

- (BOOL)attendanceTableExist:(nonnull NSString *)attendanceTableName
{
    if (self.currentAttendanceTable != nil && ([attendanceTableName compare:[self getTheNameOfTheCurrentAttendanceTable]] == NSOrderedSame)) {
        return YES;
    }
    
    for (NSString *tableName in self.attendance_table_list) {
        if ([tableName compare:attendanceTableName] == NSOrderedSame) {
            return YES;
        }
    }
    
    return NO;
}

- (BOOL)switchToAttendanceTable:(nonnull NSString *)attendanceTableName
{
    //NSLog(@"begin switch to table:%@", attendanceTableName);

    if (self.currentAttendanceTable != nil && [[self getTheNameOfTheCurrentAttendanceTable] compare:attendanceTableName] == NSOrderedSame) {
        return YES;
    }
    
    [self saveCurrentAttendanceTable];
    
    self.currentAttendanceTable = [self getAttendanceTable:attendanceTableName];
                                                  
    if (self.currentAttendanceTable) {
        return YES;
    }
    
    NSLog(@"fail to swtich to table:%@", attendanceTableName);
    
    return NO;
}

- (nonnull NSDictionary *)attendanceTableByName:(nonnull NSString *)attendanceTableName
{
    return (NSDictionary *)[self getAttendanceTable:attendanceTableName];
}

- (nullable NSMutableDictionary *)getAttendanceTable:(nonnull NSString *)attendanceTableName
{
    if (self.currentAttendanceTable && ([attendanceTableName compare:[self getTheNameOfTheCurrentAttendanceTable]] == NSOrderedSame)) {
        //NSLog(@"no need for table switch");
        return self.currentAttendanceTable;
    }
    
    NSString *path = [self pathOfAttendanceTableFile:attendanceTableName];
    if (![zkeySandboxHelper fileExitAtPath:path]) {
        return nil;
    }
    
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    NSMutableDictionary *table = [unarchiver decodeObjectForKey:ATTENDANCE_TABLE];
    [unarchiver finishDecoding];
    
    return table;
}

- (NSString *)pathOfAttendanceTableFile:(NSString *)attendanceTableName
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = [paths firstObject];
    
    return [docDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", attendanceTableName, ATTENDANCE_TABLE_FILE_EXTENSION]];
}

- (NSInteger)numberOfMemberInPart:(NSString *)part
{
    NSDictionary *part_info = [self.member_info_db objectForKey:part];
    if (part_info == nil) {
        return 0;
    }
    
    return [[part_info allKeys] count];
}

- (void)saveFile
{
    [self saveDBFile];
    [self saveCurrentAttendanceTable];
}

- (void)saveDBFile
{
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:self.attendance_table_list forKey:ATTENDANCE_RECORD_TABLE_LIST];
    [archiver encodeObject:self.member_info_db forKey:MEMBER_INFO_DB];
    [archiver finishEncoding];
    
    NSString *filePath = [ZivDBManager pathOfDatabaseFile];
    if (![data writeToFile:filePath atomically:YES]) {
        NSLog(@"fail to save db file");
    }
    
}

- (BOOL)saveCurrentAttendanceTable
{
    if (self.currentAttendanceTable == nil) {
        return YES;
    }
    
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:self.currentAttendanceTable forKey:ATTENDANCE_TABLE];
    [archiver finishEncoding];
    NSString *currentAttendanceTableName = [self getTheNameOfTheCurrentAttendanceTable];
    if (![data writeToFile:[self pathOfAttendanceTableFile:currentAttendanceTableName] atomically:YES]) {
        NSLog(@"fail to save Attendance table");
        return NO;
    }
    
    return YES;
}

- (void)saveAttendanceTable:(NSMutableDictionary *)attendanceTable
{
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:attendanceTable forKey:ATTENDANCE_TABLE];
    [archiver finishEncoding];
    
    NSString *tableName = [attendanceTable objectForKey:ATTENDANCE_TABLE_NAME];
    [data writeToFile:[self pathOfAttendanceTableFile:tableName] atomically:YES];
}

- (BOOL)deleteMemberInfo:(NSString *)name fromPart:(NSString *)part
{
    NSMutableDictionary *part_info = [self.member_info_db objectForKey:part];
    [part_info removeObjectForKey:name];
    
    return YES;
}

- (BOOL)removeName:(NSArray *)nameList inPart:(NSString *)part FromAttendanceTable:(NSString *)attendanceTableName
{
    [self switchToAttendanceTable:attendanceTableName];
    
    NSMutableDictionary *part_info = [self.currentAttendanceTable objectForKey:part];
    
    NSMutableSet *part_attendance_list = [part_info objectForKey:ATTENDANCE_TABLE_ATTENDANCE_LIST];
    NSMutableSet *part_ask_for_leave_list = [part_info objectForKey:ATTENDANCE_TABLE_ASK_FOR_LEAVE_LIST];
    
    for (NSString *name in nameList) {
        [part_attendance_list removeObject:name];
        [part_ask_for_leave_list removeObject:name];
    }
    
    
    return YES;
}

- (BOOL)deleteAttendanceTable:(NSString *)attendanceTableName
{
    NSString *path = [self pathOfAttendanceTableFile:attendanceTableName];
    if (![zkeySandboxHelper deleteFileAtPath:path]) {
        return NO;
    }
    
    NSInteger index = 0;
    NSString *tableName = nil;
    for (index = 0; index < self.attendance_table_list.count; ++index) {
        tableName = [self.attendance_table_list objectAtIndex:index];
        if ([tableName compare:attendanceTableName] == NSOrderedSame) {
            break;
        }
    }
    
    if (!([tableName compare:attendanceTableName] == NSOrderedSame)) {
        return NO;
    }
    
    [self.attendance_table_list removeObjectAtIndex:index];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:REFRESH_ATTENDANCE_TABLE_LIST_NOTIFICATION object:nil];
    
    // 删除成功 将当前签到表置空
    self.currentAttendanceTable = nil;
    
    return YES;
}

- (void)dealloc
{
    [self saveFile];
}


- (void)updateDatabaseVersion
{
//    [self.attendance_table_list removeAllObjects];
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *docDir = [paths firstObject];
//    NSDirectoryEnumerator *fileEnumerator = [fileManager enumeratorAtPath:docDir];
//    NSString *filePath = nil;
//    while ((filePath = [fileEnumerator nextObject]) != nil) {
//        NSLog(@"%@", filePath);
//        if (filePath.length == 16) {
//            [self.attendance_table_list addObject:[filePath substringToIndex:10]];
//        }
//    }
//    
//    [self saveDBFile];
//    
//    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"updated_version"];
//    
//    return;
    
    [self updateToBuild5];
    [self updateToBuild7];
    
}

// 签到表名称从"20160813大排" -> "20160813周六中关村大排"
- (void)updateToBuild5
{
    // 判断是否需要升级数据库
    
    NSNumber *updated_version = [[NSUserDefaults standardUserDefaults] objectForKey:UPDATED_VERSION];
    if (updated_version != nil && [updated_version integerValue] >= 5) {
        // 已经做过此次升级
        return;
    }
    
    if (self.attendance_table_list.count <= 0) {
        // 没有签到表，或者直接安装Build5，而非从更低版本升级到Build5
        // build 5
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:5] forKey:UPDATED_VERSION];
        [[NSUserDefaults standardUserDefaults] synchronize];
        return;
    }
    
    NSString *example_attendance_table_name = [self.attendance_table_list firstObject];
    if (example_attendance_table_name.length > 10) {
        // 已经做过此次升级
        // build 5
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:5] forKey:UPDATED_VERSION];
        [[NSUserDefaults standardUserDefaults] synchronize];
        return;
    }
    
    
    // 签到表名称从"20160813大排" -> "20160813周六中关村大排"
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyyMMdd"];
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSArray *oldAttendanceTableList = self.attendance_table_list;
    NSMutableArray *newAttendanceTableList = [NSMutableArray arrayWithCapacity:oldAttendanceTableList.count];
    
    for (NSString *tableName in oldAttendanceTableList) {
        NSMutableDictionary *table = [self getAttendanceTable:tableName];
        NSString *attendanceDate = [table objectForKey:ATTENDANCE_TABLE_DATE];
        NSDate *date = [dateFormat dateFromString:attendanceDate];
        NSDateComponents *comps = [calendar components:NSCalendarUnitWeekday fromDate:date];
        
        NSString *zone = ZivAttendanceZoneIdentifireZhongguancun;
        NSString *isFormalAttendanceString = [table objectForKey:ATTENDANCE_TABLE_IS_FORMAL_ATTENDANCE];
        BOOL isFormalAttendance = [isFormalAttendanceString boolValue];
        NSString *weekdayString = @"周三";
        if (isFormalAttendance) {
            // 大排
            if (comps.weekday == 1) {
                // 大排－周日－雁栖湖
                weekdayString = @"周日";
                zone = ZivAttendanceZoneIdentifireYanqi;
            } else if (comps.weekday == 7) {
                // 大排－周六－中关村
                zone = ZivAttendanceZoneIdentifireZhongguancun;
                weekdayString = @"周六";
            } else if (comps.weekday == 4) {
                // 大排－周三－中关村
                zone = ZivAttendanceZoneIdentifireZhongguancun;
                weekdayString = @"周三";
            }
            
            NSString *newAttendanceTableName = [NSString stringWithFormat:@"%@%@%@%@",attendanceDate, weekdayString, zone, (isFormalAttendance ? @"大排" : @"小排")];
            [table setObject:zone forKey:ATTENDANCE_TABLE_ZONE];
            [table setObject:newAttendanceTableName forKey:ATTENDANCE_TABLE_NAME];
            [table setObject:weekdayString forKey:ATTENDANCE_TABLE_WEEKDAY];
            
            // 保存新文件
            [newAttendanceTableList addObject:newAttendanceTableName];
            [self saveAttendanceTable:table];
            
        } else {
            // 小排－拆分签到表
            if (comps.weekday != 4) {
                continue;
            }
            
            if ([tableName compare:@"20160914小排"] != NSOrderedSame) {
                zone = ZivAttendanceZoneIdentifireYanqi;
                weekdayString = @"周三";
                NSString *newAttendanceTableName = [NSString stringWithFormat:@"%@%@%@%@",attendanceDate, weekdayString, zone, (isFormalAttendance ? @"大排" : @"小排")];
                [table setObject:zone forKey:ATTENDANCE_TABLE_ZONE];
                [table setObject:newAttendanceTableName forKey:ATTENDANCE_TABLE_NAME];
                [table setObject:weekdayString forKey:ATTENDANCE_TABLE_WEEKDAY];
                
                // 保存新文件
                [newAttendanceTableList addObject:newAttendanceTableName];
                [self saveAttendanceTable:table];
                
                continue;
            }
            
            // 周三
            weekdayString = @"周三";
            NSString *zhongguancun_table_name = [NSString stringWithFormat:@"%@%@%@%@",attendanceDate, weekdayString, ZivAttendanceZoneIdentifireZhongguancun, (isFormalAttendance ? @"大排" : @"小排")];
            NSMutableDictionary *zhongguancun_table = [self newAttendanceTable:zhongguancun_table_name inDate:attendanceDate andWeekday:weekdayString atZone:ZivAttendanceZoneIdentifireZhongguancun withType:(isFormalAttendance ? @"大排" : @"小排")];
            NSString *yanqi_table_name = [NSString stringWithFormat:@"%@%@%@%@",attendanceDate, weekdayString, ZivAttendanceZoneIdentifireYanqi, (isFormalAttendance ? @"大排" : @"小排")];
            NSMutableDictionary *yanqi_table = [self newAttendanceTable:yanqi_table_name inDate:attendanceDate andWeekday:weekdayString atZone:ZivAttendanceZoneIdentifireYanqi withType:(isFormalAttendance ? @"大排" : @"小排")];
            
            for (NSString *part in self.partList) {
                NSMutableDictionary *zhongguancun_part = [zhongguancun_table objectForKey:part];
                NSMutableSet *zhongguancun_attendance_list = [zhongguancun_part objectForKey:ATTENDANCE_TABLE_ATTENDANCE_LIST];
                NSMutableSet *zhongguancun_leave_list = [zhongguancun_part objectForKey:ATTENDANCE_TABLE_ASK_FOR_LEAVE_LIST];
                NSMutableDictionary *yanqi_part = [yanqi_table objectForKey:part];
                NSMutableSet *yanqi_attendance_list = [yanqi_part objectForKey:ATTENDANCE_TABLE_ATTENDANCE_LIST];
                NSMutableSet *yanqi_leave_list = [yanqi_part objectForKey:ATTENDANCE_TABLE_ASK_FOR_LEAVE_LIST];
                NSDictionary *part_info = [table objectForKey:part];
                NSSet *attendance_list = [part_info objectForKey:ATTENDANCE_TABLE_ATTENDANCE_LIST];
                NSSet *leave_list = [part_info objectForKey:ATTENDANCE_TABLE_ASK_FOR_LEAVE_LIST];
                
                NSString *zone = nil;
                for (NSString *name in attendance_list) {
                    NSDictionary *personal_info = [[self.member_info_db objectForKey:part] objectForKey:name];
                    zone = [personal_info objectForKey:MEMBER_INFO_KEY_ZONE];
                    if ([zone compare:ZivAttendanceZoneIdentifireYanqi] == NSOrderedSame) {
                        [yanqi_attendance_list addObject:name];
                    } else if ([zone compare:ZivAttendanceZoneIdentifireZhongguancun] == NSOrderedSame) {
                        [zhongguancun_attendance_list addObject:name];
                    }
                }
                
                for (NSString *name in leave_list) {
                    NSDictionary *personal_info = [[self.member_info_db objectForKey:part] objectForKey:name];
                    zone = [personal_info objectForKey:MEMBER_INFO_KEY_ZONE];
                    if ([zone compare:ZivAttendanceZoneIdentifireYanqi] == NSOrderedSame) {
                        [yanqi_leave_list addObject:name];
                    } else if ([zone compare:ZivAttendanceZoneIdentifireZhongguancun] == NSOrderedSame) {
                        [zhongguancun_leave_list addObject:name];
                    }
                }
                
            }
            
            // 保存这两张签到表
            [self saveAttendanceTable:yanqi_table];
            [self saveAttendanceTable:zhongguancun_table];
            [newAttendanceTableList addObject:zhongguancun_table_name];
            [newAttendanceTableList addObject:yanqi_table_name];
            
        }
        
    }
    
    self.attendance_table_list = newAttendanceTableList;
    [self saveDBFile];

    // set updated_verison flag to build 5
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:5] forKey:UPDATED_VERSION];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)updateToBuild7
{
    NSNumber *updated_version = [[NSUserDefaults standardUserDefaults] objectForKey:UPDATED_VERSION];
    if (updated_version != nil && [updated_version integerValue] >= 7) {
        // 已经做过此次升级
        return;
    }
    
    if (self.attendance_table_list.count <= 0) {
        // 没有签到表，或者直接安装Build7，而非从更低版本升级到Build7
        // build 7
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:7] forKey:UPDATED_VERSION];
        [[NSUserDefaults standardUserDefaults] synchronize];
        return;
    }
    
    // 从Build5升级到Build7
    for (NSString *tableName in self.attendance_table_list) {
        NSMutableDictionary *table = [self getAttendanceTable:tableName];
        BOOL isFormalAttendance = [[table objectForKey:ATTENDANCE_TABLE_IS_FORMAL_ATTENDANCE] boolValue];
        if (isFormalAttendance) {
            [table setObject:ZivAttendanceTypeDapai forKey:ATTENDANCE_TABLE_TYPE];
        } else {
            [table setObject:ZivAttendanceTypeXiaopai forKey:ATTENDANCE_TABLE_TYPE];
        }
        
        [self saveAttendanceTable:table];
    }
    
    // build 7
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:7] forKey:UPDATED_VERSION];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)shareAttendanceTable:(NSArray *)attendancetableNameArray
{
    NSMutableArray *backup_table_list = [NSMutableArray arrayWithCapacity:attendancetableNameArray.count];
    
    for (NSString *tableName in attendancetableNameArray) {
        NSMutableDictionary *table = [self getAttendanceTable:tableName];
        [backup_table_list addObject:table];
    }
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = [paths firstObject];
    NSString *fileName = [NSString stringWithFormat:@"%@等%ld张签到表.pdf", [attendancetableNameArray firstObject], (unsigned long)attendancetableNameArray.count];
    NSString *backup_path = [docDir stringByAppendingPathComponent:fileName];
    
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:backup_table_list forKey:ATTENDANCE_TABLE];
    [archiver encodeObject:self.member_info_db forKey:MEMBER_INFO_DB];
    [archiver finishEncoding];
    
    if ([data writeToFile:backup_path atomically:YES]) {
        return backup_path;
    }
    
    NSLog(@"fail to backup");
    
    return nil;
}

@end
