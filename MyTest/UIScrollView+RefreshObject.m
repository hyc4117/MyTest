//
//  UIScrollView+RefreshObject.m
//  MyTest
//
//  Created by Mac on 15/11/26.
//  Copyright © 2015年 Mac. All rights reserved.
//

#import "UIScrollView+RefreshObject.h"
#import <objc/runtime.h>
static char hRreshObjectKey;
@implementation UIScrollView (RefreshObject)
-(void)setRefreshObject:(RefreshObject *)refreshObject{
    objc_setAssociatedObject(self, &hRreshObjectKey, refreshObject, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
-(RefreshObject *)refreshObject{
    return objc_getAssociatedObject(self, &hRreshObjectKey);
}

#pragma mark -

- (void)addObserver {
    
    if (self.refreshObject && self.refreshObject.scrollView == nil) {
        
        // 获取scrollView
        self.refreshObject.scrollView = self;
        
        // 添加监听
        [self addObserver:self.refreshObject
               forKeyPath:@"contentOffset"
                  options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                  context:nil];
    }
}
- (void)removeObserver {
    
    if (self.refreshObject) {
        
        // 移除监听
        [self removeObserver:self.refreshObject
                  forKeyPath:@"contentOffset"];
        
        self.refreshObject.scrollView = nil;
        self.refreshObject            = nil;
    }
}
@end
