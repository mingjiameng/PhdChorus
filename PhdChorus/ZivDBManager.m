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

@interface ZivDBManager()

@property (nonatomic, nonnull, strong) NSMutableArray *attendance_table_list;
@property (nonatomic, nonnull, strong) NSMutableDictionary *member_info_db;
@property (nonatomic, strong) NSMutableDictionary *currentAttendanceTable;
@property (nonatomic, strong) NSArray *partList;
@property (nonatomic, strong) NSArray *zoneList;

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

- (BOOL)createAttendanceTable:(NSString *)attendanceTableName inDate:(NSString *)attendanceTableDate withDescription:(BOOL)isFormalAttendance
{
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
        self.currentAttendanceTable = [self newAttendanceTable:attendanceTableName inDate:attendanceTableDate withDescription:isFormalAttendance];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:REFRESH_ATTENDANCE_TABLE_LIST_NOTIFICATION object:nil];
        
        return YES;
    }
    
    return NO;
}

- (nonnull NSMutableDictionary *)newAttendanceTable:(nonnull NSString *)attendanceTableName inDate:(NSString *)date withDescription:(BOOL)isFormalAttendance
{
    NSMutableDictionary *newTable = [NSMutableDictionary dictionary];
    [newTable setObject:attendanceTableName forKey:ATTENDANCE_TABLE_NAME];
    [newTable setObject:(isFormalAttendance ? @"1" : @"0") forKey:ATTENDANCE_TABLE_IS_FORMAL_ATTENDANCE];
    [newTable setObject:date forKey:ATTENDANCE_TABLE_DATE];
    
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

- (BOOL)mergeAttendanceTableToLocalDatabase:(NSData *)attendanceTableData
{
    // table01是外部传入的签到表，需要将table01合并到本地
    
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:attendanceTableData];
    NSMutableDictionary *table = [unarchiver decodeObjectForKey:ATTENDANCE_TABLE];
    NSMutableDictionary *memberInfo = [unarchiver decodeObjectForKey:MEMBER_INFO_DB];
    
    if (![self mergeMemberInfoDB:memberInfo]) {
        return NO;
    }
    
    if (![self mergeAttendanceTable:table]) {
        return NO;
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
    BOOL isFormalAttendance = [[table01 objectForKey:ATTENDANCE_TABLE_IS_FORMAL_ATTENDANCE] boolValue];
    NSString *attendanceTableDate = [table01 objectForKey:ATTENDANCE_TABLE_DATE];
    //NSLog(@"begin merge file:%@", tableName01);
    
    if (![self attendanceTableExist:attendanceTableName]) {
        // 本地没有这个日期的签到表，直接将接受到的签到表存到本地
        if (![self createAttendanceTable:attendanceTableName inDate:attendanceTableDate withDescription:isFormalAttendance]) {
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

- (NSArray *)zoneList
{
    if (!_zoneList) {
        _zoneList = @[ZivAttendanceZoneIdentifireYanqi, ZivAttendanceZoneIdentifireZhongguancun];
    }
    
    return _zoneList;
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





@end
