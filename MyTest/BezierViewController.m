//
//  BezierViewController.m
//  MyTest
//
//  Created by Mac on 15/11/17.
//  Copyright © 2015年 Mac. All rights reserved.
//

#import "BezierViewController.h"

@interface BezierViewController (){
    int count;
}
@property (retain,nonatomic) CAShapeLayer *animationLayer;
@property (retain,nonatomic) NSTimer *timer;
@property (nonatomic) CGPathRef oldPath;
@property (nonatomic) CGPathRef path;
@end

@implementation BezierViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    count = 0;
    self.view.backgroundColor = [UIColor whiteColor];
    _animationLayer = [CAShapeLayer layer];
    _animationLayer.borderWidth = 0.5f;
    _animationLayer.frame = CGRectMake(0, 0, 200, 200);
    _animationLayer.position = self.view.center;
    _animationLayer.path = [self creatPath].CGPath;
    _animationLayer.fillColor = [UIColor greenColor].CGColor;
    [self.view.layer addSublayer:_animationLayer];
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(event) userInfo:nil repeats:YES];
    
    // Do any additional setup after loading the view.
}
-(void)event{
    _oldPath = _animationLayer.path;
    _path = [self creatPath].CGPath;
    CABasicAnimation *basicAnimation = [CABasicAnimation animationWithKeyPath:@"bPath"];
    basicAnimation.duration = 0.1;
    basicAnimation.fromValue = (__bridge id _Nullable)(_oldPath);
    basicAnimation.toValue = (__bridge id _Nullable)(_path);
    _animationLayer.path = _path;
    [_animationLayer addAnimation:basicAnimation forKey:@"animateCirclePath"];
}
-(UIBezierPath *)creatPath{
    if (count == 200) {
        [_timer invalidate];
        return nil;
    }
    int h = 30;
    CGFloat controlPoint1_X = 0;
    CGFloat controlPoint1_Y = 0;
    CGFloat controlPoint2_X = 0;
    CGFloat controlPoint2_Y = 0;
    if (count ++ % 2 == 0) {
        controlPoint1_X = [self randomNum_70_79];
//        if (count >= 200-h+20) {
//            count = 200-h+20;
//        }
        controlPoint1_Y = 200-count-h;
        
        controlPoint2_X = [self randomNum_120_129];
        controlPoint2_Y = 200-count;
    }else{
        controlPoint1_X = [self randomNum_70_79];
        controlPoint2_X = [self randomNum_120_129];
//        if (count >= 200-h+20) {
//            count = 200-h+20;
//        }
        controlPoint1_Y = 200-count;
        controlPoint2_Y = 200-count-h;
    }
    //获取贝塞尔曲线
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint:CGPointMake(0, 200 - count)];
    [bezierPath addCurveToPoint:CGPointMake(200, 200 - count) controlPoint1:CGPointMake(controlPoint1_X, controlPoint1_Y) controlPoint2:CGPointMake(controlPoint2_X, controlPoint2_Y)];
    [bezierPath addLineToPoint:CGPointMake(200, 200)];
    [bezierPath addLineToPoint:CGPointMake(0, 200)];
    [bezierPath closePath];
    
    return bezierPath;
}
-(CGFloat)randomNum_70_79{
    return (CGFloat)(random()%10+70);
}
-(CGFloat)randomNum_120_129{
    return (CGFloat)(random()%10+120);
}
-(void)dealloc{
    NSLog(@"dealloc");
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [_timer invalidate];
    _timer = nil;
    [_animationLayer removeFromSuperlayer];
    _animationLayer = nil;
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
