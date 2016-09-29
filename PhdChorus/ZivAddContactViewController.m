//
//  ZivAddContactViewController.m
//  PhdChorusCommunity
//
//  Created by 梁志鹏 on 16/9/21.
//  Copyright © 2016年 PhdChorus. All rights reserved.
//

#import "ZivAddContactViewController.h"

#import "ZivDBManager.h"
#import "SHARED_MICRO.h"

@interface ZivAddContactViewController () <UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate>


@property (nonatomic, weak) IBOutlet UITextField *nameTextField;
@property (nonatomic, weak) IBOutlet UITextField *partTextField;
@property (nonatomic, weak) IBOutlet UITextField *stageTextField;
@property (nonatomic, weak) IBOutlet UITextField *zoneTextField;
@property (weak, nonatomic) IBOutlet UIPickerView *partPickerView;
@property (weak, nonatomic) IBOutlet UIPickerView *zonePickerView;

@property (nonatomic, strong) NSArray *partList;
@property (nonatomic, strong) NSArray *zoneList;

@end



@implementation ZivAddContactViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    self.navigationItem.title = @"添加团员";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
    
    [self configInput];
}

- (void)configInput
{
    self.nameTextField.delegate = self;
    self.partTextField.delegate = self;
    self.stageTextField.delegate = self;
    self.zoneTextField.delegate = self;
    
    
    self.partPickerView.delegate = self;
    self.partPickerView.dataSource = self;
    
    self.zonePickerView.dataSource = self;
    self.zonePickerView.delegate = self;
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (textField == self.partTextField) {
        [self.view endEditing:YES];
        self.partPickerView.hidden = NO;
        self.zonePickerView.hidden = YES;
        return NO;
        
    } else if (textField == self.zoneTextField) {
        [self.view endEditing:YES];
        self.zonePickerView.hidden = NO;
        self.partPickerView.hidden = YES;
        return NO;
        
    } else {
        self.zonePickerView.hidden = YES;
        self.partPickerView.hidden = YES;
        return YES;
        
    }
    
    return YES;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (pickerView == self.partPickerView) {
        return self.partList.count;
    } else if (pickerView == self.zonePickerView) {
        return self.zoneList.count;
    }
    
    return 0;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (pickerView == self.partPickerView) {
        return [self.partList objectAtIndex:row];
    } else if (pickerView == self.zonePickerView) {
        return [self.zoneList objectAtIndex:row];
    }
    
    return @"";
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (pickerView == self.partPickerView) {
        self.partTextField.text = [self.partList objectAtIndex:row];
    } else if (pickerView == self.zonePickerView) {
        self.zoneTextField.text = [self.zoneList objectAtIndex:row];
    }
    
}

- (NSArray *)partList
{
    if (!_partList) {
        _partList = [[ZivDBManager shareDatabaseManager] partList];
    }
    
    return _partList;
}

- (NSArray *)zoneList
{
    if (!_zoneList) {
        _zoneList = [[ZivDBManager shareDatabaseManager] zoneList];
    }
    
    return _zoneList;
}

- (void)cancel
{
    [self.navigationController dismissViewControllerAnimated:YES completion:NULL];
}

- (void)done
{
    BOOL success = [[ZivDBManager shareDatabaseManager] registerName:self.nameTextField.text toPart:self.partTextField.text withStage:self.stageTextField.text andZone:self.zoneTextField.text];
    
    if (!success) {
        NSLog(@"fail to add contact");
    }
    
    [self.navigationController dismissViewControllerAnimated:YES completion:NULL];
    
    
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
