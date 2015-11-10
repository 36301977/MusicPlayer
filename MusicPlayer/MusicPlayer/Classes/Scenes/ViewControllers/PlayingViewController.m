
//
//  PlayingViewController.m
//  MusicPlayer
//
//  Created by 大米 on 15/11/5.
//  Copyright © 2015年 rice. All rights reserved.
//

#import "PlayingViewController.h"
#import "PlayerManager.h"
#import "DataManager.h"
#import "MusicModel.h"
#import "LyricManager.h"
#import "LyricModel.h"

@interface PlayingViewController ()<PlayerManagerDelegate,UITableViewDataSource>
/**
 *  记录下当前音乐播放的索引
 */
@property (nonatomic,assign)NSInteger currentIndex;

/**
 *  记录当前正在播放的音乐
 */
@property (nonatomic,strong)MusicModel * currentModel;

#pragma mark 控件
@property (strong, nonatomic) IBOutlet UILabel *lab4SongName;
@property (strong, nonatomic) IBOutlet UILabel *lab4SingerName;
@property (strong, nonatomic) IBOutlet UIImageView *img4Pic;
@property (strong, nonatomic) IBOutlet UILabel *lab4PlayedTime;
@property (strong, nonatomic) IBOutlet UILabel *lab4LastTime;
@property (strong, nonatomic) IBOutlet UISlider *slider4Time;
@property (strong, nonatomic) IBOutlet UISlider *slider4Volume;
@property (strong, nonatomic) IBOutlet UIButton *btn4PlayOrPause;
@property (strong, nonatomic) IBOutlet UITableView *tabelView4Lyric;

#pragma mark 控件事件
- (IBAction)action4Prev:(id)sender;
- (IBAction)action4PlayOrPause:(UIButton *)sender;
- (IBAction)action4Next:(id)sender;
- (IBAction)action4ChangeTime:(id)sender;
- (IBAction)action4ChangeVolume:(id)sender;


@end

static PlayingViewController * playingVC = nil;
static NSString * cellIdentifier = @"cell";
@implementation PlayingViewController

+(instancetype)sharedPlayingPVC{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
//        拿到main sb
        UIStoryboard * sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//        获取storyboard入口的controller（instantiateInitialViewController）
//        在main sb 拿到我们要用的试图控制器
        playingVC = [sb instantiateViewControllerWithIdentifier:@"playingVC"];
        
        
    });
    return playingVC;
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillDisappear:animated];
//    如果要播放的音乐和当前播放的音乐一样，就什么也不干了
    if (_index == _currentIndex) {
        return;
    }
//    如果不等于 
    _currentIndex = _index;
    [self startPlay];
}

// 开始播放
- (void)startPlay{
    [[PlayerManager sharedManager]playWithUrlString:self.currentModel.mp3Url];
    [self buildUI];
}

/**
 *  构造UI
 */
