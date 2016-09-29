//
//  ZivStaticFunctionListViewController.m
//  PhdChorusCommunity
//
//  Created by 梁志鹏 on 16/9/22.
//  Copyright © 2016年 PhdChorus. All rights reserved.
//

#import "ZivStaticFunctionListViewController.h"
#import "ZivAttendanceTableListViewController.h"
#import "ZivSelectStartEndTimeViewController.h"

@interface ZivStaticFunctionListViewController ()

@end

@implementation ZivStaticFunctionListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (IBAction)attendanceStaticsByDay:(UIButton *)sender
{
    ZivAttendanceTableListViewController *attendanceTableListVC = [[ZivAttendanceTableListViewController alloc] init];
    attendanceTableListVC.usage = ZivAttendanceTableListUsageStatic;
    attendanceTableListVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:attendanceTableListVC animated:YES];
}

- (IBAction)exportAttendanceExcelFile:(UIButton *)sender
{
    ZivSelectStartEndTimeViewController *selectTimeVC = [[ZivSelectStartEndTimeViewController alloc] init];
    selectTimeVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:selectTimeVC animated:YES];
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
