//
//  ShanNianViewController.m
//  CutImageForYou
//
//  Created by chenxi on 2018/5/23.
//  Copyright © 2018年 chenxi. All rights reserved.
//

#import "ShanNianViewController.h"
#import "UIViewController+InteractivePushGesture.h"
#import "ShanNianMuLuViewController.h"
#import "BCShanNianKaPianManager.h"
#import "SettingViewController.h"
#import "PcmPlayerDelegate.h"
#import "UIImage+Gradient.h"
#import "ISRDataHelper.h"
#import "IATConfig.h"
#import "PopupView.h"
#import "WaveView.h"
#import "PcmPlayer.h"
#import "LZSqliteTool.h"
#import "LZiCloud.h"
#import "EventCalendar.h"
#import "DatePickerView.h"
#import "ChuLiImageManager.h"

#import<AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>
#import <StoreKit/StoreKit.h>
#import <EventKit/EventKit.h>


#define SPEAKVIEW_HEIZGHT   kAUTOHEIGHT(170)
#define SPEAKVIEW_WIDTH     ScreenWidth - kAUTOWIDTH(40)

#define DAMPING  12
#define STIFFNESS 100
#define MASS   1
#define  INITIALVE   1
#define Dur_Time  2

#define AnimationTime 0.3

#define NAME        @"userwords"
#define USERWORDS   @"{\"userword\":[{\"name\":\"我的常用词\",\"words\":[\"佳晨实业\",\"蜀南庭苑\",\"高兰路\",\"复联二\"]},{\"name\":\"我的好友\",\"words\":[\"李馨琪\",\"鹿晓雷\",\"张集栋\",\"周家莉\",\"叶震珂\",\"熊泽萌\"]}]}"

@interface ShanNianViewController ()<IFlySpeechRecognizerDelegate,IFlyRecognizerViewDelegate,UIActionSheetDelegate,IFlyPcmRecorderDelegate,PcmPlayerDelegate,AVAudioPlayerDelegate,WKNavigationDelegate,WKUIDelegate,UIViewControllerInteractivePushGestureDelegate,DatePickerViewDelegate>{
    UIView * _backWindowView;
}




@property (nonatomic, strong) IFlyPcmRecorder *pcmRecorder;//PCM Recorder to be used to demonstrate Audio Stream Recognition.
@property (nonatomic, strong) IFlyRecognizerView *iflyRecognizerView;//Recognition control with view
@property (nonatomic, strong) IFlySpeechRecognizer *iFlySpeechRecognizer;//讯飞不带界面的识别对象
@property (nonatomic, assign) BOOL isStreamRec;//Whether or not it is Audio Stream function
@property (nonatomic, strong) CALayer *webViewSubLayer;//弹出网页视图的背景，用于加阴影
@property (nonatomic, strong) CALayer *speakSubLayer;//弹出识别视图的背景，用于加阴影
@property (nonatomic, strong) UILabel *speakLabel;//用来展示识别文字的，测试使用
@property (nonatomic, strong) IFlyDataUploader *uploader;//upload control
@property (nonatomic, strong) UIButton *beginSpeakButton;//开始识别按钮
@property (nonatomic, strong) PopupView *popUpView;//讯飞的弹出视图
@property (nonatomic, strong) UIButton *beginPlayButton;//开始播放录音
@property (nonatomic, strong) UIButton *pushButton;//跳转列表按钮
@property (nonatomic, strong) PcmPlayer *audioPlayer;//播放录
@property (nonatomic, strong) NSString * result;//识别结果字符串
@property (nonatomic, strong) WaveView *waveView;//波纹动画
@property (nonatomic, strong) WKWebView *webView;//网页
@property (nonatomic, strong) UIButton *setBtn;//跳转设置页面
@property (nonatomic, strong) UIVisualEffectView *effectView;//模糊视图
@property (nonatomic, strong) UIBlurEffect *effect;//模糊视图
@property (nonatomic, strong) WaveView *miniWaveView;//波纹动画
@property (nonatomic,strong) UIButton *playBtn;

@property(nonatomic,strong)DatePickerView * pikerView;
@property(nonatomic,copy)NSString * selectValue;
@property(nonatomic,copy)NSString * laterselectValue;

@end

@implementation ShanNianViewController

//- (UIViewController *)destinationViewControllerFromViewController:(UIViewController *)fromViewController {
//    ShanNianMuLuViewController *vc = [[ShanNianMuLuViewController alloc] init];
////    vc.view.backgroundColor = [UIColor colorWithRed:arc4random_uniform(256)/255.0 green:arc4random_uniform(256)/255.0 blue:arc4random_uniform(256)/255.0 alpha:1.0];
//    return vc;
//}

#pragma mark ========== 切换主题 ===========

- (void)createBgImageView{
    self.bgImageView = [[UIImageView alloc]initWithFrame:self.view.bounds];
//    self.bgImageView.image = [UIImage imageNamed:@"smart"];
    self.bgImageView.backgroundColor = [UIColor blackColor];
    
    self.effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    self.effectView = [[UIVisualEffectView alloc] initWithEffect:self.effect];
    self.effectView.userInteractionEnabled = YES;
    self.effectView.frame = self.bgImageView.bounds;
    [self.view addSubview:self.bgImageView];
    [self.bgImageView addSubview:self.effectView];
    [self.view sendSubviewToBack:self.bgImageView];
    self.effectView.alpha = 1.f;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)changeZhiTi{
    [self createBgImageView];
}

- (void)changeZhuTiDefault{
    if ([_bgImageView isDescendantOfView:self.view]) {
        [_bgImageView removeFromSuperview];
    }
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
    _navTitleLabel.text = @"闪念碎片";
    _navTitleLabel.font = [UIFont fontWithName:@"HeiTi SC" size:18];
    _navTitleLabel.textColor = [UIColor blackColor];
    _navTitleLabel.textAlignment = NSTextAlignmentCenter;
    [_titleView addSubview:_navTitleLabel];
    
    
    
    _backBtn = [Factory createButtonWithTitle:@"" frame:CGRectMake(20, 28, 25, 25) backgroundColor:[UIColor clearColor] backgroundImage:[UIImage imageNamed:@""] target:self action:@selector(backAction)];
    [_backBtn setImage:[UIImage imageNamed:@"返回箭头2"] forState:UIControlStateNormal];
    if (PNCisIPHONEX) {
        _backBtn.frame = CGRectMake(20, 48, 25, 25);
        _navTitleLabel.frame = CGRectMake(ScreenWidth/2 - kAUTOWIDTH(150)/2, kAUTOHEIGHT(27), kAUTOWIDTH(150), kAUTOHEIGHT(66));
    }
//    [_titleView addSubview:_backBtn];
    
    self.setBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.setBtn setImage:[UIImage imageNamed:@"设置 (1).png"] forState:UIControlStateNormal];
    [self.setBtn setTitle:@"设置" forState:UIControlStateNormal];
    self.setBtn.frame = CGRectMake(15, 25, 40, 40);
    self.setBtn.layer.masksToBounds = YES;
    self.setBtn.layer.cornerRadius = 25;
    [self.view addSubview:self.setBtn];
    [self.setBtn addTarget:self action:@selector(pushSettingViewController:) forControlEvents:UIControlEventTouchUpInside];
    [_titleView addSubview:_setBtn];

    if (PNCisIPHONEX) {
        self.setBtn.frame = CGRectMake(15, 47, 40, 40);
    }
    
    
    _setBtn.transform = CGAffineTransformMakeRotation(M_PI_4);
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2* NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        CABasicAnimation* rotationAnimation;
        
        rotationAnimation =[CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        //        rotationAnimation.fromValue =[NSNumber numberWithFloat: 0M_PI_4];
        
        rotationAnimation.toValue =[NSNumber numberWithFloat: 0];
        rotationAnimation.duration =0.4;
        rotationAnimation.repeatCount =1;
        rotationAnimation.removedOnCompletion = NO;
        rotationAnimation.fillMode = kCAFillModeForwards;
        [_setBtn.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
        
    });
}

- (void)tongBuiCloud{
    
    NSString *path = [LZSqliteTool LZCreateSqliteWithName:LZSqliteName];
    NSLog(@"我是路径 === %@",path);
    [LZiCloud uploadToiCloud:path resultBlock:^(NSError *error) {
        if (error == nil) {
//                        [SVProgressHUD showInfoWithStatus:@"同步成功"];
            
        } else {
            
//                        [SVProgressHUD showErrorWithStatus:@"同步出错"];
        }
        
    }];
    
}

+(NSString *)getNowTimeTimestamp{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
    
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"]; // ----------设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制
    
    //设置时区,这个对于时间的处理有时很重要
    
    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];
    
    [formatter setTimeZone:timeZone];
    
    NSDate *datenow = [NSDate date];//现在时间,你可以输出来看下是什么格式
    
    NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)[datenow timeIntervalSince1970]];
    
    return timeSp;
    
}

#pragma mark ========== 生命周期 ===========

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setDefaultConfig];
    [self createBaseUI];
    [self createUI];
    [self initOtherUI];
    [self tongBuiCloud];
    IATConfig *config = [IATConfig sharedInstance];
   config.icoloudShiJianChuo = [ShanNianViewController getNowTimeTimestamp];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self initRecognizer];
    [_beginPlayButton setEnabled:YES];
    [_beginSpeakButton setEnabled:YES];
    [self chuShiShuaZhuTi];
    
//    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
//        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
//    }
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];

//    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
//        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
//    }
    NSLog(@"%s",__func__);
    if ([IATConfig sharedInstance].haveView == NO) {
        [_iFlySpeechRecognizer cancel];
        [_iFlySpeechRecognizer setDelegate:nil];
        [_iFlySpeechRecognizer setParameter:@"" forKey:[IFlySpeechConstant PARAMS]];
        [_pcmRecorder stop];
        _pcmRecorder.delegate = nil;
    }else{
        [_iflyRecognizerView cancel];
        [_iflyRecognizerView setDelegate:nil];
        [_iflyRecognizerView setParameter:@"" forKey:[IFlySpeechConstant PARAMS]];
    }
}

- (void)createUI{
//    _popUpView = [[PopupView alloc] initWithFrame:CGRectMake(100, 100, 0, 0) withParentView:self.view];
    self.sloginLabel = [[UILabel alloc]initWithFrame:CGRectMake(kAUTOWIDTH(20), ScreenHeight/2 - kAUTOHEIGHT(20), ScreenWidth - kAUTOWIDTH(40), kAUTOHEIGHT(100))];
    self.sloginLabel.font = [UIFont fontWithName:@"FZSKBXKFW--GB1-0" size:15];
    self.sloginLabel.textColor = [UIColor grayColor];
    self.sloginLabel.text = @"长按开始说出你的闪念碎片，松手即可保存以及编辑。";
    self.sloginLabel.numberOfLines = 0;
    [self.view addSubview:self.sloginLabel];
}

- (void)setDefaultConfig{
    self.nowColor = @"52";
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationController.navigationBar.hidden = YES;
    self.volumArray = [[NSMutableArray alloc]init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeZhuTiDefault) name:@"CHANGEZHUTIDEFAULT" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeZhiTi) name:@"CHANGEZHUTI" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeZhiTiBaiSe) name:@"CHANGEZHUTIBAISE" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeZhiTiHeiSe) name:@"CHANGEZHUTIHEISE" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeZhiTiFenHong) name:@"CHANGEZHUTIFENHONG" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeZhiTiQingHuai) name:@"CHANGEZHUTIQINGHUAI" object:nil];


}

