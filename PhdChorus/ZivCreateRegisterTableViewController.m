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
    
    self.navigationItem.title = @"创建签到表";
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
    NSString *name = [date stringByAppendingString:(self.formalAttendanceSwitch.on ? @"大排" : @"小排")];
    if (![[ZivDBManager shareDatabaseManager] createAttendanceTable:name inDate:date withDescription:self.formalAttendanceSwitch.on]) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"创建失败" message:@"签到表已存在" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"好" style:UIAlertActionStyleDefault handler:NULL];
        [alertController addAction:confirmAction];
        
        [self presentViewController:alertController animated:YES completion:NULL];
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
    
    NSDateComponents *comps = [self currentYearMonthDay];
    self.yearLabel.text = [NSString stringWithFormat:@"%ld", (long)comps.year];
    self.monthLabel.text = [NSString stringWithFormat:@"%02ld", (long)comps.month];
    self.dayLabel.text = [NSString stringWithFormat:@"%02ld", (long)comps.day];
    
    [self.yearPickerView selectRow:(comps.year - 2016) inComponent:0 animated:NO];
    [self.monthPickerView selectRow:(comps.month - 1) inComponent:0 animated:NO];
    [self.dayPickerView selectRow:(comps.day - 1) inComponent:0 animated:NO];
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
