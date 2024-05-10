//
//  UIAlertController+Short.h
//  rtc2demo
//
//  Created by 姚肖 on 2023/3/29.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef void(^ActionBlock)(NSInteger index);
typedef void(^ActionValueBlock)(NSInteger index, NSArray *values);

@interface UIAlertController (Short)

- (void)shortShowAlert:(NSArray *)placeholders actions:(NSString *)actionName vc:(UIViewController *)vc actionBlock:(nullable ActionValueBlock)completion;

- (void)shortShowSheet:(NSString *)title actions:(NSArray *)actionNames vc:(UIViewController *)vc actionBlock:(nullable ActionBlock)completion;

@end

NS_ASSUME_NONNULL_END
