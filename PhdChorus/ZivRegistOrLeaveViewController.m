//
//  ZivRegistOrLeaveViewController.m
//  PhdChorusCommunity
//
//  Created by 梁志鹏 on 16/9/21.
//  Copyright © 2016年 PhdChorus. All rights reserved.
//

#import "ZivRegistOrLeaveViewController.h"

#import "ZivRegisterViewController.h"
#import "ZivAskForLeaveViewController.h"
#import "ZivDBManager.h"
#import <sys/utsname.h>
#import "zkeySandboxHelper.h"

@interface ZivRegistOrLeaveViewController ()

@property (weak, nonatomic) IBOutlet UIButton *registerButton;
@property (weak, nonatomic) IBOutlet UIButton *leaveButton;

@end

@implementation ZivRegistOrLeaveViewController

- (void)viewDidLoad {
    
    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.navigationItem.title = [self.regiterTableName stringByAppendingString:@"签到表"];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(shareRegisterTable:)];
    
}

- (void)shareRegisterTable:(UIBarButtonItem *)item
{
    NSString *fileName = self.regiterTableName;
    NSURL *fileURL = [[ZivDBManager shareDatabaseManager] publicUrlForAttendanceTable:fileName];
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:@[fileName, fileURL] applicationActivities:nil];
    
    NSString *device = [zkeySandboxHelper getDeviceString];
    if ([device hasPrefix:@"iPhone"]) {
        
    } else if ([device hasPrefix:@"iPad"]) {
        UIPopoverPresentationController *popOverVC = activityVC.popoverPresentationController;
        if (popOverVC) {
            popOverVC.sourceView = self.view;
            popOverVC.permittedArrowDirections = UIPopoverArrowDirectionUp;
        }
    }
    
    [self presentViewController:activityVC animated:YES completion:NULL];
}

- (IBAction)register:(UIButton *)sender
{
    ZivRegisterViewController *registerVC = [[ZivRegisterViewController alloc] init];
    registerVC.regiterTableName = self.regiterTableName;
    
    [self.navigationController pushViewController:registerVC animated:YES];
    
}

- (IBAction)leave:(UIButton *)sender
{
    ZivAskForLeaveViewController *leaveVC = [[ZivAskForLeaveViewController alloc] init];
    leaveVC.regiterTableName = self.regiterTableName;
    
    [self.navigationController pushViewController:leaveVC animated:YES];
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
