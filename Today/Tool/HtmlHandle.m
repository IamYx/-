//
//  HtmlHandle.m
//  HistoryToday
//
//  Created by 姚肖 on 2023/6/14.
//

#import "HtmlHandle.h"

@implementation HtmlHandle

+ (MusicModel *)handleHtmlString:(NSString *)html {
    MusicModel *model = [[MusicModel alloc] init];
    
    //name
    model.name = [HtmlHandle stringContentWithString:html str1:@"title: \'" str2:@"\',"];
    
    //author
    model.author = [HtmlHandle stringContentWithString:html str1:@"author:\'" str2:@"\',"];
    
    //url
    model.url = [HtmlHandle stringContentWithString:html str1:@"url: \'get_music.php?key=" str2:@"\',"];
    model.url = [@"https://hifini.com/get_music.php?key=" stringByAppendingString:model.url];
//    NSLog(@"=== %@", model.url);
    
    //pic
    model.pic = [HtmlHandle stringContentWithString:html str1:@"pic: \'" str2:@"\'"];
    
    //content
    model.content = [HtmlHandle stringContentWithString:html str1:@"歌词" str2:@"</h5><p><a href="];
    
    model.time = [NSString stringWithFormat:@"%f", [[NSDate date] timeIntervalSince1970]];
    
    return model;
}

+ (NSString *)stringContentWithString:(NSString *)str str1:(NSString *)str1 str2:(NSString *)str2 {
    
    NSString *result = @"";
    
    NSArray *nameArray1 = [str componentsSeparatedByString:str1];
    if (nameArray1.count > 0) {
        NSArray *nameArray2 = [nameArray1.lastObject componentsSeparatedByString:str2];
        if (nameArray2.count > 0) {
            result = nameArray2.firstObject;
        }
    }
    
//    NSLog(@"=== %@", result);
    return result;
}

@end
