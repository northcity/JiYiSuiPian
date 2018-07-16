//
//  LaunchViewController.m
//  shijianjiaonang
//
//  Created by chenxi on 2018/3/23.
//  Copyright © 2018年 chenxi. All rights reserved.
//

#import "LaunchViewController.h"

#import "ViewController.h"
#import "ShanNianViewController.h"
@interface LaunchViewController ()


@property (strong, nonatomic) UILabel *titleLabel;

@property (strong, nonatomic) UILabel *sologinLabel;

@property (strong, nonatomic) UIView *redView;

@property (strong, nonatomic) UIView *yellowView;

@property (strong, nonatomic) UIImageView *iconImageView;

@property (copy , nonatomic)NSString *contentStr;


@end

@implementation LaunchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
//    [self createImageView];
    self.navigationController.navigationBar.hidden = YES;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2* NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [UIView animateWithDuration:0.33 animations:^{
            self.iconImageView.alpha = 0;
            self.redView.alpha = 0;
            self.titleLabel.alpha = 0;
            self.sologinLabel.alpha = 0;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.5 animations:^{
                self.view.backgroundColor = [UIColor whiteColor];
            } completion:^(BOOL finished) {
                ShanNianViewController *lvc = [[ShanNianViewController alloc]init];
                [self.navigationController pushViewController:lvc animated:NO];
            }];
         
        }];
     
   
    });
    [self startAnimation];
}
- (void)startAnimation{
    
   
    self.redView = [[UIView alloc]initWithFrame:CGRectMake(ScreenWidth/2 - 3.5f, ScreenHeight - kAUTOHEIGHT(100), 7, 7)];
    self.redView.backgroundColor = [UIColor redColor];
    
    self.redView.layer.cornerRadius = 3.5f;
    self.redView.layer.masksToBounds = YES;
    [self.view addSubview:self.redView];
    
    self.titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(ScreenWidth/2 - kAUTOWIDTH(100), CGRectGetMaxY(self.redView.frame) + kAUTOHEIGHT(0), kAUTOWIDTH(200), kAUTOHEIGHT(30))];
    self.titleLabel.textColor =  PNCColorWithHex(0xdcdcdc);
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.font = [UIFont fontWithName:@"HeiTi SC" size:8];
    self.titleLabel.numberOfLines = 0;
    [self.view addSubview:self.titleLabel];
    
    
    self.sologinLabel = [[UILabel alloc]initWithFrame:CGRectMake(kAUTOWIDTH(20), CGRectGetMaxY(self.titleLabel.frame) + kAUTOHEIGHT(5),ScreenWidth - kAUTOWIDTH(40), kAUTOHEIGHT(20))];
    self.sologinLabel.textColor = PNCColor(132, 133, 135);
    self.sologinLabel.textAlignment = NSTextAlignmentCenter;
    self.sologinLabel.text = @"Inspiration comes from Smartisan Idea Pills";
    self.sologinLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:11];
    self.sologinLabel.font = [UIFont boldSystemFontOfSize:11];
    self.sologinLabel.numberOfLines = 0;
    [self.view addSubview:self.sologinLabel];
    
 
    
    [self startHeartAnimation:self.redView.layer repeatCount:MAXFLOAT];

    self.iconImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 100, 100)];
    self.iconImageView.image = [UIImage imageNamed:@"icon.png"];
    self.iconImageView.center = self.view.center;
    [self.view addSubview:self.iconImageView];
    self.view.backgroundColor = [UIColor blackColor];
    
    self.yellowView = [[UIView alloc]initWithFrame:CGRectMake(ScreenWidth/2 - 5, CGRectGetMaxY(self.iconImageView.frame) + 5, 10, 10)];
    self.yellowView.backgroundColor = [UIColor yellowColor];
    
    [self startHeartAnimation:self.yellowView.layer repeatCount:MAXFLOAT];

    self.yellowView.layer.cornerRadius = 5;
    self.yellowView.layer.masksToBounds = YES;
