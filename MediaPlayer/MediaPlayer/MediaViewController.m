//
//  MediaViewController.m
//  MediaPlayer
//
//  Created by Erwin on 16/5/30.
//  Copyright © 2016年 C.Erwin. All rights reserved.
//

#import "MediaViewController.h"
#import "PlayerView.h"

@interface MediaViewController ()

@property (nonatomic, copy)NSURL *movieUrl;

/**
 *  定时器
 */
@property (nonatomic, weak) NSTimer *timer;

/**
 *  视频播放视图
 */
@property (nonatomic, strong) PlayerView *playerView;


/**
 *  进度显示视图
 */
@property (nonatomic, retain) UIProgressView * progressView;

/**
 *  时长显示视图
 */
@property (nonatomic, strong) UILabel * timeLabel;


/**
 *  视频播放控制视图
 */
@property (nonatomic, strong) UIView *controlView;

/**
 *  总时长
 */
@property (nonatomic, strong) NSString *totalTime;

/**
 *   总时长
 */
@property (nonatomic, assign)CGFloat   toTime;

/**
 *  是否播放
 */
@property (nonatomic, assign) BOOL isPlay;

/**
 *  是否全屏
 */
@property (nonatomic, assign) BOOL ifFullScreen;

@property (nonatomic, strong) UIButton *fullScreen;

@property (nonatomic, strong) AVPlayerItem *avplayerItem;

/**
 *  音量控制条
 */
@property (nonatomic, strong)UISlider *volumeSlider;

@end

@implementation MediaViewController

- (instancetype)initWithUrl:(NSURL *)url
{
    self = [super init];
    if (self) {
        self.movieUrl = url;
    }
    return self;
}


- (void)createUserInteface{
    
    self.view.backgroundColor = [UIColor whiteColor];
    _playerView = [[PlayerView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.width*0.65)];
    _playerView.userInteractionEnabled = YES;
    UISwipeGestureRecognizer *swipeUP = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(upSwipeGestureAction:)];
    swipeUP.direction = UISwipeGestureRecognizerDirectionUp;
    
    UISwipeGestureRecognizer *swipeDown = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(upSwipeGestureAction:)];
    swipeDown.direction = UISwipeGestureRecognizerDirectionDown;
    
    [_playerView addGestureRecognizer:swipeUP];
    [_playerView addGestureRecognizer:swipeDown];
    
    [self.view addSubview:_playerView];
    
    
    _controlView = [[UIView alloc]initWithFrame:CGRectMake(0, _playerView.frame.size.height - 30, _playerView.frame.size.width, 30)];
    _controlView.backgroundColor = [UIColor grayColor];
    _controlView.userInteractionEnabled = YES;
    [_playerView addSubview:_controlView];
    
    [self resetControlItemFrame];
    
    
    UIButton *playBtn = [[UIButton alloc]initWithFrame:CGRectMake(5, 5, 30, 20)];
    [playBtn setImage:[UIImage imageNamed:@"Fav_Voice_Pause"] forState:UIControlStateNormal];
    [playBtn setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    playBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [playBtn addTarget:self action:@selector(playOrPausePlay:) forControlEvents:UIControlEventTouchUpInside];
    [_controlView addSubview:playBtn];
    
    _playerView.backgroundColor = [UIColor whiteColor];
    _progressView.tintColor = [UIColor orangeColor];
    
    [_controlView addSubview:_progressView];
    
    _timeLabel.textColor = [UIColor orangeColor];
    _timeLabel.textAlignment = NSTextAlignmentCenter;
    _timeLabel.font = [UIFont systemFontOfSize:10];
    _timeLabel.text = @"00:00/00:00";
    [_controlView addSubview:_timeLabel];
    
    
    [_fullScreen setTitle:@"全屏" forState:UIControlStateNormal];
    [_fullScreen setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    _fullScreen.titleLabel.font = [UIFont systemFontOfSize:14];
    [_fullScreen addTarget:self action:@selector(fullScreenOnclick:) forControlEvents:UIControlEventTouchUpInside];
    [_controlView addSubview:_fullScreen];
    
    
    _volumeSlider.tintColor = [UIColor orangeColor];
    _volumeSlider.hidden = YES;
    [self.view addSubview:_volumeSlider];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    [self createUserInteface];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.translucent = YES;
    [self initPlayer];
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:3.0f target:self selector:@selector(hidenNavigationBar:) userInfo:nil repeats:NO];
    [_timer setFireDate:[NSDate distantPast]];
}

