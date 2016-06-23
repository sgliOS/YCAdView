//
//  PHAdView.m
//  shplayhall
//
//  Created by sgl on 15/12/4.
//  Copyright © 2015年 PinLu. All rights reserved.
//

#import "PLAdView.h"
#import "BannerModel.h"
#import "UIImageView+WebCache.h"

@interface PLAdView ()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>
{
    // 数据
    NSTimer             *_timer;
    NSArray             *_adlist;
    CGSize              _adSize;
    BOOL                _loaded;
    // UI
    UICollectionView    *_collectionView;
    UIPageControl       *_pageControl;
}

@end

@implementation PLAdView
@synthesize delegate;
/**
 *  初始化
 */
- (id)initWithAdSize:(CGSize)adSize
{
    self = [super init];
    if (self) {
        _adSize = adSize;
        [self initViewData];
        [self initViewUI];
    }
    return self;
}
- (void)initViewData
{
    _adlist = [[NSMutableArray alloc] init];
}
- (void)initViewUI
{
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.scrollDirection =  UICollectionViewScrollDirectionHorizontal;        // 设置水平滑动
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
    [_collectionView setBackgroundColor:[UIColor whiteColor]];
    [_collectionView setShowsHorizontalScrollIndicator:NO];
    [_collectionView setShowsVerticalScrollIndicator:NO];
    [_collectionView setBounces:NO];
    [_collectionView setPagingEnabled:YES];
    _collectionView.alwaysBounceHorizontal = YES;
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    // register class for cells
    [_collectionView registerClass:[PLAdViewCell class] forCellWithReuseIdentifier:[PLAdViewCell reuseIdentifier]];
    [self addSubview:_collectionView];
  
    _pageControl = [[UIPageControl alloc] init];
    _pageControl.backgroundColor = [UIColor clearColor];
    _pageControl.pageIndicatorTintColor = [UIColor colorWithHexString:@"#bebebe" alpha:0.5];
    _pageControl.currentPageIndicatorTintColor = [UIColor colorWithHexString:@"#ffffff" alpha:1.0];
    [_pageControl setHidesForSinglePage:YES];
    [self addSubview:_pageControl];
    
    [_pageControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self);
        make.right.equalTo(self.mas_right).with.offset(-K_UI_Margins_Padding_5);
    }];
    
    [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
}
#pragma mark - public fuc
/**
 *  刷新数据
 */
- (void)setAdList:(NSArray*)adList
{
    // 获取数据成功
    _loaded = NO;
    _adlist = adList;
    _pageControl.numberOfPages = [_adlist count];
    [_collectionView reloadData];
}
-(void)tiemerDetect:(id)sender
{
    if ([_adlist count]<=1) {
        WarningLog(@"");
    }
    else {
        int currentIndex = _collectionView.contentOffset.x/_adSize.width;
        currentIndex++;
        if (currentIndex>=0&&currentIndex<[_adlist count]+2) {
            [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:currentIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
            if (currentIndex==0) {
                // 显示最后一个
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                    [_pageControl setCurrentPage:[_adlist count]-1];
                    [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:[_adlist count] inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
                });
            }
            else if(currentIndex==[_adlist count]+1) {
                // 显示第一个
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                    [_pageControl setCurrentPage:0];
                    [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
                });
            }
            else {
                [_pageControl setCurrentPage:currentIndex-1];
            }
        }
        else {
            WarningLog(@"invalid index:%d",currentIndex);
        }
    }
    
}
#pragma mark - UICollectionViewDataSource
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if ([_adlist count]<=1) {
        return [_adlist count];
    }
    else {
        return [_adlist count]+2;
    }
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsZero;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return _adSize;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([_adlist count]<=1) {
        PLAdViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[PLAdViewCell reuseIdentifier] forIndexPath:indexPath];
        id adModel = [_adlist firstObject];
        [cell setAdModel:adModel];
        return cell;
    }
    else {
        if (indexPath.row==0) {
            PLAdViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[PLAdViewCell reuseIdentifier] forIndexPath:indexPath];
            [cell setAdModel:[_adlist lastObject]];
            return cell;
        }
        else if(indexPath.row == [_adlist count]+1) {
            PLAdViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[PLAdViewCell reuseIdentifier] forIndexPath:indexPath];
            [cell setAdModel:[_adlist firstObject]];
            return cell;
        }
        else {
            PLAdViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[PLAdViewCell reuseIdentifier] forIndexPath:indexPath];
            if (indexPath.row-1>=0&&indexPath.row-1<[_adlist count]) {
                id adModel = [_adlist objectAtIndex:indexPath.row-1];
                [cell setAdModel:adModel];
            }
            return cell;
        }
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    // 按礼包排列
    id adModel = nil;
    if ([_adlist count]<=1) {
        adModel = [_adlist firstObject];
    }
    else {
        if (indexPath.row==0) {
            // 最后一个
            adModel = [_adlist lastObject];
        }
        else if(indexPath.row==[_adlist count]+1) {
            adModel = [_adlist firstObject];
        }
        else  {
            adModel = [_adlist objectAtIndex:indexPath.row-1];
        }
    }
    if (delegate&&[delegate respondsToSelector:@selector(didTouchNDetailHeadImageAtIndex:withImagesArr:)]) {
        [delegate didTouchNDetailHeadImageAtIndex:indexPath.row withImagesArr:_adlist];
    }
}
//8.0 以后方法
- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        if (!_loaded) {
            _loaded = YES;
            if ([_adlist count]>1) {
                [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
            }
        }
    }
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    int currentIndex = _collectionView.contentOffset.x/_adSize.width;
    if ([_adlist count]<=1) {
        [_pageControl setCurrentPage:currentIndex];
    }
    else {
        if (currentIndex==0) {
            // 显示最后一个
            [_pageControl setCurrentPage:[_adlist count]-1];
            [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:[_adlist count] inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
        }
        else if(currentIndex==[_adlist count]+1) {
            // 显示第一个
            [_pageControl setCurrentPage:0];
            [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
        }
        else {
            [_pageControl setCurrentPage:currentIndex-1];
        }
    }
}
@end




@implementation PLAdViewCell
/**
 *  获取Cell的reuseIdentifier
 */
+ (NSString*)reuseIdentifier
{
    return @"PLAdViewCellReuseIdentifier";
}
-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _imageView = [[UIImageView alloc] init];
        [self.contentView addSubview:_imageView];
        [_imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.contentView);
        }];
    }
    return self;
}
/**
 *  设置板块数据
 */
- (void)setAdModel:(id)adModel
{
    if ([adModel isKindOfClass:[BannerModel class]]) {
        [_imageView sd_setImageWithURL:[[GLGlobalValue ShareValue] urlWithString:((BannerModel*)adModel).commercialUrl] placeholderImage:[UIImage imageNamed:@"placeholder"]];
    }
}

@end

