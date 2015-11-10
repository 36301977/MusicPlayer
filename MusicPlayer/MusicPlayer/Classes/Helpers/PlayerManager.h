//
//  PlayerManager.h
//  MusicPlayer
//
//  Created by 大米 on 15/11/5.
//  Copyright © 2015年 rice. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol  PlayerManagerDelegate<NSObject>

//当播放一首歌结束后，让代理去做的事情
- (void)playerDidPlayEnd;
// 播放中间一直在重复执行的一个方法
- (void)playerPlayingWithTime:(NSTimeInterval)time;
@end


@interface PlayerManager : NSObject

/**
 *  是否正在播放
 */
@property (nonatomic,assign) BOOL isPlaying;

/**
 *  设置代理
 */
@property (nonatomic,assign) id<PlayerManagerDelegate> delegate;;

+(instancetype)sharedManager;

// 给一个链接，
- (void)playWithUrlString:(NSString *)urlStr;

// 播放
- (void)play;

// 暂停
- (void)pause;

//改变进度
-(void)seekToTime:(NSTimeInterval)time;

//改变声音
-(void)changeToVolume:(CGFloat)volume;

//用来访问avplayer的音量
- (CGFloat)volume;

@end
