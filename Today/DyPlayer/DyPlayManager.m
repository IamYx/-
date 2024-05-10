//
//  DyPlayManager.m
//  HistoryToday
//
//  Created by 姚肖 on 2023/5/23.
//

#import "DyPlayManager.h"

@implementation DyPlayManager

+ (instancetype)sharedManager {
    static DyPlayManager *_sharedSingleton = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedSingleton = [[DyPlayManager alloc] init];
    });
    return _sharedSingleton;
}

- (void)setPlayers:(NSMutableArray *)players {
    if (players.count > 3) {
        DyPlayController *player = players.firstObject;
        [player mStop];
        player = nil;
        [players removeObject:player];
        _players = players;
    }
}

@end
