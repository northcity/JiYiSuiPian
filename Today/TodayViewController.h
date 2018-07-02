//
//  TodayViewController.h
//  Today
//
//  Created by chenxi on 2018/7/2.
//  Copyright © 2018 chenxi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TodayViewController : UIViewController

@property(nonatomic,assign)BOOL isPresnted;

@property(nonatomic,strong)UILabel *navTitleLabel;
@property(nonatomic,strong)UIView *titleView;
@property(nonatomic,strong)UIButton *backBtn;

@end
