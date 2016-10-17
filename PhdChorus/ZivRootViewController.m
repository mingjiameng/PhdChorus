//
//  ZivRootViewController.m
//  PhdChorusCommunity
//
//  Created by 梁志鹏 on 16/9/21.
//  Copyright © 2016年 PhdChorus. All rights reserved.
//

#import "ZivRootViewController.h"

#import "ZivInfoRegistTableViewController.h"
#import "ZivAttendanceTableListViewController.h"
#import "ZivStaticFunctionListViewController.h"
#import "ZivDBManager.h"

@interface ZivRootViewController ()

@property (nonatomic, strong) ZivAttendanceTableListViewController *attendanceTableListViewController;
@property (nonatomic, strong) ZivInfoRegistTableViewController *infoRegistViewController;
@property (nonatomic, strong) ZivStaticFunctionListViewController *staticFunctionListViewController;
@end

@implementation ZivRootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[ZivDBManager shareDatabaseManager] updateDatabaseVersion];
    
    _attendanceTableListViewController = [[ZivAttendanceTableListViewController alloc] init];
    _attendanceTableListViewController.title = @"签到";
    _attendanceTableListViewController.tabBarItem = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemBookmarks tag:0];
    _attendanceTableListViewController.usage = ZivAttendanceTableListUsageAsign;
    [self addChildViewController:[[UINavigationController alloc] initWithRootViewController:_attendanceTableListViewController]];
    
    _infoRegistViewController = [[ZivInfoRegistTableViewController alloc] init];
    _infoRegistViewController.title = @"团员信息";
    _infoRegistViewController.tabBarItem = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemContacts tag:0];
    [self addChildViewController:[[UINavigationController alloc] initWithRootViewController:_infoRegistViewController]];
    
    _staticFunctionListViewController = [[ZivStaticFunctionListViewController alloc] init];
    _staticFunctionListViewController.title = @"数据统计";
    _staticFunctionListViewController.tabBarItem = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemHistory tag:0];
    [self addChildViewController:[[UINavigationController alloc] initWithRootViewController:_staticFunctionListViewController]];
    
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
