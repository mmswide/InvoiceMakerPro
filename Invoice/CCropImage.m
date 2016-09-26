//
//  CCropImage.m
//  Webshy
//
//  Created by XGRoup5 on 10/31/12.
//
//

#import "CCropImage.h"
#import "Defines.h"

@interface CCropImage () <UIGestureRecognizerDelegate> {
    CGPoint _previousPositionImage;
    CGFloat _maxScale;
    CGFloat _minScale;
}
@end

@implementation CCropImage
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame imageData:(NSData *)data andTag:(int)tag {
	self = [super initWithFrame:frame];
	
	if (self) {
		self.tag = tag;
        [self setClipsToBounds:YES];
        
		image_data = [[NSMutableData alloc] initWithData:data];
		
		UIView *grayView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height - 50)];
		[grayView setBackgroundColor:[UIColor grayColor]];
		[self addSubview:grayView];
	
		UIImage *temp = [UIImage imageWithData:image_data];
		
		CGSize actualSize = CGSizeMake(frame.size.width, frame.size.height - 50);
		
		actualSize = CGSizeMake(actualSize.width, (temp.size.height / temp.size.width) * actualSize.width);
		
		theImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, actualSize.width, actualSize.height)];
		[theImage setImage:[UIImage imageWithData:image_data]];
        [theImage setUserInteractionEnabled:YES];
		[theImage setContentMode:UIViewContentModeScaleAspectFit];
		[self addSubview:theImage];
        
        _minScale = theImage.frame.size.width / theImage.image.size.width;
        _maxScale = 1.0;
				
		UIView *use_view = [[UIView alloc] initWithFrame:CGRectMake(0, dvc_height - 50, dvc_width, 50)];
		[use_view setBackgroundColor:[UIColor whiteColor]];
		[self addSubview:use_view];
		
		UIButton *closeCMR = [[UIButton alloc] initWithFrame:CGRectMake(5, 5, 60, 40)];
		[closeCMR setTitle:@"Cancel" forState:UIControlStateNormal];
		[closeCMR setTitleColor:app_tab_selected_color forState:UIControlStateNormal];
		[closeCMR setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
		[closeCMR.titleLabel setFont:HelveticaNeueLight(17)];
		[closeCMR addTarget:self action:@selector(close:) forControlEvents:UIControlEventTouchUpInside];
		[use_view addSubview:closeCMR];
		
		UIButton *usePhoto = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 63, 30)];
		[usePhoto setCenter:CGPointMake(dvc_width / 2, 25)];
		[usePhoto setTitle:@"USE" forState:UIControlStateNormal];
		[usePhoto setTitleEdgeInsets:UIEdgeInsetsMake(3, 0, 0, 0)];
		[usePhoto setTitleColor:app_tab_selected_color forState:UIControlStateNormal];
		[usePhoto setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
		[usePhoto.titleLabel setFont:HelveticaNeueLight(17)];
		[usePhoto addTarget:self action:@selector(useTheImage:) forControlEvents:UIControlEventTouchUpInside];
		[use_view addSubview:usePhoto];
		
		[self createTheModel];
	}
	return self;
}

- (void)useTheImage:(UIButton *)sender {
    
    CGFloat lRatio = theImage.frame.size.width / theImage.image.size.width;
    
    CGFloat lOffsetX = myRect.origin.x - theImage.frame.origin.x;
    CGFloat lOffsetY = myRect.origin.y - theImage.frame.origin.y;
    
    CGRect theCroppedRect = CGRectMake(lOffsetX / lRatio, lOffsetY / lRatio, myRect.size.width / lRatio, myRect.size.height / lRatio);

	CGImageRef imageRef = CGImageCreateWithImageInRect([theImage.image CGImage], theCroppedRect);
	
	UIImage *neededImage = [UIImage imageWithCGImage:imageRef];
	
	image_data = [[NSMutableData alloc] initWithData:UIImagePNGRepresentation(neededImage)];
	
	CGImageRelease(imageRef);
	
	if (delegate && [delegate respondsToSelector:@selector(cropperDidCropImage:)]) {
		[delegate cropperDidCropImage:[UIImage imageWithData:image_data]];
	}
	
	[self close:nil];
}

#pragma mark - SET MODEL

