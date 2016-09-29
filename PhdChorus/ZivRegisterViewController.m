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

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *partTextField;

@property (weak, nonatomic) UITextField *currentTextField;
@property (strong, nonatomic) NSDictionary *memberInfo;
@property (strong, nonatomic) NSArray *currentPartNameList;

@end

@implementation ZivRegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.navigationItem.title = @"签到";
    [self configInputView];
}

- (IBAction)register:(UIButton *)sender
{
    BOOL success = [[ZivDBManager shareDatabaseManager] attendAt:self.regiterTableName inPart:self.partTextField.text withName:self.nameTextField.text];
    
    NSString *message = (success ? @"签到成功" : @"签到失败");
    
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
        self.partTextField.text = [self.partList objectAtIndex:row];
        self.currentPartNameList = [[self.memberInfo objectForKey:self.partTextField.text] allKeys];
        [self.namePickerView reloadAllComponents];
        
    } else if (pickerView == self.namePickerView) {
        self.nameTextField.text = [self.currentPartNameList objectAtIndex:row];
    }
    
}

- (NSArray *)partList
{
    if (!_partList) {
        _partList = CHORUS_PART_LIST;
    }
    
    return _partList;
}

- (NSDictionary *)memberInfo
{
    if (!_memberInfo) {
        _memberInfo = [[ZivDBManager shareDatabaseManager] member_info];
    }
    
    return _memberInfo;
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
