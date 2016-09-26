//
//  SignatureView.m
//  Work.
//
//  Created by Paul on 19/11/13.
//  Copyright (c) 2013 XGRoup. All rights reserved.
//

#import "SignatureView.h"

@implementation SignatureView

-(id)init
{
	self = [super initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width - 20, [UIScreen mainScreen].bounds.size.width - 20)];
	
	if (self)
	{		
		_signaturePath = [[UIBezierPath alloc] init];
		[_signaturePath setLineWidth:4];
		[self setColor:[UIColor blackColor]];
		
		_topLeftPoint = CGPointMake(self.frame.size.width, self.frame.size.width);
		_bottomRightPoint = CGPointMake(0, 0);
	}
	
	return self;
}

-(id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	
	if (self)
	{
		_signaturePath = [[UIBezierPath alloc]init];
		[_signaturePath setLineWidth:4];
		[self setColor:[UIColor blackColor]];
		
		_topLeftPoint = CGPointMake(self.frame.size.width, self.frame.size.width);
		_bottomRightPoint = CGPointMake(0, 0);
	}
	
	return self;
}

-(id)initWithFrame:(CGRect)frame signature:(UIImage*)sender andSignatureFrame:(CGRect)sFrame
{
	self = [super initWithFrame:frame];
	
	if (self)
	{
		startedWithImage = YES;
		
		_topLeftPoint = CGPointMake(self.frame.size.width, self.frame.size.width);
		_bottomRightPoint = CGPointMake(0, 0);
		
		if (sender)
		{
			if (sFrame.origin.x != 0.0f && sFrame.origin.y != 0.0f && sFrame.size.width != 0.0f && sFrame.size.height != 0.0f)
			{
				_topLeftPoint = sFrame.origin;
				_bottomRightPoint = CGPointMake(_topLeftPoint.x + sFrame.size.width, _topLeftPoint.y + sFrame.size.height);
			}
			
			UIImageView * signatureView = [[UIImageView alloc] initWithFrame:sFrame];
			[signatureView setImage:sender];
			[self addSubview:signatureView];
		}
		
		_signaturePath = [[UIBezierPath alloc]init];
		[_signaturePath setLineWidth:4];
		[self setColor:[UIColor blackColor]];
	}
	
	return self;
}

-(void)drawRect:(CGRect)rect
{
	[brushColor setStroke];
	[_signaturePath strokeWithBlendMode:kCGBlendModeNormal alpha:1.0];
}

-(void)clear
{
	_topLeftPoint = CGPointMake(self.frame.size.width, self.frame.size.width);
	_bottomRightPoint = CGPointMake(0, 0);
	
	[_signaturePath removeAllPoints];
	
	while (self.subviews.count > 0)
	{
		[[self.subviews lastObject] removeFromSuperview];
	}
	
	[self setNeedsDisplay];
	
	isEmpty = YES;
}

-(void)setColor:(UIColor*)color
{
	brushColor = color;
}

-(UIImage*)theSignature
{
	if (isEmpty)
	{
		return nil;
	}
	
	UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 0.0);
	[self.layer renderInContext:UIGraphicsGetCurrentContext()];
	
	UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
	
	UIGraphicsEndImageContext();
	
	CGFloat scale = 1.0f;
	
	if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)])
	{
		scale = [[UIScreen mainScreen] scale];
	}
	
	CGRect cropRect;
		
	cropRect = CGRectMake(_topLeftPoint.x * scale,
				    _topLeftPoint.y * scale,
				    (_bottomRightPoint.x - _topLeftPoint.x) * scale,
				    (_bottomRightPoint.y - _topLeftPoint.y) * scale);
	
	CGImageRef imageRef = CGImageCreateWithImageInRect([img CGImage], cropRect);
	
	UIImage * neededImage = [UIImage imageWithCGImage:imageRef];
	
	CGImageRelease(imageRef);
	
	return neededImage;
}

#pragma mark - TOUCH CONTROL

-(void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event
{
	UITouch * myTouch = [[touches allObjects] objectAtIndex:0];
	
	CGPoint point = [myTouch locationInView:self];
	
	[_signaturePath moveToPoint:point];
	[self setNeedsDisplay];
	
	[self createBoundariesForPoint:point];
}

-(void)touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event
{
	UITouch * myTouch = [[touches allObjects] objectAtIndex:0];
	
	CGPoint point = [myTouch locationInView:self];
	
	[_signaturePath addLineToPoint:point];
	[self setNeedsDisplay];
	
	isEmpty = NO;
	
	[self createBoundariesForPoint:point];
}

-(void)createBoundariesForPoint:(CGPoint)sender
{
	CGPoint topPoint = CGPointMake(sender.x - 2, sender.y - 2);
	CGPoint bottomPoint = CGPointMake(sender.x + 2, sender.y + 2);
	
	if (_topLeftPoint.x > topPoint.x)
	{
		_topLeftPoint = CGPointMake(topPoint.x, _topLeftPoint.y);
	}
	
	if (_topLeftPoint.y > topPoint.y)
	{
		_topLeftPoint = CGPointMake(_topLeftPoint.x, topPoint.y);
	}
	
	if (_bottomRightPoint.x < bottomPoint.x)
	{
		_bottomRightPoint = CGPointMake(bottomPoint.x, _bottomRightPoint.y);
	}
	
	if (_bottomRightPoint.y < bottomPoint.y)
	{
		_bottomRightPoint = CGPointMake(_bottomRightPoint.x, bottomPoint.y);
	}
	
	if (_topLeftPoint.x < 0)
	{
		_topLeftPoint = CGPointMake(0, _topLeftPoint.y);
	}
	
	if (_topLeftPoint.y < 0)
	{
		_topLeftPoint = CGPointMake(_topLeftPoint.x, 0);
	}
	
	if (_bottomRightPoint.x < 0)
	{
		_bottomRightPoint = CGPointMake(0, _bottomRightPoint.y);
	}
	
	if (_bottomRightPoint.y < 0)
	{
		_bottomRightPoint = CGPointMake(_bottomRightPoint.x, 0);
	}
	
	if (_topLeftPoint.x > self.frame.size.width)
	{
		_topLeftPoint = CGPointMake(self.frame.size.width, _topLeftPoint.y);
	}
	
	if (_topLeftPoint.y > self.frame.size.height)
	{
		_topLeftPoint = CGPointMake(_topLeftPoint.x, self.frame.size.height);
	}
	
	if (_bottomRightPoint.x > self.frame.size.width)
	{
		_bottomRightPoint = CGPointMake(self.frame.size.width, _bottomRightPoint.y);
	}
	
	if (_bottomRightPoint.y > self.frame.size.height)
	{
		_bottomRightPoint = CGPointMake(_bottomRightPoint.x, self.frame.size.height);
	}
}

-(void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event
{
	[self setNeedsDisplay];
}

@end