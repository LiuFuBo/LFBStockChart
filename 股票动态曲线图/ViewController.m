//
//  ViewController.m
//  股票动态曲线图
//
//  Created by postop_iosdev on 2017/6/8.
//  Copyright © 2017年 postop_iosdev. All rights reserved.
//

#import "ViewController.h"
#import "LFBCurveLineView.h"

#define RGB(r,g,b) [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:1]
#define lineRateValue @"lineRateValue"

@interface ViewController ()
@property (nonatomic, strong) LFBCurveLineView *curveLine;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) NSMutableArray *dataSources;
@end

@implementation ViewController{

    int count;
}

- (void)dealloc{
    if ([self.timer isValid]) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initlizeAppearance];
}

- (void)initlizeAppearance{
    
    count = 0;
    self.view.backgroundColor = RGB(50, 48, 56);
    UIButton *button = [[UIButton alloc]init];
    button.bounds = CGRectMake(0, 0, 120, 44);
    button.center = CGPointMake(self.view.center.x, 100);
    [button setTitle:@"点击发送数据" forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:14];
    button.backgroundColor = [UIColor orangeColor];
    button.layer.cornerRadius = 10;
    button.layer.masksToBounds = YES;
    [button addTarget:self action:@selector(respondsToButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    self.curveLine = [LFBCurveLineView creatInstance];
    [self.view addSubview:self.curveLine];
    
    
}

- (void)respondsToButton:(UIButton *)sender{
    __block typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        weakSelf.timer = [NSTimer timerWithTimeInterval:1.0f target:weakSelf selector:@selector(timeChange) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop]addTimer:weakSelf.timer forMode:NSDefaultRunLoopMode];
        [[NSRunLoop currentRunLoop] run];
    });
}

- (void)timeChange{
    
    if (!_dataSources) {
        _dataSources = [NSMutableArray arrayWithObjects:[NSNumber numberWithInteger:93],[NSNumber numberWithInteger:100],[NSNumber numberWithInteger:110],[NSNumber numberWithInteger:120],[NSNumber numberWithInteger:130],[NSNumber numberWithInteger:132],[NSNumber numberWithInteger:134],[NSNumber numberWithInteger:136],[NSNumber numberWithInteger:137],[NSNumber numberWithInteger:140],[NSNumber numberWithInteger:145],[NSNumber numberWithInteger:150],[NSNumber numberWithInteger:155],[NSNumber numberWithInteger:160],[NSNumber numberWithInteger:190],[NSNumber numberWithInteger:185],[NSNumber numberWithInteger:180],[NSNumber numberWithInteger:178],[NSNumber numberWithInteger:173],[NSNumber numberWithInteger:170],[NSNumber numberWithInteger:160],[NSNumber numberWithInteger:155],[NSNumber numberWithInteger:152],[NSNumber numberWithInteger:151],[NSNumber numberWithInteger:140],[NSNumber numberWithInteger:170],[NSNumber numberWithInteger:185], nil];
    }
    
    if (count>=_dataSources.count) {
        count = _dataSources.count%count;
    }

    [[NSNotificationCenter defaultCenter]postNotificationName:lineRateValue object:_dataSources[count] userInfo:nil];
    count = count + 1;
 }



@end
