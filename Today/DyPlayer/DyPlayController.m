//
//  DyPlayController.m
//  HistoryToday
//
//  Created by 姚肖 on 2023/5/11.
//

#import "DyPlayController.h"
#import "DyPlayManager.h"
#import <AVKit/AVKit.h>
#import "DyPlayerTableViewCell.h"

@interface DyPlayController ()

@property (nonatomic, strong)AVPlayer *mPlayer;
@property (nonatomic, strong)AVPlayerLayer *mLayer;
@property (nonatomic, assign)BOOL playFinish;

@end

@implementation DyPlayController

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull trainCollection) {
            if ([trainCollection userInterfaceStyle] == UIUserInterfaceStyleLight) {
                return [UIColor whiteColor];
            }
            else {
                return [UIColor blackColor];
            }
        }];
    }
    return self;
}

- (void)mSetupAvPlayer:(NSString *)url {
//    NSURL *url1 = [NSURL URLWithString:url];
    NSURL *url1 = [NSURL fileURLWithPath:url];
//    AVAsset *asset = [AVAsset assetWithURL:url1];
//    AVPlayerItem * item = [[AVPlayerItem alloc] initWithAsset:asset];
    
    _mPlayer = [[AVPlayer alloc] initWithURL:url1];
    _mPlayer.muted = NO;
    _mPlayer.allowsExternalPlayback = YES;
    _mPlayer.usesExternalPlaybackWhileExternalScreenIsActive = YES;
    
    _mLayer = [AVPlayerLayer playerLayerWithPlayer:_mPlayer];
//    layer.backgroundColor = [UIColor yellowColor].CGColor;
    _mLayer.frame = CGRectMake(20, 100 +200*16/9 + 10, 200*16/9, 200);
    _mLayer.frame = self.bounds;
    _mLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    [self.layer addSublayer:_mLayer];
    
//    NSMutableArray *muArray = [[DyPlayManager sharedManager].players mutableCopy];
//    [muArray addObject:self];
//    [DyPlayManager sharedManager].players = muArray;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerDidFinishPlaying:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
}

- (void)playerDidFinishPlaying:(id)sender {
    _playing = NO;
    _playFinish = YES;
    DyPlayerTableViewCell *cell = (DyPlayerTableViewCell *)self.superview;
    if (cell.heeMusicView) {
        [cell.heeMusicView stop];
    }
}

- (void)mPlay {
    NSMutableArray *tempArray = [self.layer.sublayers mutableCopy];
    for (AVPlayerLayer *layer in tempArray) {
        if ([layer isKindOfClass:[AVPlayerLayer class]]) {
            [layer removeFromSuperlayer];
        }
    }
    [self.layer addSublayer:_mLayer];
    [_mPlayer play];
    _playing = YES;
    _playFinish = NO;
}

- (void)mrePlay {
    if (_playFinish) {
        [_mPlayer seekToTime:kCMTimeZero];
    }
    [_mPlayer play];
    _playing = YES;
    _playFinish = NO;
}

- (void)mPause {
    [_mPlayer pause];
    
    _playing = NO;
}

- (void)mStop {
    _mPlayer = nil;
    [_mLayer removeFromSuperlayer];
    _playing = NO;
    _playFinish = YES;
}

@end
