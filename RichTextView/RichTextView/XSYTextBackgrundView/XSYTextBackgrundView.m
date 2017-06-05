//
//  XSYTextBackgrundView.m
//  RichTextView
//
//  Created by xsy on 2016/12/8.
//  Copyright © 2016年 CidTech. All rights reserved.
//

#import "XSYTextBackgrundView.h"
#import "UITextView+Delete.h"

#define SCREENWIDTH [UIScreen mainScreen].bounds.size.width
#define SCREENHEIGHT [UIScreen mainScreen].bounds.size.height

@interface XSYTextBackgrundView ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate,XSYTextViewDelegate>


@property (nonatomic, strong) UIImagePickerController *imagePickerController;      //选择图片或拍照
@property (nonatomic, strong) NSMutableDictionary *imageIndexAndImageLocationDic;  //存储图片在selectImageArr中的存储索引 以及 图片在textView中的location （存储形式：{@"index":index,@"location":location} ，在删除图片的时候通过range找到index,index控制删除selectImageArr中的图片）
@property (nonatomic, strong) NSMutableArray *imageIndexAndImageLocationDicArr;    //多张图片会有多个location和index
@property (nonatomic, strong) NSMutableArray *imageLocationArr;                    //存放图片的location
@property (nonatomic, strong) UIView *backgroundView;                              //五个btn的父视图
@property (nonatomic, strong) NSMutableDictionary *attributeDic;                   //存储富文本的属性的字典
@property (nonatomic, assign) NSInteger location;                                  //记录富文本开始的位置
@property (nonatomic, strong) UIImageView *colorImageView;                         //颜色背景视图
@property (nonatomic, assign) BOOL clickBackViewType;                              //看四点击了那个View，如果是_colorImageView为1,_backgroundView 为0

@end

@implementation XSYTextBackgrundView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self prepareParam];
        [self prepareSubViews];
    }
    return self;
}

#pragma mark - 基本的数据初始化方法

/**
 初始化数据
 */
- (void)prepareParam {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHidden:) name:UIKeyboardWillHideNotification object:nil];
    _selectImageArr = [[NSMutableArray alloc] init];
    _imageIndexAndImageLocationDicArr = [[NSMutableArray alloc] init];
    _imageLocationArr = [[NSMutableArray alloc] init];
    _attributeDic = [[NSMutableDictionary alloc] init];
    [_attributeDic setObject:@(4) forKey:NSKernAttributeName];
}
#pragma mark - 基本的ui

/**
 添加视图
 */
- (void)prepareSubViews {
    ///添加textView
    _textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width , self.frame.size.height)];
    _textView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    _textView.layer.cornerRadius = 5.0;
    self.backgroundColor = [UIColor grayColor];
    _textView.delegate = self;
    [self addSubview:_textView];
    
    ///添加属性选择视图
    NSMutableArray * imageArr = [NSMutableArray arrayWithObjects:@"b-",@"yanse",@"a",@"i",@"picter", nil];
    NSMutableArray * didselectArr = [NSMutableArray arrayWithObjects:@"b-_s",@"",@"a+",@"i_s",@"", nil];
    _backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREENHEIGHT - self.frame.origin.y, 200, 40)];
    for (int i = 0; i < imageArr.count; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(0 + i*40, 0, 40, 40);
        if (i == 0 || i == 2 || i == 3) {
            [btn setImage:[UIImage imageNamed:didselectArr[i]] forState:UIControlStateSelected];
        }
        [btn setImage:[UIImage imageNamed:imageArr[i]] forState:UIControlStateNormal];
        [_backgroundView addSubview:btn];
        btn.tag = 200 + i;
        [btn addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
    }
    [self addSubview:_backgroundView];
    
    ///添加颜色选择视图
    
}

