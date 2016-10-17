//
//  ZivStaticByNameViewController.m
//  PhdChorus
//
//  Created by 梁志鹏 on 16/10/14.
//  Copyright © 2016年 PhdChorus. All rights reserved.
//

#import "ZivStaticByNameViewController.h"

#import "ZivDBManager+Statics.h"

@interface ZivStaticByNameViewController ()

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *personalDetailInfoLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeIntervalLabel;
@property (weak, nonatomic) IBOutlet UILabel *staticLabel01;
@property (weak, nonatomic) IBOutlet UILabel *staticLabel02;

@property (weak, nonatomic) IBOutlet UILabel *weekAttendanceLabel01;
@property (weak, nonatomic) IBOutlet UILabel *weekAttendanceLabel02;
@property (weak, nonatomic) IBOutlet UILabel *weekAttendanceLabel03;
@property (weak, nonatomic) IBOutlet UILabel *weekAttendanceLabel04;

@end

@implementation ZivStaticByNameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self configInputView];
    [self calculateStatics];
}

- (void)configInputView
{
    self.navigationItem.title = @"个人出勤统计";
    self.nameLabel.text = self.name;
    self.personalDetailInfoLabel.text = [[ZivDBManager shareDatabaseManager] personalInfoDescriptionOfMember:self.name inPart:self.part];
    self.timeIntervalLabel.text = [NSString stringWithFormat:@"%@~%@签到统计", self.startTime, self.endTime];
}

- (void)calculateStatics
{
    NSArray *staticsArray = [[ZivDBManager shareDatabaseManager] part:self.part attendanceStaticByName:self.name from:self.startTime to:self.endTime];
    self.staticLabel01.text = [staticsArray objectAtIndex:0];
    self.staticLabel02.text = [staticsArray objectAtIndex:1];
    
    NSArray *weekStaticsArray = [[ZivDBManager shareDatabaseManager] part:self.part last3WeekAttendanceStaticByName:self.name];
    self.weekAttendanceLabel01.text = [weekStaticsArray objectAtIndex:0];
    self.weekAttendanceLabel02.text = [weekStaticsArray objectAtIndex:1];
    self.weekAttendanceLabel03.text = [weekStaticsArray objectAtIndex:2];
    self.weekAttendanceLabel04.text = [weekStaticsArray objectAtIndex:3];
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
