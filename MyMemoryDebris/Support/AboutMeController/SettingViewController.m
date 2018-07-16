//
//  MEEEEViewController.m
//  leisure
//
//  Created by qianfeng0 on 16/3/3.
//  Copyright © 2016年 陈希. All rights reserved.
//

#import "SettingViewController.h"
#import "MainContentCell.h"
#import <MessageUI/MessageUI.h>
#import "AboutViewController.h"
#import "ShanNianVoiceSetViewController.h"

#import "BCMiMaYuJieSuoViewController.h"
#import "LZBaseNavigationController.h"
#import "LZiCloudViewController.h"

#import "SouSuoSheZhiViewController.h"

const CGFloat kNavigationBarHeight = 44;
const CGFloat kStatusBarHeight = 20;

@interface SettingViewController ()<UITableViewDataSource,UITableViewDelegate,MFMailComposeViewControllerDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) UIView *backView;
@property (nonatomic, strong) UIColor *backColor;
@property (nonatomic, assign) CGFloat headerHeight;

@property (nonatomic, strong) UIView *headerContentView;
@property (nonatomic, strong) UIImageView *headerImageView;
@property (nonatomic, strong) UIImageView *icon;
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, assign) CGFloat scale;

@property(nonatomic,strong)UIAlertController *alert;
@property(nonatomic,strong)UIImageView * backGroundImage;
@property(nonatomic,strong)UIVisualEffectView *effectView;
@property(nonatomic,strong)UIBlurEffect *effect;
@property(nonatomic,strong)UILabel *desginLabel;

@property(nonatomic,strong)UILabel *zhuTiDetailLabel;
@property(nonatomic,strong)UISwitch *zhuTiKaiGuanButon;

@end


@implementation SettingViewController

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
    _navTitleLabel.text = @"通用设置";
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
    [_titleView addSubview:_backBtn];
    
    
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

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    UIImageView *pin = [[UIImageView alloc]initWithFrame:CGRectMake(10, 35, 60, 30)];
    pin.image = [UIImage imageNamed:@"pin"];
    
    [self.navigationController.navigationBar addSubview:pin];
    
    UIImageView *image = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 44)];
    image.image = [UIImage imageNamed:@"titlebar_shadow"];
    
    //信息内容
    [self createUI];
    [self.view insertSubview:image aboveSubview:self.tableView];
    [self initOtherUI];

    
}
- (void)viewWillAppear:(BOOL)animated{
    
    self.navigationController.navigationBar.hidden = YES;
    self.tabBarController.tabBar.hidden = YES;

}
- (void)backAction{
    
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}
- (void)createUI{
    
  
    
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight) style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerNib:[UINib nibWithNibName:@"MainContentCell" bundle:nil] forCellReuseIdentifier:@"cell"];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.sectionHeaderHeight = 5;
    self.tableView.sectionFooterHeight = 0;
    if (PNCisIPHONEX) {
        //        self.tableView.sectionHeaderHeight = 24;
        self.tableView.sectionFooterHeight = 0;
    }
//    tableView!.cellLayoutMarginsFollowReadableWidth = false
    if (PNCisIPAD) {
        self.tableView.cellLayoutMarginsFollowReadableWidth = false;
    }
    UIImageView * backimage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    //    [self.view addSubview:backimage];
    backimage.image = [[UIImage imageNamed:@"QQ20180311-1.jpg"] applyBlurWithRadius:5 tintColor:nil saturationDeltaFactor:1 maskImage:nil];
    backimage.contentMode = UIViewContentModeScaleAspectFill;
    [self.view insertSubview:self.tableView aboveSubview:backimage];
    
    UIButton * backBtn = [Factory createButtonWithTitle:@"" frame:CGRectMake(20, 32, 25, 25) backgroundColor:[UIColor clearColor] backgroundImage:[UIImage imageNamed:@""] target:self action:@selector(backAction)];
    
    [backBtn setImage:[UIImage imageNamed:@"返回 (3).png"] forState:UIControlStateNormal];
