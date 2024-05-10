//
//  UIAlertController+Short.m
//  rtc2demo
//
//  Created by 姚肖 on 2023/3/29.
//

#import "UIAlertController+Short.h"

@implementation UIAlertController (Short)

- (void)shortShowAlert:(NSArray *)btns actions:(NSString *)title vc:(UIViewController *)vc actionBlock:(nullable ActionValueBlock)completion {
    
    if (btns.count > 0) {
        for (NSInteger i = 0; i < btns.count; i++) {
            [self addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                textField.placeholder = btns[i];
            }];
        }
    }
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:title style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        NSMutableArray *mArray = [[NSMutableArray alloc] init];
        for (NSInteger i = 0; i < self.textFields.count; i++) {
            UITextField *textf = self.textFields[i];
            [mArray addObject:textf.text];
        }
        completion(1, mArray);
        
    }];

    [self addAction:okAction];
    [self addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    

    [vc presentViewController:self animated:YES completion:nil];
    
}

- (void)shortShowSheet:(NSString *)title actions:(NSArray *)actionNames vc:(UIViewController *)vc actionBlock:(nullable ActionBlock)completion {

    for (NSInteger i = 0; i < actionNames.count; i++) {
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:actionNames[i] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            completion(i);
            
        }];

        [self addAction:okAction];
    }
    
    
    [vc presentViewController:self animated:YES completion:nil];
}

@end
