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
            NSString *tableDate = [tableName substringToIndex:8];
            
            NSDictionary *part_sign_info = [table objectForKey:part];
            NSSet *attendance_set = [part_sign_info objectForKey:ATTENDANCE_TABLE_ATTENDANCE_LIST];
            
            NSString *name = nil;
            
            //NSLog(@"tableName:%@, tableDate:%@", tableName, tableDate);
            
            // 在当前行写下签到表名称
            xlSheetWriteStrA(sheet, currentRow, currentColumn, [tableDate UTF8String], 0);
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
- (void)part:(NSString *)part memberCountOfHighPart:(int *)highPartCount andLowPart:(int *)lowPartCount
{
    NSString *hightPartName = [part stringByAppendingString:@"1"];
    NSString *lowPartName = [part stringByAppendingString:@"2"];
    
    *highPartCount = (int)[[[self.member_info_db objectForKey:hightPartName] allKeys] count];
    *lowPartCount = (int)[[[self.member_info_db objectForKey:lowPartName] allKeys] count];
}

- (void)part:(NSString *)part memberCountOfZhongguancun:(int *)zhongguancunCount andYanqi:(int *)yanqiCount
{
    NSString *hightPartName = [part stringByAppendingString:@"1"];
    NSString *lowPartName = [part stringByAppendingString:@"2"];
    NSArray *partArray = @[hightPartName, lowPartName];
    
    int yanqi_tmp = 0, zhongguancun_tmp = 0;
    
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

- (void)part:(NSString *)part attendanceCountOfHighPart:(int *)highPartCount andLowPart:(int *)lowPartCount inAttendanceTable:(nonnull NSString *)tableName
{
    NSString *hightPartName = [part stringByAppendingString:@"1"];
    NSString *lowPartName = [part stringByAppendingString:@"2"];
    NSDictionary *attendanceTable = [self attendanceTableByName:tableName];
    
    int high_part_count = (int)[[[attendanceTable objectForKey:hightPartName] objectForKey:ATTENDANCE_TABLE_ATTENDANCE_LIST] count];
    int low_part_count = (int)[[[attendanceTable objectForKey:lowPartName] objectForKey:ATTENDANCE_TABLE_ATTENDANCE_LIST] count];
    
    *highPartCount = high_part_count;
    *lowPartCount = low_part_count;
}

- (void)part:(NSString *)part attendanceCountOfZhongguancun:(int *)zhongguancunCount andYanqi:(int *)yanqiCount inAttendanceTable:(nonnull NSString *)tableName
{
    NSString *hightPartName = [part stringByAppendingString:@"1"];
    NSString *lowPartName = [part stringByAppendingString:@"2"];
    NSDictionary *attendanceTable = [self attendanceTableByName:tableName];
    
    NSSet *hight_part_attendance_list = [[attendanceTable objectForKey:hightPartName] objectForKey:ATTENDANCE_TABLE_ATTENDANCE_LIST];
    NSSet *low_part_attendance_list = [[attendanceTable objectForKey:lowPartName] objectForKey:ATTENDANCE_TABLE_ATTENDANCE_LIST];
    
    int zhongguancun_count = 0, yanqi_count = 0;
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

- (void)part:(NSString *)part absenceCountOfHighPart:(int *)highPartCount andLowPart:(int *)lowPartCount inAttendanceTable:(nonnull NSString *)tableName
{
    NSString *hightPartName = [part stringByAppendingString:@"1"];
    NSString *lowPartName = [part stringByAppendingString:@"2"];
    NSDictionary *attendanceTable = [self attendanceTableByName:tableName];
    
    int high_part_count = (int)[[[attendanceTable objectForKey:hightPartName] objectForKey:ATTENDANCE_TABLE_ASK_FOR_LEAVE_LIST] count];
    int low_part_count = (int)[[[attendanceTable objectForKey:lowPartName] objectForKey:ATTENDANCE_TABLE_ASK_FOR_LEAVE_LIST] count];
    
    *highPartCount = high_part_count;
    *lowPartCount = low_part_count;
}

@end
