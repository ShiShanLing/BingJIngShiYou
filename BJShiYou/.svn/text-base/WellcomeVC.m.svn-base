//
//  WellcomeVC.m
//  BJShiYou
//
//  Created by vstyle on 16/3/14.
//  Copyright (c) 2016年 com.vstyle. All rights reserved.
//

#import "WellcomeVC.h"
#import "Header.h"

@interface WellcomeVC ()<UIScrollViewDelegate>

@end

@implementation WellcomeVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGSize size = [UIScreen mainScreen].bounds.size;
    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.frame = CGRectMake(0, 0, size.width, size.height);
    self.scrollView.contentSize = CGSizeMake(size.width *3,size.height);
    self.scrollView.delegate = self;
    self.scrollView.pagingEnabled = YES;
    [self.view addSubview:self.scrollView];
    
    self.pageControl = [[UIPageControl alloc] init];
    self.pageControl.frame = CGRectMake((size.width - 0.0f)/2, size.height - 50, 55, 44);
    CGRect pageControlSize = self.pageControl.frame;
    DLog(@"%@",NSStringFromCGRect(pageControlSize));
    pageControlSize.origin.x = (size.width - 55)/2;
    DLog(@"%@",NSStringFromCGRect(pageControlSize));
    self.pageControl.frame = pageControlSize;
    self.pageControl.numberOfPages = 3;
    [self.view addSubview:self.pageControl];
    DLog(@"%@",NSStringFromCGRect(self.pageControl.frame));
    
    for (int i = 0; i < 3; i++) {
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.frame = CGRectMake(size.width *i, 0, size.width, size.height);
        imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"Image-%d",i+1]];
        [self.scrollView addSubview:imageView];
    }
    
    [self.enterButton setBackgroundImage:[[UIImage imageNamed:@"VSButtonBlueBg"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)] forState:UIControlStateNormal];
    [self.enterButton setBackgroundImage:[[UIImage imageNamed:@"VSButtonBlueBgHL"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)] forState:UIControlStateHighlighted];
    self.enterButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.enterButton setTitle:@"进入应用" forState:UIControlStateNormal];
    self.enterButton.titleLabel.font = [UIFont systemFontOfSize:22.0f];
    self.enterButton.layer.masksToBounds = YES;
    self.enterButton.layer.cornerRadius = 6.0;
    [self.enterButton setBackgroundColor:[UIColor colorWithRed:217/255.0 green:2/255.0 blue:4/255.0 alpha:1.0]];
    [self.enterButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.enterButton addTarget:self action:@selector(enterButtonPress:) forControlEvents:UIControlEventTouchUpInside];
    self.enterButton.frame = CGRectMake(size.width *2 + (size.width - 200.0f)/2, size.height - 150, 200, 44);
    [self.scrollView addSubview:self.enterButton];
    
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width*3, self.scrollView.frame.size.height);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)enterButtonPress:(id)sender {
    [[NSUserDefaults standardUserDefaults] setInteger:WELLCOME_VERSION forKey:KEY_WELLCOME_VERSION];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    NSInteger x = scrollView.contentOffset.x/scrollView.frame.size.width;
    self.pageControl.currentPage = x;
}

@end