//----------------------- 代理方法 ------------------------/
#pragma mark - Delegate Method (代理方法)
#pragma mark - UIImagePickerViewDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    UIImage *oriangeImage = (UIImage *)info[@"UIImagePickerControllerOriginalImage"];
    //将图片加入富文本
    [self addImagestotherichtext:oriangeImage];
    [[self viewController] dismissViewControllerAnimated:YES completion:^{
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [[self viewController] dismissViewControllerAnimated:YES completion:^{
    }];
}

#pragma mark - UITextViewDelegate
- (void)textViewDidChange:(UITextView *)textView {
    NSInteger currentLocation = textView.selectedRange.location;//获取textView的location
    NSRange richRange = NSMakeRange(_location, currentLocation - _location);//得到需要设置富文本的range
    if (currentLocation - _location > 0) {
        [textView.textStorage setAttributes:_attributeDic range:richRange];
    }
//    NSLog(@"%@richRange%@range%@",_attributeDic,NSStringFromRange(richRange),NSStringFromRange(_textView.selectedRange));
}

- (void)textViewDidDeleteBackward:(UITextView *)textView {
    [self deleteTextViewTextContentLocation:textView.selectedRange.location];//删除是对location实时监听
    NSLog(@"%s\n _imageIndexAndImageLocationDicArr%@\n range%lu",__FUNCTION__,_imageIndexAndImageLocationDicArr,(unsigned long)textView.selectedRange.location);
    NSLog(@"%lu",(unsigned long)_selectImageArr.count);
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
    }
    return YES;
}

//----------------------- 封装方法 ------------------------/
#pragma mark 封装出来的方法，为了减少方法内的代码
/**
 点击背景更换背景图片
 */
-(void)tapHeadViewEvent {
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    if (_imagePickerController == nil) {
        _imagePickerController = [[UIImagePickerController alloc]init];
    }
    UIAlertAction *alertActionPhoto = [UIAlertAction actionWithTitle:@"从手机相册选择" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        _imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        _imagePickerController.delegate = self;
        [[self viewController] presentViewController:_imagePickerController animated:YES completion:nil];
    }];
    UIAlertAction *alertActionCamera = [UIAlertAction actionWithTitle:@"照相机" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        _imagePickerController.delegate = self;
        _imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        [[self viewController] presentViewController:_imagePickerController animated:YES completion:nil];
    }];
    UIAlertAction *back = [UIAlertAction actionWithTitle:@"返回" style:UIAlertActionStyleCancel handler:nil];
    [alertVC addAction:alertActionPhoto];
    [alertVC addAction:alertActionCamera];
    [alertVC addAction:back];
    [[self viewController] presentViewController:alertVC animated:YES completion:^{
    }];
}

/**
 将图片加入富文本
 
 @param image 选择后的图片
 */
- (void)addImagestotherichtext:(UIImage *)image {
    NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
    attachment.bounds = CGRectMake(0, 0, [self changeImageHeigh:40 image:image].width, 40);
    attachment.image = image;
    NSAttributedString *attributedString = [NSAttributedString attributedStringWithAttachment:attachment];
    NSInteger location = _textView.selectedRange.location;
    [_textView.textStorage insertAttributedString:attributedString atIndex:location];
    _location = _textView.selectedRange.location;//选择图片后，因为图片会被当做富文本处理了
    _location = _location + 1;//设置富文本的开始位置
//    NSLog(@"%@%ld",_textView.attributedText,(long)location);
    
    ///存储图片、索引、location
    [self selectImageAddImage:image location:location];
}


/**
 对图片进行location
 将图片加入selecrImageArr,用于压缩和上传
 并记录图片在textView中的location(记录location
 是为了在删除图片的时候相应的删除_selectImage里面的转化为data的图片)
 
 @param image 需要存储的图片
 @param location 图片的location
 */
