//
//  ZivDayAttendanceViewController.h
//  PhdChorus
//
//  Created by 梁志鹏 on 16/10/4.
//  Copyright © 2016年 PhdChorus. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZivDayAttendanceViewController : UIViewController

@property (nonatomic, strong, nonnull) NSString *part; // S | A | T | B
@property (nonatomic, strong, nonnull) NSString *attendanceTableName;

@end