#pragma mark ===主题设置===
- (void)changeZhiTiBaiSe{
    self.view.backgroundColor = [UIColor whiteColor];
     self.sloginLabel.textColor = [UIColor grayColor];
}
- (void)changeZhiTiHeiSe{
    self.view.backgroundColor = [UIColor blackColor];
 self.sloginLabel.textColor = [UIColor whiteColor];
}
- (void)changeZhiTiFenHong{
    self.view.backgroundColor = PNCColor(247, 200, 207);
 self.sloginLabel.textColor = [UIColor whiteColor];
}
- (void)changeZhiTiQingHuai{
    self.view.backgroundColor = [UIColor whiteColor];
     self.sloginLabel.textColor = [UIColor grayColor];
}
#pragma mark - Button Handling

/**
 start speech recognition
 **/

- (void)setTextLabelIsNil{
    
    _speakLabel.text = @"";
    [_speakLabel resignFirstResponder];
    
    _speakTextView.text = @"";
    [_speakTextView resignFirstResponder];
}

- (void)startBtnHandler:(id)sender {
    
    NSLog(@"%s[IN]",__func__);
    [self.view addSubview:self.waveView];
    [self.waveView Animating];
    [self chuLiSuoYouView];
    [self createSpeakView];
//    if ([[BCUserDeafaults objectForKey:current_ZHUTI] isEqualToString:@"情怀主题"]) {
//        [self createImageView];
//    }
    [self createImageView];
    [self createSpeakViewAnimation];
    
    if ([IATConfig sharedInstance].haveView == NO) {
        
        [self setTextLabelIsNil];
        self.isCanceled = NO;
        self.isStreamRec = NO;
        
        if(_iFlySpeechRecognizer == nil){
            [self initRecognizer];
        }
        
        [_iFlySpeechRecognizer cancel];
        
        //Set microphone as audio source
        [_iFlySpeechRecognizer setParameter:IFLY_AUDIO_SOURCE_MIC forKey:@"audio_source"];
        
        //Set result type
        [_iFlySpeechRecognizer setParameter:@"json" forKey:[IFlySpeechConstant RESULT_TYPE]];
        
        //Set the audio name of saved recording file while is generated in the local storage path of SDK,by default in library/cache.
        [_iFlySpeechRecognizer setParameter:@"asr.pcm" forKey:[IFlySpeechConstant ASR_AUDIO_PATH]];
        
        [_iFlySpeechRecognizer setDelegate:self];
        
        BOOL ret = [_iFlySpeechRecognizer startListening];
        
        if (ret){
            [_beginSpeakButton setEnabled:NO];
            [_beginPlayButton setEnabled:NO];
            //            [_upContactBtn setEnabled:NO];
            
        } else {
            [_popUpView showText: NSLocalizedString(@"M_ISR_Fail", nil)];//Last session may be not over, recognition not supports concurrent multiplexing.
        }
    } else {
        
        if(_iflyRecognizerView == nil) {
            [self initRecognizer ];
        }
        
        //Set microphone as audio source
        [_iflyRecognizerView setParameter:IFLY_AUDIO_SOURCE_MIC forKey:@"audio_source"];
        
        //Set result type
        [_iflyRecognizerView setParameter:@"plain" forKey:[IFlySpeechConstant RESULT_TYPE]];
        
        //Set the audio name of saved recording file while is generated in the local storage path of SDK,by default in library/cache.
        [_iflyRecognizerView setParameter:@"asr.pcm" forKey:[IFlySpeechConstant ASR_AUDIO_PATH]];
        
        BOOL ret = [_iflyRecognizerView start];
        if (ret) {
            [_beginSpeakButton setEnabled:NO];
            [_beginPlayButton setEnabled:NO];
        }
    }
}

/**
 stop recording
 **/
- (void)stopBtnHandler:(id)sender {
    //    [BCShanNianKaPianManager maDaZhongJianZhenDong];
    NSLog(@"%s",__func__);
    
    if(self.isStreamRec && !self.isBeginOfSpeech){
        NSLog(@"%s,stop recording",__func__);
        [_pcmRecorder stop];
    }
    
    [_iFlySpeechRecognizer stopListening];
    [_speakLabel resignFirstResponder];
    [_speakTextView resignFirstResponder];
}

/**
 cancel speech recognition
 **/
- (void)cancelBtnHandler:(id)sender {
    NSLog(@"%s",__func__);
    
    if(self.isStreamRec && !self.isBeginOfSpeech){
        NSLog(@"%s,stop recording",__func__);
        [_pcmRecorder stop];
    }
    
    [_speakTextView resignFirstResponder];
    [_popUpView removeFromSuperview];
    [_speakLabel resignFirstResponder];
    [_iFlySpeechRecognizer cancel];
    self.isCanceled = YES;
}

/**
 upload contacts
 **/
- (void)upContactBtnHandler:(id)sender {
    //Ensure that the recognition session is over
    [_iFlySpeechRecognizer stopListening];
    
    [_beginPlayButton setEnabled:NO];
    [_beginSpeakButton setEnabled:NO];
    
    [self showPopup];
    
    //acquire contact list
    IFlyContact *iFlyContact = [[IFlyContact alloc] init];
    NSString *contact = [iFlyContact contact];
    
    _speakTextView.text = contact;
    _speakLabel.text = contact;
    
    [_uploader setParameter:@"contact" forKey:[IFlySpeechConstant DATA_TYPE]];
    [_uploader setParameter:@"uup" forKey:[IFlySpeechConstant SUBJECT]];
    [_uploader uploadDataWithCompletionHandler: ^(NSString * grammerID, IFlySpeechError *error) {
        [self onUploadFinished:error];
    } name:@"contact" data: _speakTextView.text];
}

/**
 upload customized words
 **/
- (void)upWordBtnHandler:(id)sender {
    
    [_iFlySpeechRecognizer stopListening];
    [_beginSpeakButton setEnabled:NO];
    [_beginPlayButton setEnabled:NO];
    
    [_uploader setParameter:@"userword" forKey:[IFlySpeechConstant DATA_TYPE]];
    [_uploader setParameter:@"uup" forKey:[IFlySpeechConstant SUBJECT]];
    
    [self showPopup];
    
    IFlyUserWords *iFlyUserWords = [[IFlyUserWords alloc] initWithJson:USERWORDS ];
    
    [_uploader uploadDataWithCompletionHandler:^(NSString * grammerID, IFlySpeechError *error) {
        if (error.errorCode == 0) {
            _speakTextView.text = @"佳晨实业\n蜀南庭苑\n高兰路\n复联二\n李馨琪\n鹿晓雷\n张集栋\n周家莉\n叶震珂\n熊泽萌\n";
        }
        [self onUploadFinished:error];
    } name:NAME data:[iFlyUserWords toString]];
}

/**
 start audio stream recognition
 **/
- (void)audioStreamBtnHandler:(id)sender {
    
    NSLog(@"%s[IN]",__func__);
    [self chuLiSuoYouView];
    [self createSpeakView];
    [self createSpeakViewAnimation];
    [self setTextLabelIsNil];
    self.isBeginOfSpeech = NO;
    self.isStreamRec = YES;
    
    if ([IATConfig sharedInstance].haveView == YES) {
        [_popUpView showText: NSLocalizedString(@"M_ISR_Stream_Fail", nil)];
        return;
    }
    
    if(_iFlySpeechRecognizer == nil) {
        [self initRecognizer];
    }
    
    [_beginPlayButton setEnabled:NO];
    [_beginSpeakButton setEnabled:NO];
    
    [_iFlySpeechRecognizer setDelegate:self];
    [_iFlySpeechRecognizer setParameter:@"json" forKey:[IFlySpeechConstant RESULT_TYPE]];
    [_iFlySpeechRecognizer setParameter:IFLY_AUDIO_SOURCE_STREAM forKey:@"audio_source"];    //Set audio stream as audio source,which requires the developer import audio data into the recognition control by self through "writeAudio:".
    BOOL ret  = [_iFlySpeechRecognizer startListening];
    
    if (ret) {
        //set the category of AVAudioSession
        [IFlyAudioSession initRecordingAudioSession];
        _pcmRecorder.delegate = self;
        BOOL ret = [_pcmRecorder start]; //start recording
        [_popUpView showText: NSLocalizedString(@"T_RecNow", nil)];
        self.isCanceled = NO;
        NSLog(@"%s[OUT],Success,Recorder ret=%d",__func__,ret);
    } else {
        [_popUpView showText: NSLocalizedString(@"M_ISR_Fail", nil)];
        [_beginSpeakButton setEnabled:YES];
        [_beginPlayButton setEnabled:YES];
        NSLog(@"%s[OUT],Failed",__func__);
    }
}

- (void)onSetting:(id)sender {}

#pragma mark - IFlySpeechRecognizerDelegate
/**
 volume callback,range from 0 to 30.
 **/
- (void) onVolumeChanged: (int)volume {
    if (self.isCanceled) {
        [_popUpView removeFromSuperview];
        return;
    }
    NSString * vol = [NSString stringWithFormat:@"%@：%d", NSLocalizedString(@"T_RecVol", nil),volume];
    [_popUpView showText: vol];
    _waveView.targetWaveHeight = (CGFloat)volume/100;
}

/**
 Beginning Of Speech
 **/
- (void) onBeginOfSpeech {
    NSLog(@"onBeginOfSpeech");
    if (self.isStreamRec == NO) {
        self.isBeginOfSpeech = YES;
        [_popUpView showText: NSLocalizedString(@"T_RecNow", nil)];
    }
}

/**
 End Of Speech
 **/
- (void) onEndOfSpeech {
    [_popUpView showText: NSLocalizedString(@"T_RecStop", nil)];
    NSLog(@"onEndOfSpeech");
    [_pcmRecorder stop];
}

/**
 recognition session completion, which will be invoked no matter whether it exits error.
 error.errorCode =
 0     success
 other fail
 **/
- (void) onCompleted:(IFlySpeechError *) error {
    NSLog(@"%s",__func__);
    NSLog(@"onBeginOfSpeech");
    if ([IATConfig sharedInstance].haveView == NO ) {
        NSString *text ;
        if (self.isCanceled) {
            text = NSLocalizedString(@"T_ISR_Cancel", nil);
        } else if (error.errorCode == 0 ) {
            if (_result.length == 0) {
                text = NSLocalizedString(@"T_ISR_NoRlt", nil);
            } else {
                text = NSLocalizedString(@"T_ISR_Succ", nil);
                //empty results
                _result = nil;
            }
        } else {
            text = [NSString stringWithFormat:@"Error：%d %@", error.errorCode,error.errorDesc];
            NSLog(@"%@",text);
        }
        [_popUpView showText: text];
    } else {
        [_popUpView showText: NSLocalizedString(@"T_ISR_Succ", nil)];
        NSLog(@"errorCode:%d",[error errorCode]);
    }
    [_beginSpeakButton setEnabled:YES];
    [_beginPlayButton setEnabled:YES];
}

/**
 result callback of recognition without view
 results：recognition results
 isLast：whether or not this is the last result
 **/
