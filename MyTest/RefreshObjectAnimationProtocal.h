//
//  RefreshObjectAnimationProtocal.h
//  MyTest
//
//  Created by Mac on 15/11/18.
//  Copyright © 2015年 Mac. All rights reserved.
//

#ifndef RefreshObjectAnimationProtocal_h
#define RefreshObjectAnimationProtocal_h


#endif /* RefreshObjectAnimationProtocal_h */
#import <Foundation/Foundation.h>

@protocol RefreshObjectAnimationProtocal <NSObject>

@required
- (void)animationWithPercent:(CGFloat)percent;
- (void)startRefreshAnimation;
- (void)endRefreshAnimation;

@end