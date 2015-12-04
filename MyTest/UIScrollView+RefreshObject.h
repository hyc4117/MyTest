//
//  UIScrollView+RefreshObject.h
//  MyTest
//
//  Created by Mac on 15/11/26.
//  Copyright © 2015年 Mac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RefreshObject.h"
@interface UIScrollView (RefreshObject)
/**
 *  需要主动赋值
 */
@property (nonatomic, strong)  RefreshObject  *refreshObject;

/**
 *  添加观察者
 */
- (void)addObserver;

/**
 *  移除观察者
 */
- (void)removeObserver;
@end
