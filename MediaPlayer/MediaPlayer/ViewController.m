//
//  ViewController.m
//  MediaPlayer
//
//  Created by Erwin on 16/5/30.
//  Copyright © 2016年 C.Erwin. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (nonatomic, strong) MediaViewController *mediaController;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"播放列表";
    
//    NSString * path = [[NSBundle mainBundle] pathForResource:@"Movie" ofType:@"mp4"];
    
    NSURL *url = [NSURL URLWithString:@"http://v.jxvdy.com/sendfile/w5bgP3A8JgiQQo5l0hvoNGE2H16WbN09X-ONHPq3P3C1BISgf7C-qVs6_c8oaw3zKScO78I--b0BGFBRxlpw13sf2e54QA"];
//    NSURL *url = [NSURL fileURLWithPath:path];
    
    _mediaController = [[MediaViewController alloc]initWithUrl:url];
    
    _mediaController.title = @"Movie.mp4";
    
    UIButton *button  = [[UIButton alloc]initWithFrame:CGRectMake(100, 100, self.view.frame.size.width-200, 50)];
    [button setTitle:@"PLAY" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [button setBackgroundColor:[UIColor orangeColor]];
    [button addTarget:self action:@selector(buttonOnclick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
}


- (void) buttonOnclick:(id) sender{
    [self.navigationController pushViewController:_mediaController animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
