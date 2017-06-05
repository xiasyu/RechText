//
//  RootViewController.m
//  RichTextView
//
//  Created by xsy on 2016/12/8.
//  Copyright © 2016年 CidTech. All rights reserved.
//

#import "RootViewController.h"
#import "XSYTextBackgrundView.h"

@interface RootViewController ()

@property (nonatomic, strong) XSYTextBackgrundView *richTextView;                                //

@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    _richTextView = [[XSYTextBackgrundView alloc] initWithFrame:CGRectMake(10, 84, self.view.frame.size.width - 20, self.view.frame.size.height / 3)];
    [self.view addSubview:_richTextView];
    self.view.backgroundColor = [UIColor grayColor];
}



@end
