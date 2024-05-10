//
//  MusicModel.m
//  HistoryToday
//
//  Created by 姚肖 on 2023/6/13.
//

#import "MusicModel.h"

@implementation MusicModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        _ext = @"";
        _name = @"";
        _content = @"";
        _time = @"";
        _author =@"";
        _url = @"";
        _pic = @"";
    }
    return self;
}

- (instancetype)initWithDict:(NSDictionary *)dict {
    
    if (self = [super init]) {
        
        [self setValuesForKeysWithDictionary:dict];
    }
    return self;
}
 
+ (instancetype)musicWithDict:(NSDictionary *)dict {
    
    return [[self alloc] initWithDict:dict];
}
 
 
- (void)setNilValueForKey:(NSString *)key {}
 
- (void)setValue:(id)value forUndefinedKey:(NSString *)key {}


- (NSDictionary *)toDictionary {
    
    NSArray *keys = @[@"content",@"time",@"author",@"name",@"ext",@"url",@"pic"];
    
    return [self dictionaryWithValuesForKeys:keys];
}

@end
