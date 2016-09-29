//
//  ZivMergeAttendanceTableViewController.m
//  PhdChorusCommunity
//
//  Created by 梁志鹏 on 16/9/22.
//  Copyright © 2016年 PhdChorus. All rights reserved.
//

#import "ZivMergeAttendanceTableViewController.h"
#import "ZivDBManager.h"

@interface ZivMergeAttendanceTableViewController ()

@property (weak, nonatomic) IBOutlet UILabel *attendanceTableNameLabel;

@end

@implementation ZivMergeAttendanceTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.navigationItem.title = @"合并签到表";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];

    self.attendanceTableNameLabel.text = self.fileName;
    
}

- (void)cancel
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)mergeAttendanceTable:(UIButton *)sender
{
    [sender setTitle:@"正在合并..." forState:UIControlStateDisabled];
    sender.enabled = NO;
    
    if ([[ZivDBManager shareDatabaseManager] mergeAttendanceTableToLocalDatabase:self.attendanceTableData]) {
        
        [sender setTitle:@"合并成功" forState:UIControlStateDisabled];
        
        [self performSelector:@selector(cancel) withObject:nil afterDelay:2.0];
        
    }
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
