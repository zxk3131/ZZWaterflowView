//
//  WaterflowView.m
//  PracticeTableView
//
//  Created by 赵祥凯 on 16/1/8.
//  Copyright © 2016年 Careerdream. All rights reserved.
//

#import "WaterflowView.h"
#import "WaterflowViewCell.h"

#define WaterflowViewDefaultCellH 70    //item默认高度
#define WaterflowViewDefaultCellW 70    //item默认宽度
#define WaterflowViewDefaultMargin 8    //默认边距
#define WaterflowViewDefaultNumberOfColumns 3   //默认列数
#define WaterflowViewDefaultNumberOfRows 3      //默认行数

@interface WaterflowView ()
/** 所有cell的frame数据 */
@property (nonatomic,strong)NSMutableArray * cellFrames;
/** 正在展示的cell */
@property (nonatomic,strong)NSMutableDictionary * displayingCells;
/** 缓存池,存放离开屏幕的cell */
@property (nonatomic,strong)NSMutableSet * reusableCell;
/** item原始背景色 */
@property (nonatomic,strong)UIColor * originalColor;
/** 点击的cell */
@property (nonatomic,weak)WaterflowViewCell * tapCell;

@end

@implementation WaterflowView
@dynamic delegate;

#pragma mark - 初始化
- (instancetype)init
{
    self = [super init];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
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

- (void)commonInit
{
    //默认垂直方向
    self.direction = WaterflowViewDirectionVertical;
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [self reloadData];
}

#pragma mark - 公共接口
- (CGFloat)cellWidth
{
    //总列数
    NSInteger numberOfColumns = [self numberOfColumns];
    CGFloat leftM = [self marginForType:WaterflowViewMarginTypeLeft];
    CGFloat rightM = [self marginForType:WaterflowViewMarginTypeRight];
    CGFloat columnM = [self marginForType:WaterflowViewMarginTypeColumn];
    
    return (self.bounds.size.width - leftM - rightM - (numberOfColumns - 1) * columnM) / numberOfColumns;
}
- (CGFloat)cellHeight
{
    //总行数
    NSInteger numberOfRows = [self numberOfRows];
    CGFloat topM = [self marginForType:WaterflowViewMarginTypeTop];
    CGFloat bottomM = [self marginForType:WaterflowViewMarginTypeBottom];
    CGFloat rowM = [self marginForType:WaterflowViewMarginTypeRow];
    
    //判断是否有导航栏
    UIResponder * nextRes = self.nextResponder;
    BOOL isNav = NO;
    while (nextRes) {
        if ([nextRes isKindOfClass:[UIViewController class]]) {
            if ([nextRes isKindOfClass:[UINavigationController class]]) {
                isNav = YES;
                break;
            }
        }
        nextRes = nextRes.nextResponder;
    }
    
    return ((isNav? self.bounds.size.height - 64 : self.bounds.size.height) - topM - bottomM - (numberOfRows - 1) * rowM) / numberOfRows;
}

/*
 *  刷新数据
 */
- (void)reloadData
{
    //清空之前的所有数据
    //移除正在显示的cell
    [self.displayingCells.allValues makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.displayingCells removeAllObjects];
    [self.cellFrames removeAllObjects];
    [self.reusableCell removeAllObjects];
    
    //cell的总数
    NSInteger numberOfCells = [self.dataSource numberOfCellInWaterflowView:self];
    
    //间距
    CGFloat topM = [self marginForType:WaterflowViewMarginTypeTop];
    CGFloat leftM = [self marginForType:WaterflowViewMarginTypeLeft];
    CGFloat bottomM = [self marginForType:WaterflowViewMarginTypeBottom];
    CGFloat rightM = [self marginForType:WaterflowViewMarginTypeRight];
    CGFloat columnM = [self marginForType:WaterflowViewMarginTypeColumn];
    CGFloat rowM = [self marginForType:WaterflowViewMarginTypeRow];
    
    if (self.direction == WaterflowViewDirectionVertical) {//垂直
        //总列数
        NSInteger numberOfColumns = [self numberOfColumns];
        
        
        //cell宽度
        CGFloat cellW = [self cellWidth];
        
        //保存所有列的最大Y值
        CGFloat maxYOfColums[numberOfColumns];
        for (int i = 0; i < numberOfColumns; i++) {
            maxYOfColums[i] = 0.0;
        }
        
        //计算所有cell的frame
        for (int i = 0; i < numberOfCells; i++) {
            //cell处在第几列(最短的一列)
            NSUInteger cellColumn = 0;
            //cell所处列的最大Y值(最短那一列的最大Y值)
            CGFloat maxYOfCellColumn = maxYOfColums[cellColumn];
            //求出最短一列
            for (int j = 1; j < numberOfColumns; j++) {
                if (maxYOfColums[j] < maxYOfCellColumn) {
                    maxYOfCellColumn = maxYOfColums[j];
                    cellColumn = j;
                }
            }
            
            //询问代理i位置的高度
            CGFloat cellH = [self heightAtIndex:i];
            
            //cell的位置
            CGFloat cellX = leftM + (cellW + columnM) * cellColumn;
            CGFloat cellY = 0;
            if (maxYOfCellColumn == 0.0) {//首行
                cellY = topM;
            }else{
                cellY = maxYOfCellColumn + rowM;
            }
            
            //添加frame到数组中
            CGRect cellFrame = CGRectMake(cellX, cellY, cellW, cellH);
            [self.cellFrames addObject:[NSValue valueWithCGRect:cellFrame]];
            
            //更新最短一列的最大Y值
            maxYOfColums[cellColumn] = CGRectGetMaxY(cellFrame);
        }
        //设置contentsize
        CGFloat contentH = maxYOfColums[0];
        for (int j = 1; j < numberOfColumns; j++) {
            if (maxYOfColums[j] > contentH) {
                contentH = maxYOfColums[j];
            }
        }
        contentH += bottomM;
        self.contentSize = CGSizeMake(0, contentH);
    }else{//水平
        //总行数
        NSInteger numberOfRows = [self numberOfRows];
        //cell高度
        CGFloat cellH = [self cellHeight];
        //保存所有行的最大x值
        CGFloat maxXOfRows[numberOfRows];
        for (int i = 1; i < numberOfRows; i++) {
            maxXOfRows[i] = 0.0;
        }
        //计算所有cell的frame
        for (int i = 0; i < numberOfCells; i++) {
            //cell所处在第几行
            NSUInteger cellRow = 0;
            //cell所处列的最小x值(最短那一列的最大X值)
            CGFloat maxXOfCellRow = maxXOfRows[cellRow];
            //求出最短一行
            for (int j = 1; j < numberOfRows; j++) {
                if (maxXOfRows[j] < maxXOfCellRow) {
                    maxXOfCellRow = maxXOfRows[j];
                    cellRow = j;
                }
            }
            //询问代理i位置的宽度
            CGFloat cellW = [self widthAtIndex:i];
            
            //cell的位置
            CGFloat cellY = topM + (cellH + rowM) * cellRow;
            CGFloat cellX = 0;
            if (maxXOfCellRow == 0.0) {
                cellX = leftM;
            }else{
                cellX = maxXOfCellRow + columnM;
            }
            
            //添加frame到数组中
            CGRect cellFrame = CGRectMake(cellX, cellY, cellW, cellH);
            [self.cellFrames addObject:[NSValue valueWithCGRect:cellFrame]];
            //更新最短一行的最大X值
            maxXOfRows[cellRow] = CGRectGetMaxX(cellFrame);
        }
        //设置contentsize
        CGFloat contentW = maxXOfRows[0];
        for (int j = 1; j < numberOfRows; j ++) {
            if (contentW < maxXOfRows[j]) {
                contentW = maxXOfRows[j];
            }
        }
        contentW += rightM;
        self.contentSize = CGSizeMake(contentW, 0);
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self reloadData];
    });
    
    //向数据源索要对应位置的cell
    NSUInteger numberOfCells = self.cellFrames.count;
    
    for (int i = 0; i < numberOfCells; i++) {
        //取出i位置的frame
        CGRect cellFrame = [self.cellFrames[i] CGRectValue];
        
        //优先从字典中取出i位置的cell
        WaterflowViewCell * cell = self.displayingCells[@(i)];
        
        //判断i位置对应的frame在不在屏幕上
        if ([self isInScreen:cellFrame]) {//在屏幕上
            if (cell == nil) {
                cell = [self.dataSource waterflowView:self cellAtIndex:i];
                cell.frame = cellFrame;
                [self addSubview:cell];
                
                [self.displayingCells setObject:cell forKey:@(i)];
            }
        }else{//不在屏幕上
            if (cell) {
                [cell removeFromSuperview];
                [self.displayingCells removeObjectForKey:@(i)];
                //放进缓存池
                [self.reusableCell addObject:cell];
            }
        }
    }
    NSLog(@"%lu",self.reusableCell.count);
}

