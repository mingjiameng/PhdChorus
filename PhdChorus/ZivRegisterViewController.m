//
//  ZivRegisterViewController.m
//  PhdChorusCommunity
//
//  Created by 梁志鹏 on 16/9/21.
//  Copyright © 2016年 PhdChorus. All rights reserved.
//

#import "ZivRegisterViewController.h"
#import "SHARED_MICRO.h"
#import "ZivDBManager.h"

@interface ZivRegisterViewController () <UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate>

@property (nonatomic, strong) NSArray *partList;

@property (weak, nonatomic) IBOutlet UIPickerView *partPickerView;
@property (weak, nonatomic) IBOutlet UIPickerView *namePickerView;
@property (weak, nonatomic) IBOutlet UIButton *actionButton;

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *partTextField;

@property (weak, nonatomic) UITextField *currentTextField;
@property (strong, nonatomic) NSArray *currentPartNameList;

@end

@implementation ZivRegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    NSString *title = @"ERROR";
    if (self.usage == ZivRegisterViewControllerUsageSignUp) {
        title = @"签到";
    } else if (self.usage ==ZivRegisterViewControllerUsageAskForLeave) {
        title = @"请假";
    } else if (self.usage == ZivRegisterViewControllerUsageAbsent) {
        title = @"缺勤";
    }
    
    self.navigationItem.title = title;
    
    [self configInputView];
}

- (IBAction)action:(UIButton *)sender
{
    BOOL success = NO;
    NSString *message = @"ERROR";
    if (self.usage == ZivRegisterViewControllerUsageSignUp) {
        success = [[ZivDBManager shareDatabaseManager] attendanceTable:self.attendanceTableName someoneSignUp:self.nameTextField.text inPart:self.partTextField.text];
        message = (success ? @"签到成功" : @"签到失败");
    } else if (self.usage == ZivRegisterViewControllerUsageAskForLeave) {
        success = [[ZivDBManager shareDatabaseManager] attendanceTable:self.attendanceTableName someoneAskForLeve:self.nameTextField.text inPart:self.partTextField.text];
        message = (success ? @"请假成功" : @"请假失败");
    } else if (self.usage == ZivRegisterViewControllerUsageAbsent) {
        success = [[ZivDBManager shareDatabaseManager] attendanceTable:self.attendanceTableName setSomeoneAbsent:self.nameTextField.text inPart:self.partTextField.text];
        message = (success ? @"已将该人设为缺勤" : @"设置失败");
    }
    
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:message message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"好" style:UIAlertActionStyleDefault handler:NULL];
    [alertController addAction:confirmAction];
    
    [self presentViewController:alertController animated:YES completion:NULL];
    
}

- (void)configInputView
{
    self.partPickerView.dataSource = self;
    self.partPickerView.delegate = self;
    self.partTextField.delegate = self;
    
    self.namePickerView.dataSource = self;
    self.namePickerView.delegate = self;
    self.nameTextField.delegate = self;
    
    NSString *title = @"ERROR";
    if (self.usage == ZivRegisterViewControllerUsageSignUp) {
        title = @"确认签到";
    } else if (self.usage ==ZivRegisterViewControllerUsageAskForLeave) {
        title = @"确认请假";
    } else if (self.usage == ZivRegisterViewControllerUsageAbsent) {
        title = @"设为缺勤";
    }
    [self.actionButton setTitle:title forState:UIControlStateNormal];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (textField == self.partTextField) {
        self.partPickerView.hidden = NO;
        self.namePickerView.hidden = YES;
        self.nameTextField.text = @"";
    } else if (textField == self.nameTextField) {
        self.partPickerView.hidden = YES;
        self.namePickerView.hidden = NO;
    }
    
    return NO;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (pickerView == self.partPickerView) {
        return [self.partList count];
    } else if (pickerView == self.namePickerView) {
        return [self.currentPartNameList count];
    }
    
    return 0;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (pickerView == self.partPickerView) {
        return [self.partList objectAtIndex:row];
    } else if (pickerView == self.namePickerView) {
        return [self.currentPartNameList objectAtIndex:row];
    }
    
    return @"";
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (pickerView == self.partPickerView) {
        NSString *part = [self.partList objectAtIndex:row];
        self.partTextField.text = part;
        self.currentPartNameList = [[ZivDBManager shareDatabaseManager] memberNameListOfPart:part];
        [self.namePickerView reloadAllComponents];
        
    } else if (pickerView == self.namePickerView) {
        self.nameTextField.text = [self.currentPartNameList objectAtIndex:row];
    }
    
}

- (NSArray *)partList
{
    if (!_partList) {
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
