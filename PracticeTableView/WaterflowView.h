//
//  WaterflowView.h
//  PracticeTableView
//
//  Created by 赵祥凯 on 16/1/8.
//  Copyright © 2016年 Careerdream. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    WaterflowViewMarginTypeTop,         //item上边距
    WaterflowViewMarginTypeBottom,      //下边距
    WaterflowViewMarginTypeLeft,
    WaterflowViewMarginTypeRight,
    WaterflowViewMarginTypeColumn,      //列
    WaterflowViewMarginTypeRow          //行
} WaterflowViewMarginType;

typedef enum : NSUInteger {
    WaterflowViewDirectionVertical,     //垂直
    WaterflowViewDirectionHorizontal    //水平
} WaterflowViewDirection;//瀑布流方向

@class WaterflowView,WaterflowViewCell;

@protocol WaterflowDataSource <NSObject>
@required
/*
 *  一共有多少数据
 */
- (NSInteger)numberOfCellInWaterflowView:(WaterflowView *)waterflowView;
/*
 *  返回index位置对应的cell
 */
- (WaterflowViewCell *)waterflowView:(WaterflowView *)waterflowView cellAtIndex:(NSUInteger)index;

@optional
/*
 *  有多少列
 */
- (NSUInteger)numberOfColumnsInWaterflowView:(WaterflowView *)waterflowView;

/*
 *  有多少行
 */
- (NSUInteger)numberOfRowsInWaterflowView:(WaterflowView *)waterflowView;

@end

@protocol WaterflowDelegate <UIScrollViewDelegate>
@optional
/*
 *  第index位置cell对应的高度
 */
- (CGFloat)waterflowView:(WaterflowView *)waterflowView heightAtIndex:(NSUInteger)index;
/*
 *  第index位置cell对应的宽度
 */
- (CGFloat)waterflowView:(WaterflowView *)waterflowView widthAtIndex:(NSUInteger)index;
/*
 *  选中index位置的cell
 */
- (void)waterflowView:(WaterflowView *)waterflowView didSelectAtIndex:(NSUInteger)index;
/*
 *  返回间距
 */
- (CGFloat)waterflowView:(WaterflowView *)waterflowView marginForType:(WaterflowViewMarginType)type;

@end

@interface WaterflowView : UIScrollView

@property (nonatomic,weak)id<WaterflowDataSource>dataSource;

@property (nonatomic,weak)id<WaterflowDelegate>delegate;

@property (nonatomic,assign)WaterflowViewDirection direction;

/*
 *  刷新数据
 */
- (void)reloadData;

/*
 *  cell宽度
 */
- (CGFloat)cellWidth;

/*
 *  根据标识去缓存池查找可循环利用的cell
 */
- (id)dequeueReusableCellWithIdentifier:(NSString *)identifier;

@end
