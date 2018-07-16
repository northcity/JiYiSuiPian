//
//  IATConfig.m
//  MSCDemo_UI
//
//  Created by wangdan on 15-4-25.
//  Copyright (c) 2015年 iflytek. All rights reserved.
//

#define PUTONGHUA   @"mandarin"
#define YUEYU       @"cantonese"
#define ENGLISH     @"en_us"
#define CHINESE     @"zh_cn";
#define SICHUANESE  @"lmz";


#define BAIDU_SEARCH @"百度搜索";
#define BIYING_SEARCH @"必应搜索";
#define SOUGOU_SEARCH @"搜狗搜索";
#define WEIJIBAIKE_SEARCH @"谷歌搜索";


#import "IATConfig.h"

@implementation IATConfig

-(id)init {
    self  = [super init];
    if (self) {
        [self defaultSetting];
        return  self;
    }
    return nil;
}


+(IATConfig *)sharedInstance {
    static IATConfig  * instance = nil;
    static dispatch_once_t predict;
    dispatch_once(&predict, ^{
        instance = [[IATConfig alloc] init];
    });
    return instance;
}


-(void)defaultSetting {
    _speechTimeout = @"30000";
    _vadEos = @"3000";
    _vadBos = @"3000";
    _dot = @"1";
    _sampleRate = @"16000";
    _language = CHINESE;
    
    _sousuoyinqin = BAIDU_SEARCH;
    _zhuTiSheZhi = @"白色主题";
    
    _accent = PUTONGHUA;
    _haveView = NO;
    _accentNickName = [[NSArray alloc] initWithObjects:NSLocalizedString(@"K_LangCant", nil), NSLocalizedString(@"K_LangChin", nil), NSLocalizedString(@"K_LangEng", nil), NSLocalizedString(@"K_LangSzec", nil), nil];
    
    _isTranslate = NO;
}


+(NSString *)mandarin {
    return PUTONGHUA;
}
+(NSString *)cantonese {
    return YUEYU;
}
+(NSString *)chinese {
    return CHINESE;
}
+(NSString *)english {
    return ENGLISH;
}
+(NSString *)sichuanese {
    return SICHUANESE;
}

+(NSString *)lowSampleRate {
    return @"8000";
}

+(NSString *)highSampleRate {
    return @"16000";
}

+(NSString *)isDot {
    return @"1";
}

+(NSString *)noDot {
    return @"0";
}

@end

