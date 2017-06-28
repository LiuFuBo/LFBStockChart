//
//  LFBCurveLineView.m
//  股票动态曲线图
//
//  Created by postop_iosdev on 2017/6/8.
//  Copyright © 2017年 postop_iosdev. All rights reserved.
//

#import "LFBCurveLineView.h"

#define ScreenWidth [UIScreen mainScreen].bounds.size.width
#define ScreenHeight [UIScreen mainScreen].bounds.size.height
#define RGB(r,g,b) [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:1]
#define lineRateValue @"lineRateValue"

// 与坐标轴相关的常量
/** 坐标轴信息区域宽度 */
static const CGFloat kPadding = 25.0;
/** 坐标系中横线的宽度 */
static const CGFloat kCoordinateLineWith = 1.0;

@interface LFBCurveLineView ()

//Y轴的单位长度
@property (nonatomic, assign) CGFloat yuintSpacing;
//X轴信息
@property (nonatomic, strong) NSMutableArray <NSString *> *xInfoArray;
//Y轴信息
@property (nonatomic, strong) NSMutableArray <NSString *> *yInfoArray;
//渐变背景视图
@property (nonatomic, strong) UIView *gradientBackgroundView;
//折线图层
@property (nonatomic, strong) CAShapeLayer *lineChartLayer;




@end

@implementation LFBCurveLineView


- (void)dealloc{

    [[NSNotificationCenter defaultCenter]removeObserver:self name:lineRateValue object:nil];
}

+ (LFBCurveLineView *)creatInstance{

    return [[LFBCurveLineView alloc]initWithFrame:CGRectMake(20, ScreenHeight/2, ScreenWidth-40, 120)];

}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onReceivedlineRate:) name:lineRateValue object:nil];
        self.backgroundColor = [UIColor clearColor];
        //设置渐变背景视图
        [self drawGradientBackgroundView];
        //设置折线图层
        [self setlineChartLayerAppearance];
    }
    return self;
}


#pragma mark - p 绘制渐变背景色
- (void)drawGradientBackgroundView{
//渐变背景色(不包含坐标轴)
    self.gradientBackgroundView = [[UIView alloc]initWithFrame:CGRectMake(kPadding, 0, ScreenWidth-kPadding, self.bounds.size.height)];
    [self addSubview:self.gradientBackgroundView];
    
    CALayer *firstLayer = [CALayer new];
    firstLayer.frame = CGRectMake(0, 5, self.bounds.size.width, self.yuintSpacing+10);
    firstLayer.backgroundColor = RGB(239, 119, 18).CGColor;
    
    CALayer *secondLayer = [CALayer new];
    secondLayer.frame = CGRectMake(0, 46,self.bounds.size.width, self.yuintSpacing);
    secondLayer.backgroundColor = RGB(93, 184, 138).CGColor;
    
    CALayer *thirdLayer = [CALayer new];
    thirdLayer.frame = CGRectMake(0, 78, self.bounds.size.width, self.yuintSpacing+10);
    thirdLayer.backgroundColor = RGB(221, 221, 221).CGColor;
    
    [self.gradientBackgroundView.layer addSublayer:firstLayer];
    [self.gradientBackgroundView .layer addSublayer:secondLayer];
    [self.gradientBackgroundView.layer addSublayer:thirdLayer];
    
}

#pragma mark - p 设置折线图层
- (void)setlineChartLayerAppearance{
  //折线路径
    UIBezierPath *path = [UIBezierPath bezierPath];
    [self drawPointsPath:path];
    if (!self.lineChartLayer) {
        self.lineChartLayer = [CAShapeLayer layer];
        self.lineChartLayer.path = path.CGPath;
        self.lineChartLayer.strokeColor = [UIColor whiteColor].CGColor;
        self.lineChartLayer.fillColor = [UIColor clearColor].CGColor;
        
        //默认设置路径宽度为0,使其在起始状态下不显示
        self.lineChartLayer.lineWidth = 2;
        self.lineChartLayer.lineCap = kCALineCapRound;
        self.lineChartLayer.lineJoin = kCALineJoinRound;
        //设置折线图层为渐变图层的mask
        self.gradientBackgroundView.layer.mask = self.lineChartLayer;

    }
}

- (void)drawPointsPath:(UIBezierPath *)path{

   [self.pointArray enumerateObjectsUsingBlock:^(NSNumber * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
       if (idx == 0) {
           [path moveToPoint:[self dataToPoint:obj atIndex:idx]];
       }else{
           [path addLineToPoint:[self dataToPoint:obj atIndex:idx]];
       }
   }];
    self.lineChartLayer.path = path.CGPath;

}

