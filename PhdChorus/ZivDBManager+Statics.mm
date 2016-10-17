//
//  ZivDBManager+Statics.m
//  PhdChorusCommunity
//
//  Created by 梁志鹏 on 16/9/23.
//  Copyright © 2016年 PhdChorus. All rights reserved.
//

#import "ZivDBManager+Statics.h"

#import <LibXL/LibXL.h>
#import "zkeySandboxHelper.h"

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/*
 * 数据统计相关
 */

@implementation ZivDBManager (Statics)

/*
 * 导出Excel表
 */
- (nullable NSString *)exportAttendanceTableOfPart:(NSString *)part from:(NSString *)startTime to:(NSString *)endTime
{
    if ([endTime compare:startTime] == NSOrderedAscending) {
        return nil;
    }
    // 找出在给定日期内的大排&小排签到表
    NSMutableArray *informal_satisfiedTableNameList = [NSMutableArray array];
    NSMutableArray *formal_satisfiedTableNameList = [NSMutableArray array];
    NSString *date = nil;
    
    for (NSString *tableName in self.attendanceTableList) {
        date = [tableName substringToIndex:8];
        if ([date compare:startTime] != NSOrderedAscending && [date compare:endTime] != NSOrderedDescending) {
            if ([tableName containsString:@"小排"]) {
                [informal_satisfiedTableNameList addObject:tableName];
            } else if ([tableName containsString:@"大排"]) {
                [formal_satisfiedTableNameList addObject:tableName];
            }
        }
    }
    
    // 找出在该声部的 雁栖湖&中关村人员列表
    NSDictionary *part_info = [self.member_info_db objectForKey:part];
    NSArray *part_name_list = [part_info allKeys];
    NSMutableArray *yanqi_part_name_list = [NSMutableArray array];
    NSMutableArray *zhongguancun_part_name_list = [NSMutableArray array];
    NSDictionary *personal_info = nil;
    NSString *personal_zone = nil;
    for (NSString *name in part_name_list) {
        personal_info = [part_info objectForKey:name];
        personal_zone = [personal_info objectForKey:MEMBER_INFO_KEY_ZONE];
        if ([personal_zone compare:ZivAttendanceZoneIdentifireYanqi] == NSOrderedSame) {
            [yanqi_part_name_list addObject:name];
        } else if ([personal_zone compare:ZivAttendanceZoneIdentifireZhongguancun] == NSOrderedSame) {
            [zhongguancun_part_name_list addObject:name];
        }
    }
    
    NSMutableArray *sheet_info_array = [NSMutableArray arrayWithCapacity:2];
    [sheet_info_array addObject:@{@"sheet_name" : @"大排", @"table_list" : formal_satisfiedTableNameList}];
    [sheet_info_array addObject:@{@"sheet_name" : @"小排", @"table_list" : informal_satisfiedTableNameList}];
    
    // 创建小排 & 大排 sheet
    BookHandle book = xlCreateBook();
    // 雁栖湖背景色设为灰色
    FontHandle blueFont = xlBookAddFontA(book, 0);
    xlFontSetColorA(blueFont, COLOR_BLUE);
    FormatHandle yanqi_format = xlBookAddFormatA(book, 0);
    xlFormatSetFontA(yanqi_format, blueFont);
    
    // 大排、小排各创建一个sheet
    for (int index = 0; index < sheet_info_array.count; ++index) {
        NSDictionary *sheet_info = [sheet_info_array objectAtIndex:index];
        NSString *sheet_name = [sheet_info objectForKey:@"sheet_name"];
        NSArray *table_list = [sheet_info objectForKey:@"table_list"];
        SheetHandle sheet = xlBookAddSheetA(book, [sheet_name UTF8String], 0);
        
        
        int currentRow = 1, startRow = 1;
        int currentColumn = 1, startColumn = 1;
        
        // 第一列写声部
        // 第二列写编号
        // 第三列写姓名
        xlSheetWriteStrA(sheet, currentRow, currentColumn, [@"声部" UTF8String], 0);
        xlSheetWriteStrA(sheet, currentRow, currentColumn + 1, [@"编号" UTF8String], 0);
        xlSheetWriteStrA(sheet, currentRow, currentColumn + 2, [@"姓名" UTF8String], 0);
        ++currentRow;
        
        // 先中关村
        for (int i = 0; i < zhongguancun_part_name_list.count; ++i) {
            xlSheetWriteStrA(sheet, currentRow, currentColumn, [part UTF8String], 0);
            xlSheetWriteStrA(sheet, currentRow, currentColumn + 1, [[NSString stringWithFormat:@"%d", currentRow - 2] UTF8String], 0);
            xlSheetWriteStrA(sheet, currentRow, currentColumn + 2, [[zhongguancun_part_name_list objectAtIndex:i] UTF8String], 0);
            ++currentRow;
        }
        // 后雁栖湖
        for (int i = 0; i < yanqi_part_name_list.count; ++i) {
            xlSheetWriteStrA(sheet, currentRow, currentColumn, [part UTF8String], yanqi_format);
            xlSheetWriteStrA(sheet, currentRow, currentColumn + 1, [[NSString stringWithFormat:@"%d", currentRow - 2] UTF8String], yanqi_format);
            xlSheetWriteStrA(sheet, currentRow, currentColumn + 2, [[yanqi_part_name_list objectAtIndex:i] UTF8String], yanqi_format);
            ++currentRow;
        }
        
        currentColumn = startColumn + 3;
        
        // 每张签到表创建一列
        for (int i = 0; i < table_list.count; ++i) {
            currentRow = startRow;
            
            
            NSString *tableName = [table_list objectAtIndex:i];
            NSDictionary *table = [self attendanceTableByName:tableName];
            //NSString *tableDate = [tableName substringToIndex:8];
            
            NSDictionary *part_sign_info = [table objectForKey:part];
            NSSet *attendance_set = [part_sign_info objectForKey:ATTENDANCE_TABLE_ATTENDANCE_LIST];
            
            NSString *name = nil;
            
            //NSLog(@"tableName:%@, tableDate:%@", tableName, tableDate);
            
            // 在当前行写下签到表名称
            xlSheetWriteStrA(sheet, currentRow, currentColumn, [tableName UTF8String], 0);
            // 移到下一行
            ++currentRow;
            
            for (int row = 0; row < zhongguancun_part_name_list.count; ++row) {
                name = [zhongguancun_part_name_list objectAtIndex:row];
                if ([attendance_set containsObject:name]) {
                    xlSheetWriteNumA(sheet, currentRow, currentColumn, 1, 0);
                } else {
                    xlSheetWriteNumA(sheet, currentRow, currentColumn, 0, 0);
                }
                
                ++currentRow;
            }
            
            for (int row = 0; row < yanqi_part_name_list.count; ++row) {
                name = [yanqi_part_name_list objectAtIndex:row];
                if ([attendance_set containsObject:name]) {
                    xlSheetWriteNumA(sheet, currentRow, currentColumn, 1, yanqi_format);
                } else {
                    xlSheetWriteNumA(sheet, currentRow, currentColumn, 0, yanqi_format);
                }
                
                ++currentRow;
            }
            
            // 移到下一列
            ++currentColumn;
        }
        
        
        
    }
    
    NSString *filePath = [self publicPathForAttendanceExcelOfPart:part From:startTime to:endTime];
    if (xlBookSaveA(book, [filePath UTF8String]) == false) {
        return nil;
    };
    
    xlBookReleaseA(book);
    
    return filePath;

}

