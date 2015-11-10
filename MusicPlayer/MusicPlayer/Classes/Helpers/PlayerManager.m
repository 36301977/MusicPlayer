//
//  PlayerManager.m
//  MusicPlayer
//
//  Created by 大米 on 15/11/5.
//  Copyright © 2015年 rice. All rights reserved.
//

#import "PlayerManager.h"
#import <AVFoundation/AVFoundation.h>

@interface PlayerManager ()

//播放器 -> 全局唯一，因为如果有两个avplayer的话，就会同时播放两个音乐
@property (nonatomic,retain)AVPlayer * player;
//计时器
@property (nonatomic,strong)NSTimer * timer;
@end

@implementation PlayerManager

// 单例方法
static PlayerManager * manager = nil;
+(instancetype)sharedManager{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [PlayerManager new];
    });
    return manager;
}

- (instancetype)init{
    self = [super init];
    if (self) {
//        添加通知中心，当self 发出 AVPlayerItemDidPlayToEndTimeNotification 时触发 playerDidPlayEnd 事件
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(playerDidPlayEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    }
    return self;
}

- (void)playerDidPlayEnd:(NSNotification *)not{
    if (self.delegate && [self.delegate respondsToSelector:@selector(playerDidPlayEnd)]) {
//        接收到item播放结束后，让代理去干一件事件，代理会怎么干，播放器不需要知道
        [self.delegate playerDidPlayEnd];
    }
}

#pragma mark 对外的
- (void)playWithUrlString:(NSString *)urlStr{
    //    如果是切换歌曲，要先把正在播放的观察者移除掉
    if (self.player.currentItem) {
        [self.player.currentItem removeObserver:self forKeyPath:@"status"];
    }
    //    创建一个Item
    AVPlayerItem * item = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:urlStr]];
    
    //    对item 添加观察者
    [item addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    
    //    替换当前正在播放的音乐
    [self.player replaceCurrentItemWithPlayerItem:item];
    
}

-(void)play{
    //    如果正在播放的话，就不播放了。直接返回就行了。
        if (_isPlaying) {
            return;
        }
//   先暂停，将NSTimer销毁，然后再播放，创建NSTimer
    [self pause];
//    开始播放
    [self.player play];
    // 开始播放标记为YES
    _isPlaying = YES;
    
//
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(playingWithSeconds) userInfo:nil repeats:YES];
}

-(void)playingWithSeconds{
    if (self.delegate && [self.delegate respondsToSelector:@selector(playerPlayingWithTime:)]) {
//        计算一下播放器现在播放的秒数
        NSTimeInterval time = self.player.currentTime.value / self.player.currentTime.timescale;
        [self.delegate playerPlayingWithTime:time];
    }
}

-(void)pause{
    [self.player pause];
    //    暂时播放时标记为NO
    _isPlaying = NO;
    
    [self.timer invalidate];
    self.timer = nil;
}

//time: 50秒
-(void)seekToTime:(NSTimeInterval)time{
//    先暂停
    [self pause];
    [self.player seekToTime:CMTimeMakeWithSeconds(time, self.player.currentTime.timescale) completionHandler:^(BOOL finished) {
        if (finished) {
//            拖拽成功后再播放
            [self play];
        }
    }];
}

-(void)changeToVolume:(CGFloat)volume{
    self.player.volume = volume;
}

-(CGFloat)volume{
    return self.player.volume;
}

#pragma mark - lazy load
-(AVPlayer *)player{
    if (!_player) {
        _player = [AVPlayer new];
    }
    return _player;
}

#pragma mark - 观察者的响应事件
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    NSLog(@"%@",keyPath);
    NSLog(@"%@",change);
    
    AVPlayerItemStatus  status = [change[@"new"]integerValue];
    
    switch (status) {
        case AVPlayerItemStatusFailed:
            NSLog(@"加载失败");
            break;
        case AVPlayerItemStatusUnknown:
            NSLog(@"资源不对");
            break;
        case AVPlayerItemStatusReadyToPlay:
            NSLog(@"准备好了，可以播放了");
            //            开始播放
            [self play];
            break;
        default:
            break;
    }
}

@end
