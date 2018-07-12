//
//  TodayViewController.m
//  Today
//
//  Created by chenxi on 2018/7/2.
//  Copyright © 2018 chenxi. All rights reserved.
//

#import "TodayViewController.h"
#import <NotificationCenter/NotificationCenter.h>

@interface TodayViewController () <NCWidgetProviding>

@end

@implementation TodayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *systemVersion = [UIDevice currentDevice].systemVersion;
//    if ([systemVersion doubleValue] > 10.3) {
//        if (@available(iOS 10.3, *)) {
//            self.extensionContext.widgetLargestAvailableDisplayMode = NCWidgetDisplayModeExpanded;
//            }
//        }
    

    
    self.preferredContentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, 100);

    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake([UIScreen mainScreen].bounds.size.width - 74, 10, 44, 44);
    
    button.backgroundColor = [UIColor clearColor];
    [button setImage:[UIImage imageNamed:@"待完成"] forState:UIControlStateNormal];
    [self.view addSubview:button];
    [button addTarget:self action:@selector(pushMatherApp) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMinX(button.frame), CGRectGetMaxY(button.frame) + 2, 44, 30)];
    label.text = @"待完成";
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont fontWithName:@"HeiTi SC" size:12];
    [self.view addSubview:label];
}

- (void)pushMatherApp{
    NSURL *url = [NSURL URLWithString:@"comchenxijiyisuipian://red"];
    
    [self.extensionContext openURL:url completionHandler:^(BOOL success) {
        
        NSLog(@"isSuccessed %d",success);
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//保存数据
- (void)saveDataByNSUserDefaults{
    NSUserDefaults *shared = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.xiaoshannian"];
    [shared setObject:@"asdfasdf" forKey:@"widget"];
    [shared synchronize];
}
//读取数据
- (NSString *)readDataFromNSUserDefaults{
    NSUserDefaults *shared = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.xiaoshannian"];
    NSString *value = [shared valueForKey:@"widget"];
    return value;
}


// 取消widget默认的inset，让应用靠左
- (UIEdgeInsets)widgetMarginInsetsForProposedMarginInsets:(UIEdgeInsets)defaultMarginInsets {
    return UIEdgeInsetsZero;
}

- (void)widgetActiveDisplayModeDidChange:(NCWidgetDisplayMode)activeDisplayMode withMaximumSize:(CGSize)maxSize {
    if(activeDisplayMode == NCWidgetDisplayModeCompact) {
        // 尺寸只设置高度即可，因为宽度是固定的，设置了也不会有效果
        self.preferredContentSize = CGSizeMake(0, 110);
    } else {
        self.preferredContentSize = CGSizeMake(0, 310);
    }
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    // Perform any setup necessary in order to update the view.
    
    // If an error is encountered, use NCUpdateResultFailed
    // If there's no update required, use NCUpdateResultNoData
    // If there's an update, use NCUpdateResultNewData

    completionHandler(NCUpdateResultNewData);
}

@end
