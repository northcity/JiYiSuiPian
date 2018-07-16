//
//  SouSuoSheZhiViewController.m
//  MyMemoryDebris
//
//  Created by 北城 on 2018/7/15.
//  Copyright © 2018年 chenxi. All rights reserved.
//

#import "SouSuoSheZhiViewController.h"
#import "ShanNianVoiceSetCell.h"
#import "IATConfig.h"


@interface SouSuoSheZhiViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (strong, nonatomic)UITableView *tableView;

@property(nonatomic,strong)UISwitch *zhuTiKaiGuanButon;

@end

@implementation SouSuoSheZhiViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //    [self setupNaviBar];
    [self initOtherUI];
    self.navTitleLabel.text = @"iCloud 设置";
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
        if ([instance.sousuoyinqin isEqualToString:@"百度搜索"]) {
            [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]
                                        animated:YES
                                  scrollPosition:UITableViewScrollPositionNone];
        }
        if ([instance.sousuoyinqin isEqualToString:@"必应搜索"]) {
            [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1]
                                        animated:YES
                                  scrollPosition:UITableViewScrollPositionNone];
        }
        if ([instance.sousuoyinqin isEqualToString:@"搜狗搜索"]) {
            [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:1]
                                        animated:YES
                                  scrollPosition:UITableViewScrollPositionNone];
        }
        if ([instance.sousuoyinqin isEqualToString:@"谷歌搜索"]) {
            [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:1]
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
    
    if (section == 0) {
        return 1;
    }else{
        return 5;
    }
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 2;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        
        MainContentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellID" forIndexPath:indexPath];
    
            if (indexPath.row == 0) {
//                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                cell.imageView.image = [UIImage imageNamed:@"new搜索"];
//                cell.textLabel.text = @"打开搜索";
                
                
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
                
                if ([[BCUserDeafaults objectForKey:SOU_SUO] isEqualToString:@"1"]) {
                    _zhuTiKaiGuanButon.on = YES;
                    cell.textLabel.text = NSLocalizedString(@"关闭搜索", nil) ;
                    
                }else if([[BCUserDeafaults objectForKey:SOU_SUO] isEqualToString:@"0"]){
                    _zhuTiKaiGuanButon.on = NO;
                    cell.textLabel.text = NSLocalizedString(@"打开搜索", nil) ;
                    
                }else{
                    _zhuTiKaiGuanButon.on = YES;
                    cell.textLabel.text = NSLocalizedString(@"关闭搜索", nil) ;
                    
                }
                
            
            
        }
        return cell;
    }else{
        ShanNianVoiceSetCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
        
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        if (indexPath.row == 0) {
            cell.imageView.image = [UIImage imageNamed:@"百度搜索"];
            cell.textLabel.text = @"百度搜索";
        }
        if (indexPath.row == 1) {
            cell.imageView.image = [UIImage imageNamed:@"必应"];
            cell.textLabel.text = @"必应搜索";
        }
        if (indexPath.row == 2) {
            cell.imageView.image = [UIImage imageNamed:@"搜狗搜索"];
            cell.textLabel.text = @"搜狗搜索";
        }
        if (indexPath.row == 3) {
            cell.imageView.image = [UIImage imageNamed:@"谷歌搜索"];
            cell.textLabel.text = @"谷歌搜索";
        }
        return cell;
    }
    

    
  
    
    return nil;
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

    if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            instance.sousuoyinqin = @"百度搜索";
            
            [[NSUserDefaults standardUserDefaults] setObject:@"百度搜索" forKey:current_SS];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        if (indexPath.row == 1) {
            instance.sousuoyinqin = @"必应搜索";
            
            [[NSUserDefaults standardUserDefaults] setObject:@"必应搜索" forKey:current_SS];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        if (indexPath.row == 2) {
            instance.sousuoyinqin = @"搜狗搜索";
            
            [[NSUserDefaults standardUserDefaults] setObject:@"搜狗搜索" forKey:current_SS];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        if (indexPath.row == 3) {
            instance.sousuoyinqin = @"谷歌搜索";
            
            [[NSUserDefaults standardUserDefaults] setObject:@"谷歌搜索" forKey:current_SS];
            [[NSUserDefaults standardUserDefaults] synchronize];
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
