//
//  ZivSelectStartEndTimeViewController.m
//  PhdChorusCommunity
//
//  Created by 梁志鹏 on 16/9/23.
//  Copyright © 2016年 PhdChorus. All rights reserved.
//

#import "ZivSelectStartEndTimeViewController.h"

#import "ZivExportExcelViewController.h"
@interface ZivSelectStartEndTimeViewController () <UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIPickerView *yearPickerView;
@property (weak, nonatomic) IBOutlet UIPickerView *monthPickerView;
@property (weak, nonatomic) IBOutlet UIPickerView *dayPickerView;
@property (weak, nonatomic) IBOutlet UIPickerView *partPickerView;

@property (weak, nonatomic) IBOutlet UITextField *startTimeTextField;
@property (weak, nonatomic) IBOutlet UITextField *endTimeTextField;
@property (weak, nonatomic) IBOutlet UITextField *partTextField;

@property (weak, nonatomic) IBOutlet UILabel *startTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *endTimeLabel;


@property (nonatomic, strong) NSArray *yearArray;
@property (nonatomic, strong) NSArray *monthArray;
@property (nonatomic, strong) NSArray *dayArray;
@property (nonatomic, strong) NSArray *partArray;

@property (nonatomic, weak) UITextField *currentTimeTextField;

@end

@implementation ZivSelectStartEndTimeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = @"选择起止日期";
    
    [self configInputView];
}

- (IBAction)export:(UIButton *)sender
{
    ZivExportExcelViewController *exportExcelVC = [[ZivExportExcelViewController alloc] init];
    exportExcelVC.startTime = self.startTimeTextField.text;
    exportExcelVC.endTime = self.endTimeTextField.text;
    exportExcelVC.part = self.partTextField.text;
    
    exportExcelVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:exportExcelVC animated:YES];
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
    } else if (pickerView == self.partPickerView) {
        return self.partArray.count;
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
    } else if (pickerView == self.partPickerView) {
        return [self.partArray objectAtIndex:row];
    }
    
    return @"";
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (pickerView == self.partPickerView) {
        self.partTextField.text = [self.partArray objectAtIndex:row];
        return;
    }
    
    NSString *year = [self.yearArray objectAtIndex:[self.yearPickerView selectedRowInComponent:0]];
    NSString *month = [self.monthArray objectAtIndex:[self.monthPickerView selectedRowInComponent:0]];
    NSString *day = [self.dayArray objectAtIndex:[self.dayPickerView selectedRowInComponent:0]];
    
    self.currentTimeTextField.text = [[year stringByAppendingString:month] stringByAppendingString:day];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (textField == self.partTextField) {
        self.yearPickerView.hidden = YES;
        self.monthPickerView.hidden = YES;
        self.dayPickerView.hidden = YES;
        self.partPickerView.hidden = NO;
        
        self.startTimeLabel.textColor = [UIColor blackColor];
        self.endTimeLabel.textColor = [UIColor blackColor];
    } else {
        self.yearPickerView.hidden = NO;
        self.monthPickerView.hidden = NO;
        self.dayPickerView.hidden = NO;
        self.partPickerView.hidden = YES;
        
        if (textField == self.startTimeTextField) {
            self.currentTimeTextField = self.startTimeTextField;
            self.startTimeLabel.textColor = self.view.tintColor;
            self.endTimeLabel.textColor = [UIColor blackColor];
            
        } else if (textField == self.endTimeTextField) {
            self.currentTimeTextField = self.endTimeTextField;
            self.startTimeLabel.textColor = [UIColor blackColor];
            self.endTimeLabel.textColor = self.view.tintColor;
            
        }
    }
    
    return NO;
}

- (void)configInputView
{
    self.yearPickerView.dataSource = self;
    self.yearPickerView.delegate = self;
    self.monthPickerView.dataSource = self;
    self.monthPickerView.delegate = self;
    self.dayPickerView.dataSource = self;
    self.dayPickerView.delegate = self;
    self.partPickerView.dataSource = self;
    self.partPickerView.delegate = self;
    
    self.startTimeTextField.delegate = self;
    self.endTimeTextField.delegate = self;
    self.partTextField.delegate = self;
    self.partTextField.delegate = self;
}


- (NSArray *)yearArray
{
    if (!_yearArray) {
        _yearArray = @[@"2016", @"2017", @"2018"];
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

- (NSArray *)partArray
{
    if (!_partArray) {
        _partArray = @[@"S", @"A", @"T", @"B"];
    }
    
    return _partArray;
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
