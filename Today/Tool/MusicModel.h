//
//  MusicModel.h
//  HistoryToday
//
//  Created by 姚肖 on 2023/6/13.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MusicModel : NSObject

@property (nonatomic, strong)NSString *content;
@property (nonatomic, strong)NSString *time;
@property (nonatomic, strong)NSString *author;
@property (nonatomic, strong)NSString *pic;
@property (nonatomic, strong)NSString *name;
@property (nonatomic, strong)NSString *ext;
@property (nonatomic, strong)NSString *url;

+ (instancetype)musicWithDict:(NSDictionary *)dict;
- (NSDictionary *)toDictionary;

@end

NS_ASSUME_NONNULL_END
