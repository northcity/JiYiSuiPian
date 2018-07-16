//
//  AppDelegate.m
//  CutImageForYou
//
//  Created by chenxi on 2018/5/11.
//  Copyright © 2018年 chenxi. All rights reserved.
//

#import "AppDelegate.h"
#import "LaunchViewController.h"
#import "ShanNianViewController.h"

// 10.18
#import "LZGestureTool.h"
#import "LZGestureScreen.h"
#import "TouchIdUnlock.h"
#import "LZSqliteTool.h"
#import "LZiCloud.h"

#import "TouchIDScreen.h"
#import "BCShanNianKaPianManager.h"
#import "ShanNianMuLuViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


#pragma mark —页面跳转

- (UIViewController *)getCurrentVC
{
    UIViewController *result = nil;
    
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal)
    {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows)
        {
            if (tmpWin.windowLevel == UIWindowLevelNormal)
            {
                window = tmpWin;
                break;
            }
        }
    }
    
    UIView *frontView = [[window subviews] objectAtIndex:0];
    id nextResponder = [frontView nextResponder];
    
    if ([nextResponder isKindOfClass:[UIViewController class]])
        result = nextResponder;
    else
        result = window.rootViewController;
    
    return result;
}
- (void)jumpViewController:(NSDictionary*)tfdic
{
    if (@available(iOS 9.0, *)) {
        UIApplicationShortcutItem *cameraItem = [tfdic objectForKey:UIApplicationLaunchOptionsShortcutItemKey];
        if ([cameraItem.type isEqualToString:@"typeOne"]){
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
               
                ShanNianViewController *mainTextVc = [[ShanNianViewController alloc] init];
//                UINavigationController *rootVC = (UINavigationController *)[UIApplication sharedApplication].delegate.window.rootViewController;
                UINavigationController *navigationVC = (UINavigationController *)[UIApplication sharedApplication].delegate.window.rootViewController;
                NSMutableArray *navContollers=[NSMutableArray arrayWithArray:navigationVC.viewControllers];
                
                mainTextVc = [navContollers firstObject];
                [mainTextVc startBtnHandler:nil];
            });
        }
    } else {
        // Fallback on earlier versions
    }
}

- (void)setup3DTouch:(UIApplication *)application{
    /**
     type 该item 唯一标识符
     localizedTitle ：标题
     localizedSubtitle：副标题
     icon：icon图标 可以使用系统类型 也可以使用自定义的图片
     userInfo：用户信息字典 自定义参数，完成具体功能需求
     */
    
    //    UIApplicationShortcutIcon *icon1 = [UIApplicationShortcutIcon iconWithTemplateImageName:@"标签.png"];
    
//    UIApplicationShortcutIcon * icon3 = [UIApplicationShortcutIcon iconWithTemplateImageName:@"反馈11"];
    UIApplicationShortcutIcon *cameraIcon = [UIApplicationShortcutIcon iconWithType:UIApplicationShortcutIconTypeAdd];
    UIApplicationShortcutItem *cameraItem = [[UIApplicationShortcutItem alloc] initWithType:@"typeOne" localizedTitle:@"我有一个新灵感" localizedSubtitle:@"" icon:cameraIcon userInfo:nil];
    application.shortcutItems = @[cameraItem];
    
}

-(void)updateFromiCloud{
    if(![[NSUserDefaults standardUserDefaults] boolForKey:@"firstText"]){
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"firstText"];
        //第一次启动
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1* NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [LZiCloud downloadFromiCloudWithBlock:^(id obj) {
                
                if (obj != nil) {
                    
                    NSData *data = (NSData *)obj;
                    
                    [data writeToFile:[LZSqliteTool LZCreateSqliteWithName:LZSqliteName] atomically:YES];
                    [SVProgressHUD showInfoWithStatus:@"同步成功"];
                } else {
                    
                    [SVProgressHUD showErrorWithStatus:@"同步出错"];
                }
            }];        });
    }
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [self setup3DTouch:application];
    [self jumpViewController:launchOptions];
    [self chuShiHuaBomb];
    [self verifyPassword];
    