- (CGPoint)dataToPoint:(NSNumber *)value atIndex:(NSUInteger)index{

    CGPoint resultPoint = CGPointZero;
    
    resultPoint.x = index * 5;
    
    NSInteger heartRateValue = value.integerValue;
    
    NSInteger yPoint = 0;
    
    NSInteger lowestValue = ((NSString*)(self.yInfoArray.firstObject)).integerValue;
    
    NSInteger hrFloorValue = ((NSString*)(self.yInfoArray[1])).integerValue;
    
    NSInteger hrCeilingValue = ((NSString*)(self.yInfoArray[2])).integerValue;
    
    NSInteger hightestValue = ((NSString*)(self.yInfoArray[3])).integerValue;
    
    
    if (heartRateValue <= lowestValue) {
        
        yPoint = 10.0 / (lowestValue) * heartRateValue;
    }
    else if(heartRateValue > lowestValue && heartRateValue <= hrFloorValue)
    {
        yPoint = 10 + (self.yuintSpacing * 1.0/(hrFloorValue - lowestValue)) * (heartRateValue - lowestValue);
    }
    else if (heartRateValue > hrFloorValue && heartRateValue <= hrCeilingValue)
    {
        yPoint = 42 + (self.yuintSpacing * 1.0/(hrCeilingValue - hrFloorValue)) * (heartRateValue - hrFloorValue);
        
    }
    else if (heartRateValue > hrCeilingValue && heartRateValue <= hightestValue)
    {
        yPoint = 74 + (self.yuintSpacing * 1.0/(hightestValue - hrCeilingValue)) * (heartRateValue - hrCeilingValue);
    }
    else
    {
        if (heartRateValue <= 270) {
            yPoint = 106 + (10.f/(270 - hightestValue)) * (heartRateValue - hightestValue);
        }
        else
        {
            yPoint = 116;
        }
    }
    
    resultPoint.y = 116 - (NSInteger)yPoint;
    
    return resultPoint;
}

#pragma mark - p 绘制坐标轴
- (void)drawRect:(CGRect)rect{

    //获取上下文
    CGContextRef context = UIGraphicsGetCurrentContext();
    //y轴
    [self.yInfoArray enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
       //计算文字尺寸
        UIFont *informationFont = [UIFont systemFontOfSize:10];
        NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
        attributes[NSForegroundColorAttributeName] = [UIColor colorWithRed:158/255.0 green:158/255.0 blue:158/255.0 alpha:1.0];
        attributes[NSFontAttributeName] = informationFont;
        CGSize informationSize = [obj sizeWithAttributes:attributes];
        // 计算绘制起点
        float drawStartPointX = 0;
        float drawStartPointY = self.bounds.size.height - 10 - idx * self.yuintSpacing - informationSize.height * 0.5;
        CGPoint drawStartPoint = CGPointMake(drawStartPointX, drawStartPointY);
        // 绘制文字信息
        [obj drawAtPoint:drawStartPoint withAttributes:attributes];
        // 横向标线
        CGContextSetRGBStrokeColor(context, 235 / 255.0, 235 / 255.0, 235 / 255.0, 0.5);
        CGContextSetLineWidth(context, kCoordinateLineWith);
        CGContextMoveToPoint(context, kPadding, self.bounds.size.height - idx * self.yuintSpacing- 10);
        // lengths的值｛10,10｝表示先绘制10个点，再跳过10个点，如此反复
        CGFloat lengths[] = {2,1};
        // 虚线的起始点
        CGContextSetLineDash(context, 0, lengths,2);
        
        CGContextAddLineToPoint(context, self.bounds.size.width, self.bounds.size.height - idx * self.yuintSpacing - 10);
        CGContextStrokePath(context);
    }];
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [self drawPointsPath:path];
}
- (void)onReceivedlineRate:(NSNotification *)info{
    
    NSNumber *hrNum = (NSNumber *)info.object;
    if (hrNum.integerValue >0) {
        if (self.pointArray.count >= (self.bounds.size.width - kPadding)/5){
            [self.pointArray removeObjectAtIndex:0];
        }else{
            [self.pointArray addObject:hrNum];
        }
    }
    [self setNeedsDisplay];
}

#pragma mark - p getter & setter
- (CGFloat)yuintSpacing{

    if (_yuintSpacing == 0) {
        _yuintSpacing = 32;
    }
    return _yuintSpacing;
}

- (NSMutableArray<NSString *> *)yInfoArray{

    return _yInfoArray?:({
        _yInfoArray = [NSMutableArray arrayWithObjects:@"50",@"130",@"180",@"220", nil];
        _yInfoArray;
    });
}

- (NSMutableArray *)pointArray{
    return _pointArray?:({
        _pointArray = [NSMutableArray array];
        _pointArray;
    });
}



@end