// return nil if the attendance is not formal
- (nullable NSString *)zoneOfAttendanceTable:(nonnull NSString *)attendaceDate
{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyyMMdd"];
    NSDate *date = [dateFormat dateFromString:attendaceDate];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *comps = [calendar components:NSCalendarUnitWeekday fromDate:date];
    
    // 从周日开始算起 周日＝1
    if (comps.weekday == 1) {
        return ZivAttendanceZoneIdentifireYanqi;
    } else if (comps.weekday == 7) {
        return ZivAttendanceZoneIdentifireZhongguancun;
    }
    
    return nil;
}

- (nonnull NSString *)publicPathForAttendanceExcelOfPart:(NSString *)part From:(NSString *)startTime to:(NSString *)endTime
{
    return [[zkeySandboxHelper pathOfTmp] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-%@签到表%@.xls", startTime, endTime, part]];
}


/*
 * 每日出勤数据统计
 */
- (void)part:(NSString *)part memberCountOfHighPart:(NSInteger *)highPartCount andLowPart:(NSInteger *)lowPartCount
{
    NSString *hightPartName = [part stringByAppendingString:@"1"];
    NSString *lowPartName = [part stringByAppendingString:@"2"];
    
    *highPartCount = [[[self.member_info_db objectForKey:hightPartName] allKeys] count];
    *lowPartCount = [[[self.member_info_db objectForKey:lowPartName] allKeys] count];
}

- (void)part:(NSString *)part memberCountOfZhongguancun:(NSInteger *)zhongguancunCount andYanqi:(NSInteger *)yanqiCount
{
    NSString *hightPartName = [part stringByAppendingString:@"1"];
    NSString *lowPartName = [part stringByAppendingString:@"2"];
    NSArray *partArray = @[hightPartName, lowPartName];
    
    NSInteger yanqi_tmp = 0, zhongguancun_tmp = 0;
    
    for (NSString *partName in partArray) {
        NSDictionary *part_info = [self.member_info_db objectForKey:partName];
        NSArray *nameArray = [part_info allKeys];
        NSDictionary *personalInfoDic = nil;
        NSString *zone = nil;
        for (NSString *name in nameArray) {
            personalInfoDic = [part_info objectForKey:name];
            zone = [personalInfoDic objectForKey:MEMBER_INFO_KEY_ZONE];
            if ([zone compare:ZivAttendanceZoneIdentifireZhongguancun] == NSOrderedSame) {
                ++zhongguancun_tmp;
            } else if ([zone compare:ZivAttendanceZoneIdentifireYanqi] == NSOrderedSame) {
                ++yanqi_tmp;
            }
        }
    }
    
    *zhongguancunCount = zhongguancun_tmp;
    *yanqiCount = yanqi_tmp;
}

- (void)part:(NSString *)part attendanceCountOfHighPart:(NSInteger *)highPartCount andLowPart:(NSInteger *)lowPartCount inAttendanceTable:(nonnull NSString *)tableName
{
    NSString *hightPartName = [part stringByAppendingString:@"1"];
    NSString *lowPartName = [part stringByAppendingString:@"2"];
    NSDictionary *attendanceTable = [self attendanceTableByName:tableName];
    
    NSInteger high_part_count = [[[attendanceTable objectForKey:hightPartName] objectForKey:ATTENDANCE_TABLE_ATTENDANCE_LIST] count];
    NSInteger low_part_count = [[[attendanceTable objectForKey:lowPartName] objectForKey:ATTENDANCE_TABLE_ATTENDANCE_LIST] count];
    
    *highPartCount = high_part_count;
    *lowPartCount = low_part_count;
}

- (void)part:(NSString *)part attendanceCountOfZhongguancun:(NSInteger *)zhongguancunCount andYanqi:(NSInteger *)yanqiCount inAttendanceTable:(nonnull NSString *)tableName
{
    NSString *hightPartName = [part stringByAppendingString:@"1"];
    NSString *lowPartName = [part stringByAppendingString:@"2"];
    NSDictionary *attendanceTable = [self attendanceTableByName:tableName];
    
    NSSet *hight_part_attendance_list = [[attendanceTable objectForKey:hightPartName] objectForKey:ATTENDANCE_TABLE_ATTENDANCE_LIST];
    NSSet *low_part_attendance_list = [[attendanceTable objectForKey:lowPartName] objectForKey:ATTENDANCE_TABLE_ATTENDANCE_LIST];
    
    NSInteger zhongguancun_count = 0, yanqi_count = 0;
    NSString *zone = nil;

    for (NSString *name in hight_part_attendance_list) {
        zone = [self zoneOfMember:name inPart:hightPartName];
        if ([zone compare:ZivAttendanceZoneIdentifireZhongguancun] == NSOrderedSame) {
            ++zhongguancun_count;
        } else if ([zone compare:ZivAttendanceZoneIdentifireYanqi] == NSOrderedSame) {
            ++yanqi_count;
        }
    }
    
    for (NSString *name in low_part_attendance_list) {
        zone = [self zoneOfMember:name inPart:lowPartName];
        if ([zone compare:ZivAttendanceZoneIdentifireZhongguancun] == NSOrderedSame) {
            ++zhongguancun_count;
        } else if ([zone compare:ZivAttendanceZoneIdentifireYanqi] == NSOrderedSame) {
            ++yanqi_count;
        }
    }
    
    *zhongguancunCount = zhongguancun_count;
    *yanqiCount = yanqi_count;
}

- (nullable NSString *)zoneOfMember:(nonnull NSString *)name inPart:(nonnull NSString *)part
{
    NSDictionary *personal_info = [[self.member_info_db objectForKey:part] objectForKey:name];
    return [personal_info objectForKey:MEMBER_INFO_KEY_ZONE];
}

- (void)part:(NSString *)part absenceCountOfHighPart:(NSInteger *)highPartCount andLowPart:(NSInteger *)lowPartCount inAttendanceTable:(nonnull NSString *)tableName
{
    NSString *hightPartName = [part stringByAppendingString:@"1"];
    NSString *lowPartName = [part stringByAppendingString:@"2"];
    NSDictionary *attendanceTable = [self attendanceTableByName:tableName];
    
    NSInteger high_part_count = [[[attendanceTable objectForKey:hightPartName] objectForKey:ATTENDANCE_TABLE_ASK_FOR_LEAVE_LIST] count];
    NSInteger low_part_count = [[[attendanceTable objectForKey:lowPartName] objectForKey:ATTENDANCE_TABLE_ASK_FOR_LEAVE_LIST] count];
    
    *highPartCount = high_part_count;
    *lowPartCount = low_part_count;
}

- (NSAttributedString *)part:(NSString *)part attendanceNameListInAttendanceTable:(NSString *)tableName
{
    NSDictionary *table = [self attendanceTableByName:tableName];
    NSString *highPartName = [part stringByAppendingString:@"1"];
    NSString *lowPartName = [part stringByAppendingString:@"2"];
    NSSet *highPartNameList = [[table objectForKey:highPartName] objectForKey:ATTENDANCE_TABLE_ATTENDANCE_LIST];
    NSSet *lowPartNameList = [[table objectForKey:lowPartName] objectForKey:ATTENDANCE_TABLE_ATTENDANCE_LIST];
    
    return [self attributedNameListWithPart:@[highPartName, lowPartName] andPartMemberList:@[highPartNameList, lowPartNameList]];
}

- (nonnull NSAttributedString *)attributedNameListWithPart:(NSArray *)partArray andPartMemberList:(NSArray *)partMemberArray
{
    if (partArray.count != partMemberArray.count) {
        return nil;
    }
    
    if (partArray.count <= 0) {
        return [[NSAttributedString alloc] initWithString:@""];
    }
    
    CGFloat fontSize = 14.0;
    UIFont *universalFont = [UIFont systemFontOfSize:fontSize];
    UIColor *partNameColor = [UIColor colorWithRed:0.0/255 green:122.0/255 blue:255.0/255 alpha:1.0];
    UIColor *zhongguancunColor = [UIColor blackColor];
    UIColor *yanqiColor = [UIColor lightGrayColor];
    NSDictionary *partNameAttribute = @{NSFontAttributeName : universalFont,
                                        NSForegroundColorAttributeName : partNameColor};
    NSDictionary *yanqiAttribute = @{NSFontAttributeName : universalFont,
                                     NSForegroundColorAttributeName : yanqiColor};
    NSDictionary *zhongguancunAttribute = @{NSFontAttributeName : universalFont,
                                            NSForegroundColorAttributeName : zhongguancunColor};
    
    NSMutableAttributedString *result = [[NSMutableAttributedString alloc] init];
    NSString *zone = nil;
    NSAttributedString *attributedName = nil;
    
    for (int index = 0; index < partArray.count; ++index) {
        NSString *part = [partArray objectAtIndex:index];
        NSArray *partNameList = [partMemberArray objectAtIndex:index];
        NSAttributedString *attributedPartName = [[NSAttributedString alloc] initWithString:[part stringByAppendingString:@"："] attributes:partNameAttribute];
        [result appendAttributedString:attributedPartName];
        
        for (NSString *name in partNameList) {
            zone = [self zoneOfMember:name inPart:part];
            if ([zone compare:ZivAttendanceZoneIdentifireZhongguancun] == NSOrderedSame) {
                attributedName = [[NSAttributedString alloc] initWithString:[name stringByAppendingString:@"、"] attributes:zhongguancunAttribute];
            } else if ([zone compare:ZivAttendanceZoneIdentifireYanqi] == NSOrderedSame) {
                attributedName = [[NSAttributedString alloc] initWithString:[name stringByAppendingString:@"、"] attributes:yanqiAttribute];
            }
            
            [result appendAttributedString:attributedName];
        }
        
        [result appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n" attributes:partNameAttribute]];
    }
    
    return result;
}

- (NSAttributedString *)part:(NSString *)part askForLeaveNameListInAttendanceTable:(NSString *)tableName
{
    NSDictionary *table = [self attendanceTableByName:tableName];
    NSString *highPartName = [part stringByAppendingString:@"1"];
    NSString *lowPartName = [part stringByAppendingString:@"2"];
    NSSet *highPartNameSet = [[table objectForKey:highPartName] objectForKey:ATTENDANCE_TABLE_ASK_FOR_LEAVE_LIST];
    NSSet *lowPartNameSet = [[table objectForKey:lowPartName] objectForKey:ATTENDANCE_TABLE_ASK_FOR_LEAVE_LIST];
    
    NSArray *highPartNameList = [highPartNameSet allObjects];
    NSArray *lowPartNameList = [lowPartNameSet allObjects];
    
    return [self attributedNameListWithPart:@[highPartName, lowPartName] andPartMemberList:@[highPartNameList, lowPartNameList]];
}

- (NSAttributedString *)part:(NSString *)part absenceNameListInAttendanceTable:(NSString *)tableName
{
    NSDictionary *table = [self attendanceTableByName:tableName];
    NSString *highPartName = [part stringByAppendingString:@"1"];
    NSString *lowPartName = [part stringByAppendingString:@"2"];
    
    NSSet *attendance_highPartNameSet = [[table objectForKey:highPartName] objectForKey:ATTENDANCE_TABLE_ATTENDANCE_LIST];
    NSSet *leave_highPartNameSet = [[table objectForKey:highPartName] objectForKey:ATTENDANCE_TABLE_ASK_FOR_LEAVE_LIST];
    NSMutableSet *all_highPartNameSet = [[NSMutableSet alloc] initWithArray:[self memberNameListOfPart:highPartName]];
    [all_highPartNameSet minusSet:attendance_highPartNameSet];
    [all_highPartNameSet minusSet:leave_highPartNameSet];
    
    NSSet *attendance_lowPartNameSet = [[table objectForKey:lowPartName] objectForKey:ATTENDANCE_TABLE_ATTENDANCE_LIST];
    NSSet *leave_lowPartNameSet = [[table objectForKey:lowPartName] objectForKey:ATTENDANCE_TABLE_ASK_FOR_LEAVE_LIST];
    NSMutableSet *all_lowPartNameSet = [[NSMutableSet alloc] initWithArray:[self memberNameListOfPart:lowPartName]];
    [all_lowPartNameSet minusSet:attendance_lowPartNameSet];
    [all_lowPartNameSet minusSet:leave_lowPartNameSet];
    
    NSArray *highPartNameList = [all_highPartNameSet allObjects];
    NSArray *lowPartNameList = [all_lowPartNameSet allObjects];
    
    return [self attributedNameListWithPart:@[highPartName, lowPartName] andPartMemberList:@[highPartNameList, lowPartNameList]];
}

/*
 * 单人出勤数据统计
 */
- (NSArray <NSString *> *)part:(NSString *)part attendanceStaticByName:(NSString *)name from:(NSString *)startTime to:(NSString *)endTime
{
    if (![self nameExist:name inPart:part]) {
        return nil;
    }
    
    // 找出在给定日期内的大排&小排签到表
//    NSMutableArray *zhongguancun_informal_satisfiedTableNameList = [NSMutableArray array];
//    NSMutableArray *zhongguancun_formal_satisfiedTableNameList = [NSMutableArray array];
//    NSMutableArray *yanqi_informal_satisfiedTableNameList = [NSMutableArray array];
//    NSMutableArray *yanqi_formal_satisfiedTableNameList = [NSMutableArray array];
    
    NSInteger zhongguancun_informal_attendance_count = 0;
    NSInteger zhongguancun_formal_attendance_count = 0;
    NSInteger yanqi_informal_attendance_count = 0;
    NSInteger yanqi_formal_attendance_count = 0;
    
    NSInteger zhongguancun_informal_attendance_table_count = 0;
    NSInteger zhongguancun_formal_attendance_table_count = 0;
    NSInteger yanqi_informal_attendance_table_count = 0;
    NSInteger yanqi_formal_attendance_table_count = 0;
    
    NSString *date = nil;
    BOOL attendance = NO;
    
    for (NSString *tableName in self.attendanceTableList) {
        date = [tableName substringToIndex:8];
        if (!([date compare:startTime] != NSOrderedAscending && [date compare:endTime] != NSOrderedDescending)) {
            continue;
        }
        
        attendance = [self part:part someone:name attendAt:tableName];
        
        if ([tableName containsString:@"小排"]) {
            if ([tableName containsString:ZivAttendanceZoneIdentifireZhongguancun]) {
                ++zhongguancun_informal_attendance_table_count;
                if (attendance) {
                    ++zhongguancun_informal_attendance_count;
                }
            } else if ([tableName containsString:ZivAttendanceZoneIdentifireYanqi]) {
                ++yanqi_informal_attendance_table_count;
                if (attendance) {
                    ++yanqi_informal_attendance_count;
                }
            }
        } else if ([tableName containsString:@"大排"]) {
            if ([tableName containsString:ZivAttendanceZoneIdentifireZhongguancun]) {
                ++zhongguancun_formal_attendance_table_count;
                if (attendance) {
                    ++zhongguancun_formal_attendance_count;
                }
            } else if ([tableName containsString:ZivAttendanceZoneIdentifireYanqi]) {
                ++yanqi_formal_attendance_table_count;
                if (attendance) {
                    ++yanqi_formal_attendance_count;
                }
            }
        }
    }
    
    NSString *zhongguancun_attendance_description = [NSString stringWithFormat:@"中关村大排%ld/%ld  ·  小排%ld/%ld",
                                                     (long)zhongguancun_formal_attendance_count,
                                                     (long)zhongguancun_formal_attendance_table_count,
                                                     (long)zhongguancun_informal_attendance_count,
                                                     (long)zhongguancun_informal_attendance_table_count];
    
    NSString *yanqi_atttendance_description = [NSString stringWithFormat:@"雁栖湖大排%ld/%ld  ·  小排%ld/%ld",
                                               (long)yanqi_formal_attendance_count,
                                               (long)yanqi_formal_attendance_table_count,
                                               (long)yanqi_informal_attendance_count,
                                               (long)yanqi_informal_attendance_table_count];
    
    return @[zhongguancun_attendance_description, yanqi_atttendance_description];
}

- (NSArray <NSString *> *)part:(NSString *)part last3WeekAttendanceStaticByName:(NSString *)name
{
    NSDate *current_date = [NSDate date];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyyMMdd"];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *comps = [calendar components:(NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear | NSCalendarUnitWeekday) fromDate:current_date];
    NSInteger current_weekday = comps.weekday;
    NSInteger current_day = comps.day;
    //NSLog(@"current_day:%ld,current_weekday:%ld", current_day, current_weekday);
    
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:3];
    
    for (NSInteger week_distance = 0; week_distance < 4; ++week_distance) {
        NSInteger wednesday_distance = 4 - current_weekday - 7 * week_distance;
        if (current_weekday == 1) {
            wednesday_distance -= 7;
        }
        NSDateComponents *wednesday_comps = [calendar components:(NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear | NSCalendarUnitWeekday) fromDate:current_date];
        [wednesday_comps setDay:current_day + wednesday_distance];
        NSDate *wednesday_date = [calendar dateFromComponents:wednesday_comps];
        NSString *wednesday_string = [self part:part someone:name attendAtDate:[dateFormat stringFromDate:wednesday_date]];
        
        
        NSInteger saturday_distance = 7 - current_weekday - 7 * week_distance;
        if (current_weekday == 1) {
            saturday_distance -= 7;
        }
        NSDateComponents *saturday_comps = [calendar components:(NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear | NSCalendarUnitWeekday) fromDate:current_date];
        [saturday_comps setDay:current_day + saturday_distance];
        NSDate *saturday_date = [calendar dateFromComponents:saturday_comps];
        NSString *saturday_string = [self part:part someone:name attendAtDate:[dateFormat stringFromDate:saturday_date]];
        
        NSInteger sunday_distance = 8 - current_weekday - 7 * week_distance;
        if (current_weekday == 1) {
            sunday_distance -= 7;
        }
        NSDateComponents *sunday_comps = [calendar components:(NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear | NSCalendarUnitWeekday) fromDate:current_date];
        [sunday_comps setDay:current_day + sunday_distance];
        NSDate *sunday_date = [calendar dateFromComponents:sunday_comps];
        NSString *sunday_string = [self part:part someone:name attendAtDate:[dateFormat stringFromDate:sunday_date]];
        
        NSString *week_string = @"本";
        if (week_distance == 1) {
            week_string = @"上";
        } else if (week_distance == 2) {
            week_string = @"隔";
        } else if (week_distance == 3) {
            week_string = @"次";
        }
        
        NSString *week_description = [NSString stringWithFormat:@"%@周三%@  ·  周六%@  ·  周日%@", week_string, wednesday_string, saturday_string, sunday_string];
        
        [result addObject:week_description];
    }
    
    return result;
}

// date = @"20160928"
// return 💤 OR ✔️ OR ✖️
- (NSString *)part:(NSString *)part someone:(NSString *)name attendAtDate:(NSString *)date
{
    //NSLog(@"query %@%@ attend at date:%@",part, name, date);
    
    BOOL isFreeday = YES;
    BOOL attended = NO;
    for (NSString *tableName in self.attendanceTableList) {
        if (![tableName containsString:date]) {
            continue;
        }
        
        isFreeday = NO;
        
        if ([self part:part someone:name attendAt:tableName]) {
            attended = YES;
            break;
        }
    }
    
    if (isFreeday) {
        return @"💤";
    } else {
        if (attended) {
            return @"✔️";
        } else {
            return @"✖️";
        }
    }
    
    return @"💤";
}


- (BOOL)part:(NSString *)part someone:(NSString *)name attendAt:(NSString *)attendanceTableName
{
    NSDictionary *table = [self attendanceTableByName:attendanceTableName];
    if (table == nil) {
        NSLog(@"alert! query attendance table:%@ which do not exist", attendanceTableName);
        return NO;
    }
    
    NSDictionary *part_info = [table objectForKey:part];
    if (part_info == nil) {
        NSLog(@"alert! query part:%@ which do not exist", part);
        return NO;
    }
    
    NSSet *attendance_set = [part_info objectForKey:ATTENDANCE_TABLE_ATTENDANCE_LIST];
    if (![attendance_set containsObject:name]) {
        return NO;
    }
    
    return YES;
}

@end
