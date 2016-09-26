//
//  ButtonForAlert.m
//  Invoice
//
//  Created by XGRoup5 on 8/14/13.
//  Copyright (c) 2013 XGRoup. All rights reserved.
//

#import "ButtonForAlert.h"

#import "Defines.h"

@implementation ButtonForAlert

-(id)initWithFrame:(CGRect)frame title:(NSString*)title andTag:(int)tag
{
	self = [super initWithFrame:frame];
	
	if (self)
	{
		[self setBackgroundImage:[[UIImage imageNamed:@"alertViewBackground.png"] stretchableImageWithLeftCapWidth:15 topCapHeight:15] forState:UIControlStateNormal];
		[self setTitle:title forState:UIControlStateNormal];
		[self setTitleColor:app_tab_selected_color forState:UIControlStateNormal];
		[self.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Light" size:18]];
		[self setTag:tag];
	}
	
	return self;
}

@end