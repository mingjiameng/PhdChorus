//
//  ZivInfoRegistTableViewController.m
//  PhdChorusCommunity
//
//  Created by 梁志鹏 on 16/9/21.
//  Copyright © 2016年 PhdChorus. All rights reserved.
//

#import "ZivInfoRegistTableViewController.h"

#import "ZivDBManager.h"
#import "ZivAddContactViewController.h"
#import "SHARED_MICRO.h"
@interface ZivInfoRegistTableViewController ()

@property (nonatomic, strong, nonnull) NSArray *partIndex;
@property (nonatomic, strong, nonnull) NSDictionary *memberInfoFromDB;
@property (nonatomic, strong, nonnull) NSMutableArray *infoList;

@end

@implementation ZivInfoRegistTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self loadTableViewInfo];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addContact)];
    self.navigationItem.title = @"团员列表";
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doneAddContact) name:ADD_CONTACT_NOTIFICATION object:nil];
}


- (void)addContact
{
    ZivAddContactViewController *addInfoVC = [[ZivAddContactViewController alloc] init];
    [self.navigationController presentViewController:[[UINavigationController alloc] initWithRootViewController:addInfoVC] animated:YES completion:NULL];
}

- (void)doneAddContact
{
    [self loadTableViewInfo];
    
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.partIndex.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self.infoList objectAtIndex:section] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"contact"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"contact"];
    }
    
    NSString *part = [self.partIndex objectAtIndex:indexPath.section];
    NSString *name = [[self.infoList objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    NSDictionary *info = [[self.memberInfoFromDB objectForKey:part] objectForKey:name];
    // Configure the cell...
    cell.textLabel.text = name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@届%@ %@", [info objectForKey:@"stage"], part, [info objectForKey:@"zone"]];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return self.partIndex;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [self.partIndex objectAtIndex:section];
}



// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        NSString *part = [self.partIndex objectAtIndex:indexPath.section];
        NSString *name = [[self.infoList objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        if ([[ZivDBManager shareDatabaseManager] deleteMemberInfo:name fromPart:part]) {
            [[self.infoList objectAtIndex:indexPath.section] removeObjectAtIndex:indexPath.row];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
        
    }
    
}

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

- (NSArray *)partIndex
{
    if (!_partIndex) {
        _partIndex = CHORUS_PART_LIST;
    }
    
    return _partIndex;
}

- (void)loadTableViewInfo
{
    self.memberInfoFromDB = [[ZivDBManager shareDatabaseManager] member_info_db];
    
    NSMutableArray *info = [[NSMutableArray alloc] initWithCapacity:8];
    for (NSString *part in self.partIndex) {
        NSDictionary *part_info_dic = [self.memberInfoFromDB objectForKey:part];
        if (part_info_dic == nil) {
            part_info_dic = [NSDictionary dictionary];
        }
        
        [info addObject:[NSMutableArray arrayWithArray:[part_info_dic allKeys]]];
    }
    
    self.infoList = info;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ADD_CONTACT_NOTIFICATION object:nil];
}

@end
