//
//  ZivAskForLeaveViewController.m
//  PhdChorusCommunity
//
//  Created by 梁志鹏 on 16/9/21.
//  Copyright © 2016年 PhdChorus. All rights reserved.
//

#import "ZivAskForLeaveViewController.h"
#import "SHARED_MICRO.h"
#import "ZivDBManager.h"

@interface ZivAskForLeaveViewController () <UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate>

@property (nonatomic, strong) NSArray *partList;

@property (weak, nonatomic) IBOutlet UIPickerView *partPickerView;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *partTextField;
@property (weak, nonatomic) IBOutlet UITextField *reasonTextField;

@end

@implementation ZivAskForLeaveViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = @"请假";
    [self configInputView];
}


- (IBAction)askForLeave:(UIButton *)sender
{
    [self.view endEditing:YES];
    self.partPickerView.hidden = YES;
    
    BOOL success = [[ZivDBManager shareDatabaseManager] askForLeaveInAttendanceTable:self.regiterTableName Part:self.partTextField.text Name:self.nameTextField.text Reason:self.reasonTextField.text];
    
    NSString *message = (success ? @"请假成功" : @"请假失败");
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:message message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"好" style:UIAlertActionStyleDefault handler:NULL];
    [alertController addAction:confirmAction];
    
    [self presentViewController:alertController animated:YES completion:NULL];
}


- (void)configInputView
{
    self.partPickerView.dataSource = self;
    self.partPickerView.delegate = self;
    
    self.nameTextField.delegate = self;
    self.partTextField.delegate = self;
    self.reasonTextField.delegate = self;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (textField == self.partTextField) {
        [self.view endEditing:YES];
        
        self.partPickerView.hidden = NO;
        
        return NO;
    }
    
    return YES;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.partList.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [self.partList objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    self.partTextField.text = [self.partList objectAtIndex:row];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSArray *)partList
{
    if (!_partList) {
        _partList = CHORUS_PART_LIST;
    }
    
    return _partList;
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
