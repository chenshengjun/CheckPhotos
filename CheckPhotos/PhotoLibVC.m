//
//  PhotoLib.m
//  CheckPhotos
//
//  Created by Beta on 2019/1/18.
//  Copyright © 2019年 Beta. All rights reserved.
//https://github.com/chenshengjun/CheckPhotos.git

#import "PhotoLibVC.h"
#import "PhotoCell.h"
#import <Photos/Photos.h>

#define kCCWidth  [[UIScreen mainScreen] bounds].size.width
#define kCCHeight [[UIScreen mainScreen] bounds].size.height
#define kMinimumLineSpacing 2
#define kMinimumInteritemSpacing 2
#define kColumnCount  3
#define kItemSize CGSizeMake((kCCWidth - kMinimumLineSpacing*2)/kColumnCount, (kCCWidth - kMinimumLineSpacing*2)/kColumnCount)
@interface PhotoLibVC ()<UICollectionViewDelegate,UICollectionViewDataSource,UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    UICollectionView *collView;
    
}

@end

@implementation PhotoLibVC
static NSString *cellID = @"PhotoThumbnailCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];

    self.imgArr = [NSMutableArray new];
    [self getThumbnailImages];
    [self createCollectionView];
}

- (void)createCollectionView {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    // 设置最小行间距
    layout.minimumLineSpacing = kMinimumLineSpacing;
    // 设置垂直间距
    layout.minimumInteritemSpacing = kMinimumInteritemSpacing;
    
    collView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, kCCWidth, kCCHeight-64) collectionViewLayout:layout];
    collView.backgroundColor = [UIColor cyanColor];
    [collView registerClass:[PhotoCell class] forCellWithReuseIdentifier:cellID];
    collView.delegate = self;
    collView.dataSource = self;
    //collView.pagingEnabled = YES;
    [self.view addSubview:collView];
    
}

#pragma mark ---- UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _assets.count;
    //    return self.imgArr.count;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
    if (!cell) {
        cell = [[PhotoCell alloc]init];
    }
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    // 同步获得图片, 只会返回1张图片
    options.synchronous = YES;
    PHAsset *asset = _assets[indexPath.row];

    // 是否要原图
    BOOL original = NO;
//    CGSize size = original ? CGSizeMake(asset.pixelWidth, asset.pixelHeight) : CGSizeZero;
    CGSize size = original ? CGSizeMake(asset.pixelWidth, asset.pixelHeight) : kItemSize;

//    __block UIImage *img = [UIImage new];
    // 从asset中获得图片
    [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:size contentMode:PHImageContentModeDefault options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        NSLog(@"%@", result);
        cell.img = result;
    }];
//    cell.img = _imgArr[indexPath.row];
    cell.backgroundColor = [UIColor purpleColor];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    // 同步获得图片, 只会返回1张图片
    options.synchronous = YES;
    PHAsset *asset = _assets[indexPath.row];
    CGSize size =  CGSizeMake(asset.pixelWidth, asset.pixelHeight);//原图
    [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:size contentMode:PHImageContentModeDefault options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        NSLog(@"%@", result);
        [self showImg:result];
    }];
}

- (void)showImg:(UIImage *)img {
    UIViewController *vc = [UIViewController new];
    vc.view.backgroundColor = [UIColor blackColor];
    [self.navigationController pushViewController:vc animated:YES];

    
    UIImageView *imgV = [[UIImageView alloc]initWithFrame:CGRectMake(vc.view.center.x, vc.view.center.y, img.size.width, img.size.height)];
    imgV.center = vc.view.center;
    
    imgV.image = img;
    [vc.view addSubview:imgV];
}

#pragma mark ---- UICollectionViewDelegateFlowLayout

//配置每个item的size
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return kItemSize;
}

//配置item的边距（注意是是item与最外层的UICollectionView的边距，不是item之间的边距）
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 0, kMinimumLineSpacing, 0);
}

- (void)getThumbnailImages
{
    // 获得所有的自定义相簿
    PHFetchResult<PHAssetCollection *> *assetCollections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    // 遍历所有的自定义相簿
    for (PHAssetCollection *assetCollection in assetCollections) {
        [self enumerateAssetsInAssetCollection:assetCollection original:NO];
    }
    
    // 获得相机胶卷
    PHAssetCollection *cameraRoll = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil].lastObject;
    [self enumerateAssetsInAssetCollection:cameraRoll original:NO];
}

/**
 *  遍历相簿中的所有图片
 *
 *  @param assetCollection 相簿
 *  @param original        是否要原图
 */
- (void)enumerateAssetsInAssetCollection:(PHAssetCollection *)assetCollection original:(BOOL)original
{
    NSLog(@"相簿名:%@", assetCollection.localizedTitle);
    
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    // 同步获得图片, 只会返回1张图片
    options.synchronous = YES;
    original = YES;
    _assets = [PHAsset fetchAssetsInAssetCollection:assetCollection options:nil];
    
  /**
   
   return;
   // 获得某个相簿中的所有PHAsset对象
   PHFetchResult<PHAsset *> *assets = [PHAsset fetchAssetsInAssetCollection:assetCollection options:nil];
   for (PHAsset *asset in assets) {
   // 是否要原图
   CGSize size = original ? CGSizeMake(asset.pixelWidth, asset.pixelHeight) : CGSizeZero;
   
   __block UIImage *img = [UIImage new];
   // 从asset中获得图片
   [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:size contentMode:PHImageContentModeDefault options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
   NSLog(@"%@", result);
   img = result;
   [self.imgArr addObject:result];
   }];
   }
   
   //    if (self.imgArr.count > 0) {
   //        PhotoLibVC *vc = [PhotoLibVC new];
   //        vc.imgArr = self.imgArr;
   //        [self.navigationController pushViewController:vc animated:YES];
   //    }
   */
}


@end
