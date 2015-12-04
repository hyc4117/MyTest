//
//  VideoRecordController.m
//  MyTest
//
//  Created by Mac on 15/8/17.
//  Copyright (c) 2015年 Mac. All rights reserved.
//

#import "VideoRecordController.h"

@interface VideoRecordController ()
@end

@implementation VideoRecordController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIView *bac = [[UIView alloc]initWithFrame:CGRectMake(50, 50, 200, 200)];
    bac.backgroundColor = [UIColor redColor];
    [self.view addSubview:bac];
    
    UIView *bac2 = [[UIView alloc]initWithFrame:CGRectMake(50, 250, 50, 50)];
    bac2.backgroundColor = [UIColor greenColor];
    [self.view addSubview:bac2];
    [UIView transitionWithView:bac duration:5 options:UIViewAnimationOptionTransitionNone animations:^{
        bac.transform = CGAffineTransformMakeScale(0, 0);
        bac.alpha = 0;
    } completion:^(BOOL finished) {
        [bac removeFromSuperview];
    }];
//    [UIView transitionFromView:bac toView:bac2 duration:5 options:UIViewAnimationOptionTransitionFlipFromLeft completion:^(BOOL finished) {
//        
//    }];
    
    // Do any additional setup after loading the view from its nib.
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
