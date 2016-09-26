//
//  ScrollWithShadow.m
//  Invoice
//
//  Created by XGRoup5 on 8/15/13.
//  Copyright (c) 2013 XGRoup. All rights reserved.
//

#import "ScrollWithShadow.h"

#import "Defines.h"

@implementation ScrollWithShadow

-(id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	
	if (self)
	{
		upperShadow = [[UIImageView alloc] initWithFrame:CGRectMake(0, -5, frame.size.width, 5)];
		[upperShadow setImage:[[UIImage imageNamed:@"shadowUp.png"] stretchableImageWithLeftCapWidth:5 topCapHeight:0]];
		[upperShadow setAlpha:0.0];
		[self addSubview:upperShadow];
		
		lowerShadow = [[UIImageView alloc] initWithFrame:CGRectMake(0, frame.size.height, frame.size.width, 5)];
		[lowerShadow setImage:[[UIImage imageNamed:@"shadowDown.png"] stretchableImageWithLeftCapWidth:5 topCapHeight:0]];
		[lowerShadow setAlpha:0.0];
		[self addSubview:lowerShadow];
		
//		if (sys_version >= 7)
//		{
//			[self setContentInset:UIEdgeInsetsMake(-20, 0, 0, 0)];
//		}
	}
	
	return self;
}

-(void)didScroll
{
	CGFloat offset = self.contentOffset.y + self.frame.size.height;
	CGFloat upperShadowOffset = -5;
	CGFloat lowerShadowOffset = self.frame.size.height + 5;
	
	if (offset < self.contentSize.height)
	{
		[UIView animateWithDuration:0.15 animations:^{
			
			[lowerShadow setAlpha:0.4];
			
		}];
		
		lowerShadowOffset = offset - 5;
	}
	else
	{
		[UIView animateWithDuration:0.15 animations:^{
			
			[lowerShadow setAlpha:0.0];
			
		}];
		
		lowerShadowOffset = offset;
	}
	
	if (self.contentOffset.y > 0)
	{
		[UIView animateWithDuration:0.15 animations:^{
			
			[upperShadow setAlpha:0.4];
			
		}];
		
		upperShadowOffset = self.contentOffset.y;
	}
	else
	{
		[UIView animateWithDuration:0.15 animations:^{
			
			[upperShadow setAlpha:0.0];
			
		}];
		
		upperShadowOffset = self.contentOffset.y - 5;
	}
	
	[upperShadow setFrame:CGRectMake(0, upperShadowOffset, self.frame.size.width, 5)];
	[lowerShadow setFrame:CGRectMake(0, lowerShadowOffset, self.frame.size.width, 5)];
	
	[self bringSubviewToFront:upperShadow];
	[self bringSubviewToFront:lowerShadow];
}

@end