- (void) onResults:(NSArray *) results isLast:(BOOL)isLast {
    NSMutableString *resultString = [[NSMutableString alloc] init];
    NSDictionary *dic = results[0];
    
    for (NSString *key in dic) {
        [resultString appendFormat:@"%@",key];
    }
    _result =[NSString stringWithFormat:@"%@%@", _speakTextView.text,resultString];
    //    _result =[NSString stringWithFormat:@"%@%@", _speakTextView.text,resultString];
    
    NSString * resultFromJson =  nil;
    
    if([IATConfig sharedInstance].isTranslate){
        
        NSDictionary *resultDic  = [NSJSONSerialization JSONObjectWithData:    //The result type must be utf8, otherwise an unknown error will happen.
                                    [resultString dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
        if(resultDic != nil){
            NSDictionary *trans_result = [resultDic objectForKey:@"trans_result"];
            
            if([[IATConfig sharedInstance].language isEqualToString:@"en_us"]) {
                NSString *dst = [trans_result objectForKey:@"dst"];
                NSLog(@"dst=%@",dst);
                resultFromJson = [NSString stringWithFormat:@"%@\ndst:%@",resultString,dst];
            } else {
                NSString *src = [trans_result objectForKey:@"src"];
                NSLog(@"src=%@",src);
                resultFromJson = [NSString stringWithFormat:@"%@\nsrc:%@",resultString,src];
            }
        }
    } else {
        resultFromJson = [ISRDataHelper stringFromJson:resultString];
    }
    
    _speakLabel.text = [NSString stringWithFormat:@"%@%@", _speakLabel.text,resultFromJson];
    _speakTextView.text = [NSString stringWithFormat:@"%@%@", _speakTextView.text,resultFromJson];
    
    if (isLast) {
        [self.waveView stopAnimating];
        
        if ([[BCUserDeafaults objectForKey:SOU_SUO] isEqualToString:@"0"]) {
            
        }else{
            [self createWebView];
            [self createWebViewAnimation];
        }
    
        
//        https://cn.bing.com/search?q=%E4%BD%A0%E5%A5%BD&qs=n&form=QBLH&sp=-1&pq=%E4%BD%A0%E5%A5%BD&sc=8-6&sk=&cvid=E6B95787A8F7430BA283E4431CF77526
        
        NSString *urlString = @"";
        

        IATConfig *config = [IATConfig sharedInstance];
        if ([config.sousuoyinqin isEqualToString:@"百度搜索"]) {
                urlString = [NSString stringWithFormat:@"https://www.baidu.com/s?wd=%@",_speakTextView.text];
        }
        if ([config.sousuoyinqin isEqualToString:@"必应搜索"]) {
                urlString = [NSString stringWithFormat:@"https://cn.bing.com/search?q=%@",_speakTextView.text];
        }
        
        if ([config.sousuoyinqin isEqualToString:@"搜狗搜索"]) {
            urlString = [NSString stringWithFormat:@"https://www.sogou.com/web?query=%@",_speakTextView.text];
        }
        
        if ([config.sousuoyinqin isEqualToString:@"谷歌搜索"]) {
            urlString = [NSString stringWithFormat:@"https://www.google.com.hk/search?safe=strict&source=hp&ei=QB1KW6LIK-rS0gLox5PgBg&q=%@",_speakTextView.text];
            
        }
        
        

        NSString *encoded=[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:encoded]]];
        NSLog(@"ISR Results(json)：%@",  self.result);
    }
    NSLog(@"_result=%@",_result);
    NSLog(@"resultFromJson=%@",resultFromJson);
    NSLog(@"isLast=%d,_textView.text=%@",isLast,_speakTextView.text);
    NSLog(@"isLast=%d,_textView.text=%@",isLast,_speakLabel.text);
}

/**
 result callback of recognition with view
 resultArray：recognition results
 isLast：whether or not this is the last result
 **/
- (void)onResult:(NSArray *)resultArray isLast:(BOOL)isLast {
    NSMutableString *resultString = [[NSMutableString alloc] init];
    NSDictionary *dic = [resultArray objectAtIndex:0];
    
    for (NSString *key in dic) {
        [resultString appendFormat:@"%@",key];
    }
    
    NSString * resultFromJson =  nil;
    if([IATConfig sharedInstance].isTranslate){
        
        NSDictionary *resultDic  = [NSJSONSerialization JSONObjectWithData:    //The result type must be utf8, otherwise an unknown error will happen.
                                    [resultString dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
        if(resultDic != nil){
            NSDictionary *trans_result = [resultDic objectForKey:@"trans_result"];
            
            if([[IATConfig sharedInstance].language isEqualToString:@"en_us"]) {
                NSString *dst = [trans_result objectForKey:@"dst"];
                NSLog(@"dst=%@",dst);
                resultFromJson = [NSString stringWithFormat:@"%@\ndst:%@",resultString,dst];
            } else {
                NSString *src = [trans_result objectForKey:@"src"];
                NSLog(@"src=%@",src);
                resultFromJson = [NSString stringWithFormat:@"%@\nsrc:%@",resultString,src];
            }
        }
    } else {
        resultFromJson = [NSString stringWithFormat:@"%@",resultString];//;[ISRDataHelper stringFromJson:resultString];
    }
    _speakTextView.text = [NSString stringWithFormat:@"%@%@", _speakTextView.text,resultFromJson];
    _speakLabel.text = [NSString stringWithFormat:@"%@%@", _speakLabel.text,resultFromJson];
}

/**
 callback of canceling recognition
 **/
- (void)onCancel{
    NSLog(@"Recognition is cancelled");
}

-(void) showPopup{
    [_popUpView showText: NSLocalizedString(@"T_ISR_Uping", nil)];
}

#pragma mark - IFlyDataUploaderDelegate

/**
 result callback of uploading contacts or customized words
 **/
- (void) onUploadFinished:(IFlySpeechError *)error {
    NSLog(@"%d",[error errorCode]);
    
    if ([error errorCode] == 0) {
        [_popUpView showText: NSLocalizedString(@"T_ISR_UpSucc", nil)];
    } else {
        [_popUpView showText: [NSString stringWithFormat:@"%@:%d", NSLocalizedString(@"T_ISR_UpFail", nil), error.errorCode]];
    }
    [_beginSpeakButton setEnabled:YES];
    [_beginPlayButton setEnabled:YES];
}

#pragma mark - Initialization
/**
 initialize recognition conctol and set recognition params
 **/
-(void)initRecognizer{
    NSLog(@"%s",__func__);
    
    if ([IATConfig sharedInstance].haveView == NO) {
        
        //recognition singleton without view
        if (_iFlySpeechRecognizer == nil) {
            _iFlySpeechRecognizer = [IFlySpeechRecognizer sharedInstance];
        }
        
        [_iFlySpeechRecognizer setParameter:@"" forKey:[IFlySpeechConstant PARAMS]];
        
        //set recognition domain
        [_iFlySpeechRecognizer setParameter:@"iat" forKey:[IFlySpeechConstant IFLY_DOMAIN]];
        
        _iFlySpeechRecognizer.delegate = self;
        
        if (_iFlySpeechRecognizer != nil) {
            IATConfig *instance = [IATConfig sharedInstance];
            
            //set timeout of recording
            [_iFlySpeechRecognizer setParameter:instance.speechTimeout forKey:[IFlySpeechConstant SPEECH_TIMEOUT]];
            //set VAD timeout of end of speech(EOS)
            [_iFlySpeechRecognizer setParameter:instance.vadEos forKey:[IFlySpeechConstant VAD_EOS]];
            //set VAD timeout of beginning of speech(BOS)
            [_iFlySpeechRecognizer setParameter:instance.vadBos forKey:[IFlySpeechConstant VAD_BOS]];
            //set network timeout
            [_iFlySpeechRecognizer setParameter:@"20000" forKey:[IFlySpeechConstant NET_TIMEOUT]];
            
            //set sample rate, 16K as a recommended option
            [_iFlySpeechRecognizer setParameter:instance.sampleRate forKey:[IFlySpeechConstant SAMPLE_RATE]];
            
            //set language
            [_iFlySpeechRecognizer setParameter:instance.language forKey:[IFlySpeechConstant LANGUAGE]];
            //set accent
            [_iFlySpeechRecognizer setParameter:instance.accent forKey:[IFlySpeechConstant ACCENT]];
            
            //set whether or not to show punctuation in recognition results
            [_iFlySpeechRecognizer setParameter:instance.dot forKey:[IFlySpeechConstant ASR_PTT]];
            
        }
        
        //Initialize recorder
        if (_pcmRecorder == nil) {
            _pcmRecorder = [IFlyPcmRecorder sharedInstance];
        }
        
        _pcmRecorder.delegate = self;
        [_pcmRecorder setSample:[IATConfig sharedInstance].sampleRate];
        [_pcmRecorder setSaveAudioPath:nil];    //not save the audio file
        
    } else {
        //recognition singleton with view
        if (_iflyRecognizerView == nil) {
            _iflyRecognizerView= [[IFlyRecognizerView alloc] initWithCenter:self.view.center];
        }
        [_iflyRecognizerView setParameter:@"" forKey:[IFlySpeechConstant PARAMS]];
        //set recognition domain
        [_iflyRecognizerView setParameter:@"iat" forKey:[IFlySpeechConstant IFLY_DOMAIN]];
        _iflyRecognizerView.delegate = self;
        if (_iflyRecognizerView != nil) {
            IATConfig *instance = [IATConfig sharedInstance];
            //set timeout of recording
            [_iflyRecognizerView setParameter:instance.speechTimeout forKey:[IFlySpeechConstant SPEECH_TIMEOUT]];
            //set VAD timeout of end of speech(EOS)
            [_iflyRecognizerView setParameter:instance.vadEos forKey:[IFlySpeechConstant VAD_EOS]];
            //set VAD timeout of beginning of speech(BOS)
            [_iflyRecognizerView setParameter:instance.vadBos forKey:[IFlySpeechConstant VAD_BOS]];
            //set network timeout
            [_iflyRecognizerView setParameter:@"20000" forKey:[IFlySpeechConstant NET_TIMEOUT]];
            //set sample rate, 16K as a recommended option
            [_iflyRecognizerView setParameter:instance.sampleRate forKey:[IFlySpeechConstant SAMPLE_RATE]];
            //set language
            [_iflyRecognizerView setParameter:instance.language forKey:[IFlySpeechConstant LANGUAGE]];
            //set accent
            [_iflyRecognizerView setParameter:instance.accent forKey:[IFlySpeechConstant ACCENT]];
            //set whether or not to show punctuation in recognition results
            [_iflyRecognizerView setParameter:instance.dot forKey:[IFlySpeechConstant ASR_PTT]];
        }
    }
    
    if([[IATConfig sharedInstance].language isEqualToString:@"en_us"]) {
        if([IATConfig sharedInstance].isTranslate){
            [self translation:NO];
        }
    } else {
        if([IATConfig sharedInstance].isTranslate){
            [self translation:YES];
        }
    }
}

- (void)translation:(BOOL) langIsZh {
    
    if ([IATConfig sharedInstance].haveView == NO) {
        [_iFlySpeechRecognizer setParameter:@"1" forKey:[IFlySpeechConstant ASR_SCH]];
        if(langIsZh){
            [_iFlySpeechRecognizer setParameter:@"cn" forKey:@"orilang"];
            [_iFlySpeechRecognizer setParameter:@"en" forKey:@"translang"];
        } else {
            [_iFlySpeechRecognizer setParameter:@"en" forKey:@"orilang"];
            [_iFlySpeechRecognizer setParameter:@"cn" forKey:@"translang"];
        }
        [_iFlySpeechRecognizer setParameter:@"translate" forKey:@"addcap"];
        
        [_iFlySpeechRecognizer setParameter:@"its" forKey:@"trssrc"];
    } else {
        [_iflyRecognizerView setParameter:@"1" forKey:[IFlySpeechConstant ASR_SCH]];
        if(langIsZh){
            [_iflyRecognizerView setParameter:@"cn" forKey:@"orilang"];
            [_iflyRecognizerView setParameter:@"en" forKey:@"translang"];
        } else {
            [_iflyRecognizerView setParameter:@"en" forKey:@"orilang"];
            [_iflyRecognizerView setParameter:@"cn" forKey:@"translang"];
        }
        [_iflyRecognizerView setParameter:@"translate" forKey:@"addcap"];
        [_iflyRecognizerView setParameter:@"its" forKey:@"trssrc"];
    }
}


-(void)setExclusiveTouchForButtons:(UIView *)myView{
    for (UIView * button in [myView subviews]) {
        if([button isKindOfClass:[UIButton class]]) {
            [((UIButton *)button) setExclusiveTouch:YES];
        } else if ([button isKindOfClass:[UIView class]]) {
            [self setExclusiveTouchForButtons:button];
        }
    }
}

#pragma mark - IFlyPcmRecorderDelegate

- (void) onIFlyRecorderBuffer: (const void *)buffer bufferSize:(int)size {
    NSData *audioBuffer = [NSData dataWithBytes:buffer length:size];
    self.pcmData = audioBuffer;
    int ret = [self.iFlySpeechRecognizer writeAudio:audioBuffer];
    if (!ret) {
        [self.iFlySpeechRecognizer stopListening];
        [_beginSpeakButton setEnabled:YES];
        [_beginPlayButton setEnabled:YES];
    }
}

- (void) onIFlyRecorderError:(IFlyPcmRecorder*)recoder theError:(int) error{}

//range from 0 to 30
- (void) onIFlyRecorderVolumeChanged:(int) power {
    //    NSLog(@"%s,power=%d",__func__,power);
    if (self.isCanceled) {
        [_popUpView removeFromSuperview];
        return;
    }
    NSString * vol = [NSString stringWithFormat:@"%@：===我是声音=========== %d", NSLocalizedString(@"T_RecVol", nil),power];
    NSLog(@"声音大小 === %d",power);
    [_popUpView showText: vol];
}





























#pragma mark ===========WebViewDelegate============
- (void)createWebViewAnimation{
    
    self.webFatherView.frame = self.beginSpeakButton.frame;
    [UIView animateWithDuration: AnimationTime delay:0 usingSpringWithDamping:100 initialSpringVelocity:0.3 options:0 animations:^{
        
        self.webFatherView.transform = CGAffineTransformMakeScale(1, 1);
        self.webFatherView.frame = CGRectMake(kAUTOWIDTH(20), CGRectGetMaxY(self.speakView.frame) + kAUTOHEIGHT(20), ScreenWidth - kAUTOWIDTH(40), ScreenHeight -SPEAKVIEW_HEIZGHT - kAUTOHEIGHT(44) - 50);
        self.webFatherView.alpha = 1;
        
    }completion:^(BOOL finished) {
        _webViewSubLayer=[CALayer layer];
        CGRect fixframe=self.webFatherView.layer.frame;
        _webViewSubLayer.cornerRadius = kAUTOHEIGHT(10);
        _webViewSubLayer.backgroundColor=[[UIColor grayColor] colorWithAlphaComponent:0.5].CGColor;
        _webViewSubLayer.shadowColor=[UIColor grayColor].CGColor;
        _webViewSubLayer.shadowOffset=CGSizeMake(0,0);
        _webViewSubLayer.masksToBounds=NO;
        _webViewSubLayer.shadowOpacity=0.7f;
        _webViewSubLayer.frame = fixframe;
        _webViewSubLayer.shadowRadius= 7;
        [self.view.layer insertSublayer:_webViewSubLayer below:self.webFatherView.layer];
    }];
}

- (void)createWebView{
    
    self.webFatherView = [[UIView alloc]initWithFrame:CGRectMake(kAUTOWIDTH(20),ScreenHeight, ScreenWidth - kAUTOWIDTH(40), ScreenHeight -SPEAKVIEW_HEIZGHT - kAUTOHEIGHT(44) - 50)];
    self.webFatherView.transform = CGAffineTransformMakeScale(0.7, 0.7);
    self.webFatherView.layer.masksToBounds = YES;
    self.webFatherView.layer.cornerRadius = 10;
    self.webFatherView.alpha = 0;
    
    UIView *titleView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth - kAUTOWIDTH(40), kAUTOHEIGHT(44))];
    titleView.backgroundColor = [UIColor whiteColor];
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:titleView.bounds];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.backgroundColor = [UIColor whiteColor];
    titleLabel.font = [UIFont fontWithName:@"HeiTi SC" size:13];
    
    UIImageView *iconImageView = [[UIImageView alloc]init];
    iconImageView.frame = CGRectMake(kAUTOWIDTH(5), kAUTOHEIGHT(6), kAUTOWIDTH(22), kAUTOHEIGHT(22));
    
    IATConfig *config = [IATConfig sharedInstance];
    if ([config.sousuoyinqin isEqualToString:@"百度搜索"]) {
        titleLabel.text = @"百度搜索";
        iconImageView.image = [UIImage imageNamed:@"百度搜索"];
    }
    if ([config.sousuoyinqin isEqualToString:@"必应搜索"]) {
        titleLabel.text = @"必应搜索";
    }
    if ([config.sousuoyinqin isEqualToString:@"搜狗搜索"]) {
        titleLabel.text = @"搜狗搜索";
    }
    if ([config.sousuoyinqin isEqualToString:@"谷歌搜索"]) {
        titleLabel.text = @"谷歌搜索";
    }
    
    titleView.layer.shadowColor=[UIColor grayColor].CGColor;
    titleView.layer.shadowOffset=CGSizeMake(0,0.5);
    titleView.layer.shadowOpacity=0.2f;
    titleView.layer.shadowRadius= 2;
    
    
    self.webView = [[WKWebView alloc] initWithFrame:CGRectMake(0,  kAUTOHEIGHT(44), SPEAKVIEW_WIDTH, ScreenHeight - SPEAKVIEW_HEIZGHT - kAUTOHEIGHT(44) - 50 - kAUTOHEIGHT(44))];
    self.webView.allowsBackForwardNavigationGestures = YES;    //开了支持滑动返回
    self.webView.backgroundColor = [UIColor yellowColor];
    self.webView.navigationDelegate = self;
    self.webView.UIDelegate = self;
    
    [titleView addSubview:titleLabel];
    [titleView addSubview:iconImageView];

    [self.webFatherView addSubview:titleView];
    [self.webFatherView sendSubviewToBack:self.webView];
    [self.webFatherView addSubview:self.webView];
    [self.view addSubview:self.webFatherView];
}

