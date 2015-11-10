//
//  MusicCell.m
//  MusicPlayer
//
//  Created by 大米 on 15/11/4.
//  Copyright © 2015年 rice. All rights reserved.
//

#import "MusicCell.h"
@interface MusicCell()
@property (strong, nonatomic) IBOutlet UIImageView *img;
@property (strong, nonatomic) IBOutlet UILabel *name;
@property (strong, nonatomic) IBOutlet UILabel *singer;


@end
@implementation MusicCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setMusicModel:(MusicModel *)musicModel{
    _musicModel = musicModel;
    _name.text = musicModel.name;
    _singer.text = musicModel.singer;
    [_img sd_setImageWithURL:musicModel.picUrl placeholderImage:[UIImage imageNamed:@"1.jpg"]];
}

@end
