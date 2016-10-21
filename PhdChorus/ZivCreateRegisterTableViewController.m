//
//  ZivCreateRegisterTableViewController.m
//  PhdChorusCommunity
//
//  Created by 梁志鹏 on 16/9/21.
//  Copyright © 2016年 PhdChorus. All rights reserved.
//

#import "ZivCreateRegisterTableViewController.h"

#import "ZivDBManager.h"

@interface ZivCreateRegisterTableViewController () <UIPickerViewDelegate, UIPickerViewDataSource>

@property (weak, nonatomic) IBOutlet UIPickerView *yearPickerView;
@property (weak, nonatomic) IBOutlet UIPickerView *monthPickerView;
@property (weak, nonatomic) IBOutlet UIPickerView *dayPickerView;
@property (weak, nonatomic) IBOutlet UISwitch *formalAttendanceSwitch;
@property (weak, nonatomic) IBOutlet UISegmentedControl *zoneSegment;

@property (weak, nonatomic) IBOutlet UILabel *yearLabel;
@property (weak, nonatomic) IBOutlet UILabel *monthLabel;
@property (weak, nonatomic) IBOutlet UILabel *dayLabel;

@property (nonatomic, strong) NSArray *yearArray;
@property (nonatomic, strong) NSArray *monthArray;
@property (nonatomic, strong) NSArray *dayArray;

@end



@implementation ZivCreateRegisterTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    if (self.usage == ZivCreateRegisterTableVCUsageCreate) {
        self.navigationItem.title = @"创建签到表";
    } else if (self.usage == ZivCreateRegisterTableVCUsageEdit) {
        self.navigationItem.title = @"编辑签到表";
    }
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
    
    [self configInputView];
}

- (void)cancel
{
    [self.navigationController dismissViewControllerAnimated:YES completion:NULL];
}

- (void)done
{
    NSString *date = [[self.yearLabel.text stringByAppendingString:self.monthLabel.text] stringByAppendingString:self.dayLabel.text];
    NSString *zone = [self.zoneSegment titleForSegmentAtIndex:[self.zoneSegment selectedSegmentIndex]];
    BOOL isFormalAttendance = self.formalAttendanceSwitch.on;
    
    BOOL success = YES;
    if (self.usage == ZivCreateRegisterTableVCUsageCreate) {
        success = [[ZivDBManager shareDatabaseManager] createAttendanceTableInDate:date atZone:zone whetherFormalAttendance:isFormalAttendance];
        
    } else if (self.usage == ZivCreateRegisterTableVCUsageEdit) {
        success = [[ZivDBManager shareDatabaseManager] editAttendanceTable:self.attendanceTableName inDate:date atZone:zone whetherFormalAttendance:isFormalAttendance];
    }
    
    if (!success) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"创建失败" message:@"签到表已存在" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"好" style:UIAlertActionStyleDefault handler:NULL];
        [alertController addAction:confirmAction];
        
        [self presentViewController:alertController animated:YES completion:NULL];
        
        return;
    }
    
    [self.navigationController dismissViewControllerAnimated:YES completion:NULL];
    
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (pickerView == self.yearPickerView) {
        return self.yearArray.count;
    } else if (pickerView == self.monthPickerView) {
        return self.monthArray.count;
    } else if (pickerView == self.dayPickerView) {
        return self.dayArray.count;
    }
    
    return 0;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (pickerView == self.yearPickerView) {
        return [self.yearArray objectAtIndex:row];
    } else if (pickerView == self.monthPickerView) {
        return [self.monthArray objectAtIndex:row];
    } else if (pickerView == self.dayPickerView) {
        return [self.dayArray objectAtIndex:row];
    }
    
    return @"";
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (pickerView == self.yearPickerView) {
        self.yearLabel.text = [self.yearArray objectAtIndex:row];
    } else if (pickerView == self.monthPickerView) {
        self.monthLabel.text = [self.monthArray objectAtIndex:row];
    } else if (pickerView == self.dayPickerView) {
        self.dayLabel.text = [self.dayArray objectAtIndex:row];
    }
}

- (void)configInputView
{
    self.yearPickerView.dataSource = self;
    self.yearPickerView.delegate = self;
    self.monthPickerView.dataSource = self;
    self.monthPickerView.delegate = self;
    self.dayPickerView.dataSource = self;
    self.dayPickerView.delegate = self;
    
    NSInteger year, month, day;
    if (self.usage == ZivCreateRegisterTableVCUsageCreate) {
        NSDateComponents *comps = [self currentYearMonthDay];
        year = comps.year;
        month = comps.month;
        day = comps.day;
    } else if (self.usage == ZivCreateRegisterTableVCUsageEdit) {
        NSString *yearString = [self.attendanceTableName substringWithRange:NSMakeRange(0, 4)];
        year = [yearString integerValue];
        NSString *monthString = [self.attendanceTableName substringWithRange:NSMakeRange(4, 2)];
        month = [monthString integerValue];
        NSString *dayString = [self.attendanceTableName substringWithRange:NSMakeRange(6, 2)];
        day = [dayString integerValue];
        
        NSString *zoneString = [self.attendanceTableName substringWithRange:NSMakeRange(10, 3)];
        if ([zoneString isEqualToString:ZivAttendanceZoneIdentifireYanqi]) {
            [self.zoneSegment setSelectedSegmentIndex:1];
        }
        
        NSString *formalString = [self.attendanceTableName substringWithRange:NSMakeRange(13, 2)];
        if ([formalString isEqualToString:@"小排"]) {
            self.formalAttendanceSwitch.on = NO;
        }
    }
    
    self.yearLabel.text = [NSString stringWithFormat:@"%ld", (long)year];
    self.monthLabel.text = [NSString stringWithFormat:@"%02ld", (long)month];
    self.dayLabel.text = [NSString stringWithFormat:@"%02ld", (long)day];
    
    [self.yearPickerView selectRow:(year - 2016) inComponent:0 animated:NO];
    [self.monthPickerView selectRow:(month - 1) inComponent:0 animated:NO];
    [self.dayPickerView selectRow:(day - 1) inComponent:0 animated:NO];
}

- (NSDateComponents *)currentYearMonthDay
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDate *currentDate = [NSDate date];
    
    NSDateComponents *comps = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:currentDate];

    return comps;
}

- (NSArray *)yearArray
{
    if (!_yearArray) {
        _yearArray = @[@"2016", @"2017"];
    }
    
    return _yearArray;
}

- (NSArray *)monthArray
{
    if (!_monthArray) {
        _monthArray = @[@"01", @"02", @"03", @"04", @"05", @"06", @"07", @"08", @"09", @"10", @"11", @"12"];
    }
    
    return _monthArray;
}

- (NSArray *)dayArray
{
    if (!_dayArray) {
        _dayArray = @[@"01", @"02", @"03", @"04", @"05", @"06", @"07", @"08", @"09", @"10", @"11", @"12", @"13", @"14", @"15", @"16", @"17", @"18", @"19", @"20", @"21", @"22", @"23", @"24", @"25", @"26", @"27", @"28", @"29", @"30", @"31"];
    }
    
    return _dayArray;
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
