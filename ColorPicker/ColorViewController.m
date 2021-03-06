//
//  ColorViewController.m
//  ColorPicker
//
//  Created by Mango on 14-2-5.
//  Copyright (c) 2014年 Mango. All rights reserved.
//

#import "ColorViewController.h"
#import <QuartzCore/QuartzCore.h>

//view
#import "UIView+Tools.h"
#import "ColorImageView.h"
#import "ColorScrollView.h"
#import "ColorPickerImageView.h"

@interface ColorViewController ()<UIScrollViewDelegate>

@property (strong, nonatomic)  ColorScrollView *colorScrollView;
@property (nonatomic,strong) UIImage *image;

@property (weak, nonatomic) IBOutlet UILabel *red;
@property (weak, nonatomic) IBOutlet UILabel *green;
@property (weak, nonatomic) IBOutlet UILabel *blue;
@property (weak, nonatomic) IBOutlet UILabel *hexRGB;
@property (weak, nonatomic) IBOutlet UIView *scrollViewSizeView;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;

@property (weak, nonatomic) IBOutlet UIView *bottomBar;

@end

@implementation ColorViewController

- (void)setChooseImage:(UIImage *)image
{
    //不能在这里直接赋值照片给ColorScrollView 因为ScrollView还为Null
    self.image = image;
}

//设置状态栏
- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    DLog(@"%@",self.bottomBar);
    
    //setup view
    [self setupBackgroud];
    [self setupScrollView];
    
    //init data
    self.red.text = self.colorScrollView.imageView.red;
    self.green.text = self.colorScrollView.imageView.green;
    self.blue.text = self.colorScrollView.imageView.blue;
    self.hexRGB.text = self.colorScrollView.imageView.hexRGB;
    
    //注册到通知中心用于更新label
    NSString * updateLabel = @"updateLabelAndColorImage";
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateLabelAndColorImage) name:updateLabel object:nil];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    //update scrollView frame
    self.colorScrollView.frame = self.scrollViewSizeView.bounds;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -setup View

- (void)setupScrollView
{
    CGRect frame = CGRectMake(0, 0, self.scrollViewSizeView.frame.size.width, self.scrollViewSizeView.frame.size.height);
    _colorScrollView = [[ColorScrollView alloc]initWithFrame:frame andUIImage:self.image];
    self.colorScrollView.delegate = self;
    [self.scrollViewSizeView addSubview:self.colorScrollView];
}

- (void)setupBackgroud
{
    //设置背景颜色
    self.view.backgroundColor = [UIColor colorWithRed:239.0/255 green:239.0/255 blue:237.0/255 alpha:1.0];
}

#pragma mark -Action
- (IBAction)saveColor:(UIButton *)sender
{
    self.saveButton.selected = YES;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
        NSArray * colorArray = [userDefaults arrayForKey:@"colorArray"];
        
        if (colorArray == nil)
        {
            NSArray * newColorArray = @[self.hexRGB.text];
            [userDefaults setObject:newColorArray forKey:@"colorArray"];
        }
        else
        {
            NSMutableArray *newColorArray = [colorArray mutableCopy];
            [newColorArray addObject:self.hexRGB.text];
            [userDefaults setObject:newColorArray forKey:@"colorArray"];
        }
        [userDefaults synchronize];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.saveButton.selected = NO;
        });
        
    });
}

#pragma mark -scrollView delegate

-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.colorScrollView.imageView;
}


#pragma - notification center
-(void)updateLabelAndColorImage
{
    self.red.text = self.colorScrollView.imageView.red;
    self.green.text = self.colorScrollView.imageView.green;
    self.blue.text = self.colorScrollView.imageView.blue;
    self.hexRGB.text = self.colorScrollView.imageView.hexRGB;
    self.saveButton.backgroundColor = self.colorScrollView.imageView.selectedColor;
}


@end
