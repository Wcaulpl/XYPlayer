//
//  VideoViewCell.m
//  XYPlayer
//
//  Created by Wcaulpl on 2018/3/23.
//  Copyright © 2018年 Wcaulpl. All rights reserved.
//

#import "VideoViewCell.h"

@interface VideoViewCell ()

@property (nonatomic, weak) UILabel *titleLabel;
@property (nonatomic, weak) UILabel *videoImgView;
@property (nonatomic, weak) UILabel *detailLabel;

@end

@implementation VideoViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
    }
    return self;
}



- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
