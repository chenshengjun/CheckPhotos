//
//  PhotoLib.h
//  CheckPhotos
//
//  Created by Beta on 2019/1/18.
//  Copyright © 2019年 Beta. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
NS_ASSUME_NONNULL_BEGIN

@interface PhotoLibVC : UIViewController
@property(nonatomic ,strong) NSMutableArray *imgArr;
@property(nonatomic ,strong) PHFetchResult<PHAsset *> *assets;
@end

NS_ASSUME_NONNULL_END
