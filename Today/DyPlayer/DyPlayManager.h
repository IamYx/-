//
//  DyPlayManager.h
//  HistoryToday
//
//  Created by 姚肖 on 2023/5/23.
//

#import <Foundation/Foundation.h>
#import "DyPlayController.h"

NS_ASSUME_NONNULL_BEGIN

@interface DyPlayManager : NSObject

@property (nonatomic, strong)NSMutableArray <DyPlayController *>*players;

+ (instancetype)sharedManager;

@end

NS_ASSUME_NONNULL_END
