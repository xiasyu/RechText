//
//  UITextView+Delete.m
//  TextVIew富文本
//
//  Created by xsy on 2016/12/6.
//  Copyright © 2016年 CidTech. All rights reserved.
//

#import "UITextView+Delete.h"
#import <objc/runtime.h>

NSString * const YXTextViewDidDeleteBackwardNotification = @"textview_did_notification";

@implementation UITextView (Delete)

+ (void)load {
    Method method1 = class_getInstanceMethod([self class], NSSelectorFromString(@"deleteBackward"));
    Method method2 = class_getInstanceMethod([self class], @selector(xsy_deleteBackward));
    method_exchangeImplementations(method1, method2);
}

- (void)xsy_deleteBackward {
    [self xsy_deleteBackward];
    
    if ([self.delegate respondsToSelector:@selector(textViewDidDeleteBackward:)])
    {
        id <XSYTextViewDelegate> delegate  = (id<XSYTextViewDelegate>)self.delegate;
        [delegate textViewDidDeleteBackward:self];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:YXTextViewDidDeleteBackwardNotification object:self];
}
@end