- (WaveView *)waveView{
    if (!_waveView) {
        _waveView = [[WaveView alloc]initWithFrame:CGRectMake(0, CGRectGetMinY(_beginSpeakButton.frame) - 150, self.view.bounds.size.width, 100)];
        _waveView.backgroundColor = [UIColor clearColor];
        _waveView.targetWaveHeight = 0;
    }
    return _waveView;
}

- (WaveView *)miniWaveView{
    if (!_miniWaveView) {
        _miniWaveView = [[WaveView alloc]initWithFrame:CGRectMake(0, SPEAKVIEW_HEIZGHT - kAUTOHEIGHT(100), self.view.bounds.size.width, 40)];
        _miniWaveView.backgroundColor = [UIColor clearColor];
        _miniWaveView.targetWaveHeight = 0;
    }
    return _miniWaveView;
}

#pragma mark ========== 上面显示的SpeakView的动画
- (void)createDismissSpeakViewAnimation{
    
    [_speakSubLayer removeFromSuperlayer];
    [UIView animateWithDuration:AnimationTime animations:^{
        self.speakView.frame = CGRectMake(ScreenWidth/2 - ScreenWidth/6, kAUTOHEIGHT(44) + SPEAKVIEW_HEIZGHT/2 - kAUTOHEIGHT(22),ScreenWidth/3, kAUTOHEIGHT(44));
        self.speakTextView.frame = CGRectMake(kAUTOWIDTH(30), kAUTOHEIGHT(15), SPEAKVIEW_WIDTH - kAUTOWIDTH(60), SPEAKVIEW_HEIZGHT - kAUTOHEIGHT(80));
        self.speakTextView.alpha = 0;
        for (int i = 0; i < 5; i ++) {
            UIButton *upButton = [self.speakView viewWithTag:1000 + i];
            upButton.transform = CGAffineTransformMakeScale(1.2, 1.2);
            
            UIButton *downButton = [self.speakView viewWithTag:100 + i];
            downButton.transform = CGAffineTransformMakeScale(1.2, 1.2);
            
            [UIView animateWithDuration: AnimationTime delay:0 usingSpringWithDamping:0.3 initialSpringVelocity:0.3 options:0 animations:^{
                upButton.transform = CGAffineTransformMakeScale(0.1, 0.1);
                downButton.transform = CGAffineTransformMakeScale(0.1, 0.1);
                
                upButton.alpha = 0;
                downButton.alpha = 0;
                self.shangViewLineView.alpha = 0;
                self.baiSeMaskImageView.alpha = 0;
                self.xiaLaShareView.frame = CGRectMake(kAUTOWIDTH(15), SPEAKVIEW_HEIZGHT - kAUTOWIDTH(44), SPEAKVIEW_WIDTH - kAUTOWIDTH(30), kAUTOHEIGHT(40));
                self.xiaLaShareView.alpha = 0;
                
            } completion:^(BOOL finished) {
                upButton.hidden = YES;
                downButton.hidden = YES;
                self.shangViewLineView.hidden = YES;
            }];
        }
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:AnimationTime animations:^{
            self.speakView.frame = CGRectMake(ScreenWidth, kAUTOHEIGHT(44) + SPEAKVIEW_HEIZGHT/2 - kAUTOHEIGHT(22),ScreenWidth/3, kAUTOHEIGHT(44));
            self.speakView.alpha = 0;
            
           
            
            [self.webViewSubLayer removeFromSuperlayer];
            self.webFatherView.frame = CGRectMake(kAUTOWIDTH(20), SPEAKVIEW_HEIZGHT - kAUTOHEIGHT(20), ScreenWidth - kAUTOWIDTH(40), ScreenHeight -SPEAKVIEW_HEIZGHT - kAUTOHEIGHT(44) - 50);
            [UIView animateWithDuration:AnimationTime animations:^{
                self.webFatherView.frame = CGRectMake(kAUTOWIDTH(20), ScreenHeight, ScreenWidth - kAUTOWIDTH(40), ScreenHeight -SPEAKVIEW_HEIZGHT - kAUTOHEIGHT(44) - 50);
            } completion:^(BOOL finished) {
                [self.webFatherView removeFromSuperview];
            }];
            
        } completion:^(BOOL finished) {
            [self.speakView removeFromSuperview];
           
            [UIView animateWithDuration:AnimationTime animations:^{
                self.titleView.alpha = 1;
                self.smartImage.alpha = 0;
                self.blurImageView.alpha = 0;
            }completion:^(BOOL finished) {
                [self.smartImage removeFromSuperview];
                [self.blurImageView removeFromSuperview];
            }];
            
        }];
    }];
}


