//
//  LFBCurveLineView.h
//  股票动态曲线图
//
//  Created by postop_iosdev on 2017/6/8.
//  Copyright © 2017年 postop_iosdev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LFBCurveLineView : UIView

//折线点数组
@property (nonatomic, strong) NSMutableArray *pointArray;
//创建对象实例
+ (LFBCurveLineView *)creatInstance;



@end
