//
//  BackButtonWhite.m
//  Invoice
//
//  Created by XGRoup on 6/25/14.
//  Copyright (c) 2014 XGRoup. All rights reserved.
//

#import "BackButtonNormal.h"

#import "Defines.h"

@implementation BackButtonNormal

-(id)initWithFrame:(CGRect)frame andTitle:(NSString*)title
{
	self = [super initWithFrame:frame];
	
	if (self)
	{
		[self setBackgroundImage:[[UIImage imageNamed:@"backButton.png"] stretchableImageWithLeftCapWidth:22 topCapHeight:0] forState:UIControlStateNormal];
		[self setTitle:title forState:UIControlStateNormal];
		[self setTitleColor:app_tab_selected_color forState:UIControlStateNormal];
		[self setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
		[self setTitleEdgeInsets:UIEdgeInsetsMake(0, 25, 0, 0)];
		[self.titleLabel setFont:HelveticaNeueLight(17)];
	}
	
	return self;
}

@end
