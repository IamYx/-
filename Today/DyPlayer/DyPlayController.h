//
//  DyPlayController.h
//  HistoryToday
//
//  Created by 姚肖 on 2023/5/11.
//

#import <UIKit/UIKit.h>

@interface DyPlayController : UIView

@property (nonatomic, assign)BOOL playing;
- (void)mSetupAvPlayer:(NSString *)url;
- (void)mPlay;
- (void)mrePlay;
- (void)mPause;
- (void)mStop;

@end
