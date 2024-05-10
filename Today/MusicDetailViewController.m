//
//  MusicDetailViewController.m
//  HistoryToday
//
//  Created by 姚肖 on 2023/6/15.
//

#import "MusicDetailViewController.h"
#import "UIImageView+WebCache.h"
#import "UIView+Frame.h"
#import "Today-Swift.h"

@interface MusicDetailViewController ()

@property (nonatomic, strong)NSTimer *timer;
@property (nonatomic, strong)UISlider *slider;

@end

@implementation MusicDetailViewController

- (void)dealloc {
    [_timer invalidate];
    _timer = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[WidgetKitManager shareManager] stopLiveAc];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self loadui];
    
    AVPlayerItem *currentItem = self.queuePlayer.currentItem;

    
    __weak MusicDetailViewController *weakSelf = self;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1 repeats:YES block:^(NSTimer * _Nonnull timer) {
        NSTimeInterval totalTime = CMTimeGetSeconds(currentItem.currentTime);
        weakSelf.slider.value = totalTime;
    }];
    
    [_slider addTarget:self action:@selector(valueChange:) forControlEvents:UIControlEventValueChanged];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerDidFinishPlaying) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    
}

- (void)playerDidFinishPlaying {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)valueChange:(UISlider *)slider {
    CMTime duration = CMTimeMakeWithSeconds(slider.value, 600);
    [self.queuePlayer seekToTime:duration];
}

- (void)loadui {
    UIColor *dColor = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull trainCollection) {
        if ([trainCollection userInterfaceStyle] == UIUserInterfaceStyleLight) {
            return [UIColor whiteColor];
        }
        else {
            return [UIColor blackColor];
        }
    }];
    
    self.view.backgroundColor = dColor;
    
    UIView *infoView = [[UIView alloc] initWithFrame:CGRectMake(20, 20, UIScreenWidth - 40, 100)];
    [self.view addSubview:infoView];
    [self musicInfoView:infoView];
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(infoView.frame) + 10, UIScreenWidth, self.view.bounds.size.height - 150)];
    [self.view addSubview:scrollView];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithData:[_model.content dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType} documentAttributes:nil error:nil];
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor lightGrayColor] range:NSMakeRange(0, attributedString.length)];
    [attributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:18] range:NSMakeRange(0, attributedString.length)];
    label.attributedText = attributedString;
    label.numberOfLines = 0;
    [scrollView addSubview:label];
    
    [label sizeToFit];
    
    label.frame = CGRectMake((UIScreenWidth - label.bounds.size.width) / 2, 20, label.bounds.size.width, label.bounds.size.height);
    
    [scrollView setContentSize:CGSizeMake(self.view.bounds.size.width, CGRectGetMaxY(label.frame) + 40)];
    
    UIView *sliderBack = [[UIView alloc] initWithFrame:CGRectMake(0, UIScreenHeight - 150, UIScreenWidth, 150)];
    sliderBack.backgroundColor = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull trainCollection) {
        if ([trainCollection userInterfaceStyle] == UIUserInterfaceStyleLight) {
            return [UIColor whiteColor];
        }
        else {
            return [UIColor blackColor];
        }
    }];
    [self.view addSubview:sliderBack];
    
    self.slider = [[UISlider alloc] initWithFrame:CGRectMake(30, 0, UIScreenWidth - 60, 50)];
    _slider.maximumValue = _duration / 1000.0;
    _slider.minimumValue = 0;
    [_slider setThumbImage:[UIImage imageNamed:[NSString stringWithFormat:@"NIMKitEmoticon.bundle/Emoji/%@", @"emoji_05"]] forState:UIControlStateNormal];
    [sliderBack addSubview:_slider];
}

- (void)musicInfoView:(UIView *)supView {
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    imageView.clipsToBounds = YES;
    imageView.layer.cornerRadius = 5;
    [imageView sd_setImageWithURL:[NSURL URLWithString:_model.pic] placeholderImage:[UIImage imageNamed:@"123"]];
    [supView addSubview:imageView];
    
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(imageView.frame) + 10, 45, 200, 25)];
    nameLabel.text = _model.name;
    [supView addSubview:nameLabel];
    
    UILabel *authorLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(imageView.frame) + 10, 75, 200, 25)];
    authorLabel.textColor = [UIColor lightGrayColor];
    authorLabel.text = _model.author;
    [supView addSubview:authorLabel];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
