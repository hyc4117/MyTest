//
//  LoadingViewController.m
//  MyTest
//
//  Created by Mac on 15/12/3.
//  Copyright © 2015年 Mac. All rights reserved.
//

#import "LoadingViewController.h"
#define AnimationDuration 1
#define SCCatWaiting_catPurple [UIColor colorWithRed:75.0f/255.0f green:52.0f/255.0f blue:97.0f/255.0f alpha:0.7f]
#define SCCatWaiting_leftFaceGray [UIColor colorWithRed:200.0f/255.0f green:198.0f/255.0f blue:200.0f/255.0f alpha:1.0f]
#define SCCatWaiting_rightFaceGray [UIColor colorWithRed:213.0f/255.0f green:212.0f/255.0f blue:213.0f/255.0f alpha:1.0f]
@implementation LoadingViewController


double radians(float degrees) {
    return ( degrees * 3.14159265 ) / 180.0;
}
CATransform3D getTransForm3DWithAngle(CGFloat angle)
{
    CATransform3D  transform = CATransform3DIdentity;
    transform  = CATransform3DRotate(transform, angle, 0, 0, 1);
    return transform;
}
- (CABasicAnimation *)rotationAnimation
{
    CABasicAnimation *rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
    rotationAnimation.fromValue = [NSValue valueWithCATransform3D:getTransForm3DWithAngle(0.0f)];
    rotationAnimation.toValue = [NSValue valueWithCATransform3D:getTransForm3DWithAngle(radians(180.0f))];
    rotationAnimation.duration = AnimationDuration;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = HUGE_VALF;
    rotationAnimation.removedOnCompletion=NO;
    rotationAnimation.fillMode=kCAFillModeForwards;
    rotationAnimation.autoreverses = NO;
    rotationAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    return rotationAnimation;
}
-(void)viewDidLoad{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor cyanColor];

    
    UIImageView *mouse = [[UIImageView alloc]initWithFrame:CGRectMake(60, 200, 200, 200)];
    mouse.image = [UIImage imageNamed:@"mouse"];
    [self.view addSubview:mouse];
    [mouse.layer addAnimation:[self rotationAnimation] forKey:@"mouseRotation"];
    
    UIImageView *cat = [[UIImageView alloc]initWithFrame:CGRectMake(110, 250, 100, 100)];
    cat.image = [UIImage imageNamed:@"MAO"];
    [self.view addSubview:cat];
    
    float scale = 2.3;
    UIView *leftEye = [[UIView alloc]initWithFrame:CGRectMake(50, 100, 6, 6)];
    
    leftEye.backgroundColor = [UIColor blackColor];
    leftEye.layer.cornerRadius = leftEye.frame.size.width/2;
    leftEye.layer.anchorPoint = CGPointMake(scale, scale);
    leftEye.layer.position = CGPointMake(cat.frame.origin.x+cat.frame.size.width/4 -leftEye.frame.size.width+8, cat.frame.origin.y+cat.frame.size.height/2-leftEye.frame.size.height+5);
    [leftEye.layer addAnimation:[self rotationAnimation] forKey:@"rotation1"];
    [self.view addSubview:leftEye];
    
    UIView *rightEye = [[UIView alloc]initWithFrame:CGRectMake(50, 100, 6, 6)];
    rightEye.backgroundColor = [UIColor blackColor];
    rightEye.layer.cornerRadius = rightEye.frame.size.width/2;
    rightEye.layer.anchorPoint = CGPointMake(scale, scale);
    rightEye.layer.position = CGPointMake(cat.frame.origin.x+cat.frame.size.width/4*3 -rightEye.frame.size.width+3, cat.frame.origin.y+cat.frame.size.height/2-rightEye.frame.size.height+5);
    [rightEye.layer addAnimation:[self rotationAnimation] forKey:@"rotation2"];
    [self.view addSubview:rightEye];
    UIScrollView *a;
    // Note : 比例是从sketch中算出来的
    float height = 10;
    float width = 42;
    UIView *_leftEyeCover = [[UIView alloc]initWithFrame:CGRectMake(leftEye.layer.position.x-width/2, cat.frame.origin.y+cat.frame.size.height/4-15, width, height)];
    _leftEyeCover.backgroundColor = SCCatWaiting_leftFaceGray;
    _leftEyeCover.layer.anchorPoint = CGPointMake(0.5, 0.0f);
    [self.view addSubview:_leftEyeCover];
    [_leftEyeCover.layer addAnimation:[self scaleAnimation] forKey:@"cover1"];
    
    UIView *_rightEyeCover = [[UIView alloc]initWithFrame:CGRectMake(rightEye.layer.position.x-width/2, cat.frame.origin.y+cat.frame.size.height/4-15, width, height)];
    _rightEyeCover.backgroundColor = SCCatWaiting_rightFaceGray;
    _rightEyeCover.layer.anchorPoint = CGPointMake(0.5, 0.0f);
    [self.view addSubview:_rightEyeCover];
    [_rightEyeCover.layer addAnimation:[self scaleAnimation] forKey:@"cover2"];

}

- (CAAnimationGroup *)scaleAnimation
{
    // 眼皮和眼珠需要确定一个运动时间曲线
    CABasicAnimation *scaleAnimation;
    scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
    scaleAnimation.fromValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
    scaleAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 3.0, 1.0)];
    scaleAnimation.duration = AnimationDuration;
    scaleAnimation.cumulative = YES;
    scaleAnimation.repeatCount = 1;
    scaleAnimation.removedOnCompletion= NO;
    scaleAnimation.fillMode=kCAFillModeForwards;
    scaleAnimation.autoreverses = NO;
    scaleAnimation.timingFunction = [CAMediaTimingFunction functionWithControlPoints:0.2:0.0 :0.8 :1.0];
//    scaleAnimation.speed = 1.0f;
    scaleAnimation.beginTime = 0;
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.duration = AnimationDuration;
    group.repeatCount = HUGE_VALF;
    group.removedOnCompletion= NO;
    group.fillMode=kCAFillModeForwards;
    group.autoreverses = YES;
    group.timingFunction = [CAMediaTimingFunction functionWithControlPoints:0.2:0.0:0.8:1.0];
    
    group.animations = [NSArray arrayWithObjects:scaleAnimation, nil];
    return group;
}
@end