- (void)createSpeakViewAnimation{
    
    [UIView animateWithDuration:AnimationTime animations:^{
        self.titleView.alpha = 0;
    }];
    
    self.speakView.frame = self.beginSpeakButton.frame;
    self.speakView.layer.anchorPoint = CGPointMake(0.5, 0.5);
    [UIView animateWithDuration: AnimationTime delay:0 usingSpringWithDamping:100 initialSpringVelocity:0.3 options:0 animations:^{
        self.speakView.transform = CGAffineTransformMakeScale(1, 1);
        self.speakView.frame = CGRectMake(kAUTOWIDTH(20), kAUTOHEIGHT(44),SPEAKVIEW_WIDTH, SPEAKVIEW_HEIZGHT);
        if (PNCisIPHONEX) {
            self.speakView.frame = CGRectMake(kAUTOWIDTH(20), kAUTOHEIGHT(64),SPEAKVIEW_WIDTH, SPEAKVIEW_HEIZGHT);
        }
        self.speakView.alpha = 1;
        self.baiSeMaskImageView.alpha = 0.6;
    }completion:^(BOOL finished) {
        
        for (int i = 0; i < 5; i ++) {
            UIButton *upButton = [self.speakView viewWithTag:1000 + i];
            upButton.hidden = NO;
            upButton.transform = CGAffineTransformMakeScale(0.8, 0.8);
            
            UIButton *downButton = [self.speakView viewWithTag:100 + i];
            downButton.hidden = NO;
            downButton.transform = CGAffineTransformMakeScale(0.8, 0.8);
            
            [UIView animateWithDuration: AnimationTime delay:0 usingSpringWithDamping:0.3 initialSpringVelocity:0.3 options:0 animations:^{
                upButton.transform = CGAffineTransformMakeScale(1, 1);
                downButton.transform = CGAffineTransformMakeScale(1, 1);
                self.shangViewLineView.hidden = NO;
                
                self.xiaLaShareView.frame = CGRectMake(kAUTOWIDTH(15), SPEAKVIEW_HEIZGHT, SPEAKVIEW_WIDTH - kAUTOWIDTH(30), kAUTOHEIGHT(40));
                self.xiaLaShareView.alpha = 1;
            } completion:nil];
            
            
        }
        
        _speakSubLayer=[CALayer layer];
        CGRect fixframe=self.speakView.layer.frame;
        _speakSubLayer.frame = fixframe;
        _speakSubLayer.backgroundColor=[[UIColor grayColor] colorWithAlphaComponent:0.5].CGColor;
        _speakSubLayer.shadowColor=[UIColor grayColor].CGColor;
        _speakSubLayer.cornerRadius = kAUTOHEIGHT(10);
        _speakSubLayer.shadowOffset=CGSizeMake(0,0);
        _speakSubLayer.masksToBounds=NO;
        _speakSubLayer.shadowOpacity=0.7f;
        _speakSubLayer.shadowRadius= 10;
        [self.view.layer insertSublayer:_speakSubLayer below:self.speakView.layer];
        
    }];
}

#pragma mark =========== 创建SpeakView ==========
- (void)createSpeakView{
    
    self.speakView = [[UIView alloc]initWithFrame:CGRectMake(kAUTOWIDTH(20),ScreenHeight,SPEAKVIEW_WIDTH, SPEAKVIEW_HEIZGHT)];
    self.speakView.transform = CGAffineTransformMakeScale(0.7, 0.7);
    self.speakView.backgroundColor = PNCColor(164, 185, 255);
    self.speakView.alpha = 0;
    
    self.xiaLaShareView = [[UIView alloc]initWithFrame:CGRectMake(kAUTOWIDTH(15), SPEAKVIEW_HEIZGHT - kAUTOHEIGHT(40), SPEAKVIEW_WIDTH - kAUTOWIDTH(30), kAUTOHEIGHT(40))];
    self.xiaLaShareView.backgroundColor = [UIColor whiteColor];
    self.xiaLaShareView.alpha = 0;
//    [self.speakView addSubview:self.xiaLaShareView];
    
    self.baiSeMaskImageView = [[UIImageView alloc]initWithFrame:CGRectMake(4, 0, SPEAKVIEW_WIDTH - 8, kAUTOHEIGHT(15))];
    self.baiSeMaskImageView.image = [UIImage imageNamed:@"白色蒙层2"];
    [self.speakView addSubview:self.baiSeMaskImageView];
    self.baiSeMaskImageView.alpha = 0;
    
    self.speakTextView = [[UITextView alloc]initWithFrame:CGRectMake(kAUTOWIDTH(30), kAUTOHEIGHT(35), SPEAKVIEW_WIDTH - kAUTOWIDTH(60), SPEAKVIEW_HEIZGHT - kAUTOHEIGHT(80))];
    self.speakTextView.font = [UIFont fontWithName:@"HeiTi SC" size:14];
    self.speakTextView.backgroundColor = [UIColor clearColor];
    self.speakTextView.tintColor = [UIColor whiteColor];
    self.speakTextView.textColor = [UIColor whiteColor];
    self.speakTextView.text = @"";
    
    [self.view addSubview:self.speakView];
    [self.speakView addSubview:self.speakTextView];
    
    self.playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    for (int i = 0 ; i < 5; i ++) {
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake( kAUTOWIDTH(100)/2  + i *(((ScreenWidth - kAUTOWIDTH(40) - kAUTOWIDTH(100))- kAUTOWIDTH(30)*5)/4 + kAUTOWIDTH(30)), -kAUTOHEIGHT(15), kAUTOWIDTH(30), kAUTOHEIGHT(30));
        [button setImageEdgeInsets:UIEdgeInsetsMake(kAUTOWIDTH(6), kAUTOHEIGHT(6),kAUTOWIDTH(6), kAUTOHEIGHT(6))];
        button.backgroundColor = [UIColor blueColor];
        [self.speakView addSubview:button];
        
        button.layer.borderColor = [UIColor whiteColor].CGColor;
        button.layer.shadowColor = [UIColor grayColor].CGColor;
        button.layer.shadowOffset = CGSizeMake(0, 2);
        button.layer.cornerRadius = kAUTOHEIGHT(15);
        button.layer.shadowOpacity = 0.3;
        button.layer.shadowRadius = 3;
        button.layer.borderWidth = 2;
        
        if (i == 0) {
            [button setImage:[UIImage imageNamed:@"目标"] forState:UIControlStateNormal];
            button.backgroundColor =  PNCColor(134, 176, 255);
        }else if (i == 1){
            [button setImage:[UIImage imageNamed:@"沟通"] forState:UIControlStateNormal];
            button.backgroundColor = PNCColor(255, 120, 159);
        }else if (i == 2){
            [button setImage:[UIImage imageNamed:@"标签"] forState:UIControlStateNormal];
            button.backgroundColor = PNCColor(255, 172, 94);
        }else if (i == 3){
            [button setImage:[UIImage imageNamed:@"女士"] forState:UIControlStateNormal];
            button.backgroundColor = PNCColor(109, 212, 92);
        }else if (i == 4){
            [button setImage:[UIImage imageNamed:@"灵感"] forState:UIControlStateNormal];
            button.backgroundColor = PNCColor(182, 118, 219);
        }
        
        [button addTarget:self action:@selector(TouchDown:)forControlEvents: UIControlEventTouchDown];        //处理按钮点击事件
        [button addTarget:self action:@selector(TouchUp:)forControlEvents: UIControlEventTouchUpInside | UIControlEventTouchUpOutside];        //处理按钮松开状态
        [button addTarget:self action:@selector(ShangYiPaiButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = 1000 + i;
        button.hidden = YES;
        
        if (PNCisIPAD) {
            button.frame = CGRectMake( kAUTOWIDTH(100)/2  + i *(((ScreenWidth - kAUTOWIDTH(40) - kAUTOWIDTH(100))- kAUTOWIDTH(30)*5)/4 + kAUTOWIDTH(30)), -kAUTOHEIGHT(15), 30, 30);
            [button setImageEdgeInsets:UIEdgeInsetsMake(6, 6,6, 6)];
        }
    }
    
    for (int i = 0; i < 5; i ++) {
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake( kAUTOWIDTH(30)/2  + i *(((ScreenWidth - kAUTOWIDTH(40) - kAUTOWIDTH(30))- kAUTOWIDTH(30)*5)/4 + kAUTOWIDTH(30)),SPEAKVIEW_HEIZGHT - kAUTOHEIGHT(35), kAUTOWIDTH(30), kAUTOHEIGHT(30));
        
        button.backgroundColor = [UIColor blueColor];
        [self.speakView addSubview:button];
        button.tag = 100 + i;
        button.hidden = YES;
        
        [button setImageEdgeInsets:UIEdgeInsetsMake(kAUTOWIDTH(4), kAUTOHEIGHT(4),kAUTOWIDTH(4), kAUTOHEIGHT(4))];
        [button addTarget:self action:@selector(XiaYiPaiButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [button setImage:[UIImage imageNamed:@"灵感"] forState:UIControlStateNormal];
        button.layer.borderColor = [UIColor whiteColor].CGColor;
        button.layer.shadowColor = [UIColor grayColor].CGColor;
        button.layer.cornerRadius = kAUTOHEIGHT(15);
        button.layer.shadowOffset = CGSizeMake(0, 2);
        button.layer.shadowOpacity = 0.3;
        button.layer.borderWidth = 2;
        button.layer.shadowRadius = 3;
        
        if (i == 0) {
            [button setImage:[UIImage imageNamed:@"删除min"] forState:UIControlStateNormal];
            button.backgroundColor =  PNCColor(134, 176, 255);
        } else if (i == 1){
            [button setImage:[UIImage imageNamed:@"分享new"] forState:UIControlStateNormal];
            button.backgroundColor = PNCColor(255, 120, 159);
        } else if (i == 2){
            [button setImage:[UIImage imageNamed:@"日历"] forState:UIControlStateNormal];
            button.backgroundColor = PNCColor(255, 172, 94);
        } else if (i == 3){
            [button setImage:[UIImage imageNamed:@"编辑"] forState:UIControlStateNormal];
            button.backgroundColor = PNCColor(109, 212, 92);
        } else if (i == 4){
            [button setImage:[UIImage imageNamed:@"下载"] forState:UIControlStateNormal];
            button.backgroundColor = PNCColor(182, 118, 219);
        }
        if (PNCisIPAD) {
            button.frame = CGRectMake( kAUTOWIDTH(30)/2  + i *(((ScreenWidth - kAUTOWIDTH(40) - kAUTOWIDTH(30))- kAUTOWIDTH(30)*5)/4 + kAUTOWIDTH(30)),SPEAKVIEW_HEIZGHT - kAUTOHEIGHT(35), 30, 30);
            [button setImageEdgeInsets:UIEdgeInsetsMake(6, 6, 6, 6)];
        }
    }
    
    self.shangViewLineView =  [[UIView alloc]initWithFrame:CGRectMake(0, SPEAKVIEW_HEIZGHT - kAUTOHEIGHT(38), SPEAKVIEW_WIDTH,0.5)];
    self.shangViewLineView.backgroundColor = PNCColor(235, 235, 235);
    self.speakView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.speakView.layer.cornerRadius = kAUTOWIDTH(10);
    [self.speakView addSubview:self.shangViewLineView];
    self.shangViewLineView.hidden = YES;
    self.speakView.layer.borderWidth = 2;
}

- (void)TouchDown:(UIButton *)sender{
    
    [UIView animateWithDuration:0.3 animations:^{
        sender.transform = CGAffineTransformMakeScale(1.5, 1.5);
    }];
}

- (void)TouchUp:(UIButton *)sender{
    [UIView animateWithDuration:0.3 animations:^{
        sender.transform = CGAffineTransformMakeScale(1, 1);
    }];
}

- (void)kaiShiAnXiaShiBieBtn{

    if ([[UIDevice currentDevice].systemVersion floatValue] >= 10.0) {
        if (@available(iOS 10.0, *)) {
            UIImpactFeedbackGenerator*impactLight = [[UIImpactFeedbackGenerator alloc]initWithStyle:UIImpactFeedbackStyleLight];
            [impactLight impactOccurred];
        }
    } else {
        AudioServicesPlaySystemSound(1519);

    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self startBtnHandler:nil];
    });
}

- (void)kaiShiSongKaiShiBieBtn{
    
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 10.0) {
        if (@available(iOS 10.0, *)) {
            UIImpactFeedbackGenerator*impactLight = [[UIImpactFeedbackGenerator alloc]initWithStyle:UIImpactFeedbackStyleLight];
            [impactLight impactOccurred];
        }
    } else {
        AudioServicesPlaySystemSound(1519);
    }
    [self stopBtnHandler:nil];
}
- (void)maDaQingZhenDongDong{
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 10.0) {
        if (@available(iOS 10.0, *)) {
            UIImpactFeedbackGenerator*impactLight = [[UIImpactFeedbackGenerator alloc]initWithStyle:UIImpactFeedbackStyleLight];
            [impactLight impactOccurred];
        }
    } else {
        AudioServicesPlaySystemSound(1519);
    }
}

