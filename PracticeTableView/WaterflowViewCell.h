//
//  WaterflowViewCell.h
//  PracticeTableView
//
//  Created by 赵祥凯 on 16/1/8.
//  Copyright © 2016年 Careerdream. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WaterflowViewCell : UIView
/** 重用标识 */
@property (nonatomic,copy)NSString * identifier;

- (instancetype)initWithIdentifiy:(NSString *)identifiy;

@property (nonatomic,copy)NSString * ID;

@end
