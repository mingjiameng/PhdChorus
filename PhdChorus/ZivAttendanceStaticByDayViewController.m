//
//  ZivAttendanceStaticByDayViewController.m
//  PhdChorusCommunity
//
//  Created by 梁志鹏 on 16/9/22.
//  Copyright © 2016年 PhdChorus. All rights reserved.
//

#import "ZivAttendanceStaticByDayViewController.h"

#import "ZivDBManager.h"
#import "ZivAttendanceByDayAndPartViewController.h"

@interface ZivAttendanceStaticByDayViewController ()
@property (weak, nonatomic) IBOutlet UILabel *s1StaticLabel;
@property (weak, nonatomic) IBOutlet UILabel *s2StaticLabel;
@property (weak, nonatomic) IBOutlet UILabel *a1StaticLabel;
@property (weak, nonatomic) IBOutlet UILabel *a2StaticLabel;
@property (weak, nonatomic) IBOutlet UILabel *t1StaticLabel;
@property (weak, nonatomic) IBOutlet UILabel *t2StaticLabel;
@property (weak, nonatomic) IBOutlet UILabel *b1StaticLabel;
@property (weak, nonatomic) IBOutlet UILabel *b2StaticLabel;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;


@property (strong, nonatomic) NSDictionary *attendanceTable;
@property (strong, nonatomic) NSArray *partList;

@end

@implementation ZivAttendanceStaticByDayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"签到统计";
    [self caculateStatics];
}

- (void)caculateStatics
{
    //NSLog(@"static table:%@", self.attendanceTable);
    
    self.titleLabel.text = [[self.attendanceTable objectForKey:ATTENDANCE_TABLE_NAME] stringByAppendingString:@"签到统计"];
    
    NSInteger s1_member_num = [[ZivDBManager shareDatabaseManager] numberOfMemberInPart:@"S1"];
    NSInteger s1_attendance_num = [self numberOfAttendenceInPart:@"S1"];
    self.s1StaticLabel.text = [NSString stringWithFormat:@"%ld/%ld", (long)s1_attendance_num, (long)s1_member_num];
    
    NSInteger s2_member_num = [[ZivDBManager shareDatabaseManager] numberOfMemberInPart:@"S2"];
    NSInteger s2_attendance_num = [self numberOfAttendenceInPart:@"S2"];
    self.s2StaticLabel.text = [NSString stringWithFormat:@"%ld/%ld", (long)s2_attendance_num, (long)s2_member_num];
    
    NSInteger a1_member_num = [[ZivDBManager shareDatabaseManager] numberOfMemberInPart:@"A1"];
    NSInteger a1_attendance_num = [self numberOfAttendenceInPart:@"A1"];
    self.a1StaticLabel.text = [NSString stringWithFormat:@"%ld/%ld", (long)a1_attendance_num, (long)a1_member_num];
    
    NSInteger a2_member_num = [[ZivDBManager shareDatabaseManager] numberOfMemberInPart:@"A2"];
    NSInteger a2_attendance_num = [self numberOfAttendenceInPart:@"A2"];
    self.a2StaticLabel.text = [NSString stringWithFormat:@"%ld/%ld", (long)a2_attendance_num, (long)a2_member_num];
    
    NSInteger t1_member_num = [[ZivDBManager shareDatabaseManager] numberOfMemberInPart:@"T1"];
    NSInteger t1_attendance_num = [self numberOfAttendenceInPart:@"T1"];
    self.t1StaticLabel.text = [NSString stringWithFormat:@"%ld/%ld", (long)t1_attendance_num, (long)t1_member_num];
    
    NSInteger t2_member_num = [[ZivDBManager shareDatabaseManager] numberOfMemberInPart:@"T2"];
    NSInteger t2_attendance_num = [self numberOfAttendenceInPart:@"T2"];
    self.t2StaticLabel.text = [NSString stringWithFormat:@"%ld/%ld", (long)t2_attendance_num, (long)t2_member_num];
    
    NSInteger b1_member_num = [[ZivDBManager shareDatabaseManager] numberOfMemberInPart:@"B1"];
    NSInteger b1_attendance_num = [self numberOfAttendenceInPart:@"B1"];
    self.b1StaticLabel.text = [NSString stringWithFormat:@"%ld/%ld", (long)b1_attendance_num, (long)b1_member_num];
    
    NSInteger b2_member_num = [[ZivDBManager shareDatabaseManager] numberOfMemberInPart:@"B2"];
    NSInteger b2_attendance_num = [self numberOfAttendenceInPart:@"B2"];
    self.b2StaticLabel.text = [NSString stringWithFormat:@"%ld/%ld", (long)b2_attendance_num, (long)b2_member_num];

}

- (NSInteger)numberOfAttendenceInPart:(NSString *)part
{
    NSDictionary *part_info = [self.attendanceTable objectForKey:part];
    if (part_info == nil) {
        return 0;
    }
    
    NSArray *part_attendance_list = [part_info objectForKey:ATTENDANCE_TABLE_ATTENDANCE_LIST];
    if (part_attendance_list == nil) {
        return 0;
    }
    
    return [part_attendance_list count];
}

- (IBAction)attendceStaticByPart:(UIButton *)sender
{
    NSString *part = [self.partList objectAtIndex:sender.tag];
    
    NSDictionary *part_attendance = [self.attendanceTable objectForKey:part];
    
    if (part_attendance == nil) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"签到表中没有该声部信息" message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"好" style:UIAlertActionStyleDefault handler:NULL];
        [alertController addAction:confirmAction];
        
        [self presentViewController:alertController animated:YES completion:NULL];
        
        return;
    }
    
    ZivAttendanceByDayAndPartViewController *partAttendanceVC = [[ZivAttendanceByDayAndPartViewController alloc] init];
    partAttendanceVC.part = part;
    partAttendanceVC.attendanceTable = self.attendanceTable;
    
    [self.navigationController pushViewController:partAttendanceVC animated:YES];
}

- (NSArray *)partList
{
    if (!_partList) {
        _partList = [[ZivDBManager shareDatabaseManager] partList];
    }
    
    return _partList;
}

- (NSDictionary *)attendanceTable
{
    if (!_attendanceTable) {
        _attendanceTable = [[ZivDBManager shareDatabaseManager] attendanceTableByName:self.attendanceTableName];
    }
    
    return _attendanceTable;
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