- (void)maDaZhongJianZhenDong{
    
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 10.0) {
        if (@available(iOS 10.0, *)) {
            UIImpactFeedbackGenerator*impactLight = [[UIImpactFeedbackGenerator alloc]initWithStyle:UIImpactFeedbackStyleMedium];
            [impactLight impactOccurred];
        }
    } else {
        AudioServicesPlaySystemSound(1519);
    }
}

- (void)pushSettingViewController:(UIButton *)sender{
    [BCShanNianKaPianManager maDaQingZhenDong];
    sender.transform = CGAffineTransformMakeScale(0.8, 0.8);    // 先缩小
    // 弹簧动画，参数分别为：时长，延时，弹性（越小弹性越大），初始速度
    [UIView animateWithDuration: 0.7 delay:0 usingSpringWithDamping:0.3 initialSpringVelocity:0.3 options:0 animations:^{
        sender.transform = CGAffineTransformMakeScale(1, 1);        // 放大
    } completion:nil];
    SettingViewController *svc = [[SettingViewController alloc]init];
    [self presentViewController:svc animated:YES completion:nil];
//    [self.navigationController pushViewController:svc animated:YES];
}

#pragma mark - ======开始心跳动画Animation=======
- (void)startHeartAnimation:(CALayer *)layer repeatCount:(CGFloat)repeatCount{
    if (@available(iOS 9.0, *)) {
        CASpringAnimation *springAnimation = [CASpringAnimation animationWithKeyPath:@"transform.scale"];
        springAnimation.mass = 10.0;
        springAnimation.stiffness = 1200;
        springAnimation.damping = 2;
        springAnimation.initialVelocity = 0;
        springAnimation.duration = 5;
        springAnimation.fromValue = [NSNumber numberWithFloat:0.95];
        springAnimation.toValue = [NSNumber numberWithFloat:1];
        springAnimation.repeatCount = repeatCount;
        springAnimation.autoreverses = YES;
        springAnimation.removedOnCompletion = NO;
        springAnimation.fillMode = kCAFillModeForwards;
        springAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        [layer addAnimation:springAnimation forKey:@"springAnimation"];
    }
}

- (void)createBaseUI{
    

    self.beginSpeakButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.beginSpeakButton.frame = CGRectMake(ScreenWidth/2 - 32.5, ScreenHeight - 100, 65, 65);
    [self.beginSpeakButton setImage:[UIImage imageNamed:@"newbeginSpeakButton"] forState:UIControlStateNormal];
    self.beginSpeakButton.layer.borderColor = [UIColor whiteColor].CGColor;
    [self.beginSpeakButton setTitle:@"说话" forState:UIControlStateNormal];
    self.beginSpeakButton.layer.masksToBounds = YES;
    self.beginSpeakButton.layer.cornerRadius = 32.5;
    self.beginSpeakButton.layer.borderWidth = 2;
    
    CALayer * speakSubLayer=[CALayer layer];
    speakSubLayer.frame = CGRectMake(ScreenWidth/2 - 30, ScreenHeight - 97.5, 60, 60);
    speakSubLayer.cornerRadius =30;
    speakSubLayer.backgroundColor=[[UIColor grayColor] colorWithAlphaComponent:0.5].CGColor;
    speakSubLayer.masksToBounds=NO;
    speakSubLayer.shadowColor=[UIColor grayColor].CGColor;
    speakSubLayer.shadowOffset=CGSizeMake(0,0);
    speakSubLayer.shadowOpacity=0.8f;
    speakSubLayer.shadowRadius= 10;
    
    [self.view.layer insertSublayer:speakSubLayer below:self.speakView.layer];
    [self.view addSubview:self.beginSpeakButton];
    [self.beginSpeakButton addTarget:self action:@selector(kaiShiAnXiaShiBieBtn) forControlEvents:UIControlEventTouchDown];
    [self.beginSpeakButton addTarget:self action:@selector(kaiShiSongKaiShiBieBtn) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
    
    self.beginPlayButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.beginPlayButton.frame = CGRectMake(ScreenWidth/2 - 25, ScreenHeight - 170, 50, 50);
    self.beginPlayButton.backgroundColor = [UIColor redColor];
    self.beginPlayButton.layer.masksToBounds = YES;
    self.beginPlayButton.layer.cornerRadius = 25;
    [self.beginPlayButton addTarget:self action:@selector(playRecord) forControlEvents:UIControlEventTouchUpInside];
    
    self.pushButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.pushButton.frame = CGRectMake(ScreenWidth -65, ScreenHeight/2 + 100, 45, 45);
    [self.pushButton setImage:[UIImage imageNamed:@"返回zhuye"] forState:UIControlStateNormal];
    self.pushButton.layer.masksToBounds = YES;
    self.pushButton.layer.cornerRadius = 25;
    [self.view addSubview:self.pushButton];
    [self.pushButton setTitle:@"next" forState:UIControlStateNormal];
    [self.pushButton addTarget:self action:@selector(pushMuLu) forControlEvents:UIControlEventTouchUpInside];
    
    [self startHeartAnimation:self.pushButton.layer repeatCount:1];
    [self startHeartAnimation:self.beginSpeakButton.layer repeatCount:MAXFLOAT];
    self.speakLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 350, ScreenWidth-20, 200)];
    self.speakLabel.textColor = [UIColor redColor];
    self.speakLabel.numberOfLines = 0;
    
}

- (void)pushMuLu{
        [BCShanNianKaPianManager maDaQingZhenDong];
    ShanNianMuLuViewController *smlVc = [[ShanNianMuLuViewController alloc]init];
    [self.navigationController pushViewController:smlVc animated:YES];
}

- (void)playRecord{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *libraryPath = [paths objectAtIndex:0];
    NSString *cachesPath = [NSString stringWithFormat:@"%@%@",libraryPath,@"/asr.pcm"];
    
    // 创建文件夹
    NSString *createDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *createDirPath =  [createDir stringByAppendingString:@"/test"];
    [self createFolder:createDirPath];
    // 把文件拷贝到Test目录
    BOOL filesPresent1 = [self copyMissingFile:cachesPath toPath:createDirPath];
    if (filesPresent1) {
        NSLog(@"OK");
    } else {
        NSLog(@"NO");
    }
    NSString *newpath = [createDirPath stringByAppendingString:@"/asr.pcm"];
    
    NSError *error = nil;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&error];
    _audioPlayer = [[PcmPlayer alloc] initWithFilePath:newpath sampleRate:[@"16000" integerValue]];
    [_audioPlayer play];
    [self.waveView Animating];
    NSString *volumParth = [createDirPath stringByAppendingString:@"/volum.xml"];
    NSArray *resultArray = [NSArray arrayWithContentsOfFile:volumParth];
    
    _waveView.targetWaveHeight = 0.15;
    __weak typeof(self) weakSelf = self;
    _audioPlayer.playEnd = ^(BOOL playEnd) {
        if (playEnd) {
            [weakSelf.waveView stopAnimating];
        }
    };
}


#pragma mark speechRecordDelegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    [_waveView stopAnimating];
    NSLog(@"in pcmPlayer audioPlayerDidFinishPlaying");
}

-(void)onPlayCompleted{}

- (BOOL)copyMissingFile:(NSString *)sourcePath toPath:(NSString *)toPath {
    BOOL retVal = YES; // If the file already exists, we'll return success…
    NSString * finalLocation = [toPath stringByAppendingPathComponent:[sourcePath lastPathComponent]];
    if (![[NSFileManager defaultManager] fileExistsAtPath:finalLocation]) {
        retVal = [[NSFileManager defaultManager] copyItemAtPath:sourcePath toPath:finalLocation error:NULL];
    }
    return retVal;
}

- (void)createFolder:(NSString *)createDir {
    BOOL isDir = NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL existed = [fileManager fileExistsAtPath:createDir isDirectory:&isDir];
    if ( !(isDir == YES && existed == YES) ) {
        [fileManager createDirectoryAtPath:createDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
}

#pragma mark - ===========Button 点击事件 =============

/**
 start speech recognition
 **/
//弹出星星评论
- (void)showAppStoreReView{
    NSString *systemVersion = [UIDevice currentDevice].systemVersion;
    //仅支持iOS10.3+（需要做校验） 且每个APP内每年最多弹出3次评分alart
    if ([systemVersion doubleValue] > 10.3) {
        if (@available(iOS 10.3, *)) {
            if([SKStoreReviewController respondsToSelector:@selector(requestReview)]) {
                //防止键盘遮挡
                [[UIApplication sharedApplication].keyWindow endEditing:YES];
                [SKStoreReviewController requestReview];
            }
        }
    }
}

- (void)XiaYiPaiButtonClick:(UIButton *)button{
    switch (button.tag) {
        case XiaYiPaiClickActionShanChu:
            [self createDismissSpeakViewAnimation];
           
            break;
        case XiaYiPaiClickActionBaoCun:
            
            if(![[NSUserDefaults standardUserDefaults] boolForKey:@"firstText"]){
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"firstText"];
                //第一次启动
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self showAppStoreReView];
                });
            }
            
            [self createDismissSpeakViewAnimation];
//            [self.smartImage removeFromSuperview];
//            self.smartImage = nil;
            [self saveDataToiCloud];
            break;
        case XiaYiPaiClickActionRiLi:
            [self shareImage];
//            [self addEvent];
            
//            [self addnewEvent];
            break;
        case XiaYiPaiClickActionShouCang:
            [self datePickShow];

//            [self copyStringToUIPasteboard];
            break;
        case XiaYiPaiClickActionBianJi:
            [self.speakTextView becomeFirstResponder];
            break;
        default:
            break;
    }
}

