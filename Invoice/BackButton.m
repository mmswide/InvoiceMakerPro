//
//  BackButton.m
//  Invoice
//
//  Created by XGRoup5 on 8/14/13.
//  Copyright (c) 2013 XGRoup. All rights reserved.
//

#import "BackButton.h"

#import "Defines.h"

@implementation BackButton

-(id)initWithFrame:(CGRect)frame andTitle:(NSString*)title
{
	self = [super initWithFrame:frame];
	
	if (self)
	{
		[self setBackgroundImage:[[UIImage imageNamed:@"backButtonWhite.png"] stretchableImageWithLeftCapWidth:22 topCapHeight:0] forState:UIControlStateNormal];
		[self setTitle:title forState:UIControlStateNormal];
		[self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		[self setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
		[self setTitleEdgeInsets:UIEdgeInsetsMake(0, 25, 0, 0)];
		[self.titleLabel setFont:HelveticaNeueLight(17)];
	}
	
	return self;
}

@end