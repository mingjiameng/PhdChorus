//
//  ZivExportExcelViewController.m
//  PhdChorusCommunity
//
//  Created by 梁志鹏 on 16/9/23.
//  Copyright © 2016年 PhdChorus. All rights reserved.
//

#import "ZivExportExcelViewController.h"

#import "ZivDBManager+Statics.h"
#import "zkeySandboxHelper.h"

@interface ZivExportExcelViewController ()

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityAnimator;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UIImageView *excelLogoImageView;

@property (strong, nonatomic) NSString *filePath;
@property (strong, nonatomic) NSString *fileName;

@end

@implementation ZivExportExcelViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.navigationItem.title = @"生成Excel文件";
    [self exportFile];
}

- (void)exportFile
{
    self.fileName = [NSString stringWithFormat:@"%@-%@签到表%@.xls", self.startTime, self.endTime, self.part];
    NSString *filePath = [[ZivDBManager shareDatabaseManager] exportAttendanceTableOfPart:self.part from:self.startTime to:self.endTime];
    
    if (filePath == nil) {
        [self.activityAnimator stopAnimating];
        self.messageLabel.text = @"文件导出失败";
        
    } else {
        [self.activityAnimator stopAnimating];
        self.messageLabel.text = self.fileName;
        self.excelLogoImageView.hidden = NO;
        self.filePath = filePath;
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(shareFile)];
        
    }
}

- (void)shareFile
{
    if (self.filePath == nil) {
        return;
    }
    
    NSURL *fileURL = [NSURL fileURLWithPath:self.filePath];
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:@[self.fileName, fileURL] applicationActivities:nil];
    
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

- (void)dealloc
{
    [zkeySandboxHelper deleteFileAtPath:self.filePath];
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
