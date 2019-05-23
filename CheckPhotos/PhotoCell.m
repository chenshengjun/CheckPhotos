//
//  PhotoCell.m
//  CheckPhotos
//
//  Created by Beta on 2019/1/18.
//  Copyright © 2019年 Beta. All rights reserved.
//

#import "PhotoCell.h"

@implementation PhotoCell
- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = YES;
        
        self.imagePic = [[UIImageView alloc] initWithFrame:self.contentView.bounds];
        self.imagePic.contentMode = UIViewContentModeScaleAspectFill;
        [self.contentView addSubview:self.imagePic];
    }
    return self;
}

- (void)setImg:(UIImage *)img {
    _img = img;
    self.imagePic.image = _img;
}
@end