//    dispatch_queue_t queue=dispatch_get_main_queue();
//    dispatch_async(queue, ^{
        [self updateFromiCloud];
//             });
    self.window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    LaunchViewController *Lvc = [[LaunchViewController alloc]init];
    UINavigationController*nav = [[UINavigationController alloc]initWithRootViewController:Lvc];
    self.window.rootViewController = nav;
    
    //Set APPID
    NSString *initString = [[NSString alloc] initWithFormat:@"appid=%@",XUNFEIAPPID_VALUE];
    
    //Configure and initialize iflytek services.(This interface must been invoked in application:didFinishLaunchingWithOptions:)
    [IFlySpeechUtility createUtility:initString];
    
    [self createSqlite];
    
    return YES;
}



- (void)createSqlite {
    
    [LZSqliteTool LZCreateSqliteWithName:LZSqliteName];
    [LZSqliteTool LZDefaultDataBase];
    [LZSqliteTool LZCreateDataTableWithName:LZSqliteDataTableName];
    [LZSqliteTool LZCreateGroupTableWithName:LZSqliteGroupTableName];
    [LZSqliteTool createPswTableWithName:LZSqliteDataPasswordKey];
    
    NSInteger groups = [LZSqliteTool LZSelectElementCountFromTable:LZSqliteGroupTableName];
    NSInteger count = [LZSqliteTool LZSelectElementCountFromTable:LZSqliteDataTableName];
    NSUserDefaults *us = [NSUserDefaults standardUserDefaults];
    BOOL isDataInit = [[us objectForKey:@"dataAlreadyInit"] boolValue];
    //    if (count <= 0 && groups <= 0 && !isDataInit) {
    //        [self creatData];
    //    }
    
    NSUserDefaults *df = [NSUserDefaults standardUserDefaults];
    BOOL isPswAlreadySaved = [[df objectForKey:@"pswAlreadySavedKey"] boolValue];
    
    if (!isPswAlreadySaved) {
        NSString *psw = [df objectForKey:@"redomSavedKey"];
        
        if (psw.length > 0) {
            
            [LZSqliteTool LZInsertToPswTable:LZSqliteDataPasswordKey passwordKey:LZSqliteDataPasswordKey passwordValue:psw];
        }
        
        [df setBool:YES forKey:@"pswAlreadySavedKey"];
    }
}


- (void)creatData {
    
    //    LZGroupModel *group = [[LZGroupModel alloc]init];
    //    group.groupName = @"未分组";
    //
    //    [LZSqliteTool LZInsertToGroupTable:LZSqliteGroupTableName model:group];
    //
    //    NSUserDefaults *us = [NSUserDefaults standardUserDefaults];
    //    [us setBool:YES forKey:@"dataAlreadyInit"];
    //    [us synchronize];
    //
    //    return;
    //    LZGroupModel *group1 = [[LZGroupModel alloc]init];
    //    group1.groupName = @"社交";
    //
    //    [LZSqliteTool LZInsertToGroupTable:LZSqliteGroupTableName model:group1];
    
    //    LZGroupModel *group2 = [[LZGroupModel alloc]init];
    //    group2.groupName = @"博客";
    
    //    [LZSqliteTool LZInsertToGroupTable:LZSqliteGroupTableName model:group2];
    
    LZDataModel *model = [[LZDataModel alloc]init];
    model.userName = @"";
    model.nickName = @"";
    model.password = @"";
    model.urlString = @"";
    model.groupName = @"";
    model.email = @"";
    model.dsc = @"";
    //    model.groupID = group2.identifier;
    model.titleString = @"";
    model.contentString = @"";
    model.colorString = @"";
    
    [LZSqliteTool LZInsertToTable:LZSqliteDataTableName model:model];
    
    LZDataModel *model1 = [[LZDataModel alloc]init];
    model1.userName = @"";
    model1.nickName = @"";
    model1.password = @"";
    //    model1.groupID = group1.identifier;
    model1.groupName = @"";
    model1.email = @"";
    model1.dsc = @"QQ号";
    model1.titleString = @"";
    model1.contentString = @"";
    model1.colorString = @"";
    [LZSqliteTool LZInsertToTable:LZSqliteDataTableName model:model1];
    
    LZDataModel *model2 = [[LZDataModel alloc]init];
    model2.userName = @"";
    model2.nickName = @"";
    model2.password = @"";
    
    model2.groupName = @"";
    model2.email = @"";
    //    model2.groupID = group.identifier;
    model2.titleString = @"";
    model2.contentString = @"";
    model2.colorString = @"";
    
    [LZSqliteTool LZInsertToTable:LZSqliteDataTableName model:model2];
    
    LZDataModel *model3 = [[LZDataModel alloc]init];
    model3.userName = @"";
    model3.nickName = @"";
    model3.password = @"";
    model3.urlString = @"";
    model3.groupName = @"";
    //    model3.groupID = group.identifier;
    model3.titleString = @"";
    model3.contentString = @"";
    model3.colorString = @"";
    [LZSqliteTool LZInsertToTable:LZSqliteDataTableName model:model3];
}





