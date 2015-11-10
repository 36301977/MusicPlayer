//
//  PlayingViewController.h
//  MusicPlayer
//
//  Created by 大米 on 15/11/5.
//  Copyright © 2015年 rice. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlayingViewController : UIViewController

//要播放第几首歌曲
@property (nonatomic,assign) NSInteger index;

+ (instancetype)sharedPlayingPVC;

@end