//    [self.view addSubview:backBtn];
    
    UILabel * label = [Factory createLabelWithTitle: NSLocalizedString(@"关于", nil)  frame:CGRectMake(60, 25, 100, 40) fontSize:14.f];
    label.font = [UIFont fontWithName:@"Heiti SC" size:16.f];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor blackColor];
//    [self.view addSubview:label];
    
    if (PNCisIPHONEX) {
        backBtn.frame = CGRectMake(20, 48, 25, 25);
        label.frame = CGRectMake(60, 40, 60, 40);
    }
    
    UIView *label111 = [[UIView alloc]initWithFrame:CGRectMake((ScreenWidth-80)/2, ScreenHeight-150, 80, 80)];
    label111.backgroundColor = [UIColor whiteColor];
    label111.layer.cornerRadius=12;
    label111.layer.shadowColor=[UIColor grayColor].CGColor;
    label111.layer.shadowOffset=CGSizeMake(0.5, 0.5);
    label111.layer.shadowOpacity=0.8;
    label111.layer.shadowRadius=1.2;
    //    [self.view addSubview:label111];
    
    self.desginLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, ScreenHeight - kAUTOHEIGHT(60), ScreenWidth - 40, 44)];
    self.desginLabel.text = @"- - Create By NorthCity - -";
    self.desginLabel.textColor = PNCColorWithHex(0xdcdcdc);
    self.desginLabel.textAlignment = NSTextAlignmentCenter;
    self.desginLabel.font = [UIFont fontWithName:@"HeiTi SC" size:9];
    self.desginLabel.alpha = 0.9;
    [self.view addSubview:self.desginLabel];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    
    return UITableViewAutomaticDimension;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    if (section == 0) {
        
        return @"基本通用设置";
    }else if (section == 1){
        return @"使用设置";
    }
    else {
        
        return @"更多设置";
    }
}
//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
//
//    return 10;
//}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (PNCisIPHONEX) {
        if (section == 0) {
            
            return 85;
        } else {
            
            return 35;
        }
    }
    if (section == 0) {
        
        return 75;
    } else {
        
        return 35;
    }}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return 4;
    }else{
        return 4;
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.row == 4 && indexPath.section == 2) {
        NSString *statusString = [[NSUserDefaults standardUserDefaults] objectForKey:@"KaiGuanShiFouDaKai"];
        if ([statusString isEqualToString:@"关"]) {
            return 1;
            
        }else if ([statusString isEqualToString:@"开"]){
            return 62;
        }else{
            return 1;
        }
    }
    
    
    return 62;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MainContentCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    
    if (indexPath.section == 0 && indexPath.row == 0) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.imageView.image = [UIImage imageNamed:@"语音1"];
        cell.textLabel.text = @"语音识别设置";
    }
    if (indexPath.section == 0 && indexPath.row == 1) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.imageView.image = [UIImage imageNamed:@"云1"];
        cell.textLabel.text = @"iCloud设置";
    }
    if (indexPath.section == 0 && indexPath.row == 2) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.imageView.image = [UIImage imageNamed:@"密码1"];
        cell.textLabel.text = @"密码与解锁";
    }
    if (indexPath.section == 0 && indexPath.row == 3) {
        cell.imageView.image = [UIImage imageNamed:@"主题前.png"];
        if (!_zhuTiKaiGuanButon) {
            _zhuTiKaiGuanButon = [[UISwitch alloc]initWithFrame:CGRectMake(cell.bounds.size.width - kAUTOWIDTH(70), CGRectGetMinY(cell.label.frame) + 10, kAUTOWIDTH(50), 50)];
            if (PNCisIPAD) {
                _zhuTiKaiGuanButon.frame = CGRectMake(cell.bounds.size.width - 70, CGRectGetMinY(cell.label.frame) + 10, 50, 50);
            }
        }
        [cell.contentView addSubview:_zhuTiKaiGuanButon];
        [_zhuTiKaiGuanButon addTarget:self action:@selector(qieHuanZhuTiAction:) forControlEvents:UIControlEventTouchUpInside];
        _zhuTiKaiGuanButon.transform = CGAffineTransformMakeScale(0.8,0.8);
        _zhuTiKaiGuanButon.tintColor = [UIColor blackColor];
        _zhuTiKaiGuanButon.onTintColor = [UIColor blackColor];
        
        if ([[BCUserDeafaults objectForKey:@"ZHUTI"] isEqualToString:@"1"]) {
            _zhuTiKaiGuanButon.on = YES;
            cell.textLabel.text = NSLocalizedString(@"白色主题", nil) ;
            
        }else if([[BCUserDeafaults objectForKey:@"ZHUTI"] isEqualToString:@"0"]){
            _zhuTiKaiGuanButon.on = NO;
            cell.textLabel.text = NSLocalizedString(@"黑色主题", nil) ;
            
        }else{
            _zhuTiKaiGuanButon.on = YES;
            cell.textLabel.text = NSLocalizedString(@"白色主题", nil) ;
            
        }
        
        if (!_zhuTiDetailLabel) {
            _zhuTiDetailLabel = [Factory createLabelWithTitle:@"" frame:CGRectMake(cell.bounds.size.width - kAUTOWIDTH(195), 5, kAUTOWIDTH(120), 50)];
            if (PNCisIPAD) {
                _zhuTiDetailLabel.frame = CGRectMake(cell.bounds.size.width - 215, 5, 140, 50);
            }
//            _zhuTiDetailLabel.text =  NSLocalizedString(@"切换后需重启App生效", nil) ;
            _zhuTiDetailLabel.font = [UIFont fontWithName:@"Heiti SC" size:10];
            _zhuTiDetailLabel.textAlignment = NSTextAlignmentRight;
            
            if (ScreenWidth < 375) {
                _zhuTiDetailLabel.font = [UIFont fontWithName:@"Heiti SC" size:8];
            }
        }
        [cell.contentView addSubview:_zhuTiDetailLabel];
        
    
//        cell.textLabel.text = @"主题设置";
    }
    
    if (indexPath.section == 1 && indexPath.row == 0) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.imageView.image = [UIImage imageNamed:@"new搜索"];
        cell.textLabel.text = @"搜索设置";
    }
    
    if (indexPath.section == 2 && indexPath.row == 0) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.imageView.image = [UIImage imageNamed:@"反馈11"];
        cell.textLabel.text = @"发送反馈";
    }
    if (indexPath.section == 2 && indexPath.row == 1) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.imageView.image = [UIImage imageNamed:@"发送11"];
        cell.textLabel.text = @"分享给朋友";
    }
    if (indexPath.section == 2 && indexPath.row == 2) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.imageView.image = [UIImage imageNamed:@"点赞11"];
        cell.textLabel.text = @"给个小心心";
    }
    if (indexPath.section == 2 && indexPath.row == 3) {
        
        NSString *statusString = [[NSUserDefaults standardUserDefaults] objectForKey:@"KaiGuanShiFouDaKai"];
        if ([statusString isEqualToString:@"开"]) {
            cell.contentView.hidden = NO;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }else if ([statusString isEqualToString:@"关"]){
            cell.contentView.hidden = YES;
            cell.accessoryType = UITableViewCellAccessoryNone;
        }else{
            cell.contentView.hidden = YES;
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        
        cell.imageView.image = [UIImage imageNamed:@"个人111"];
        cell.textLabel.text = @"关于";
    }
    
    return  cell;
}

