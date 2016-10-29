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
    self.staticTypeSegment.selectedSegmentIndex = 0;
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
    
    //NSLog(@"%@", partTendencyStatic);
    
    PNLineChart *partChart = [[PNLineChart alloc] initWithFrame:CGRectMake(0, 0, self.partTendencyView.frame.size.width, self.partTendencyView.frame.size.height)];
    [self.partTendencyView addSubview:partChart];
    
    NSArray *indexArray = [partTendencyStatic objectForKey:@"date"];
    partChart.xLabelFont = [UIFont systemFontOfSize:12.0f];
    [partChart setXLabels:indexArray];
    
    NSMutableArray *chartDataArray = [NSMutableArray array];
    NSArray *partList = [[ZivDBManager shareDatabaseManager] satbPartList];
    for (NSString *part in partList) {
        NSArray *dataArray = [partTendencyStatic objectForKey:part];
        PNLineChartData *chartData = [PNLineChartData new];
        chartData.color = [self pnColorForPart:part];
        chartData.dataTitle = part;
        chartData.itemCount = dataArray.count;
        chartData.inflexionPointColor = chartData.color;
        chartData.inflexionPointStyle = [self inflexionPointStyleForPart:part];
        chartData.getData = ^(NSUInteger index) {
            CGFloat yValue = [[dataArray objectAtIndex:index] floatValue];
            return [PNLineChartDataItem dataItemWithY:yValue];
        };
        
        [chartDataArray addObject:chartData];
    }
    
    partChart.chartData = chartDataArray;
    [partChart strokeChart];
    
    partChart.legendFont = [UIFont systemFontOfSize:12.0f];
    partChart.legendFontColor = [UIColor lightGrayColor];
    partChart.legendStyle = PNLegendItemStyleSerial;
    
    UIView *legendView = [partChart getLegendWithMaxWidth:self.partLegendView.frame.size.width];
    [legendView setFrame:CGRectMake((self.partLegendView.frame.size.width - legendView.frame.size.width) / 2.0f, (self.partLegendView.frame.size.height - legendView.frame.size.height) / 2.0f, legendView.frame.size.width, legendView.frame.size.height)];
    [self.partLegendView addSubview:legendView];
}

- (PNLineChartPointStyle)inflexionPointStyleForPart:(NSString *)part
{
    if ([part isEqualToString:ZivChorusPartS]) {
        return PNLineChartPointStyleTriangle;
    } else if ([part isEqualToString:ZivChorusPartA]) {
        return PNLineChartPointStyleCircle;
    } else if ([part isEqualToString:ZivChorusPartT]) {
        return PNLineChartPointStyleSquare;
    } else if ([part isEqualToString:ZivChorusPartB]) {
        return PNLineChartPointStyleTriangle;
    }
    
    return PNLineChartPointStyleNone;
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
    
    NSArray *dataArray = [allMemberTendancyStatic objectForKey:@"all_member"];
    PNLineChartData *chartData = [PNLineChartData new];
    chartData.color = PNFreshGreen;
    chartData.dataTitle = @"全团出勤总数";
    chartData.itemCount = dataArray.count;
    chartData.inflexionPointColor = chartData.color;
    chartData.inflexionPointStyle = PNLineChartPointStyleTriangle;
    chartData.getData = ^(NSUInteger index) {
        CGFloat yValue = [[dataArray objectAtIndex:index] floatValue];
        return [PNLineChartDataItem dataItemWithY:yValue];
    };
    
    allMemberChart.chartData = @[chartData];
    [allMemberChart strokeChart];
    
    allMemberChart.legendFont = [UIFont systemFontOfSize:12.0f];
    allMemberChart.legendFontColor = [UIColor lightGrayColor];
    allMemberChart.legendStyle = PNLegendItemStyleSerial;
    
    UIView *legendView = [allMemberChart getLegendWithMaxWidth:self.allMemberLegendView.frame.size.width];
    [legendView setFrame:CGRectMake((self.allMemberLegendView.frame.size.width - legendView.frame.size.width) / 2.0f, (self.allMemberLegendView.frame.size.height - legendView.frame.size.height) / 2.0f, legendView.frame.size.width, legendView.frame.size.height)];
    [self.allMemberLegendView addSubview:legendView];
}

- (UIColor *)pnColorForPart:(NSString *)part
{
    if ([part isEqualToString:ZivChorusPartS]) {
        return PNRed;
    } else if ([part isEqualToString:ZivChorusPartA]) {
        return PNLightBlue;
    } else if ([part isEqualToString:ZivChorusPartT]) {
        return PNStarYellow;
    } else if ([part isEqualToString:ZivChorusPartB]) {
        return PNBrown;
    }
    
    return PNFreshGreen;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self drawStaticForType:[self.staticTypeSegment titleForSegmentAtIndex:0]];
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