- (void)datePickShow{
  
        if(_pikerView==nil){
            _backWindowView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
            [[UIApplication sharedApplication].keyWindow addSubview:_backWindowView];
            _backWindowView.backgroundColor = [UIColor blackColor];
            
            _pikerView = [DatePickerView datePickerView];
            _pikerView.frame= CGRectMake(0, ScreenHeight, ScreenWidth, 257);
            _backWindowView.alpha = 0.5;
            _pikerView.delegate = self;
            _pikerView.type = 1;
            
            NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
            NSDate *currentDate = [NSDate date];
            NSDateComponents *comps1 = [[NSDateComponents alloc] init];
            [comps1 setYear:100];//设置最大时间为：当前时间推后十年
            NSDate *maxDate = [calendar dateByAddingComponents:comps1 toDate:currentDate options:0];
            NSDateComponents *comps2 = [[NSDateComponents alloc] init];
            [comps2 setDay:0];//设置最大时间为：当前时间推后十年
            NSDate *minDate = [calendar dateByAddingComponents:comps2 toDate:currentDate options:0];
            _pikerView.datePickerView.minimumDate = minDate;
            _pikerView.datePickerView.maximumDate = maxDate;
            
            [[UIApplication sharedApplication].keyWindow addSubview:_pikerView];
            [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                _pikerView.frame = CGRectMake(0, ScreenHeight-257, ScreenWidth, 257);
            } completion:nil];
            [_pikerView.sureBtn addTarget:self action:@selector(dataPickViewSureBtnClicked) forControlEvents:UIControlEventTouchUpInside];
            [_pikerView.cannelBtn addTarget:self action:@selector(dataPickViewCancleBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        }else{
            [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                _pikerView.frame = CGRectMake(0, ScreenHeight, ScreenWidth, 257);
                [_backWindowView removeFromSuperview];
                _backWindowView = nil;
            } completion:^(BOOL finished) {
                [self.pikerView removeFromSuperview];
                self.pikerView = nil;
            }];
        
    }
}

- (void)dataPickViewSureBtnClicked{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    _selectValue = [dateFormatter stringFromDate:self.pikerView.datePickerView.date];
    NSLog(@"确定 = %@",_selectValue);
    
    [UIView animateWithDuration:0.5 animations:^{
        [_backWindowView removeFromSuperview];
        _backWindowView = nil;
        _pikerView.frame = CGRectMake(0, ScreenHeight, ScreenWidth, 257);
    } completion:^(BOOL finished) {
        [self addnewEvent];
    }];
}

-(void)dataPickViewCancleBtnClicked{
    [_backWindowView removeFromSuperview];
    [self.pikerView removeFromSuperview];
    self.pikerView = nil;
    NSLog(@"取消");
}

//字符串转日期格式
- (NSDate *)stringToDate:(NSString *)dateString withDateFormat:(NSString *)format
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:format];
    
    NSDate *date = [dateFormatter dateFromString:dateString];
    return [self worldTimeToChinaTime:date];
}

//将世界时间转化为中国区时间
- (NSDate *)worldTimeToChinaTime:(NSDate *)date
{
    NSTimeZone *timeZone = [NSTimeZone systemTimeZone];
    NSInteger interval = [timeZone secondsFromGMTForDate:date];
    NSDate *localeDate = [date  dateByAddingTimeInterval:interval];
    return localeDate;
}

- (void) addnewEvent {
    EventCalendar *calendar = [EventCalendar sharedEventCalendar];
//
//    NSString *str = [self dateToString:nowDate withDateFormat:@"yyyy-MM-dd HH:mm:ss"];
//    NSLog(@"%@",str);
    
//    NSDate *newdate = [self stringToDate:_selectValue withDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
 
    
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    format.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSDate *newdate = [format dateFromString:_selectValue];

    NSLog(@"%@",newdate);

    [calendar createEventCalendarTitle:@"闪念-日程" location:_speakTextView.text startDate:[NSDate dateWithTimeInterval:60 sinceDate:newdate] endDate:[NSDate dateWithTimeInterval:300 sinceDate:newdate] allDay:NO alarmArray:@[@"-30"]];
}

- (void)addEvent{
    EKEventStore *eventStore = [[EKEventStore alloc] init];
    //6.0及以上通过下面方式写入事件
    if ([eventStore respondsToSelector:@selector(requestAccessToEntityType:completion:)])
    {
        // the selector is available, so we must be on iOS 6 or newer
        [eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (error)
                {
                    //错误细心
                    // display error message here
                }
                else if (!granted)
                {
                    //被用户拒绝，不允许访问日历
                    // display access denied error message here
                }
                else
                {
                    // access granted
                    // ***** do the important stuff here *****
                    
                    //事件保存到日历
                    
                    
                    //创建事件
                    EKEvent *event  = [EKEvent eventWithEventStore:eventStore];
                    event.title     = @"哈哈哈，我是日历事件啊";
                    event.location = @"我在上海市普陀区";
                    
                    NSDateFormatter *tempFormatter = [[NSDateFormatter alloc]init];
                    [tempFormatter setDateFormat:@"dd.MM.yyyy HH:mm"];
                    
                    event.startDate = [[NSDate alloc]init ];
                    event.endDate   = [[NSDate alloc]init ];
                    event.allDay = YES;
                    
                    //添加提醒
                    [event addAlarm:[EKAlarm alarmWithRelativeOffset:60.0f * -60.0f * 24]];
                    [event addAlarm:[EKAlarm alarmWithRelativeOffset:60.0f * -15.0f]];
                    
                    [event setCalendar:[eventStore defaultCalendarForNewEvents]];
                    NSError *err;
                    [eventStore saveEvent:event span:EKSpanThisEvent error:&err];
                    
                    UIAlertView *alert = [[UIAlertView alloc]
                                          initWithTitle:@"Event Created"
                                          message:@"Yay!?"
                                          delegate:nil
                                          cancelButtonTitle:@"Okay"
                                          otherButtonTitles:nil];
                    [alert show];
                    
                    NSLog(@"保存成功");
                    
                }
            });
        }];
    }
    else
    {
        // this code runs in iOS 4 or iOS 5
        // ***** do the important stuff here *****
        
        //4.0和5.0通过下述方式添加
        
        //保存日历
        EKEvent *event  = [EKEvent eventWithEventStore:eventStore];
        event.title     = @"哈哈哈，我是日历事件啊";
        event.location = @"我在上海市普陀区";
        
        NSDateFormatter *tempFormatter = [[NSDateFormatter alloc]init];
        [tempFormatter setDateFormat:@"dd.MM.yyyy HH:mm"];
        
        event.startDate = [[NSDate alloc]init ];
        event.endDate   = [[NSDate alloc]init ];
        event.allDay = YES;
        
        
        [event addAlarm:[EKAlarm alarmWithRelativeOffset:60.0f * -60.0f * 24]];
        [event addAlarm:[EKAlarm alarmWithRelativeOffset:60.0f * -15.0f]];
        
        [event setCalendar:[eventStore defaultCalendarForNewEvents]];
        NSError *err;
        [eventStore saveEvent:event span:EKSpanThisEvent error:&err];
        
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Event Created"
                              message:@"Yay!?"
                              delegate:nil
                              cancelButtonTitle:@"Okay"
                              otherButtonTitles:nil];
        [alert show];
        
        NSLog(@"保存成功");
    }
        
}

