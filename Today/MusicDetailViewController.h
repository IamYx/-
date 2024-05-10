//
//  MusicDetailViewController.h
//  HistoryToday
//
//  Created by 姚肖 on 2023/6/15.
//

#import <UIKit/UIKit.h>
#import "MusicModel.h"
#import <AVKit/AVKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MusicDetailViewController : UIViewController

@property (nonatomic, strong)MusicModel *model;
@property (nonatomic, assign)NSInteger duration;
@property (nonatomic, strong)AVQueuePlayer *queuePlayer;

@end

NS_ASSUME_NONNULL_END