- (void)selectImageAddImage:(UIImage *)image location:(NSInteger)location{
    ///将location和index放入字典中，并存入数组.将location单独放入_imageLocationArr数组
    _imageIndexAndImageLocationDic = [[NSMutableDictionary alloc] init];
    [_imageIndexAndImageLocationDic setObject:@(location) forKey:@"location"];
    [_imageIndexAndImageLocationDicArr addObject:_imageIndexAndImageLocationDic];
    [_imageLocationArr addObject:@(location)];
    ///将图片转化为data存储到数组
    NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
    [_selectImageArr addObject:imageData]; //此时_selectImageArr 的存储索引与 _imageIndexAndImageLocationDic[@"index"]对应
}

/**
 监听删除文字的location，返回的是离删除的字符的Location最近，且较大的_imageLocationArr中的location（包括插入删除和末尾删除）
 
 @param location 实时删除的location，没删一个遍历一次
 @return 返回的是a[i-1] < location < a[i]的a[i]
 */
- (NSInteger)notificationdeleteLocation:(NSInteger)location {
    for (NSNumber *imageLocation in _imageLocationArr) { //进入方法就说明不为空
        if (location <= [imageLocation integerValue]) { //_imageLocationArr已经排好序了
            return [imageLocation integerValue];
        }
    }
    return 0;
}

/**
 textView删除内容的时候判断删除的是否有图片,有则通过range获取图片在_selectImageArr中的索引，并通过索引从_selectImageArr中删除图片
 
 @param location 传入的是判断好的location
 */
- (void)deleteTextViewTextContentLocation:(NSInteger)location {
    NSInteger temLocation = [self notificationdeleteLocation:location];//返回的是_imageIndexAndImageLocationDicArr中的location
//    NSLog(@"%s%ld",__FUNCTION__,(long)temLocation);
    if (temLocation == location) { //当删除的location和图片的location相同时删除数组中的字典和数组中的图片
        for (int i = 0; i < _imageIndexAndImageLocationDicArr.count; i++) {
            NSDictionary *imageIndexAndLocationDic = _imageIndexAndImageLocationDicArr[i];
            if ([imageIndexAndLocationDic[@"location"] integerValue] == temLocation) {
                NSInteger imageIndex = i;
                [_imageLocationArr removeObjectAtIndex:imageIndex]; //location存储的是最新的location
                [_selectImageArr removeObjectAtIndex:imageIndex];//删除_selectImageArr中index对应的图片
                [_imageIndexAndImageLocationDicArr removeObjectAtIndex:imageIndex];//删除_imageIndexAndImageLocationDicArr中对应的dic
                return;
            }
        }
    } else {//更新图片的location无需删除图片，重置数组中的location即可
        for (int i = 0; i < _imageIndexAndImageLocationDicArr.count; i++) {
            NSDictionary *imageIndexAndLocationDic = _imageIndexAndImageLocationDicArr[i];
            if ([imageIndexAndLocationDic[@"location"] integerValue] == temLocation) {
                NSInteger imageIndex = i;
                _imageIndexAndImageLocationDic = [[NSMutableDictionary alloc] init];
                [_imageIndexAndImageLocationDic setObject:@(temLocation - 1) forKey:@"location"]; //没删除一次监听一次。故每次减一即可
                [_imageLocationArr replaceObjectAtIndex:imageIndex withObject:@(temLocation - 1)]; //实时更新_imagaLocationArr中的location（*）
                [_imageIndexAndImageLocationDicArr replaceObjectAtIndex:imageIndex withObject:_imageIndexAndImageLocationDic];//删除_imageIndexAndImageLocationDicArr中对应的dic
                return;
            }
        }
    }
}

- (void)addColorBtnAboveColorImageView:(UIImageView *)colorImageView {
    NSArray *colorArr = @[[UIColor redColor],[UIColor orangeColor],[UIColor blueColor],[UIColor greenColor],[UIColor purpleColor],[UIColor blackColor]];
    for (int i = 0 ; i < 6; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(2 + i * (1 + 30), 1, 30, 30);
        btn.backgroundColor = colorArr[i];
        btn.tag = 300 + i;
        [btn addTarget:self action:@selector(changeTextColorWithColorBtn:) forControlEvents:UIControlEventTouchUpInside];
        [colorImageView addSubview:btn];
        
    }
}
//----------------------- 动作方法 ------------------------/
#pragma mark - Action Method (响应方法)
/**
 视图上button的点击方法
 
 @param sender 传入的是 btn的tag
 */
