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

#import "TouchIDScreen.h"
#import "BCShanNianKaPianManager.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [self verifyPassword];
    self.window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    ShanNianViewController *Lvc = [[ShanNianViewController alloc]init];
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

