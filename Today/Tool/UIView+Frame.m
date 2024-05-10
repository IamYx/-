//
//  UIView+Frame.m
//  Today
//
//  Created by 姚肖 on 2023/8/1.
//

#import "UIView+Frame.h"

#define yxScreenWidth                              ([UIScreen mainScreen].bounds.size.width)
#define yxScreenHeight                             ([UIScreen mainScreen].bounds.size.height)

@implementation UIView (Frame)

- (void)yx_initWithW:(float)w H:(float)h X:(float)x Y:(float)y {
    
    self.frame = CGRectMake(x, y, w, h);
}

- (void)yx_addSubView:(UIView *)view {
    
    NSArray *subViews = self.subviews;
    
    UIView *lastView = subViews.lastObject;
    
    float width = 0;
    
    if (view.frame.size.width == 0 && view.frame.size.height == 0) {
        //不固定宽高，指定坐标
        if (CGRectGetMaxY(lastView.frame) > view.frame.origin.y) {
            //在一行内
            
        }
        
        if (CGRectGetMaxX(lastView.frame) > view.frame.origin.x) {
            //在一列内
        }
    }
    
    [self addSubview:view];
}

@end