- (void)verifyPassword {
    
    if ([LZGestureTool isGestureEnable]) {
        
        [[LZGestureScreen shared] show];
        
        if ([[TouchIdUnlock sharedInstance] canVerifyTouchID]) {
            
            [[TouchIdUnlock sharedInstance] startVerifyTouchID:^{
                
                [[LZGestureScreen shared] dismiss];
            }];
        }
    }else if([[TouchIdUnlock sharedInstance] isTouchIdEnabledOrNotByUser]){
        [[TouchIDScreen shared] show];
        if ([[TouchIdUnlock sharedInstance] canVerifyTouchID]) {
            
            [[TouchIdUnlock sharedInstance] startVerifyTouchID:^{
                
                [[TouchIDScreen shared] dismiss];
                [BCShanNianKaPianManager maDaQingZhenDong];
            }];
        }
    }else{
        
    }
}


- (void)chuShiHuaBomb{
    
    [Bmob registerWithAppKey:@"075c9e426a01a48a81aa12305924e532"];
//    
//                //往GameScore表添加一条playerName为小明，分数为78的数据
//                BmobObject *gameScore = [BmobObject objectWithClassName:@"appKaiGuan"];
//                [gameScore setObject:@"1" forKey:@"ShanNian"];
//                [gameScore saveInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
//    
//                }];
    
    
    NSString *nowStatus = [[NSUserDefaults standardUserDefaults] objectForKey:@"KaiGuanShiFouDaKai"];
    
    if ([nowStatus isEqualToString:@"开"]) {
        
    }else{
        //查找GameScore表
        BmobQuery   *bquery = [BmobQuery queryWithClassName:@"appKaiGuan"];
        //查找GameScore表里面id为0c6db13c的数据
        [bquery getObjectInBackgroundWithId:@"4975313599" block:^(BmobObject *object,NSError *error){
            if (error){
                //进行错误处理
            }else{
                //表里有id为0c6db13c的数据
                if (object) {
                    //得到playerName和cheatMode
                    NSString *KaiGuanStatus = [object objectForKey:@"ShanNian"];
                    NSLog(@"%@=========",KaiGuanStatus);
                    [[NSUserDefaults standardUserDefaults] setObject:KaiGuanStatus forKey:@"KaiGuanShiFouDaKai"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                }
            }
        }];
    }
    
    
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    if ([[url absoluteString] hasPrefix:@"comchenxijiyisuipian://red"])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:[NSString stringWithFormat:@"你点击了%@按钮",[url host]] delegate:nil cancelButtonTitle:@"好的👌" otherButtonTitles:nil, nil];
        
        ShanNianMuLuViewController *mainTextVc = [[ShanNianMuLuViewController alloc] init];
        //                UINavigationController *rootVC = (UINavigationController *)[UIApplication sharedApplication].delegate.window.rootViewController;
        UINavigationController *navigationVC = (UINavigationController *)[UIApplication sharedApplication].delegate.window.rootViewController;
        NSMutableArray *navContollers=[NSMutableArray arrayWithArray:navigationVC.viewControllers];

        [navigationVC pushViewController:mainTextVc animated:YES];
//        [alert show];
    }
    return  YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [self verifyPassword];
    
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end