- (id)dequeueReusableCellWithIdentifier:(NSString *)identifier
{
    __block WaterflowViewCell * reusableCell = nil;
    [self.reusableCell enumerateObjectsUsingBlock:^(WaterflowViewCell * cell, BOOL * _Nonnull stop) {
        if ([cell.identifier isEqualToString:identifier]) {
            reusableCell = cell;
            *stop = YES;
        }
    }];
    
    if (reusableCell) {//从缓存池中移除
        [self.reusableCell removeObject:reusableCell];
    }
    
    return reusableCell;
}

#pragma mark - event response
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch * touch = touches.anyObject;
    CGPoint point = [touch locationInView:self];
    
    NSNumber * selectIndex = [self selectIndexWithPoint:point];
    
    if (selectIndex) {
        WaterflowViewCell * cell = [self.displayingCells objectForKey:selectIndex];
        self.tapCell = cell;
        self.originalColor = cell.backgroundColor;
        cell.backgroundColor = [UIColor lightGrayColor];
    }
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if (self.tapCell) {
        self.tapCell.backgroundColor = self.originalColor;
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if (self.tapCell) {
        self.tapCell.backgroundColor = self.originalColor;
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self performSelector:@selector(touchesCancelled:withEvent:) withObject:nil afterDelay:0.1];
    
    if (![self.delegate respondsToSelector:@selector(waterflowView:didSelectAtIndex:)]) return;
    
    UITouch * touch = touches.anyObject;
    CGPoint point = [touch locationInView:self];
    
    NSNumber * selectIndex = [self selectIndexWithPoint:point];
    
    if (selectIndex) {
        [self.delegate waterflowView:self didSelectAtIndex:selectIndex.unsignedIntegerValue];
    }
}

