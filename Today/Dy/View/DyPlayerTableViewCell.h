//
//  DyPlayerTableViewCell.h
//  HistoryToday
//
//  Created by 姚肖 on 2023/5/10.
//

#import <UIKit/UIKit.h>
#import "DyPlayController.h"
#import "HeeeMusicAnimateView.h"

NS_ASSUME_NONNULL_BEGIN

@interface DyPlayerTableViewCell : UITableViewCell

@property (nonatomic, strong)UILabel *lyrLabel;
@property (nonatomic, strong)DyPlayController *dyPlayC;
@property (nonatomic, strong)HeeeMusicAnimateView *heeMusicView;
- (void)startPlay:(NSString *)url;

@end

NS_ASSUME_NONNULL_END
