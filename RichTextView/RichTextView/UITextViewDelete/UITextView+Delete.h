//
//  UITextView+Delete.h
//  TextVIew富文本
//
//  Created by xsy on 2016/12/6.
//  Copyright © 2016年 CidTech. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString * const YXTextViewDidDeleteBackwardNotification;

@protocol XSYTextViewDelegate <UITextViewDelegate>
@optional
- (void)textViewDidDeleteBackward:(UITextView *)textView;
@end

@interface UITextView (Delete)

@property (nonatomic, weak) id<XSYTextViewDelegate> delegate;

@end
