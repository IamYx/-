//
//  TodayPrefixHeader.h
//  Today
//
//  Created by 姚肖 on 2023/7/20.
//

#ifndef TodayPrefixHeader_h
#define TodayPrefixHeader_h


#define TOPVideo @"DYVideoTop"
#define UIScreenWidth                              ([UIScreen mainScreen].bounds.size.width)
#define UIScreenHeight                             ([UIScreen mainScreen].bounds.size.height)
#define statusBarHeight         [UIApplication sharedApplication].statusBarFrame.size.height
#define kSafeAreaHeight \
({CGFloat height = 0;\
if (@available(iOS 11.0, *)) {\
height = UIApplication.sharedApplication.delegate.window.safeAreaInsets.bottom;\
}\
(height);})

#endif /* TodayPrefixHeader_h */