-(void)buildUI{
    self.lab4SingerName.text = self.currentModel.singer;
    self.lab4SongName.text = self.currentModel.name;
    [self.img4Pic sd_setImageWithURL:[NSURL URLWithString:self.currentModel.picUrl]];
//    更改btn
    [self.btn4PlayOrPause setTitle:@"暂停" forState:(UIControlStateNormal)];
    
//    改变进度条的最大值
    self.slider4Time.maximumValue = [self.currentModel.duration integerValue] / 1000;
    
//    更改旋转的角度
    self.img4Pic.transform = CGAffineTransformMakeRotation(0);
//    解析歌词
    [[LyricManager sharedManager]loadLyricWith:self.currentModel.lyric];
    
    [self.tabelView4Lyric reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _currentIndex = -1;
    
//    设置自己为播放器的代理，帮播放器干一些事情
    [PlayerManager sharedManager].delegate = self;
    
//    加圆角
    _img4Pic.layer.masksToBounds = YES;
    _img4Pic.layer.cornerRadius = 120;
    // Do any additional setup after loading the view.
    
//    注册cell
    [self.tabelView4Lyric registerClass:[UITableViewCell class] forCellReuseIdentifier:cellIdentifier];
    
    self.slider4Volume.value = [[PlayerManager sharedManager] volume];
}
- (IBAction)action4Back:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
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

//上一首
- (IBAction)action4Prev:(id)sender {
    _currentIndex --;
//    判断上一首是不是第一首
    if (_currentIndex == -1) {
//        如果是第一首就播放最后一首
        _currentIndex = [DataManager sharedManager].allMusic.count - 1;
    }
    [self  startPlay];
}

// 暂停或者播放事件
- (IBAction)action4PlayOrPause:(UIButton *)sender {
//    判断是否正在播放
    if ([PlayerManager sharedManager].isPlaying) {
//        如果正在播放，就让播放器暂停，同时改变button的text
        [[PlayerManager sharedManager] pause];
        [sender setTitle:@"播放" forState:(UIControlStateNormal)];
    }else{
//        暂停状态：开始播放，并改变btn 为 暂停
        [[PlayerManager sharedManager] play];
        [sender setTitle:@"暂停" forState:(UIControlStateNormal)];
    }
}


// 下一首
- (IBAction)action4Next:(id)sender {
////    在播放下一首时先暂停，销毁timer
//    [[PlayerManager sharedManager]pause];
    _currentIndex  ++;
//    判断是不是最后一首
    if (_currentIndex == [DataManager sharedManager].allMusic.count) {
//        如果是最后一首就播放第一首
        _currentIndex = 0;
    }
    
    [self startPlay];
}

//改变播放进度
- (IBAction)action4ChangeTime:(id)sender {
    UISlider * slider = sender;
//    调用接口
    [[PlayerManager sharedManager]seekToTime:slider.value];
}

- (IBAction)action4ChangeVolume:(UISlider *)sender {
    [[PlayerManager sharedManager] changeToVolume:sender.value];
}


#pragma mark -PlayerManagerDelegate
-(void)playerDidPlayEnd{
    [self action4Next:nil];
}

//播放器每0.1秒会让代理（也就是这个页面）执行一下这个事件
-(void)playerPlayingWithTime:(NSTimeInterval)time{
    if ([[self.btn4PlayOrPause titleForState:(UIControlStateNormal)] isEqualToString:@"播放"]) {
        [self.btn4PlayOrPause  setTitle:@"暂停" forState:(UIControlStateNormal)];
    }
//    NSLog(@"%f",time);
    self.slider4Time.value = time;
    self.lab4PlayedTime.text = [self stringWithTime:time];
//    剩余时间
    NSTimeInterval time2 = [self.currentModel.duration integerValue] / 1000 - time;
    self.lab4LastTime.text = [self stringWithTime:time2];
    
//    每0.1秒旋转1度
    self.img4Pic.transform = CGAffineTransformRotate(self.img4Pic.transform,M_PI / 180);
    
//    根据当前播放时间获取到应该播放那句歌词
    NSInteger index = [[LyricManager sharedManager] indexWith:time];
    
    NSIndexPath * path = [NSIndexPath indexPathForRow:index inSection:0];
//    让tableView 选中我们找到的歌词
    [self.tabelView4Lyric selectRowAtIndexPath:path animated:YES scrollPosition:(UITableViewScrollPositionMiddle)];
}

// 根据时间获取到字符串
-(NSString *)stringWithTime:(NSTimeInterval)time{
    NSInteger minutes = time / 60;
    NSInteger seconde = (int)time % 60;
    return [NSString stringWithFormat:@"%ld:%ld",minutes,seconde];
}

#pragma mark - getter
//确保当前播放的音乐是最新的
-(MusicModel *)currentModel{
//    取到要播放的model
    MusicModel * model = [[DataManager sharedManager]musicModelWithIndex:self.currentIndex];
    return model;
}

#pragma mark -UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [LyricManager sharedManager].allLyric.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
//    取到对应的cell
    LyricModel * lyric = [LyricManager sharedManager].allLyric[indexPath.row];
//    设置歌词
    cell.textLabel.text = lyric.lyricContext;
//    设置居中
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    return cell;
}
@end
