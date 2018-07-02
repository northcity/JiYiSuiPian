//
//  ShanNianMuLuDetailViewController.m
//  CutImageForYou
//
//  Created by chenxi on 2018/6/8.
//  Copyright © 2018 chenxi. All rights reserved.
//

#import "ShanNianMuLuDetailViewController.h"
#import "APLTextView/APLTextView.h"

@interface ShanNianMuLuDetailViewController ()<UITextViewDelegate>{
    UITapGestureRecognizer *tgr;
}
@property (nonatomic,strong) APLTextView *textView;

@end

@implementation ShanNianMuLuDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self initOtherUI];
    [self createTextUI];
}

- (void)viewWillAppear:(BOOL)animated{
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHidden:) name:UIKeyboardDidHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];

    [super viewWillAppear:animated];
}

- (void)keyboardDidHidden:(NSNotification *)notification{
    [self.textView resignFirstResponder];
    [self.textView removeGestureRecognizer:tgr];
}
- (void)keyboardDidShow:(NSNotification *)notification{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(keyboardHide:)];
    tap.cancelsTouchesInView = NO;
    [self.textView addGestureRecognizer:tap];
    tgr = tap;
    
}

- (void) keyboardHide:(UITapGestureRecognizer *)tap{
    [self.textView resignFirstResponder];
    [self.textView removeGestureRecognizer:tap];
}

- (void)textViewDidBeginEditing:(UITextView *)textView{
}
- (APLTextView *)textView{
    if (!_textView) {
        _textView = [[APLTextView alloc]initWithFrame:CGRectMake(30, PCTopBarHeight + kAUTOHEIGHT(40), ScreenWidth - 60, kAUTOHEIGHT(400))];
        _textView.backgroundColor = [UIColor whiteColor];
//        _textView.delegate = self;
        _textView.font = [UIFont fontWithName:@"FZSKBXKFW--GB1-0" size:15];
        _textView.textColor = [UIColor blackColor];
        _textView.textAlignment = NSTextAlignmentCenter;
        _textView.placeholder = @"请编辑您的内容（3000字以内）";
        _textView.text = _model.titleString;
        _textView.maxCharacters = 3000;
    }
    return _textView;
}

- (void)createTextUI{
    [self.view addSubview:self.textView];
}

- (void)initOtherUI{

    _titleView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, PCTopBarHeight)];
    _titleView.backgroundColor = [UIColor whiteColor];
    _titleView.layer.shadowColor=[UIColor grayColor].CGColor;
    _titleView.layer.shadowOffset=CGSizeMake(0, 2);
    _titleView.layer.shadowOpacity=0.1f;
    _titleView.layer.shadowRadius=12;
    [self.view addSubview:_titleView];
    [self.view insertSubview:_titleView atIndex:99];

    _navTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(ScreenWidth/2 - kAUTOWIDTH(150)/2, kAUTOHEIGHT(5), kAUTOWIDTH(150), kAUTOHEIGHT(66))];
    _navTitleLabel.text = @"编辑碎片";
    _navTitleLabel.font = [UIFont fontWithName:@"HeiTi SC" size:18];
    _navTitleLabel.textColor = [UIColor blackColor];
    _navTitleLabel.textAlignment = NSTextAlignmentCenter;
    [_titleView addSubview:_navTitleLabel];


    _backBtn = [Factory createButtonWithTitle:@"" frame:CGRectMake(20, 28, 25, 25) backgroundColor:[UIColor clearColor] backgroundImage:[UIImage imageNamed:@""] target:self action:@selector(backAction)];
    [_backBtn setImage:[UIImage imageNamed:@"关闭2"] forState:UIControlStateNormal];
    if (PNCisIPHONEX) {
        _backBtn.frame = CGRectMake(20, 48, 25, 25);
        _navTitleLabel.frame = CGRectMake(ScreenWidth/2 - kAUTOWIDTH(150)/2, kAUTOHEIGHT(27), kAUTOWIDTH(150), kAUTOHEIGHT(66));

    }
    [_titleView addSubview:_backBtn];

    _doneBtn = [Factory createButtonWithTitle:@"" frame:CGRectMake(ScreenWidth - 45, 28, 25, 25) backgroundColor:[UIColor clearColor] backgroundImage:[UIImage imageNamed:@""] target:self action:@selector(saveToDb)];
    [_doneBtn setImage:[UIImage imageNamed:@"dkw_完成"] forState:UIControlStateNormal];
    if (PNCisIPHONEX) {
        _doneBtn.frame = CGRectMake(ScreenWidth - 45, 48, 25, 25);
    }
    [_titleView addSubview:_doneBtn];

    _backBtn.transform = CGAffineTransformMakeRotation(M_PI_4);


    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2* NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        CABasicAnimation* rotationAnimation;

        rotationAnimation =[CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        //        rotationAnimation.fromValue =[NSNumber numberWithFloat: 0M_PI_4];

        rotationAnimation.toValue =[NSNumber numberWithFloat: 0];
        rotationAnimation.duration =0.4;
        rotationAnimation.repeatCount =1;
        rotationAnimation.removedOnCompletion = NO;
        rotationAnimation.fillMode = kCAFillModeForwards;
        [_backBtn.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];

    });
}

- (void)saveToDb{
    LZDataModel *model = [[LZDataModel alloc]init];
    model = self.model;
    model.titleString = self.textView.text;
    NSLog(@"%@",model);

    [LZSqliteTool LZUpdateTable:LZSqliteDataTableName model:model];
    [SVProgressHUD showInfoWithStatus:@"更新成功"];

    NSArray* array = [LZSqliteTool LZSelectAllElementsFromTable:LZSqliteDataTableName];
    NSLog(@"array");
}

- (void)backAction{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