- (void)shareImage{
    
    NSString *text = _speakTextView.text;
    NSURL *urlToShare = [NSURL URLWithString:@"https://itunes.apple.com/cn/app/id1397149726?mt=8"];

//    NSData *data = [NSData dataWithContentsOfURL:urlToShare];
//        NSString *imageName = @"QQ20180311-1.jpg";
    //    NSString *path = [[NSBundle mainBundle] pathForResource:imageName ofType:nil];
    //    UIImage *image2 = nil;
    //
    //    UIImageView *imageView1 = [[UIImageView alloc]init];
    //    imageView1.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight - 130);
    //    imageView1.image = image2;
    //    imageView1.contentMode = UIViewContentModeScaleAspectFit;
    //
    //    UIImageView *imageView2 = [[UIImageView alloc]init];
    //    imageView2.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight);
    //    [imageView2 addSubview:imageView1];
    //
    //    UIImageView  *iconImage3 = [[UIImageView alloc]init];
    //    iconImage3.frame = CGRectMake(20, ScreenHeight - 100, 60, 60);
    //    iconImage3.image = [UIImage imageNamed:@"shareicon.jpeg"];
    //    [imageView2 addSubview:iconImage3];
    //
    //
    //    UILabel *label = [Factory createLabelWithTitle:@"时间胶囊" frame:CGRectMake(20, ScreenHeight - 40, 60, 20)];
    //    label.font = [UIFont fontWithName:@"Heiti SC" size:9];
    //    label.textAlignment = NSTextAlignmentCenter;
    //    [imageView2 addSubview:label];
    //
    //    imageView2.backgroundColor = [UIColor whiteColor];
    ////    UIImage *zuihouImage = [self convertImageViewToImage:imageView2];
    
    UIImage *iconImage = [UIImage imageNamed:@"icon.png"];
    
    NSArray *activityItems = @[text,urlToShare];
    
    UIActivityViewController *activityViewController =[[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
    activityViewController.popoverPresentationController.sourceView = self.view;
    [self presentViewController:activityViewController animated:YES completion:nil];
    // 分享类型
    [activityViewController setCompletionWithItemsHandler:^(NSString * __nullable activityType, BOOL completed, NSArray * __nullable returnedItems, NSError * __nullable activityError){
        // 显示选中的分享类型
        NSLog(@"当前选择分享平台 %@",activityType);
        if (completed) {
            [SVProgressHUD showInfoWithStatus:@"分享成功"];
            NSLog(@"分享成功");
        } else {
            [SVProgressHUD showInfoWithStatus:@"分享失败"];
            NSLog(@"分享失败");
        }
    }];
}

- (void)copyStringToUIPasteboard{
    UIPasteboard * pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = self.speakTextView.text;
    [SVProgressHUD showInfoWithStatus:@"复制成功"];
}

- (void)ShangYiPaiButtonClick:(UIButton *)button{
    switch (button.tag) {
        case ShangYiPaiClickActionDaiban:
            self.speakView.backgroundColor = PNCColor(164, 185, 255);
            self.nowColor = @"52";
            break;
        case ShangYiPaiClickActionDaiFaXiaoXi:
            self.speakView.backgroundColor = PNCColor(255, 120, 159);
            self.nowColor = @"53";
            break;
        case ShangYiPaiClickActionJiShi:
            self.speakView.backgroundColor = PNCColor(255, 172, 94);
            self.nowColor = @"54";
            break;
        case ShangYiPaiClickActionLiaoTian:
            self.speakView.backgroundColor = PNCColor(109, 212, 92);
            self.nowColor = @"55";
            
            break;
        case ShangYiPaiClickActionLingGan:
            self.speakView.backgroundColor = PNCColor(182, 118, 219);
            self.nowColor = @"56";
            break;
        default:
            break;
    }
}

//处理所有View
- (void)chuLiSuoYouView{
    if (!self.speakView) {
        [self createSpeakView];
    }else{
        [self.speakView removeFromSuperview];
        [self createSpeakView];
    }
    [self.speakSubLayer removeFromSuperlayer];
    
    if (!self.webFatherView) {
        [self createWebView];
    }else{
        [self.webFatherView removeFromSuperview];
        [self createWebView];
    }
    [self.webViewSubLayer removeFromSuperlayer];
}

- (void)saveDataToiCloud{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *libraryPath = [paths objectAtIndex:0];
    NSString *cachesPath = [NSString stringWithFormat:@"%@%@",libraryPath,@"/asr.pcm"];
    NSFileManager* fm=[NSFileManager defaultManager];
    NSData *data = [fm contentsAtPath:cachesPath];
    
    LZDataModel *model3 = [[LZDataModel alloc]init];
    model3.userName = @"";
    model3.nickName = @"0";
    model3.password = @"";
    model3.urlString = @"";
    model3.groupName = @"";
    //    model3.groupID = group.identifier;
    model3.titleString = _speakTextView.text;
    model3.contentString = [ShanNianViewController getCurrentTimes];
    model3.colorString = self.nowColor;
    
    NSData * compressCardBackStrData = [BCShanNianKaPianManager gzipData:data];
    NSString *imageBackDataString=[compressCardBackStrData base64EncodedStringWithOptions:0];
    
    model3.pcmData = imageBackDataString;
    [LZSqliteTool LZInsertToTable:LZSqliteDataTableName model:model3];
    
    //    [iCloudHandle saveCloudKitModelWithTitle:_speakTextView.text
    //                                     content:_speakTextView.text
    //                                  photoImage:data];
    //
    
    [self saveDataByNSUserDefaultsWithTitle:_speakTextView.text withKey:@"widgetTitle"];
    [self saveDataByNSUserDefaultsWithTitle:[ShanNianViewController getCurrentTimes] withKey:@"widgetTime"];

    NSLog(@"======================%@===========",[self readDataFromNSUserDefaultsWithKey:@"widgetTitle"]);
}

//读取数据
- (NSString *)readDataFromNSUserDefaultsWithKey:(NSString *)key{
    NSUserDefaults *shared = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.xiaoshannian"];
    NSString *value = [shared valueForKey:key];
    return value;
}
//保存数据
- (void)saveDataByNSUserDefaultsWithTitle:(NSString *)titleString withKey:(NSString *)key{
    NSUserDefaults *shared = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.xiaoshannian"];
    [shared setObject:titleString forKey:key];
    [shared synchronize];
}

+(NSString*)getCurrentTimes{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    // ----------设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制
    
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    
    //现在时间,你可以输出来看下是什么格式
    
    NSDate *datenow = [NSDate date];
    
    //----------将nsdate按formatter格式转成nsstring
    
    NSString *currentTimeString = [formatter stringFromDate:datenow];
    
    NSLog(@"currentTimeString =  %@",currentTimeString);
    
    return currentTimeString;
    
}

- (void)playPcmWith:(NSData *)pcmData{
    NSError *error = nil;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&error];
    _audioPlayer = [[PcmPlayer alloc] initWithData:pcmData sampleRate:[@"16000" integerValue]];
    [_audioPlayer play];
}

#pragma mark ===========WebView=============

// 页面开始加载时调用
-(void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation{
    
}
// 当内容开始返回时调用
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation{
    
}
// 页面加载完成之后调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{//这里修改导航栏的标题，动态改变
    self.title = webView.title;
}
// 页面加载失败时调用
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation{
    
}
// 接收到服务器跳转请求之后再执行
- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation{
    
}
// 在收到响应后，决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler{
    
    NSLog(@"%@",webView);
    NSLog(@"%@",navigationResponse);
    
    WKNavigationResponsePolicy actionPolicy = WKNavigationResponsePolicyAllow;
    //这句是必须加上的，不然会异常
    decisionHandler(actionPolicy);
    
}
// 在发送请求之前，决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler{
    
    self.title = webView.title;
    
    WKNavigationActionPolicy actionPolicy = WKNavigationActionPolicyAllow;
    
    
    if (navigationAction.navigationType==WKNavigationTypeBackForward) {//判断是返回类型
        
        //同时设置返回按钮和关闭按钮为导航栏左边的按钮 这里可以监听左滑返回事件，仿微信添加关闭按钮。
        //        self.navigationItem.leftBarButtonItems = @[self.backBtn, self.closeBtn];
        //可以在这里找到指定的历史页面做跳转
        //        if (webView.backForwardList.backList.count>0) {                                  //得到栈里面的list
        //            NSLog(@"%@",webView.backForwardList.backList);
        //            NSLog(@"%@",webView.backForwardList.currentItem);
        //            WKBackForwardListItem * item = webView.backForwardList.currentItem;          //得到现在加载的list
        //            for (WKBackForwardListItem * backItem in webView.backForwardList.backList) { //循环遍历，得到你想退出到
        //                //添加判断条件
        //                [webView goToBackForwardListItem:[webView.backForwardList.backList firstObject]];
        //            }
        //        }
    }
    //这句是必须加上的，不然会异常
    decisionHandler(actionPolicy);
}

//显示一个JS的Alert（与JS交互）
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler{
    NSLog(@"弹窗alert");
    NSLog(@"%@",message);
    NSLog(@"%@",frame);
    //    [self.view makeToast:message];
    completionHandler();
}

//弹出一个输入框（与JS交互的）
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(nullable NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * __nullable result))completionHandler{
    NSLog(@"弹窗输入框");
    NSLog(@"%@",prompt);
    NSLog(@"%@",defaultText);
    NSLog(@"%@",frame);
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:prompt message:defaultText preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *a1 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        //这里必须执行不然页面会加载不出来
        completionHandler(@"");
    }];
    UIAlertAction *a2 = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"%@",
              [alert.textFields firstObject].text);
        completionHandler([alert.textFields firstObject].text);
    }];
    [alert addAction:a1];
    [alert addAction:a2];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        NSLog(@"%@",textField.text);
    }];
    [self presentViewController:alert animated:YES completion:nil];
}

//显示一个确认框（JS的）
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL result))completionHandler{
    NSLog(@"弹窗确认框");
    NSLog(@"%@",message);
    NSLog(@"%@",frame);
    
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:message message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(NO);
    }];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(YES);
    }];
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}
//-(void)backNative{
//    //判断是否有上一层H5页面
//    if ([self.webView canGoBack]) {
//        //如果有则返回
//        [self.webView goBack];
//        //同时设置返回按钮和关闭按钮为导航栏左边的按钮
//        self.navigationItem.leftBarButtonItems = @[self.backBtn, self.closeBtn];
//    } else {
//        [self closeNative];
//    }
//}


//生成一张毛玻璃图片
- (UIImage*)blur:(UIImage*)theImage
{
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *inputImage = [CIImage imageWithCGImage:theImage.CGImage];
    
    CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur"];
    [filter setValue:inputImage forKey:kCIInputImageKey];
    [filter setValue:[NSNumber numberWithFloat:20.0f] forKey:@"inputRadius"];
    CIImage *result = [filter valueForKey:kCIOutputImageKey];
    
    CGImageRef cgImage = [context createCGImage:result fromRect:[inputImage extent]];
    
    UIImage *returnImage = [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);
    return returnImage;
}

- (void)createImageView{

//    if (!self.smartImage) {
        self.smartImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
       
        if ([[BCUserDeafaults objectForKey:current_ZHUTI] isEqualToString:@"情怀主题"]) {
            [self.view addSubview:self.smartImage];
            [self.view insertSubview:self.smartImage atIndex:0];
        }
    
        UIImage *image = [ChuLiImageManager decodeEchoImageBaseWith:[BCUserDeafaults objectForKey:current_BEIJING]];
        self.smartImage.image = image;
//    }
   
//    if (!self.blurImageView) {
        self.blurImageView = [[UIImageView alloc]initWithFrame:self.smartImage.bounds];
        UIImage *screenImage = [self imageWithScreenshot];
        if ([[BCUserDeafaults objectForKey:current_ZHUTI] isEqualToString:@"情怀主题"]) {
            UIImage *image = [ChuLiImageManager decodeEchoImageBaseWith:[BCUserDeafaults objectForKey:current_BEIJING]];
            self.blurImageView.image = [self blur:image];
            [self.smartImage addSubview:self.blurImageView];
        }else{
            self.blurImageView.image = [self blur:screenImage];
            [self.view addSubview:self.blurImageView];
            [self.view insertSubview:self.blurImageView belowSubview:self.beginSpeakButton];
            [self.view insertSubview:self.sloginLabel belowSubview:self.blurImageView];

            
        }
    self.smartImage.alpha = 0;
    self.blurImageView.alpha = 0;

    [UIView animateWithDuration:0.3 animations:^{
        self.smartImage.alpha = 1;
        self.blurImageView.alpha = 1;
    }];
//    }
}


/**
 *  截取当前屏幕
 *
 *  @return NSData *
 */
- (NSData *)dataWithScreenshotInPNGFormat
{
    CGSize imageSize = CGSizeZero;
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (UIInterfaceOrientationIsPortrait(orientation))
        imageSize = [UIScreen mainScreen].bounds.size;
    else
        imageSize = CGSizeMake([UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width);
    
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    for (UIWindow *window in [[UIApplication sharedApplication] windows])
    {
        CGContextSaveGState(context);
        CGContextTranslateCTM(context, window.center.x, window.center.y);
        CGContextConcatCTM(context, window.transform);
        CGContextTranslateCTM(context, -window.bounds.size.width * window.layer.anchorPoint.x, -window.bounds.size.height * window.layer.anchorPoint.y);
        if (orientation == UIInterfaceOrientationLandscapeLeft)
        {
            CGContextRotateCTM(context, M_PI_2);
            CGContextTranslateCTM(context, 0, -imageSize.width);
        }
        else if (orientation == UIInterfaceOrientationLandscapeRight)
        {
            CGContextRotateCTM(context, -M_PI_2);
            CGContextTranslateCTM(context, -imageSize.height, 0);
        } else if (orientation == UIInterfaceOrientationPortraitUpsideDown) {
            CGContextRotateCTM(context, M_PI);
            CGContextTranslateCTM(context, -imageSize.width, -imageSize.height);
        }
        if ([window respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)])
        {
            [window drawViewHierarchyInRect:window.bounds afterScreenUpdates:YES];
        }
        else
        {
            [window.layer renderInContext:context];
        }
        CGContextRestoreGState(context);
    }
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return UIImagePNGRepresentation(image);
}

/**
 *  返回截取到的图片
 *
 *  @return UIImage *
 */
- (UIImage *)imageWithScreenshot
{
    NSData *imageData = [self dataWithScreenshotInPNGFormat];
    return [UIImage imageWithData:imageData];
}


- (void)chuShiShuaZhuTi{
    IATConfig *config = [IATConfig sharedInstance];
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:current_ZHUTI] isEqualToString:@"白色主题"]) {
        config.zhuTiSheZhi = @"白色主题";
        
        [[NSNotificationCenter defaultCenter ] postNotificationName:@"CHANGEZHUTIBAISE" object:self];
        
    }
    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:current_ZHUTI] isEqualToString:@"黑色主题"]) {
        config.zhuTiSheZhi = @"黑色主题";
        
        [[NSNotificationCenter defaultCenter ] postNotificationName:@"CHANGEZHUTIHEISE" object:self];
        
    }
    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:current_ZHUTI] isEqualToString:@"粉红主题"]) {
        config.zhuTiSheZhi = @"粉红主题";
        
        [[NSNotificationCenter defaultCenter ] postNotificationName:@"CHANGEZHUTIFENHONG" object:self];
        
    }
    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:current_ZHUTI] isEqualToString:@"情怀主题"]) {
        config.zhuTiSheZhi = @"情怀主题";
        
        [[NSNotificationCenter defaultCenter ] postNotificationName:@"CHANGEZHUTIQINGHUAI" object:self];
        
    }
}

@end