- (void)createTheModel {
    
	maskPath = [UIBezierPath bezierPathWithRect:CGRectZero];
	
	if(self.tag == 0) {
        // ICON CASE
		myRect = CGRectMake(50, 95, dvc_width - 100, dvc_width - 100);
        
	} else if(self.tag == 1) {
        
        // BACKGROUND IMAGE CASE
		float percentage = (2480 * 100) / 3508;
		float width = (dvc_width - 20) * percentage / 100;
				
		myRect = CGRectMake((dvc_width - width)/2, 55, width, dvc_width - 20);
	}
	
	maskPath = [UIBezierPath bezierPathWithRect:myRect];
    
    CGRect lFrameImage = theImage.frame;
    lFrameImage.origin.x = myRect.origin.x;
    lFrameImage.origin.y = myRect.origin.y;
    
    _previousPositionImage.x = myRect.origin.x;
    _previousPositionImage.y = myRect.origin.y;
    
    [theImage setFrame:lFrameImage];
	
	maskView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height - 50)];
	[maskView setBackgroundColor:[UIColor blackColor]];
	[maskView setUserInteractionEnabled:NO];
	
	mask = [[CAShapeLayer alloc] init];
	mask.frame = maskView.layer.bounds;

	CGRect invertRect = CGRectMake(mask.frame.origin.x, mask.frame.origin.y, mask.frame.size.width, mask.frame.size.height);
	
	[maskPath moveToPoint:CGPointMake(CGRectGetMinX(invertRect), CGRectGetMinY(invertRect))];
	[maskPath addLineToPoint:CGPointMake(CGRectGetMinX(invertRect), CGRectGetMaxY(invertRect))];
	[maskPath addLineToPoint:CGPointMake(CGRectGetMaxX(invertRect), CGRectGetMaxY(invertRect))];
	[maskPath addLineToPoint:CGPointMake(CGRectGetMaxX(invertRect), CGRectGetMinY(invertRect))];
	[maskPath addLineToPoint:CGPointMake(CGRectGetMinX(invertRect), CGRectGetMinY(invertRect))];
    
	mask.path = maskPath.CGPath;
	[mask setFillRule:kCAFillRuleEvenOdd];
	mask.fillColor = [[UIColor colorWithWhite:0.0 alpha:0.75] CGColor];
	maskView.layer.mask = mask;
	[self addSubview:maskView];
    
    circleView = [[UIView alloc] initWithFrame:CGRectMake(myRect.origin.x - 10, myRect.origin.y + myRect.size.height - 10, 20, 20)];
    circleView.layer.cornerRadius = 10;
    [circleView setBackgroundColor:[UIColor colorWithRed:0.15 green:0.44 blue:1.0 alpha:1.0]];
    [self addSubview:circleView];
    
    UIPanGestureRecognizer *lMaskPanGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveMask:)];
    lMaskPanGestureRecognizer.minimumNumberOfTouches = 1;
    [circleView addGestureRecognizer:lMaskPanGestureRecognizer];
    
    UIPinchGestureRecognizer *lPinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchHandler:)];
    [self addGestureRecognizer:lPinchGestureRecognizer];
    
    UIPanGestureRecognizer * lImagePanGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveImage:)];
    [lImagePanGestureRecognizer setDelegate:self];
    [theImage addGestureRecognizer:lImagePanGestureRecognizer];
	
	UILabel *tip = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, dvc_width - 40, 25)];
	[tip setText:@"Move and scale image to crop."];
	[tip setTextAlignment:NSTextAlignmentCenter];
	[tip setTextColor:[UIColor colorWithWhite:0.5 alpha:0.8]];
	[tip setBackgroundColor:[UIColor clearColor]];
	[maskView addSubview:tip];
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
	if (newSuperview) {
		CGFloat y = self.frame.origin.y;
		[self setFrame:CGRectMake(self.frame.origin.x, self.frame.size.height, self.frame.size.width, self.frame.size.height)];
		
		[UIView animateWithDuration:0.25 animations:^{
			[self setFrame:CGRectMake(self.frame.origin.x, y, self.frame.size.width, self.frame.size.height)];
		}];
	}
}

