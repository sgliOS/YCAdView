//
//  PHAdView.h
//  shplayhall
//
//  Created by sgl on 15/12/4.
//  Copyright © 2015年 PinLu. All rights reserved.
//

#import <UIKit/UIKit.h>


@class PLAdView;

@protocol PLAdViewDelegate <NSObject>

@optional
/*!
 @abstract      点击商品详情其中的某个图片的事件
 @param         index  点击的图片的位置
 @param         imageUrls 所有图url的数组
 */
- (void)didTouchNDetailHeadImageAtIndex:(NSInteger)index withImagesArr:(NSArray *)imageUrls;

@end

@interface PLAdView : UIView
{
    __unsafe_unretained id<PLAdViewDelegate>delegate;
}
@property(nonatomic,assign)id delegate;
/**
 *  初始化
 */
- (id)initWithAdSize:(CGSize)adSize;
/**
 *  刷新数据
 */
- (void)setAdList:(NSArray*)adList;

@end


@interface PLAdViewCell : UICollectionViewCell
@property(nonatomic,strong)  UIImageView *imageView;

/**
 *  获取Cell的reuseIdentifier
 */
+ (NSString*)reuseIdentifier;
/**
 *  设置板块数据
 */
- (void)setAdModel:(id)adModel;
@end
