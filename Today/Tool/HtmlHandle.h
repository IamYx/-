//
//  HtmlHandle.h
//  HistoryToday
//
//  Created by 姚肖 on 2023/6/14.
//

#import <Foundation/Foundation.h>
#import "MusicModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface HtmlHandle : NSObject

+ (MusicModel *)handleHtmlString:(NSString *)html;

@end

NS_ASSUME_NONNULL_END