- (void)qieHuanZhuTiAction:(UISwitch *)kaiGuanBtn{
    
    NSIndexPath *path=[NSIndexPath indexPathForRow:3 inSection:0];
    MainContentCell *cell = (MainContentCell *)[_tableView cellForRowAtIndexPath:path];
    
    CABasicAnimation *baseAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    baseAnimation.duration = 0.4;
    baseAnimation.repeatCount = 1;
    baseAnimation.fromValue = [NSNumber numberWithFloat:0.0]; // 起始角度
    baseAnimation.toValue = [NSNumber numberWithFloat:M_PI]; // 终止角度
    [cell.imageView.layer addAnimation:baseAnimation forKey:@"rotate-layer"];
    
    
    if (kaiGuanBtn.on == YES) {
        [BCUserDeafaults setObject:@"1" forKey:@"ZHUTI"];
        [BCUserDeafaults synchronize];
        cell.textLabel.text =  NSLocalizedString(@"白色主题", nil) ;
        [[NSNotificationCenter defaultCenter ] postNotificationName:@"CHANGEZHUTIDEFAULT" object:self];
        
    }else{
        [BCUserDeafaults setObject:@"0" forKey:@"ZHUTI"];
        [BCUserDeafaults synchronize];
        
        cell.textLabel.text = NSLocalizedString(@"黑色主题", nil) ;
        [[NSNotificationCenter defaultCenter ] postNotificationName:@"CHANGEZHUTI" object:nil];

    }
    
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0 && indexPath.row == 0) {
        ShanNianVoiceSetViewController *svc = [[ShanNianVoiceSetViewController alloc]init];
        [self presentViewController:svc animated:YES completion:nil];
    }
    
    if (indexPath.section == 0 && indexPath.row == 1) {
        LZiCloudViewController *bvc = [[LZiCloudViewController alloc]init];
        LZBaseNavigationController *nav = [[LZBaseNavigationController alloc]initWithRootViewController:bvc];
        [self presentViewController:nav animated:YES completion:nil];
    }
    
    if (indexPath.section == 0 && indexPath.row == 2) {
        BCMiMaYuJieSuoViewController *bvc = [[BCMiMaYuJieSuoViewController alloc]init];
        LZBaseNavigationController *nav = [[LZBaseNavigationController alloc]initWithRootViewController:bvc];
        [self presentViewController:nav animated:YES completion:nil];
    }
    
    if (indexPath.section == 1 && indexPath.row == 0) {
        SouSuoSheZhiViewController *bvc = [[SouSuoSheZhiViewController alloc]init];
        LZBaseNavigationController *nav = [[LZBaseNavigationController alloc]initWithRootViewController:bvc];
        [self presentViewController:nav animated:YES completion:nil];
    }
    

    if (indexPath.section == 2 && indexPath.row == 0) {
        [self pushEmail];
    }
    
    if (indexPath.section == 2 && indexPath.row == 1) {
        [self shareImage];
    }
    
    if (indexPath.section == 2 && indexPath.row == 2) {
        NSString *itunesurl = @"itms-apps://itunes.apple.com/cn/app/id1397149726?mt=8&action=write-review";
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:itunesurl]];
    }
    
    if (indexPath.section == 2 && indexPath.row == 3){
        NSString *statusString = [[NSUserDefaults standardUserDefaults] objectForKey:@"KaiGuanShiFouDaKai"];
        if ([statusString isEqualToString:@"开"]) {
            AboutViewController * ab = [[AboutViewController alloc]init];
            [self presentViewController:ab animated:YES completion:nil];
        }
    }
}


