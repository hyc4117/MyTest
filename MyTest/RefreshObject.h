//
//  RefreshObject.h
//  MyTest
//
//  Created by Mac on 15/11/18.
//  Copyright © 2015年 Mac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class RefreshObject;

typedef enum : NSUInteger {
    
    NORMAL_STATE,  // 正常状态
    REFRESH_STATE, // 刷新状态
    
} ERefreshState;


@protocol RefreshObjectDelegate <NSObject>

@required
/**
 *  开始刷新
 *
 *  @param refreshObject
 */
- (void)startRefreshing:(RefreshObject *)refreshObject;

/**
 *  结束刷新
 *
 *  @param refreshObject
 */
- (void)endRefresh:(RefreshObject *)refreshObject;

- (void)moving:(RefreshObject *)refreshObject offset:(CGFloat)offset percent:(CGFloat)percent;

@end

@interface RefreshObject : NSObject
/**
 *  代理
 */
@property (nonatomic, weak)     id <RefreshObjectDelegate> delegate;

/**
 *  当前状态
 */
@property (nonatomic, readonly) ERefreshState    state;
@property (nonatomic)           CGFloat          height;
@property (nonatomic, weak)     UIScrollView    *scrollView;

/**
 *  === 子类可以重写该方法实现新的刷新效果 ===
 *
 *  开始刷新
 */
- (void)beginRefreshing;


/**
 *  === 子类可以重写该方法实现新的刷新效果 ===
 *
 *  结束刷新
 */
- (void)endRefresh;

@end
