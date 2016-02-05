//
//  ViewController.m
//  PracticeTableView
//
//  Created by 赵祥凯 on 16/1/8.
//  Copyright © 2016年 Careerdream. All rights reserved.
//

#import "ViewController.h"
#import "WaterflowView.h"
#import "WaterflowViewCell.h"
#import "Masonry.h"

@interface ViewController ()<WaterflowDataSource,WaterflowDelegate>

@property (nonatomic, strong) NSMutableArray *shops;
@property (nonatomic, weak) WaterflowView *waterflowView;

@end

@implementation ViewController
- (NSMutableArray *)shops
{
    if (_shops == nil) {
        self.shops = [NSMutableArray array];
    }
    return _shops;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // 1.瀑布流控件
    WaterflowView *waterflowView = [[WaterflowView alloc] init];
    waterflowView.backgroundColor = [UIColor cyanColor];
    waterflowView.direction = WaterflowViewDirectionVertical;
    waterflowView.dataSource = self;
    waterflowView.delegate = self;
    waterflowView.pagingEnabled = YES;
    [self.view addSubview:waterflowView];
    self.waterflowView = waterflowView;
    
    [waterflowView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.equalTo(@0);
        make.centerX.equalTo(self.view);
    }];
    
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    //    NSLog(@"屏幕旋转完毕");
    [self.waterflowView reloadData];
}

- (NSInteger)numberOfCellInWaterflowView:(WaterflowView *)waterflowView
{
    return 40;
}

- (WaterflowViewCell *)waterflowView:(WaterflowView *)waterflowView cellAtIndex:(NSUInteger)index
{
    WaterflowViewCell * cell = [waterflowView dequeueReusableCellWithIdentifier:@"Cell"];
    
    if (!cell) {
        cell = [[WaterflowViewCell alloc]initWithIdentifiy:@"Cell"];
    }
    CGFloat red = (arc4random() % 256);
    CGFloat green = (arc4random() % 256);
    CGFloat blue = (arc4random() % 256);
    
    cell.backgroundColor = [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:1];
    
    cell.ID = @"12";
    
    return cell;
}

- (NSUInteger)numberOfColumnsInWaterflowView:(WaterflowView *)waterflowView
{
    if(UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
        return 3;
    }else{
        return 5;
    }
}

- (NSUInteger)numberOfRowsInWaterflowView:(WaterflowView *)waterflowView
{
    if(UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
        return 1;
    }else{
        return 5;
    }
}

- (CGFloat)waterflowView:(WaterflowView *)waterflowView heightAtIndex:(NSUInteger)index
{
    return (arc4random() % 100) + 60;
}

- (CGFloat)waterflowView:(WaterflowView *)waterflowView marginForType:(WaterflowViewMarginType)type
{
    if (waterflowView.direction == WaterflowViewDirectionHorizontal) {
        return 0;
    }
    return 8;
}

- (CGFloat)waterflowView:(WaterflowView *)waterflowView widthAtIndex:(NSUInteger)index
{
    return self.view.bounds.size.width;
}

- (void)waterflowView:(WaterflowView *)waterflowView didSelectAtIndex:(NSUInteger)index
{
    NSLog(@"点击了第%lu",index);
}

@end
