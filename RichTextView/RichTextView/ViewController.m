//
//  ViewController.m
//  RichTextView
//
//  Created by xsy on 2016/12/8.
//  Copyright © 2016年 CidTech. All rights reserved.
//

#import "ViewController.h"
#import "XSYTextBackgrundView.h"

@interface ViewController ()

@property (nonatomic, strong) XSYTextBackgrundView *richTextView;                                //

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _richTextView = [[XSYTextBackgrundView alloc] initWithFrame:CGRectMake(10, 84, self.view.frame.size.width - 20, self.view.frame.size.height / 3)];
    [self.view addSubview:_richTextView];
    self.view.backgroundColor = [UIColor grayColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}


@end
