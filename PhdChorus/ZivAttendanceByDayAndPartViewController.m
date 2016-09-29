//
//  ZivAttendanceByDayAndPartViewController.m
//  PhdChorusCommunity
//
//  Created by 梁志鹏 on 16/9/22.
//  Copyright © 2016年 PhdChorus. All rights reserved.
//

#import "ZivAttendanceByDayAndPartViewController.h"
#import "ZivDBManager.h"

@interface ZivAttendanceByDayAndPartViewController ()
@property (weak, nonatomic) IBOutlet UITextView *attendaceTextView;
@property (weak, nonatomic) IBOutlet UITextView *leaveTextView;
@property (weak, nonatomic) IBOutlet UITextView *absenceTextView;

@end

@implementation ZivAttendanceByDayAndPartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = [NSString stringWithFormat:@"%@%@出勤情况", [self.attendanceTable objectForKey:ATTENDANCE_TABLE_NAME], self.part];
    [self calculateStatic];
}

- (void)calculateStatic
{
    NSDictionary *part_info = [self.attendanceTable objectForKey:self.part];
    
    NSSet *attendance_set = [part_info objectForKey:ATTENDANCE_TABLE_ATTENDANCE_LIST];
    NSArray *attendance_list = [attendance_set allObjects];
    NSMutableString *attendance_txt = [NSMutableString string];
    for (NSString *name in attendance_list) {
        [attendance_txt appendString:name];
        [attendance_txt appendString:@"、"];
    }
    self.attendaceTextView.text = attendance_txt;
    
    NSSet *leave_set = [part_info objectForKey:ATTENDANCE_TABLE_ASK_FOR_LEAVE_LIST];
    NSArray *leave_list = [leave_set allObjects];
    NSMutableString *leave_txt = [NSMutableString string];
    for (NSString *name in leave_list) {
        [leave_txt appendString:name];
        [leave_txt appendString:@"、"];
    }
    self.leaveTextView.text = leave_txt;
    
    NSArray *all_member_list = [[[[ZivDBManager shareDatabaseManager] member_info] objectForKey:self.part] allKeys];
    NSMutableSet *all_member_set = [NSMutableSet setWithArray:all_member_list];
    [all_member_set minusSet:attendance_set];
    [all_member_set minusSet:leave_set];
    NSMutableString *absence_txt = [NSMutableString string];
    for (NSString *name in all_member_set.allObjects) {
        [absence_txt appendString:name];
        [absence_txt appendString:@"、"];
    }
    self.absenceTextView.text = absence_txt;
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
