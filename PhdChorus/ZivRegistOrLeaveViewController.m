//
//  ZivRegistOrLeaveViewController.m
//  PhdChorusCommunity
//
//  Created by 梁志鹏 on 16/9/21.
//  Copyright © 2016年 PhdChorus. All rights reserved.
//

#import "ZivRegistOrLeaveViewController.h"

#import "ZivRegisterViewController.h"
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
    
    self.navigationItem.title = [self.attendanceTableName stringByAppendingString:@"签到表"];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(shareRegisterTable:)];
    
}

- (void)shareRegisterTable:(UIBarButtonItem *)item
{
    NSString *fileName = self.attendanceTableName;
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

- (IBAction)signUp:(UIButton *)sender
{
    ZivRegisterViewController *registerVC = [[ZivRegisterViewController alloc] init];
    registerVC.attendanceTableName = self.attendanceTableName;
    registerVC.usage = ZivRegisterViewControllerUsageSignUp;
    
    [self.navigationController pushViewController:registerVC animated:YES];
    
}

- (IBAction)leave:(UIButton *)sender
{
    ZivRegisterViewController *registerVC = [[ZivRegisterViewController alloc] init];
    registerVC.attendanceTableName = self.attendanceTableName;
    registerVC.usage = ZivRegisterViewControllerUsageAskForLeave;
    
    [self.navigationController pushViewController:registerVC animated:YES];
}

- (IBAction)setAbsent:(UIButton *)sender
{
    ZivRegisterViewController *registerVC = [[ZivRegisterViewController alloc] init];
    registerVC.attendanceTableName = self.attendanceTableName;
    registerVC.usage = ZivRegisterViewControllerUsageAbsent;
    
    [self.navigationController pushViewController:registerVC animated:YES];
}


- (IBAction)deleteAttendanceTable:(UIButton *)sender
{
    NSString *msg = [NSString stringWithFormat:@"删除%@签到表", self.attendanceTableName];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"确认删除？" message:msg preferredStyle:UIAlertControllerStyleAlert];
    __weak typeof(self) weakSelf = self;
    UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf confirmDeleteAttendanceTable];
    }];
    [alertController addAction:deleteAction];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:NULL];
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:YES completion:NULL];
}

- (void)confirmDeleteAttendanceTable
{
    if ([[ZivDBManager shareDatabaseManager] deleteAttendanceTable:self.attendanceTableName]) {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"删除失败" message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"好" style:UIAlertActionStyleCancel handler:NULL];
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:YES completion:NULL];
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
