//
//  XSYTextBackgrundView.h
//  RichTextView
//
//  Created by xsy on 2016/12/8.
//  Copyright © 2016年 CidTech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XSYTextBackgrundView : UIView

@property (nonatomic, strong) UITextView *textView;                                //富文本的textView
@property (nonatomic, strong) NSMutableArray *selectImageArr;                      //选取的图片组(以data的形式存储)再上传图片、压缩图片的时候会用到

@end
