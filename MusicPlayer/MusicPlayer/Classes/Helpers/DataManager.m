//
//  DataManager.m
//  MusicPlayer
//
//  Created by 大米 on 15/11/4.
//  Copyright © 2015年 rice. All rights reserved.
//

#import "DataManager.h"
#import "MusicModel.h"

@interface DataManager()

@property (nonatomic,strong)NSMutableArray * musicArray;

@end

@implementation DataManager

static DataManager * manager =nil;

+(DataManager *)sharedManager{
//    gcd 提供一种单例方法
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [DataManager new];
        [manager requestData];
    });
    return manager;
}

-(void)requestData{
//    在子线程中请求数据，防止假死
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
//        数据链接
        NSURL * url = [NSURL URLWithString:kMusicListURL];
//        请求数据
        NSArray * dataArray = [NSArray arrayWithContentsOfURL:url];
        
        for (int i = 0; i < dataArray.count; i ++) {
            MusicModel * model = [MusicModel new];
            [model setValuesForKeysWithDictionary:dataArray[i]];
            [self.musicArray addObject:model];
        }
//         返回主线程更新UI
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!self.myUpdataUI) {
                NSLog(@"block 没有代码");
            }
            else{
                self.myUpdataUI();//等价于 [self.tableView reloadData];
            }
        });
    });
}

#pragma mark - lazy load
-(NSMutableArray *)musicArray{
    if (!_musicArray) {
        _musicArray = [NSMutableArray array];
    }
    return _musicArray;
}

-(NSArray *)allMusic{
    return self.musicArray;
}

-(MusicModel *)musicModelWithIndex:(NSInteger)index{
    return _musicArray[index];
}

@end