- (void)shareImage{
    
    NSString *text = @"闪念碎片";
   
    NSURL *urlToShare = [NSURL URLWithString:@"https://itunes.apple.com/cn/app/id1397149726?mt=8"];
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
        }else {
            [SVProgressHUD showInfoWithStatus:@"分享失败"];
            
            NSLog(@"分享失败");
        }
        
    }];
    
}

-(void)pushEmail{
    MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
    if (!controller) {
        // 在设备还没有添加邮件账户的时候mailViewController为空，下面的present view controller会导致程序崩溃，这里要作出判断
        NSLog(@"设备还没有添加邮件账户");
    }else{
        controller.mailComposeDelegate = self;
        [controller setSubject:@"闪念碎片(iOS版)反馈"];
        NSString * device = [[UIDevice currentDevice] model];
        NSString * ios = [[UIDevice currentDevice] systemVersion];
        NSString *body = [NSString stringWithFormat:@"请留下您的宝贵建议和意见：\n\n\n以下信息有助于我们确认您的问题，建议保留。\nDevice: %@\nOS Version: %@\n", device, ios];
        [controller setMessageBody:body isHTML:NO];
        NSArray *toRecipients = [NSArray arrayWithObject:@"506343891@qq.com"];
        [controller setToRecipients:toRecipients];
        
        [self presentViewController:controller animated:YES completion:nil];
        
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError*)error;
{
    if (result == MFMailComposeResultSent) {
        NSLog(@"It's away!");
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"您的反馈发送成功。" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end