- (void)click:(UIButton *)sender {
    _clickBackViewType = 0;
    NSInteger tag = sender.tag - 200;
//    NSLog(@"%s%ld",__FUNCTION__,(long)tag);
    switch (tag) {
        case 0:   //将富文本的字体变粗
        {
            sender.selected = !sender.selected;//更改btn选择状态
            if (sender.selected) {
                [_attributeDic setObject:[NSNumber numberWithFloat:7.0] forKey:NSStrokeWidthAttributeName];
            } else {
                [_attributeDic removeObjectForKey:NSStrokeWidthAttributeName];
            }
             _location = _textView.selectedRange.location;//设置富文本的开始位置
        }
            break;
        case 1:   //给富文本的字自定义颜色
        {
            _clickBackViewType = 1;
            sender.selected = !sender.selected;//更改btn选择状态
            //弹出另一个颜色列表
            if (_colorImageView == nil) {
                _colorImageView = [[UIImageView alloc] initWithFrame:CGRectMake(_backgroundView.frame.origin.x + 9 ,  _backgroundView.frame.origin.y - 33, 189, 35)];//每个颜色（40*40）间距（5）上下间距（5）
                UIImage *colorImage = [UIImage imageNamed:@"圆角矩形-2"];
                colorImage = [colorImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, 20, 0, 0) resizingMode:UIImageResizingModeStretch];
                _colorImageView.image =  colorImage;
                _colorImageView.userInteractionEnabled = YES;
                [self addColorBtnAboveColorImageView:_colorImageView];
                [self addSubview:_colorImageView];
            }
            if (sender.selected) {
                _colorImageView.hidden = NO;
            } else {
                _colorImageView.hidden = YES;
            }
        }
            break;
        case 2:   //将富文本的字体变大
        {
            sender.selected = !sender.selected;//更改btn选择状态
            if (sender.selected) {
                [_attributeDic setObject:[UIFont systemFontOfSize:15.0] forKey:NSFontAttributeName];
                
            } else {
                [_attributeDic setObject:[UIFont systemFontOfSize:12.0] forKey:NSFontAttributeName];
            }
            _location = _textView.selectedRange.location;//设置富文本的开始位置
        }
            break;
        case 3:   //将富文本的字体变为斜体
        {
            sender.selected = !sender.selected;//更改btn选择状态
            if (sender.selected) {
                [_attributeDic setObject:[NSNumber numberWithFloat:0.5f] forKey:NSObliquenessAttributeName];
            }else {
                [_attributeDic removeObjectForKey:NSObliquenessAttributeName];
            }
            _location = _textView.selectedRange.location;//是指富文本的开始位置
        }
            break;
        case 4:   //给富文本添加图片
        {
            [self tapHeadViewEvent];
        }
            break;
            
        default:
            break;
    }
}

/**
 改变则提的颜色

 @param sender 不同的颜色按钮
 */
- (void)changeTextColorWithColorBtn:(UIButton *)sender {
    NSInteger btntag = sender.tag - 300;
    switch (btntag) {
        case 0://红色
            [_attributeDic setObject:[UIColor redColor] forKey:NSForegroundColorAttributeName];
            break;
        case 1://橙色
            [_attributeDic setObject:[UIColor orangeColor] forKey:NSForegroundColorAttributeName];
            break;
        case 2://蓝色
            [_attributeDic setObject:[UIColor blueColor] forKey:NSForegroundColorAttributeName];
            break;
        case 3://绿色
            [_attributeDic setObject:[UIColor greenColor] forKey:NSForegroundColorAttributeName];
            break;
        case 4://紫色
            [_attributeDic setObject:[UIColor purpleColor] forKey:NSForegroundColorAttributeName];
            break;
        case 5://黑色
            [_attributeDic setObject:[UIColor blackColor] forKey:NSForegroundColorAttributeName];
            break;
            
        default:
            break;
    }
    _location = _textView.selectedRange.location;//设置富文本开始（过改变的）的location
    _clickBackViewType = 0;//设置为_backImageView 可点击。（只有_backgroundView显示之后才能出现_colorImageView）
    _colorImageView.hidden = YES;//点击颜色后隐藏
    ((UIButton *)[self viewWithTag:201]).selected = !((UIButton *)[self viewWithTag:201]).selected;//（click:）方法中通过selected来控制_colcorImageView的显示和隐藏。
}

