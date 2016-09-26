//
//  TopBar.m
//  Invoice
//
//  Created by XGRoup5 on 9/5/13.
//  Copyright (c) 2013 XGRoup. All rights reserved.
//

#import "TopBar.h"

#import "Defines.h"

@implementation TopBar

-(id)initWithFrame:(CGRect)frame andTitle:(NSString*)title
{
	self = [super initWithFrame:frame];
	
	if (self)
	{
		[self setBackgroundColor:[UIColor colorWithRed:(float)57/255 green:(float)177/255 blue:(float)238/255 alpha:1.0]];
		
		UIView * grayLine = [[UIView alloc] initWithFrame:CGRectMake(0, frame.size.height - 1, dvc_width, 1)];
		[grayLine setBackgroundColor:[UIColor lightGrayColor]];
		[self addSubview:grayLine];
		
//		UIImageView * upperShadow = [[UIImageView alloc] initWithFrame:CGRectMake(0, 42, dvc_width, 5)];
//		[upperShadow setImage:[[UIImage imageNamed:@"shadowUp.png"] stretchableImageWithLeftCapWidth:5 topCapHeight:0]];
//		[upperShadow setAlpha:0.3];
//		[self addSubview:upperShadow];
		
		titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, frame.size.height - 40, dvc_width - 160, 40)];
		[titleLabel setText:title];
		[titleLabel setTextAlignment:NSTextAlignmentCenter];
		[titleLabel setTextColor:[UIColor whiteColor]];
		[titleLabel setFont:HelveticaNeueMedium(17)];
		[titleLabel setBackgroundColor:[UIColor clearColor]];
		[titleLabel setAdjustsFontSizeToFitWidth:YES];
		[self addSubview:titleLabel];
	}
	
	return self;
}

-(void)setText:(NSString*)text
{
	[titleLabel setText:text];
}

-(void)setTextColor:(UIColor*)color
{
	[titleLabel setTextColor:color];
}

@end