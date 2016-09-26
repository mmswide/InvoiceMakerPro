//
//  ColorPicker.m
//  Work.
//
//  Created by XGRoup5 on 19/11/13.
//  Copyright (c) 2013 XGRoup. All rights reserved.
//

#import "ColorPicker.h"

#import "Defines.h"
#import "SignatureView.h"

@implementation ColorPicker

-(id)initWithFrame:(CGRect)frame andColor:(UIColor*)color
{
	self = [super initWithFrame:frame];
	
	if (self)
	{
		_bgColor = color;
		
		[self.layer setCornerRadius:7.0f];
		[self.layer setMasksToBounds:YES];
		
		border = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height) cornerRadius:7.0f];
		[border setLineWidth:2];
		
		const CGFloat * components = CGColorGetComponents(_bgColor.CGColor);
		
		RED = components[0];
		GREEN = components[1];
		BLUE = components[2];
		ALPHA = CGColorGetAlpha(_bgColor.CGColor);
	}
	
	return self;
}

-(void)drawRect:(CGRect)rect
{
	[[UIColor darkGrayColor] setStroke];
	
	[border strokeWithBlendMode:kCGBlendModeNormal alpha:1.0];
}

#pragma mark - TOUCH CONTROL

-(void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event
{
	[UIView animateWithDuration:0.2 animations:^{
		
		[self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, dvc_width - self.frame.origin.x * 2, self.frame.size.height)];
		
		UNIT = (self.frame.size.width / 6) / 100;
		
		[border removeAllPoints];
		[border appendPath:[UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height) cornerRadius:7.0f]];
		[self setNeedsDisplay];
		
	}];
}

-(void)touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event
{
	UITouch * mytouch=[[touches allObjects] objectAtIndex:0];
	CGPoint point = [mytouch locationInView:self];
	
	CGFloat segmentSize = self.frame.size.width / 6;
	int segment = (int)point.x / (int)segmentSize + 1;
	CGFloat position = point.x;
	
	switch (segment)
	{
		case 1:
		{
			RED = 1.0f;
			BLUE = 0.0f;
			
			GREEN = position / segmentSize;
			
			break;
		}
			
		case 2:
		{
			position = point.x - segmentSize;
			
			BLUE = 0.0f;
			GREEN = 1.0f;
			
			RED = 1 - (position / segmentSize);
			
			break;
		}
			
		case 3:
		{
			position = point.x - segmentSize * 2;
			
			RED = 0.0f;
			GREEN = 1.0f;
			
			BLUE = position / segmentSize;
			
			break;
		}
			
		case 4:
		{
			position = point.x - segmentSize * 3;
			
			RED = 0.0f;
			BLUE = 1.0f;
			
			GREEN = 1 - (position / segmentSize);
			
			break;
		}
			
		case 5:
		{
			position = point.x - segmentSize * 4;
			
			BLUE = 1.0f;
			GREEN = 0.0f;
			
			RED = position / segmentSize;
			
			break;
		}
			
		case 6:
		{
			position = point.x - segmentSize * 5;
			
			RED = 1.0f;
			GREEN = 0.0f;
			
			BLUE = 1 - (position / segmentSize);
			
			break;
		}
			
		default:
			break;
	}
	
	[self setBackgroundColor:[UIColor colorWithRed:RED green:GREEN blue:BLUE alpha:ALPHA]];
	[_parent setColor:self.backgroundColor];
	[_parent setNeedsDisplay];
}

-(void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event
{
	[UIView animateWithDuration:0.2 animations:^{
		
		[self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.height, self.frame.size.height)];
		
	} completion:^(BOOL finished) {
		
		[border removeAllPoints];
		[border appendPath:[UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height) cornerRadius:7.0f]];
		[self setNeedsDisplay];
		
	}];
}

@end