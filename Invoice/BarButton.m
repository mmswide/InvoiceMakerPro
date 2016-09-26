//
//  BarButton.m
//  Invoice
//
//  Created by XGRoup5 on 8/14/13.
//  Copyright (c) 2013 XGRoup. All rights reserved.
//

#import "BarButton.h"

#import "Defines.h"

@implementation BarButton

-(id)initWithFrame:(CGRect)frame title:(NSString*)title andTag:(int)tag
{
	self = [super initWithFrame:frame];
	
	if (self)
	{
		[self setTag:tag];
		
//		[self setBackgroundImage:[[UIImage imageNamed:@"selectedTab.png"] stretchableImageWithLeftCapWidth:20 topCapHeight:20] forState:UIControlStateSelected];
//		[self setBackgroundImage:nil forState:UIControlStateNormal];
		
		UIImage * image = [UIImage imageNamed:[NSString stringWithFormat:@"tabImg%d.png", tag]];
		
		buttonImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
		[buttonImage setContentMode:UIViewContentModeScaleAspectFit];
		[buttonImage setImage:[UIImage imageNamed:[NSString stringWithFormat:@"tabImg%d@2x.png", tag]]];
		[buttonImage setCenter:CGPointMake(frame.size.width / 2, buttonImage.frame.size.height / 2 + 5)];
		[self addSubview:buttonImage];
		
		labelWithTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, frame.size.height - 15, frame.size.width, 12)];
		[labelWithTitle setText:title];
		[labelWithTitle setTextAlignment:NSTextAlignmentCenter];
		[labelWithTitle setTextColor:[UIColor colorWithRed:(float)186/255 green:(float)194/255 blue:(float)205/255 alpha:1.0]];
		[labelWithTitle setFont:HelveticaNeueMedium(9)];
		[labelWithTitle setBackgroundColor:[UIColor clearColor]];
		[self addSubview:labelWithTitle];
	}
	
	return self;
}

-(void)setSelected:(BOOL)selected
{
	[super setSelected:selected];
	
	if (selected)
	{
		[labelWithTitle setTextColor:app_tab_selected_color];
		
		[buttonImage setImage:[UIImage imageNamed:[NSString stringWithFormat:@"tabImg%ldON@2x.png", (long)self.tag]]];
	}
	else
	{
		[labelWithTitle setTextColor:[UIColor colorWithRed:(float)186/255 green:(float)194/255 blue:(float)205/255 alpha:1.0]];
		
		[buttonImage setImage:[UIImage imageNamed:[NSString stringWithFormat:@"tabImg%ld@2x.png", (long)self.tag]]];
	}
}

@end