//
//  ZivStaticsDayAttendanceViewController.m
//  PhdChorus
//
//  Created by 梁志鹏 on 16/10/3.
//  Copyright © 2016年 PhdChorus. All rights reserved.
//

#import "ZivStaticsDayAttendanceViewController.h"

#import "ZivDBManager+Statics.h"

#import "ZivDayAttendanceViewController.h"

@interface ZivStaticsDayAttendanceViewController () <UITableViewDelegate>

@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *attendanceCountLabels;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *absenceCountLabels;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *zhongguancunAttendanceCountLabels;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *yanqiAttendanceCountLabels;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *partAttendanceLabels;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;


@end

@implementation ZivStaticsDayAttendanceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"签到统计";
    self.titleLabel.text = self.attendanceTableName;
    [self calculateStatics];
}

- (void)calculateStatics
{
    NSArray *partArray = @[ZivChorusPartS, ZivChorusPartA, ZivChorusPartT, ZivChorusPartB];
    NSInteger member_count_high_part, member_count_low_part;
    NSInteger member_count_zone_zhongguancun, member_count_zone_yanqi;
    NSInteger attendance_count_high_part, attendance_count_low_part;
    NSInteger absence_count_high_part, absence_count_low_part;
    NSInteger attendance_count_zone_zhongguancun, attendance_count_zone_yanqi;
    NSString *partName = nil;
    UILabel *attendanceCountLabel, *absenceCountLabel, *zhongguancunAttendanceCountLabel, *yanqiAttendanceCountLabel;
    UILabel *highPartAttendanceLabel, *lowPartAttendanceLabel;
    
    for (NSInteger i = 0; i < partArray.count; ++i) {
        partName = [partArray objectAtIndex:i];
        [[ZivDBManager shareDatabaseManager] part:partName memberCountOfHighPart:&member_count_high_part andLowPart:&member_count_low_part];
        [[ZivDBManager shareDatabaseManager] part:partName memberCountOfZhongguancun:&member_count_zone_zhongguancun andYanqi:&member_count_zone_yanqi];
        [[ZivDBManager shareDatabaseManager] part:partName absenceCountOfHighPart:&absence_count_high_part andLowPart:&absence_count_low_part inAttendanceTable:self.attendanceTableName];
        [[ZivDBManager shareDatabaseManager] part:partName attendanceCountOfHighPart:&attendance_count_high_part andLowPart:&attendance_count_low_part inAttendanceTable:self.attendanceTableName];
        [[ZivDBManager shareDatabaseManager] part:partName attendanceCountOfZhongguancun:&attendance_count_zone_zhongguancun andYanqi:&attendance_count_zone_yanqi inAttendanceTable:self.attendanceTableName];
        
        attendanceCountLabel = [self attendanceCountLabelOfPart:partName];
        absenceCountLabel = [self absenceCountLabelOfPart:partName];
        zhongguancunAttendanceCountLabel = [self zhongguancunCountLabelOfPart:partName];
        yanqiAttendanceCountLabel = [self yanqiCountLabelOfPart:partName];
        highPartAttendanceLabel = [self highPartCountLabelOfPart:partName];
        lowPartAttendanceLabel = [self lowPartCountLabelOfPart:partName];
        
        attendanceCountLabel.text = [NSString stringWithFormat:@"出勤 %ld", (attendance_count_high_part + attendance_count_low_part)];
        absenceCountLabel.text = [NSString stringWithFormat:@"请假 %ld", (absence_count_high_part + absence_count_low_part)];
        zhongguancunAttendanceCountLabel.text = [NSString stringWithFormat:@"%ld/%ld", attendance_count_zone_zhongguancun, member_count_zone_zhongguancun];
        yanqiAttendanceCountLabel.text = [NSString stringWithFormat:@"%ld/%ld", attendance_count_zone_yanqi, member_count_zone_yanqi];
        lowPartAttendanceLabel.text = [NSString stringWithFormat:@"%ld/%ld", attendance_count_low_part, member_count_low_part];
        highPartAttendanceLabel.text = [NSString stringWithFormat:@"%ld/%ld", attendance_count_high_part, member_count_high_part];
        
        
    }
}

- (UILabel *)attendanceCountLabelOfPart:(NSString *)part
{
    NSInteger tagID = [self tagIdOfPart:part];
    return [self labelWithTagID:tagID inLabelArray:self.attendanceCountLabels];
}

- (UILabel *)absenceCountLabelOfPart:(NSString *)part
{
    NSInteger tagID = [self tagIdOfPart:part];
    return [self labelWithTagID:tagID inLabelArray:self.absenceCountLabels];
}

- (UILabel *)zhongguancunCountLabelOfPart:(NSString *)part
{
    NSInteger tagID = [self tagIdOfPart:part];
    return [self labelWithTagID:tagID inLabelArray:self.zhongguancunAttendanceCountLabels];
}

- (UILabel *)yanqiCountLabelOfPart:(NSString *)part
{
    NSInteger tagID = [self tagIdOfPart:part];
    return [self labelWithTagID:tagID inLabelArray:self.yanqiAttendanceCountLabels];
}

- (UILabel *)highPartCountLabelOfPart:(NSString *)part
{
    NSInteger tagID = [self tagIdOfPart:part];
    tagID *= 2;
    tagID += 0;
    return [self labelWithTagID:tagID inLabelArray:self.partAttendanceLabels];
}

- (UILabel *)lowPartCountLabelOfPart:(NSString *)part
{
    NSInteger tagID = [self tagIdOfPart:part];
    tagID *= 2;
    tagID += 1;
    return [self labelWithTagID:tagID inLabelArray:self.partAttendanceLabels];
}

- (NSInteger)tagIdOfPart:(NSString *)part
{
    if ([part compare:ZivChorusPartS] == NSOrderedSame) {
        return 0;
    } else if ([part compare:ZivChorusPartA] == NSOrderedSame) {
        return 1;
    } else if ([part compare:ZivChorusPartT] == NSOrderedSame) {
        return 2;
    } else if ([part compare:ZivChorusPartB] == NSOrderedSame) {
        return 3;
    }
    
    return -1;
}

- (NSString *)partOfTagID:(NSInteger)tagID
{
    switch (tagID) {
        case 0:
            return ZivChorusPartS;
            break;
        case 1:
            return ZivChorusPartA;
            break;
        case 2:
            return ZivChorusPartT;
            break;
        case 3:
            return ZivChorusPartB;
            break;
            
        default:
            break;
    }
    
    return nil;
}

- (nullable UILabel *)labelWithTagID:(NSInteger)tagID inLabelArray:(NSArray *)labelArray
{
    for (UILabel *label in labelArray) {
        if (label.tag == tagID) {
            return label;
        }
    }
    
    NSLog(@"can't find label with tagID:%ld", (long)tagID);
    
    return nil;
}

- (IBAction)selectPart:(UIButton *)sender
{
    NSLog(@"touched");
    
    NSString *part = [self partOfTagID:sender.tag];
    ZivDayAttendanceViewController *dayVC = [[ZivDayAttendanceViewController alloc] init];
    dayVC.part = part;
    dayVC.attendanceTableName = self.attendanceTableName;
    [self.navigationController pushViewController:dayVC animated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
