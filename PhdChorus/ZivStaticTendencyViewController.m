//
//  ZivStaticTendencyViewController.m
//  PhdChorus
//
//  Created by 梁志鹏 on 16/10/28.
//  Copyright © 2016年 PhdChorus. All rights reserved.
//

#import "ZivStaticTendencyViewController.h"

#import "PNChart.h"
#import "ZivDBManager+Statics.h"

@interface ZivStaticTendencyViewController ()

@property (weak, nonatomic) IBOutlet UIView *partTendencyView;
@property (weak, nonatomic) IBOutlet UIView *partLegendView;
@property (weak, nonatomic) IBOutlet UIView *allMemberTendencyView;
@property (weak, nonatomic) IBOutlet UIView *allMemberLegendView;

@property (weak, nonatomic) IBOutlet UISegmentedControl *staticTypeSegment;

@end

@implementation ZivStaticTendencyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = @"全团出勤趋势";
    [self drawStaticForType:@"周六中关村大排"];
}

- (IBAction)selectStaticType:(UISegmentedControl *)sender
{
    if (sender.selectedSegmentIndex == 0) {
        [self drawStaticForType:[self.staticTypeSegment titleForSegmentAtIndex:0]];
    } else if (sender.selectedSegmentIndex == 1) {
        [self drawStaticForType:[self.staticTypeSegment titleForSegmentAtIndex:1]];
    }
}

- (void)drawStaticForType:(NSString *)type
{
    [self drawPartTendencyForType:type];
    [self drawAllMemberTendencyForType:type];
}

- (void)drawPartTendencyForType:(NSString *)type
{
    NSArray *tendancySubviews = self.partTendencyView.subviews;
    for (UIView *view in tendancySubviews) {
        [view removeFromSuperview];
    }
    
    NSArray *legendSubviews = self.partLegendView.subviews;
    for (UIView *view in legendSubviews) {
        [view removeFromSuperview];
    }
    
    NSDictionary *partTendencyStatic = [[ZivDBManager shareDatabaseManager] partTendancyForAttendanceType:type];
    
    PNLineChart *partChart = [[PNLineChart alloc] initWithFrame:CGRectMake(0, 0, self.partTendencyView.frame.size.width, self.partTendencyView.frame.size.height)];
    [self.partTendencyView addSubview:partChart];
    
    NSArray *indexArray = [partTendencyStatic objectForKey:@"date"];
    [partChart setXLabels:indexArray];
    partChart.legendStyle = PNLegendItemStyleSerial;
    partChart.legendFont = [UIFont systemFontOfSize:12.0f];
    UIView *partLegend = [partChart getLegendWithMaxWidth:CGRectGetWidth(self.view.frame)];
    [self.partLegendView addSubview:partLegend];
    partLegend.center = self.partLegendView.center;
    
    NSMutableArray *chartDataArray = [NSMutableArray array];
    for (NSString *part in [[ZivDBManager shareDatabaseManager] partList]) {
        NSArray *dataArray = [partTendencyStatic objectForKey:part];
        PNLineChartData *chartData = [PNLineChartData new];
        chartData.color = [self pnColorForPart:part];
        chartData.dataTitle = part;
        chartData.itemCount = dataArray.count;
        chartData.getData = ^(NSUInteger index) {
            CGFloat yValue = [[dataArray objectAtIndex:index] floatValue];
            return [PNLineChartDataItem dataItemWithY:yValue];
        };
        
        [chartDataArray addObject:chartData];
    }
    
    partChart.chartData = chartDataArray;
    [partChart strokeChart];
}

- (void)drawAllMemberTendencyForType:(NSString *)type
{
    NSArray *tendancySubviews = self.allMemberTendencyView.subviews;
    for (UIView *view in tendancySubviews) {
        [view removeFromSuperview];
    }
    
    NSArray *legendSubviews = self.allMemberLegendView.subviews;
    for (UIView *view in legendSubviews) {
        [view removeFromSuperview];
    }
    
    NSDictionary *allMemberTendancyStatic = [[ZivDBManager shareDatabaseManager] allMemberTendancyForAttendanceType:type];
    
    PNLineChart *allMemberChart = [[PNLineChart alloc] initWithFrame:CGRectMake(0, 0, self.allMemberTendencyView.frame.size.width, self.allMemberTendencyView.frame.size.height)];
    [self.allMemberTendencyView addSubview:allMemberChart];
    
    NSArray *indexArray = [allMemberTendancyStatic objectForKey:@"date"];
    [allMemberChart setXLabels:indexArray];
    allMemberChart.legendStyle = PNLegendItemStyleSerial;
    allMemberChart.legendFont = [UIFont systemFontOfSize:12.0f];
    UIView *partLegend = [allMemberChart getLegendWithMaxWidth:CGRectGetWidth(self.view.frame)];
    [self.allMemberLegendView addSubview:partLegend];
    partLegend.center = self.allMemberLegendView.center;
    
    NSArray *dataArray = [allMemberTendancyStatic objectForKey:@"all_member"];
    PNLineChartData *chartData = [PNLineChartData new];
    chartData.color = PNFreshGreen;
    chartData.dataTitle = @"出勤总数";
    chartData.itemCount = dataArray.count;
    chartData.getData = ^(NSUInteger index) {
        CGFloat yValue = [[dataArray objectAtIndex:index] floatValue];
        return [PNLineChartDataItem dataItemWithY:yValue];
    };
    
    allMemberChart.chartData = @[chartData];
    [allMemberChart strokeChart];
}

- (UIColor *)pnColorForPart:(NSString *)part
{
    if ([part isEqualToString:ZivChorusPartS]) {
        return PNCloudWhite;
    } else if ([part isEqualToString:ZivChorusPartA]) {
        return PNBlue;
    } else if ([part isEqualToString:ZivChorusPartT]) {
        return PNYellow;
    } else if ([part isEqualToString:ZivChorusPartB]) {
        return PNBrown;
    }
    
    return PNFreshGreen;
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
