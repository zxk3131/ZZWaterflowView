//
//  WaterflowViewCell.m
//  PracticeTableView
//
//  Created by 赵祥凯 on 16/1/8.
//  Copyright © 2016年 Careerdream. All rights reserved.
//

#import "WaterflowViewCell.h"

@interface WaterflowViewCell ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong)UITableView * tableView;

@end

@implementation WaterflowViewCell

- (instancetype)initWithIdentifiy:(NSString *)identifiy
{
    self = [super init];
    self.identifier = identifiy;
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.tableView.frame = self.bounds;
}

- (void)commonInit
{
    UITableView * tableView = [[UITableView alloc]initWithFrame:self.bounds];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.rowHeight = 40;
    
    CGFloat red = (arc4random() % 256);
    CGFloat green = (arc4random() % 256);
    CGFloat blue = (arc4random() % 256);
    
    tableView.backgroundColor = [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:1];
    
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    self.tableView = tableView;
    [self addSubview:tableView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 20;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.textLabel.text = [NSString stringWithFormat:@"%lu",indexPath.row];
    
    CGFloat red = (arc4random() % 256);
    CGFloat green = (arc4random() % 256);
    CGFloat blue = (arc4random() % 256);
    
    cell.backgroundColor = [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:1];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"row - %lu",indexPath.row);
}

- (void)setID:(NSString *)ID
{
    _ID = ID;
    
}

@end
