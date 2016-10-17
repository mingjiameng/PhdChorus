//
//  ZivSelectMemberToQueryViewController.m
//  PhdChorus
//
//  Created by 梁志鹏 on 16/10/5.
//  Copyright © 2016年 PhdChorus. All rights reserved.
//

#import "ZivSelectMemberToQueryViewController.h"

#import "ZivDBManager.h"
#import "ZivStaticByNameViewController.h"

@interface ZivSelectMemberToQueryViewController () <UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate>

@property (weak, nonatomic) IBOutlet UIPickerView *yearPickerView;
@property (weak, nonatomic) IBOutlet UIPickerView *monthPickerView;
@property (weak, nonatomic) IBOutlet UIPickerView *dayPickerView;
@property (weak, nonatomic) IBOutlet UIPickerView *partAndNamePickerView;
@property (weak, nonatomic) IBOutlet UIStackView *timeStackView;



@property (weak, nonatomic) IBOutlet UILabel *startTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *endTimeLabel;

@property (weak, nonatomic) IBOutlet UITextField *startTimeTextField;
@property (weak, nonatomic) IBOutlet UITextField *endTimeTextField;
@property (weak, nonatomic) IBOutlet UITextField *partTextField;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;

@property (nonatomic, weak) UITextField *currentTimeTextField;

@property (nonatomic, strong) NSArray *yearArray;
@property (nonatomic, strong) NSArray *monthArray;
@property (nonatomic, strong) NSArray *dayArray;
@property (nonatomic, strong) NSArray *partList;
@property (nonatomic, strong) NSArray *currentPartNameList;

@end

@implementation ZivSelectMemberToQueryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = @"条件选择";
    [self configInputView];
}

- (IBAction)doQuery:(UIButton *)sender
{
    ZivStaticByNameViewController *staticByNameVC = [[ZivStaticByNameViewController alloc] init];
    staticByNameVC.startTime = self.startTimeTextField.text;
    staticByNameVC.endTime = self.endTimeTextField.text;
    staticByNameVC.part = self.partTextField.text;
    staticByNameVC.name = self.nameTextField.text;
    
    [self.navigationController pushViewController:staticByNameVC animated:YES];
}


- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    if (pickerView == self.partAndNamePickerView) {
        return 2;
    }
    
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
    } else if (pickerView == self.partAndNamePickerView) {
        if (component == 0) {
            return self.partList.count;
        } else if (component == 1) {
            return self.currentPartNameList.count;
        }
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
    } else if (pickerView == self.partAndNamePickerView) {
        if (component == 0) {
            return [self.partList objectAtIndex:row];
        } else if (component == 1) {
            return [self.currentPartNameList objectAtIndex:row];
        }
    }
    
    return @"";
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (pickerView == self.partAndNamePickerView) {
        if (component == 0) {
            NSString *part = [self.partList objectAtIndex:row];
            self.partTextField.text = part;
            self.currentPartNameList = [[ZivDBManager shareDatabaseManager] memberNameListOfPart:part];
            [pickerView reloadComponent:1];
            
        } else if (component == 1) {
            self.nameTextField.text = [self.currentPartNameList objectAtIndex:row];
        }
        
    } else {
        NSString *year = [self.yearArray objectAtIndex:[self.yearPickerView selectedRowInComponent:0]];
        NSString *month = [self.monthArray objectAtIndex:[self.monthPickerView selectedRowInComponent:0]];
        NSString *day = [self.dayArray objectAtIndex:[self.dayPickerView selectedRowInComponent:0]];
        
        self.currentTimeTextField.text = [[year stringByAppendingString:month] stringByAppendingString:day];
    }

}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (textField == self.partTextField || textField == self.nameTextField) {
        self.timeStackView.hidden = YES;
        self.partAndNamePickerView.hidden = NO;
        
        self.startTimeLabel.textColor = [UIColor blackColor];
        self.endTimeLabel.textColor = [UIColor blackColor];
        
    } else {
        self.timeStackView.hidden = NO;
        self.partAndNamePickerView.hidden = YES;
        
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


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)configInputView
{
    self.yearPickerView.dataSource = self;
    self.yearPickerView.delegate = self;
    self.monthPickerView.dataSource = self;
    self.monthPickerView.delegate = self;
    self.dayPickerView.dataSource = self;
    self.dayPickerView.delegate = self;
    self.partAndNamePickerView.dataSource = self;
    self.partAndNamePickerView.delegate = self;
    
    self.startTimeTextField.delegate = self;
    self.endTimeTextField.delegate = self;
    self.partTextField.delegate = self;
    self.nameTextField.delegate = self;
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

- (NSArray *)partList
{
    if (!_partList ) {
        _partList = [[ZivDBManager shareDatabaseManager] partList];
    }
    
    return _partList;
}

- (NSArray *)currentPartNameList
{
    if (!_currentPartNameList) {
        _currentPartNameList = [[ZivDBManager shareDatabaseManager] memberNameListOfPart:[self.partList firstObject]];
    }
    
    return _currentPartNameList;
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