- (void)initPlayer{
    _avplayerItem = [AVPlayerItem playerItemWithURL:_movieUrl];
    
    AVPlayer * avplayer = [AVPlayer playerWithPlayerItem:_avplayerItem];
    
    /**
     *  添加监听器
     */
    [_avplayerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    [_avplayerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    
    [_playerView setPlayer:avplayer];
    [_playerView.player play];
    _isPlay = YES;
    
    __block MediaViewController *this = self;
    
    [_playerView.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:NULL usingBlock:^(CMTime time) {
        CMTime cuTime = [this.playerView.player currentTime];
        CGFloat curTime = (CGFloat)cuTime.value/cuTime.timescale;
        NSString * currentTime = [this convertTime:curTime];
        
        this.progressView.progress = curTime/_toTime;
        this.timeLabel.text = [NSString stringWithFormat:@"%@/%@",currentTime,this.totalTime];
        
        NSLog(@"%@",this.timeLabel.text);
        
    }];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    
    if ([keyPath isEqualToString:@"status"]) {
        if (_avplayerItem.status == AVPlayerStatusReadyToPlay) {
            /**
             *  获取当前视频的总时长
             */
            CMTime time = _avplayerItem.asset.duration;
            
            _toTime = (CGFloat)time.value/time.timescale;
            
            _totalTime = [self convertTime:_toTime];
        }
    }else if ([keyPath isEqualToString:@"loadedTimeRanges"]){
        NSTimeInterval timeInterval = [self loadingVedio];
        NSLog(@"%@",@(timeInterval));
    }
    
}

/**
 *  把时间转成字符串
 *
 *  @param second 要转换的float类型的时间
 *
 *  @return 转换格式后的时间字符串
 */
- (NSString *)convertTime:(CGFloat)second{
    NSDate *d = [NSDate dateWithTimeIntervalSince1970:second];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    if (second/3600 >= 1) {
        [dateFormatter setDateFormat:@"HH:mm:ss"];
    } else {
        [dateFormatter setDateFormat:@"mm:ss"];
    }
    NSString *showtimeNew = [dateFormatter stringFromDate:d];
    return showtimeNew;
}


- (NSTimeInterval)loadingVedio{
    /**
     *  获取视频的缓冲区域
     */
    NSArray *loadTimesRanges = [[self.playerView.player currentItem] loadedTimeRanges];
    
    CMTimeRange timeRange = [loadTimesRanges.firstObject CMTimeRangeValue];
    
    float startSeconds = CMTimeGetSeconds(timeRange.start);
    float durationSeconds = CMTimeGetSeconds(timeRange.duration);
    
    NSTimeInterval result = startSeconds + durationSeconds;// 计算缓冲总进度
    
    return result;
}



//隐藏导航栏
- (void) hidenNavigationBar:(id) sender{
    self.navigationController.navigationBar.hidden = YES;
    _controlView.hidden = YES;
}

/**
 *  设置当前播放器的播放和暂停
 *
 *  @param sender
 */
- (void)playOrPausePlay:(id)sender{
    UIButton *button = (UIButton *)sender;
    if (_isPlay) {
        [button setImage:[UIImage imageNamed:@"Fav_Voice_Play"] forState:UIControlStateNormal];
        [_playerView.player pause];
        _isPlay = NO;
    }else{
        [button setImage:[UIImage imageNamed:@"Fav_Voice_Pause"] forState:UIControlStateNormal];
        [_playerView.player play];
        _isPlay = YES;
    }
}


/**
 *  用户手动全屏设置
 *
 *  @param sender
 */

- (void)fullScreenOnclick:(id)sender{
    
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        SEL selector = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        
        if (_ifFullScreen) {
            int val = UIInterfaceOrientationPortrait;
            _playerView.frame = CGRectMake(0, 0, self.view.frame.size.height, self.view.frame.size.height*0.65);
            _controlView.frame = CGRectMake(0, _playerView.frame.size.height-30, _playerView.frame.size.width, 30);
            [self resetControlItemFrame];
            [invocation setArgument:&val atIndex:2];
            [invocation invoke];
            _ifFullScreen = NO;
        }else{
            int val = UIInterfaceOrientationLandscapeRight;
            _playerView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width);
            _controlView.frame = CGRectMake(0, _playerView.frame.size.height-30, _playerView.frame.size.width, 30);
            [self resetControlItemFrame];
            [invocation setArgument:&val atIndex:2];
            [invocation invoke];
            _ifFullScreen = YES;
            
        }
    }
}

- (void)resetControlItemFrame{
    _progressView = [[UIProgressView alloc]initWithFrame:CGRectMake(40, 15, _controlView.frame.size.width-165, 20)];
    _timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(_controlView.frame.size.width - 120, 5, 75, 20)];
    _volumeSlider = [[UISlider alloc]initWithFrame:CGRectMake(100, self.view.frame.size.height-100, self.view.frame.size.width-200, 30)];
    _fullScreen = [[UIButton alloc]initWithFrame:CGRectMake(_controlView.frame.size.width - 35, 5, 30, 20)];
    
}


- (void)upSwipeGestureAction:(UISwipeGestureRecognizer *)swipe{
    switch (swipe.direction) {
        case UISwipeGestureRecognizerDirectionUp:
            _volumeSlider.value += 0.1;
            _playerView.player.volume = _volumeSlider.value * 30;
            _volumeSlider.hidden = NO;
            break;
        case UISwipeGestureRecognizerDirectionDown:
            _volumeSlider.value -= 0.1;
            _playerView.player.volume = _volumeSlider.value * 30;
            _volumeSlider.hidden = NO;
            break;
        default:
            break;
    }
    
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (self.navigationController.navigationBar.isHidden) {
        self.navigationController.navigationBar.hidden = NO;
        self.controlView.hidden = NO;
    }else{
        self.navigationController.navigationBar.hidden = YES;
        self.controlView.hidden = YES;
    }
}

- (void)viewWillDisappear:(BOOL)animated{
    [_avplayerItem removeObserver:self forKeyPath:@"status"];
    [_avplayerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
    _playerView.player.rate = 0;
    _playerView.player = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
