//
//  ZivDayAttendanceViewController.m
//  PhdChorus
//
//  Created by 梁志鹏 on 16/10/4.
//  Copyright © 2016年 PhdChorus. All rights reserved.
//

#import "ZivDayAttendanceViewController.h"

#import "ZivDBManager+Statics.h"

@interface ZivDayAttendanceViewController ()

@property (weak, nonatomic) IBOutlet UITextView *attendanceTextView;
@property (weak, nonatomic) IBOutlet UITextView *askForLeaveTextView;
@property (weak, nonatomic) IBOutlet UITextView *absenceTextView;

@end

@implementation ZivDayAttendanceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = [NSString stringWithFormat:@"%@%@出勤", self.attendanceTableName, self.part];
    [self calculateStatics];
}

- (void)calculateStatics
{
    self.attendanceTextView.attributedText = [[ZivDBManager shareDatabaseManager] part:self.part attendanceNameListInAttendanceTable:self.attendanceTableName];
    self.askForLeaveTextView.attributedText = [[ZivDBManager shareDatabaseManager] part:self.part askForLeaveNameListInAttendanceTable:self.attendanceTableName];
    self.absenceTextView.attributedText = [[ZivDBManager shareDatabaseManager] part:self.part absenceNameListInAttendanceTable:self.attendanceTableName];
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
