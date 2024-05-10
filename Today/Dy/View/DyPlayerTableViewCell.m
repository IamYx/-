//
//  DyPlayerTableViewCell.m
//  HistoryToday
//
//  Created by 姚肖 on 2023/5/10.
//

#import "DyPlayerTableViewCell.h"
#import "YXFileManager.h"

@interface DyPlayerTableViewCell()

@end

@implementation DyPlayerTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
        
        self.dyPlayC = [[DyPlayController alloc] initWithFrame:CGRectMake(0, 0, UIScreenWidth, UIScreenHeight - statusBarHeight - 44 - kSafeAreaHeight - 44)];
        [self addSubview:_dyPlayC];
        
        self.lyrLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, UIScreenWidth, UIScreenHeight - statusBarHeight - 44 - kSafeAreaHeight - 44)];
        _lyrLabel.numberOfLines = 0;
        _lyrLabel.font = [UIFont systemFontOfSize:10];
        [self addSubview:_lyrLabel];
        
        self.heeMusicView = [[HeeeMusicAnimateView alloc] initWithFrame:CGRectZero];
        _heeMusicView.center = _lyrLabel.center;
        [self addSubview:_heeMusicView];
    }
    return self;
}

- (void)startPlay:(NSString *)url {
    [_dyPlayC mSetupAvPlayer:url];
    if ([[url pathExtension] isEqualToString:@"mp3"]) {
        _lyrLabel.hidden = NO;
        _heeMusicView.hidden = NO;
        NSArray *array = [url componentsSeparatedByString:@"/"];
        
        [self htmlLryToString:[YXFileManager getValueForKey:array.lastObject]];
    } else {
        _lyrLabel.hidden = YES;
        _heeMusicView.hidden = YES;
    }
}

- (void)htmlLryToString:(NSString *)html {
    
//    NSLog(@"lry === %@", html);
    
//    NSString *httmlStr = [html componentsSeparatedByString:@"class=\"current\"><em><i>"].lastObject;
    __block NSString *httmlStr = @"";
//    if (httmlStr.length > 0) {
//        NSString *pattern = @"</?i></?em></?p>< ?p ?class ?= ?\" ?(dClass)?\" ?>< ?em ?>< ?i ?>";
//        NSError *error = nil;
//        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:&error];
//        NSString *result = [regex stringByReplacingMatchesInString:httmlStr options:0 range:NSMakeRange(0, [httmlStr length]) withTemplate:@"\n"];
//        _lyrLabel.text = result;
//    } else {
//        _lyrLabel.text = html;
//    }
    
//    httmlStr = [httmlStr stringByReplacingOccurrencesOfString:@"<p class=\"\"><em><i>" withString:@"\n"];
//    httmlStr = [httmlStr stringByReplacingOccurrencesOfString:@"</i></em></p>" withString:@"\n"];
    
    __weak DyPlayerTableViewCell *weakSelf = self;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSArray *array1 = [html componentsSeparatedByString:@"<"];
        for (NSInteger i = 0; i < array1.count; i++) {
            NSString *str1 = array1[i];
            NSArray *array2 = [str1 componentsSeparatedByString:@">"];
            NSString *str2 = array2.lastObject;
            if (str2.length > 0) {
                httmlStr = [httmlStr stringByAppendingString:str2];
                httmlStr = [httmlStr stringByAppendingString:@"\n"];
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.lyrLabel.text = httmlStr;
        });
    });

}

@end
