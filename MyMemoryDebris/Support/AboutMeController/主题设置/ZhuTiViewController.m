//
//  ZhuTiViewController.m
//  MyMemoryDebris
//
//  Created by 北城 on 2018/7/16.
//  Copyright © 2018年 chenxi. All rights reserved.
//

#import "ZhuTiViewController.h"
#import "ShanNianVoiceSetCell.h"
#import "IATConfig.h"


@interface ZhuTiViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (strong, nonatomic)UITableView *tableView;

@property(nonatomic,strong)UISwitch *zhuTiKaiGuanButon;

@end

@implementation ZhuTiViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //    [self setupNaviBar];
    [self initOtherUI];
    self.navTitleLabel.text = @"主题设置";
    [self.backBtn setImage:[UIImage imageNamed:@"返回箭头2"] forState:UIControlStateNormal];
    
    [self tableView];
    [self.view insertSubview:self.titleView aboveSubview:self.tableView];
    
}


- (void)backAction{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)setupNaviBar {
    
    LZWeakSelf(ws)
    [self lzSetNavigationTitle:@"iCloud 设置"];
    [self lzSetLeftButtonWithTitle:nil selectedImage:@"houtui" normalImage:@"houtui" actionBlock:^(UIButton *button) {
        
        [ws.navigationController popViewControllerAnimated:YES];
    }];
}

- (UITableView *)tableView {
    if (_tableView == nil) {
        UITableView *table = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        
        table.delegate = self;
        table.dataSource = self;
        [self.view addSubview:table];
        _tableView = table;
        
        
        [self.tableView registerNib:[UINib nibWithNibName:@"MainContentCell" bundle:nil] forCellReuseIdentifier:@"cellID"];
        [self.tableView registerNib:[UINib nibWithNibName:@"ShanNianVoiceSetCell" bundle:nil] forCellReuseIdentifier:@"cell"];
        
        self.tableView.backgroundColor = [UIColor whiteColor];
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        IATConfig *instance = [IATConfig sharedInstance];
        if ([instance.zhuTiSheZhi isEqualToString:@"白色主题"]) {
            [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                                        animated:YES
                                  scrollPosition:UITableViewScrollPositionNone];
        }
        if ([instance.zhuTiSheZhi isEqualToString:@"黑色主题"]) {
            [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]
                                        animated:YES
                                  scrollPosition:UITableViewScrollPositionNone];
        }
        if ([instance.zhuTiSheZhi isEqualToString:@"粉红主题"]) {
            [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]
                                        animated:YES
                                  scrollPosition:UITableViewScrollPositionNone];
        }
        if ([instance.zhuTiSheZhi isEqualToString:@"情怀主题"]) {
            [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]
                                        animated:YES
                                  scrollPosition:UITableViewScrollPositionNone];
        }
        
        [table mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.and.bottom.mas_equalTo(self.view);
            make.top.mas_equalTo(self.view).offset(LZNavigationHeight);
        }];
    }
    
    return _tableView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 62;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
        return 4;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
 
        ShanNianVoiceSetCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
        
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        if (indexPath.row == 0) {
            cell.imageView.image = [UIImage imageNamed:@"圆环白"];
            cell.imageView.layer.shadowOffset = CGSizeMake(0, 0);
            cell.imageView.layer.shadowColor = [UIColor grayColor].CGColor;
            cell.imageView.layer.shadowRadius = 5;
            cell.imageView.layer.shadowOpacity = 0.5;
            cell.textLabel.text = @"纯白主题";
        }
        if (indexPath.row == 1) {
            cell.imageView.image = [UIImage imageNamed:@"圆环黑"];
            cell.textLabel.text = @"曜黑主题";
        }
        if (indexPath.row == 2) {
            cell.imageView.image = [UIImage imageNamed:@"圆环粉红"];
            cell.textLabel.text = @"粉红主题";
        }
        if (indexPath.row == 3) {
            cell.imageView.image = [UIImage imageNamed:@"锤子情怀"];
            cell.textLabel.text = @"情怀主题";
        }
        return cell;
}

- (void)qieHuanZhuTiAction:(UISwitch *)kaiGuanBtn{
    
    NSIndexPath *path=[NSIndexPath indexPathForRow:0 inSection:0];
    MainContentCell *cell = (MainContentCell *)[_tableView cellForRowAtIndexPath:path];
    
    CABasicAnimation *baseAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    baseAnimation.duration = 0.4;
    baseAnimation.repeatCount = 1;
    baseAnimation.fromValue = [NSNumber numberWithFloat:0.0]; // 起始角度
    baseAnimation.toValue = [NSNumber numberWithFloat:M_PI *  2]; // 终止角度
    [cell.imageView.layer addAnimation:baseAnimation forKey:@"rotate-layer"];
    
    
    if (kaiGuanBtn.on == YES) {
        [BCUserDeafaults setObject:@"1" forKey:SOU_SUO];
        [BCUserDeafaults synchronize];
        cell.textLabel.text =  NSLocalizedString(@"关闭搜索", nil) ;
        //        [[NSNotificationCenter defaultCenter ] postNotificationName:@"CHANGEZHUTIDEFAULT" object:self];
        
    }else{
        [BCUserDeafaults setObject:@"0" forKey:SOU_SUO];
        [BCUserDeafaults synchronize];
        
        cell.textLabel.text = NSLocalizedString(@"打开搜索", nil) ;
        //        [[NSNotificationCenter defaultCenter ] postNotificationName:@"CHANGEZHUTI" object:nil];
        
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    IATConfig *instance = [IATConfig sharedInstance];
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            instance.zhuTiSheZhi = @"白色主题";
            
            [[NSUserDefaults standardUserDefaults] setObject:@"白色主题" forKey:current_ZHUTI];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [[NSNotificationCenter defaultCenter ] postNotificationName:@"CHANGEZHUTIBAISE" object:self];

        }
        if (indexPath.row == 1) {
            instance.zhuTiSheZhi = @"黑色主题";
            
            [[NSUserDefaults standardUserDefaults] setObject:@"黑色主题" forKey:current_ZHUTI];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [[NSNotificationCenter defaultCenter ] postNotificationName:@"CHANGEZHUTIHEISE" object:self];

        }
        if (indexPath.row == 2) {
            instance.zhuTiSheZhi = @"粉红主题";
            
            [[NSUserDefaults standardUserDefaults] setObject:@"粉红主题" forKey:current_ZHUTI];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [[NSNotificationCenter defaultCenter ] postNotificationName:@"CHANGEZHUTIFENHONG" object:self];

        }
        if (indexPath.row == 3) {
            instance.zhuTiSheZhi = @"情怀主题";
            
            [[NSUserDefaults standardUserDefaults] setObject:@"情怀主题" forKey:current_ZHUTI];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [[NSNotificationCenter defaultCenter ] postNotificationName:@"CHANGEZHUTIQINGHUAI" object:self];

        }
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    
    return UITableViewAutomaticDimension;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    
    if (section == 0) {
        
        return @"注意: 同步到iCloud操作, 会覆盖已在iCloud的备份!";
    } else {
        
        return @"注意: 从iCloud同步到本地操作, 会覆盖本地已有的数据!";
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return 10;
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
