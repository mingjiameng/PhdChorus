//
//  ZivRegisterViewController.h
//  PhdChorusCommunity
//
//  Created by 梁志鹏 on 16/9/21.
//  Copyright © 2016年 PhdChorus. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, ZivRegisterViewControllerUsage) {
    ZivRegisterViewControllerUsageSignUp = 1,
    ZivRegisterViewControllerUsageAskForLeave = 2,
    ZivRegisterViewControllerUsageAbsent = 3
};

@interface ZivRegisterViewController : UIViewController

@property (nonatomic, strong) NSString *attendanceTableName;
@property (nonatomic) ZivRegisterViewControllerUsage usage;

@end