//    [self.view addSubview:self.yellowView];
    
    
    NSThread *thread = [[NSThread alloc]initWithTarget:self selector:@selector(animationLabel) object:nil];
    [thread start];
    self.contentStr = @"HELLO WORLD";

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.titleLabel.layer addAnimation:[self opacityForeverAnimation:0.5] forKey:nil];
    });
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


- (CABasicAnimation *)opacityForeverAnimation:(float)time
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];//必须写opacity才行。
    animation.fromValue = [NSNumber numberWithFloat:1.0f];
    animation.toValue = [NSNumber numberWithFloat:0.0f];//这是透明度。
    animation.autoreverses = YES;
    animation.duration = time;
    animation.repeatCount = MAXFLOAT;
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    animation.timingFunction=[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];///没有的话是均匀的动画。
    return animation;
}

- (void)animationLabel
{
    for (NSInteger i = 0; i < self.contentStr.length; i++)
    {
        [self performSelectorOnMainThread:@selector(refreshUIWithContentStr:) withObject:[self.contentStr substringWithRange:NSMakeRange(0, i+1)] waitUntilDone:YES];
        [NSThread sleepForTimeInterval:0.15];
    }
}


- (void)refreshUIWithContentStr:(NSString *)contentStr
{
    self.titleLabel.text = contentStr;
}

//生成一张毛玻璃图片
- (UIImage*)blur:(UIImage*)theImage
{
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *inputImage = [CIImage imageWithCGImage:theImage.CGImage];
    
    CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur"];
    [filter setValue:inputImage forKey:kCIInputImageKey];
    [filter setValue:[NSNumber numberWithFloat:15.0f] forKey:@"inputRadius"];
    CIImage *result = [filter valueForKey:kCIOutputImageKey];
    
    CGImageRef cgImage = [context createCGImage:result fromRect:[inputImage extent]];
    
    UIImage *returnImage = [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);
    return returnImage;
}

- (void)createImageView{
    

    
    UIImageView *iconImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    [self.view addSubview:iconImage];
    iconImage.image = [UIImage imageNamed:@"smart"];
    
    //方法二：Core Image
    UIImageView *blurImageView = [[UIImageView alloc]initWithFrame:iconImage.bounds];
    blurImageView.image = [self blur:[UIImage imageNamed:@"smart"]];
    [iconImage addSubview:blurImageView];
    
//    iconImage.center = self.view.center;
//    iconImage.image = [UIImage imageNamed:@""];
//    iconImage.layer.cornerRadius = kAUTOHEIGHT(8);
//    //        iconImage.layer.borderWidth = 0.5f;
//    //        iconImage.layer.borderColor = [UIColor grayColor].CGColor;
//    iconImage.layer.masksToBounds = YES;
//    CALayer *subLayer=[CALayer layer];
//    CGRect fixframe=iconImage.layer.frame;
//    subLayer.frame = fixframe;
//    subLayer.cornerRadius = kAUTOHEIGHT(8);
//    subLayer.backgroundColor=[[UIColor grayColor] colorWithAlphaComponent:0.5].CGColor;
//    subLayer.masksToBounds=NO;
//    subLayer.shadowColor=[UIColor grayColor].CGColor;
//    subLayer.shadowOffset=CGSizeMake(0,5);
//    subLayer.shadowOpacity=0.5f;
//    subLayer.shadowRadius= 4;
//    [self.view.layer insertSublayer:subLayer below:iconImage.layer];
//
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1* NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [UIView animateWithDuration:2 animations:^{
////            iconImage.alpha = 0;
////            subLayer.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0].CGColor;
//        }];
//    });
//
    UILabel * label = [Factory createLabelWithTitle:@"Create BY NorthCity" frame:CGRectMake(30, ScreenHeight - kAUTOHEIGHT(74), ScreenWidth - 60, 44)];
    [self.view addSubview:label];
    label.textColor = PNCColorWithHex(0xdcdcdc);
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont fontWithName:@"Heiti SC" size:10.f];

//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1* NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [UIView animateWithDuration:1 animations:^{
//            label.textColor = [UIColor whiteColor];
//            self.view.backgroundColor = [UIColor blackColor];
//        }];
//    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2* NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:1 animations:^{
            label.textColor = [UIColor clearColor];
        }];
    });
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
