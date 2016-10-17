//
//  ZivAttendanceTableListViewController.m
//  PhdChorusCommunity
//
//  Created by 梁志鹏 on 16/9/21.
//  Copyright © 2016年 PhdChorus. All rights reserved.
//

#import "ZivAttendanceTableListViewController.h"

#import "ZivCreateRegisterTableViewController.h"
#import "ZivDBManager.h"
#import "SHARED_MICRO.h"
#import "zkeySandboxHelper.h"
#import "ZivRegistOrLeaveViewController.h"
#import "ZivAttendanceStaticByDayViewController.h"
#import "ZivStaticsDayAttendanceViewController.h"

@interface ZivAttendanceTableListViewController ()

@property (nonatomic, strong) NSArray *registerTableList;

@end

@implementation ZivAttendanceTableListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    if (self.usage == ZivAttendanceTableListUsageAsign) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addRegisterTable)];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(backupAttendanceTable)];
    }
    
    self.navigationItem.title = @"签到表";
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTableView) name:REFRESH_ATTENDANCE_TABLE_LIST_NOTIFICATION object:nil];

}

- (void)backupAttendanceTable
{
    NSString *filePath = [[ZivDBManager shareDatabaseManager] backupAllAttendanceTable];
    if (filePath == nil) {
        return;
    }
    
    NSString *fileName = @"签到表备份.txt";
    NSURL *fileURL = [NSURL fileURLWithPath:filePath];
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

- (void)reloadTableView
{
    self.registerTableList = [[ZivDBManager shareDatabaseManager] attendanceTableList];
    [self.tableView reloadData];
}

- (void)addRegisterTable
{
    ZivCreateRegisterTableViewController *newTableVC = [[ZivCreateRegisterTableViewController alloc] init];
    
    [self.navigationController presentViewController:[[UINavigationController alloc] initWithRootViewController:newTableVC] animated:YES completion:NULL];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.registerTableList.count;
}

- (NSArray *)registerTableList
{
    return [[ZivDBManager shareDatabaseManager] attendanceTableList];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"register_table"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"register_table"];
    }
    // Configure the cell...
    cell.textLabel.text = [self.registerTableList objectAtIndex:indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (self.usage == ZivAttendanceTableListUsageAsign) {
        ZivRegistOrLeaveViewController *registerVC = [[ZivRegistOrLeaveViewController alloc] init];
        registerVC.hidesBottomBarWhenPushed = YES;
        registerVC.attendanceTableName = [self.registerTableList objectAtIndex:indexPath.row];
        
        [self.navigationController pushViewController:registerVC animated:YES];
        
    } else if (self.usage == ZivAttendanceTableListUsageStatic) {
//        ZivAttendanceStaticByDayViewController *dayStaticVC = [[ZivAttendanceStaticByDayViewController alloc] init];
        
        ZivStaticsDayAttendanceViewController *dayStaticVC = [[ZivStaticsDayAttendanceViewController alloc] init];
        dayStaticVC.attendanceTableName = [self.registerTableList objectAtIndex:indexPath.row];
        
        [self.navigationController pushViewController:dayStaticVC animated:YES];
        
    }
    
    
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:REFRESH_ATTENDANCE_TABLE_LIST_NOTIFICATION object:nil];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
