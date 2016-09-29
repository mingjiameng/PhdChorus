//
//  ZivAttendanceTableListViewController.h
//  PhdChorusCommunity
//
//  Created by 梁志鹏 on 16/9/21.
//  Copyright © 2016年 PhdChorus. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, ZivAttendanceTableListUsage) {
    ZivAttendanceTableListUsageAsign = 1, // 用作签到
    ZivAttendanceTableListUsageStatic = 2 // 用作统计
};

@interface ZivAttendanceTableListViewController : UITableViewController

@property (nonatomic) ZivAttendanceTableListUsage usage;

@end