//----------------------- 工具方法 ------------------------/
#pragma  mark -Private Method (工具方法)

/**
 设定宽度，获取等比例缩小的图片
 
 @param heigh 自定义的高度
 @param image 需要的图片
 @return 修改后的图片的size
 */
- (CGSize)changeImageHeigh:(CGFloat)heigh image:(UIImage *)image {
    CGSize imageSize = image.size;
    CGSize size = CGSizeMake(heigh/imageSize.height * imageSize.width, heigh);
    return size;
}

/**
 查找父视图

 @return 返回父视图VC
 */
- (UIViewController *)viewController {
    for (UIView *next = self.superview; next; next = next.superview) {
        UIResponder *nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)nextResponder;
        }
    }
    return nil;
}

//--------------------- 监听方法 ---------------------/
#pragma mark - Notification Method (监听方法)

/**
 监听键盘高度--弹出键盘

 @param notification 返回的监听对象
 */
- (void)keyboardWillShow:(NSNotification*)notification {
//    NSLog(@"%@",notification);
    CGRect keyboardRect = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    _backgroundView.frame = CGRectMake(0, (SCREENHEIGHT - self.frame.origin.y - 40 - keyboardRect.size.height), 200, 40);
    _colorImageView.frame = CGRectMake(_backgroundView.frame.origin.x + 9, _backgroundView.frame.origin.y - 33, 189, 35);
}

/**
 监听键盘高度--收回键盘

 @param notification 返回的监听对象
 */
- (void) keyboardWillHidden:(NSNotification*)notification {
    NSInteger time = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] integerValue];
    [UIView animateWithDuration:time animations:^{
        _backgroundView.frame = CGRectMake(0, SCREENHEIGHT - self.frame.origin.y, 200, 40);
        _colorImageView.frame = CGRectMake(_backgroundView.frame.origin.x + 9, _backgroundView.frame.origin.y - 33, 189, 35);
        if (!_colorImageView.hidden) {//只有当_colorImageView显示的时候对其进行隐藏、对button进行点击的设置
            ((UIButton *)[self viewWithTag:201]).selected = !((UIButton *)[self viewWithTag:201]).selected;//（click:）方法中通过selected来控制_colcorImageView的显示和隐藏。
            _colorImageView.hidden = YES;//收起键盘要隐藏_colorImageView
        }
    }];

}


//---------------------- 重写系统方法 ------------------/
#pragma mark - RewriteSystemMethod (重写系统方法)
/**
 重写系统的响应者链方法

 @param point 焦点
 @param event 事件
 @return 通过响应者链返回触发事件的子视图
 */
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *view = [super hitTest:point withEvent:event];
    if (view == nil && !_clickBackViewType) {
        for (UIButton *btn in _backgroundView.subviews) {
            CGPoint tempoint = [btn convertPoint:point fromView:self];
            if (CGRectContainsPoint(btn.bounds, tempoint))
            {
                view = btn;
            }
        }
    } else if (view == nil && _clickBackViewType) {
        if (view == nil && _clickBackViewType) {
            for (UIButton *btn in _colorImageView.subviews) {
                CGPoint tempoint = [btn convertPoint:point fromView:self];
                if (CGRectContainsPoint(btn.bounds, tempoint))
                {
                    view = btn;
                }
            }
        }
    }
    return view;
}


@end
