//
//  DataManager.h
//  MusicPlayer
//
//  Created by 大米 on 15/11/4.
//  Copyright © 2015年 rice. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MusicModel.h"

typedef void(^UpdataUI)();

@interface DataManager : NSObject

@property (nonatomic,copy) UpdataUI myUpdataUI;
@property (nonatomic,strong) NSArray * allMusic;

/**
 *  单例方法
 *
 *  @return 单例
 */
+ (DataManager *)sharedManager;

-(MusicModel *)musicModelWithIndex:(NSInteger)index;
@end