#pragma mark - private methods
/*
 *  判断一个frame是否显示在屏幕上
 */
- (BOOL)isInScreen:(CGRect)frame
{
    if (self.direction == WaterflowViewDirectionVertical) {
        return (CGRectGetMaxY(frame) > self.contentOffset.y) && CGRectGetMinY(frame) < self.bounds.size.height + self.contentOffset.y;
    }else{
        return (CGRectGetMaxX(frame) > self.contentOffset.x) && CGRectGetMinX(frame) < self.bounds.size.width + self.contentOffset.x;
    }
}

/*
 *  判断一个frame是否显示在屏幕上
 */
- (NSNumber *)selectIndexWithPoint:(CGPoint)point
{
    __block NSNumber * selectIndex = nil;
    [self.displayingCells enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, WaterflowViewCell * cell, BOOL * _Nonnull stop) {
        if (CGRectContainsPoint(cell.frame, point)) {
            selectIndex = key;
            *stop = YES;
        }
    }];
    return selectIndex;
}

/*
 *  总列数
 */
- (NSUInteger)numberOfColumns
{
    if ([self.dataSource respondsToSelector:@selector(numberOfColumnsInWaterflowView:)]) {
        return [self.dataSource numberOfColumnsInWaterflowView:self];
    }else{
        return WaterflowViewDefaultNumberOfColumns;
    }
}

/*
 *  总行数
 */
- (NSUInteger)numberOfRows
{
    if ([self.dataSource respondsToSelector:@selector(numberOfRowsInWaterflowView:)]) {
        return [self.dataSource numberOfRowsInWaterflowView:self];
    }else{
        return WaterflowViewDefaultNumberOfRows;
    }
}

/*
 *  index位置对应的高度
 */
- (CGFloat)heightAtIndex:(NSUInteger)index
{
    if ([self.delegate respondsToSelector:@selector(waterflowView:heightAtIndex:)]) {
        return [self.delegate waterflowView:self heightAtIndex:index];
    }else{
        return WaterflowViewDefaultCellH;
    }
}

/*
 *  index位置对w应的宽度
 */
- (CGFloat)widthAtIndex:(NSUInteger)index
{
    if ([self.delegate respondsToSelector:@selector(waterflowView:widthAtIndex:)]) {
        return [self.delegate waterflowView:self widthAtIndex:index];
    }else{
        return WaterflowViewDefaultCellW;
    }
}

/*
 *  间距
 */
- (CGFloat)marginForType:(WaterflowViewMarginType)type
{
    if ([self.delegate respondsToSelector:@selector(waterflowView:marginForType:)]) {
        return [self.delegate waterflowView:self marginForType:type];
    }else{
        return WaterflowViewDefaultMargin;
    }
}

#pragma mark - setters getters

- (NSMutableArray *)cellFrames
{
    if (_cellFrames == nil) {
        _cellFrames = [NSMutableArray array];
    }
    return _cellFrames;
}

- (NSMutableDictionary *)displayingCells
{
    if (_displayingCells == nil) {
        _displayingCells = [NSMutableDictionary dictionary];
    }
    return _displayingCells;
}

- (NSMutableSet *)reusableCell
{
    if (_reusableCell == nil) {
        _reusableCell = [NSMutableSet set];
    }
    return _reusableCell;
}

@end
