//
//  TransViewController.m
//  MyTest
//
//  Created by Mac on 15/9/22.
//  Copyright © 2015年 Mac. All rights reserved.
//

#import "TransViewController.h"

@interface TransViewController ()
{
    UIView *v1,*v2;
}
@end

@implementation TransViewController
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
//    v1 = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 50, 50)];
//    v1.backgroundColor = [UIColor redColor];
//    [self.view addSubview:v1];
//    v2 = [[UIView alloc]initWithFrame:CGRectMake(100, 100, 200, 200)];
//    v2.backgroundColor = [UIColor greenColor];
//    [self.view addSubview:v2];
//    [UIView transitionFromView:v1 toView:v2 duration:2 options:UIViewAnimationOptionTransitionFlipFromBottom completion:^(BOOL finished) {
//        
//    }];
    
    UIView *view2 = [[UIView alloc] initWithFrame:CGRectMake(50, 100, 80, 80)];
    view2.backgroundColor = [UIColor redColor];
    [self.view addSubview:view2];
    
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:view2.bounds byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight cornerRadii:CGSizeMake(0, 0)];
    
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = view2.bounds;
    maskLayer.path = maskPath.CGPath;
    view2.layer.mask = maskLayer;

}
- (void)viewDidLoad {
    [super viewDidLoad];
        // Do any additional setup after loading the view.
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
