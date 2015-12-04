//
//  ViewController.m
//  MyTest
//
//  Created by Mac on 15/8/17.
//  Copyright (c) 2015年 Mac. All rights reserved.
//

#import "ViewController.h"
#import "VideoRecordController.h"
#import "TestPlayVideoViewController.h"
#import "TransViewController.h"
#import "ListPlayViewController.h"
#import <Crashlytics/Crashlytics.h>
#import <objc/runtime.h>
#import "DownLoadOperate.h"  //测试静态库
#import "BezierViewController.h"
#import "LoadingViewController.h"
static NSString * RelateKey = @"releaa" ;
@interface ViewController ()<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate>
{
	NSArray *itemsAry;
	UITableView *tab;
}
@end

@implementation ViewController
-(instancetype)init{
	if(self = [super init]){
		itemsAry = @[@"录视频",@"播放在线视频",@"transView",@"列表播放视频",@"测试贝塞尔曲线",@"loading动画"];
//        DownLoadOperate *a = [[DownLoadOperate alloc]init];
        UITableView *cell = [UITableView new];
        [self.view addSubview:cell];
	}
	return self;
}
//struct objc_object {Class isa;};
//typedef struct objc_object *id;

- (void)viewDidLoad {
	[super viewDidLoad];
    //    NSString *noStr = [blist.cardNo substringWithRange:NSMakeRange(blist.cardNo.length-4, 4)];
    //    NSString *mStr = [@"" stringByPaddingToLength:blist.cardNo.length-4 withString:@"*" startingAtIndex:0];
    //    cell.detailTextLabel.text=[NSString stringWithFormat:@"%@%@",mStr,noStr];
    NSString*account = @"123456789@163.com";
    NSString *mStr = [@"" stringByPaddingToLength:account.length-6 withString:@"*" startingAtIndex:0];
    NSLog(@"mStr = %@",mStr);
    
	tab = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];
	tab.delegate = self;
	tab.dataSource = self;
	tab.tableFooterView = [[UIView alloc]init];
    [self.view addSubview:tab];
//    NSArray *a = [NSArray array];
//    id b = a[2];
//    NSLog(@"b=%@",b);
//    [[Crashlytics sharedInstance] crash];
    
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提醒" message:@"神谟庙算" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alert show];
    objc_setAssociatedObject(alert, &RelateKey, @"什么鬼", OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	// Do any additional setup after loading the view, typically from a nib.
}
NSString * const _recognizerRefreshObject = @"recognizerRefreshObject";
static char sssss;
- (void)setRefreshObject:(NSString *)refreshObject {
    
    objc_setAssociatedObject(self, &sssss, refreshObject, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSLog(@"objc_getAssociatedObject = %@",objc_getAssociatedObject(alertView, &RelateKey));
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
	return itemsAry.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	return 44;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.row) {
        case 0:{
            VideoRecordController *vc = [[VideoRecordController alloc]init];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 1:{
            TestPlayVideoViewController  *tvv = [[TestPlayVideoViewController alloc]init];
            [self.navigationController pushViewController:tvv animated:YES];
        }
            break;
        case 2:{
            TransViewController *tvc = [[TransViewController alloc]init];
            [self.navigationController pushViewController:tvc animated:YES];
        }
            break;
        case 3:{
            ListPlayViewController *tvc = [[ListPlayViewController alloc]init];
            [self.navigationController pushViewController:tvc animated:YES];
        }
            break;
        case 4:{
            BezierViewController *tvc = [[BezierViewController alloc]init];
            [self.navigationController pushViewController:tvc animated:YES];
        }
            break;
        case 5:{
            LoadingViewController *load = [[LoadingViewController alloc]init];
            [self.navigationController pushViewController:load animated:YES];
        }
            break;
        default:
            break;
    }
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
	static NSString *cellStr = @"cellStr";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellStr];
	if (!cell) {
		cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellStr];
	}
	cell.textLabel.text = itemsAry[indexPath.row];
	return cell;
	
	
}
- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

@end
