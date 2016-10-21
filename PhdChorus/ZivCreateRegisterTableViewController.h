//
//  ZivCreateRegisterTableViewController.h
//  PhdChorusCommunity
//
//  Created by 梁志鹏 on 16/9/21.
//  Copyright © 2016年 PhdChorus. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, ZivCreateRegisterTableVCUsage) {
    ZivCreateRegisterTableVCUsageCreate = 1,
    ZivCreateRegisterTableVCUsageEdit = 2
};

@interface ZivCreateRegisterTableViewController : UIViewController

@property (nonatomic) ZivCreateRegisterTableVCUsage usage;

// nonnull when ZivCreateRegisterTableVCUsage = Edit
@property (nonatomic, strong, nonnull) NSString *attendanceTableName;

@end
