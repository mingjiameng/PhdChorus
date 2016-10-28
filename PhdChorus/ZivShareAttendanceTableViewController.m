//
//  ZivShareAttendanceTableViewController.m
//  PhdChorus
//
//  Created by 梁志鹏 on 16/10/26.
//  Copyright © 2016年 PhdChorus. All rights reserved.
//

#import "ZivShareAttendanceTableViewController.h"
#import "ZivDBManager.h"
#import "zkeySandboxHelper.h"

@interface ZivShareAttendanceTableViewController ()

@property (nonatomic, strong, nonnull) NSArray *registerTableList;

@end

@implementation ZivShareAttendanceTableViewController
{
    bool is_row_selected[1000];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancel)];
    UIBarButtonItem *allItem = [[UIBarButtonItem alloc] initWithTitle:@"全选" style:UIBarButtonItemStylePlain target:self action:@selector(selectAll)];
    self.navigationItem.leftBarButtonItems = @[cancelItem, allItem];
    self.navigationItem.title = @"批量分享签到表";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"分享" style:UIBarButtonItemStyleDone target:self action:@selector(done)];
    
    memset(is_row_selected, 0, sizeof(is_row_selected));
}

- (void)cancel
{
    [self.navigationController dismissViewControllerAnimated:YES completion:NULL];
}

- (void)selectAll
{
    memset(is_row_selected, 1, sizeof(is_row_selected));
    [self.tableView reloadData];
}

- (void)done
{
    NSMutableArray *selectedTableArray = [NSMutableArray array];
    for (int i = 0; i < self.registerTableList.count; ++i) {
        if (is_row_selected[i]) {
            [selectedTableArray addObject:[self.registerTableList objectAtIndex:i]];
        }
    }
    
    if (selectedTableArray.count <= 0) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"请选择至少一张签到表" message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"好" style:UIAlertActionStyleDefault handler:NULL];
        [alertController addAction:confirmAction];
        
        [self presentViewController:alertController animated:YES completion:NULL];
        return;
    }
    
    NSString *filePath = [[ZivDBManager shareDatabaseManager] shareAttendanceTable:selectedTableArray];
    if (filePath == nil) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"分享失败" message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"好" style:UIAlertActionStyleDefault handler:NULL];
        [alertController addAction:confirmAction];
        
        [self presentViewController:alertController animated:YES completion:NULL];
        return;
    }
    
    NSString *fileName = [NSString stringWithFormat:@"%@等%ld张签到表.pdf", [selectedTableArray firstObject], (unsigned long)selectedTableArray.count];
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"register_table"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"register_table"];
    }
    
    // Configure the cell...
    cell.textLabel.text = [self.registerTableList objectAtIndex:indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    if (is_row_selected[indexPath.row]) {
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    } else {
        [cell setAccessoryType:UITableViewCellAccessoryNone];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (is_row_selected[indexPath.row]) {
        [[tableView cellForRowAtIndexPath:indexPath] setAccessoryType:UITableViewCellAccessoryNone];
    } else {
        [[tableView cellForRowAtIndexPath:indexPath] setAccessoryType:UITableViewCellAccessoryCheckmark];
    }
    
    is_row_selected[indexPath.row] = !is_row_selected[indexPath.row];
}

- (NSArray *)registerTableList
{
    if (!_registerTableList) {
        _registerTableList = [[ZivDBManager shareDatabaseManager] attendanceTableList];
    }
    
    return _registerTableList;
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
