//
//  CCropImage.h
//  Webshy
//
//  Created by XGRoup5 on 10/31/12.
//
//

#import <UIKit/UIKit.h>

@protocol ImageCropperDelegate <NSObject>

-(void)cropperDidCropImage:(UIImage*)image;

@end

@interface CCropImage : UIView <UIScrollViewDelegate>

{
	UIView * maskView;
	NSMutableData * image_data;
	UIScrollView * imgScroll;
	UIImageView * theImage;
	CGSize scrollSize;
	CGSize cropSize;
    UIView *circleView;
    CAShapeLayer  *mask;
    UIBezierPath *maskPath;
    CGRect myRect;
}

@property (weak) id<ImageCropperDelegate> delegate;

-(id)initWithFrame:(CGRect)frame imageData:(NSData*)data andTag:(int)tag;
-(void)useTheImage:(UIButton*)sender;
-(void)createTheModel;
-(void)close:(UIButton*)sender;

@end