- (void)pinchHandler:(UIPinchGestureRecognizer *)pan {
    CGFloat lMeasurmentScale = theImage.frame.size.width * pan.scale;
    CGFloat lCurrentScale =  lMeasurmentScale / theImage.image.size.width;
    
    if (lCurrentScale > _minScale && lCurrentScale < _maxScale) {
        theImage.transform = CGAffineTransformScale(theImage.transform, pan.scale, pan.scale);
        theImage.frame = CGRectMake(theImage.frame.origin.x, myRect.origin.y, theImage.frame.size.width, theImage.frame.size.height);
        pan.scale = 1;
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    _previousPositionImage = [gestureRecognizer locationInView:self];
    return YES;
}

- (void)moveImage:(UIPanGestureRecognizer *)pan {
    CGPoint translation = [pan locationInView:self];
    
    CGRect lFrameImage = theImage.frame;

    CGFloat lOffsetY = translation.y - _previousPositionImage.y;
    CGFloat lOffsetX = translation.x - _previousPositionImage.x;
    
    if (lOffsetY < 0) {
        if (lFrameImage.size.height > myRect.size.height) {
            lOffsetY = (theImage.center.y + lOffsetY + theImage.frame.size.height / 2 > myRect.origin.y + myRect.size.height) ? lOffsetY : 0;
        } else {
            lOffsetY = 0;
        }
    } else  if (lOffsetY > 0){
         lOffsetY = (theImage.center.y + lOffsetY - theImage.frame.size.height / 2 < myRect.origin.y) ?  lOffsetY : 0;
    }
    
    if (lOffsetX < 0 ) {
        if (lFrameImage.size.width > myRect.size.width) {
            lOffsetX = (theImage.center.x + lOffsetX + theImage.frame.size.width / 2 > myRect.origin.x + myRect.size.width) ? lOffsetX : 0;
        } else {
            lOffsetX = 0;
        }
    } else if (lOffsetX > 0) {
        lOffsetX = (theImage.center.x + lOffsetX - theImage.frame.size.width / 2 < myRect.origin.x) ?  lOffsetX : 0;
    }
    _previousPositionImage = translation;
    theImage.center = CGPointMake(theImage.center.x + lOffsetX, theImage.center.y + lOffsetY);
}

- (void)moveMask:(UIPanGestureRecognizer *)pan {
    CGPoint lNewPoint = [pan locationInView:circleView.superview];
    CGPoint lOffset = CGPointMake(lNewPoint.x - circleView.center.x, lNewPoint.y - circleView.center.y);
    
    if ((lNewPoint.x <= self.frame.size.width / 2 - 25 || lOffset.x == 0) && (lNewPoint.y >= myRect.origin.y + 50 || lOffset.y == 0)) {
        
        if (lNewPoint.x >= 10 && lNewPoint.y <= self.frame.size.height - 60) {
            
            myRect = CGRectMake(myRect.origin.x + lOffset.x, myRect.origin.y, myRect.size.width + -lOffset.x + -lOffset.x, myRect.size.height + lOffset.y);
            
            cropSize = CGSizeMake(myRect.size.width, myRect.size.height);
            
            maskPath = [UIBezierPath bezierPathWithRect:myRect];
            CGRect invertRect = CGRectMake(mask.frame.origin.x, mask.frame.origin.y, mask.frame.size.width, mask.frame.size.height);
            
            [maskPath moveToPoint:CGPointMake(CGRectGetMinX(invertRect), CGRectGetMinY(invertRect))];
            [maskPath addLineToPoint:CGPointMake(CGRectGetMinX(invertRect), CGRectGetMaxY(invertRect))];
            [maskPath addLineToPoint:CGPointMake(CGRectGetMaxX(invertRect), CGRectGetMaxY(invertRect))];
            [maskPath addLineToPoint:CGPointMake(CGRectGetMaxX(invertRect), CGRectGetMinY(invertRect))];
            [maskPath addLineToPoint:CGPointMake(CGRectGetMinX(invertRect), CGRectGetMinY(invertRect))];
            mask.path = maskPath.CGPath;
            
            maskView.layer.mask = mask;
            circleView.center = [pan locationInView:circleView.superview];
        }
    }
}

- (void)close:(UIButton *)sender {
	[UIView animateWithDuration:0.25 animations:^{
		
		[self setFrame:CGRectMake(self.frame.origin.x, self.frame.size.height, self.frame.size.width, self.frame.size.height)];
		
	} completion:^(BOOL done){
		[self removeFromSuperview];
	}];
}

@end
