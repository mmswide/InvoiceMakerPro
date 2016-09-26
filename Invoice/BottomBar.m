//
//  BottomBar.m
//  Invoice
//
//  Created by XGRoup5 on 8/14/13.
//  Copyright (c) 2013 XGRoup. All rights reserved.
//

#import "BottomBar.h"

#import "Defines.h"
#import "BarButton.h"

@implementation BottomBar

-(id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	
	if (self)
	{
		[self setBackgroundColor:[UIColor whiteColor]];
		
//		UIImageView * lowerShadow = [[UIImageView alloc] initWithFrame:CGRectMake(0, -5, frame.size.width, 5)];
//		[lowerShadow setImage:[[UIImage imageNamed:@"shadowDown.png"] stretchableImageWithLeftCapWidth:5 topCapHeight:0]];
//		[lowerShadow setAlpha:0.3];
//		[self addSubview:lowerShadow];
		
		UIView * line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 1)];
		[line setBackgroundColor:[UIColor colorWithRed:(float)166/255 green:(float)168/255 blue:(float)171/255 alpha:1.0]];
		[self addSubview:line];
		
/*		CGFloat button_width = 65.0f;
		
		CGFloat button_spacing = 5.0f;
		
		if (iPad)
		{
			button_width = 90.0f;
			button_spacing = 30.0f;
		}
		
		CGFloat side_spacing = (dvc_width - (button_width * 4)) / 2; */
		
		CGFloat button_width = 65.0f;
		
		CGFloat button_spacing = 5.0f;
		
		if (iPad)
		{
			button_width = 90.0f;
			button_spacing = 30.0f;
		}
		
		CGFloat side_spacing = (dvc_width - (button_width * 5)) / 2;
		
		NSArray * titlesArray;
		
		kApplicationVersion version = app_version;
		
		switch (version)
		{
			case kApplicationVersionInvoice:
			{
				titlesArray = [NSArray arrayWithObjects:@"Menu", @"Products", @"Contacts", @"Projects",@"Settings", nil];
				break;
			}
				
			case kApplicationVersionQuote:
			{
				titlesArray = [NSArray arrayWithObjects:@"Quotes", @"Products", @"Contacts", @"Projects", @"Settings", nil];
				break;
			}
				
			case kApplicationVersionEstimate:
			{
				titlesArray = [NSArray arrayWithObjects:@"Estimates", @"Products", @"Contacts", @"Projects",@"Settings", nil];
				break;
			}
				
			case kApplicationVersionPurchase:
			{
				titlesArray = [NSArray arrayWithObjects:@"P.Os", @"Products", @"Contacts", @"Projects",@"Settings", nil];
				break;
			}
				
			case kApplicationVersionReceipts:
			{
				titlesArray = [NSArray arrayWithObjects:@"Receipts", @"Products", @"Contacts", @"Projects",@"Settings", nil];
				break;
			}
				
			case kApplicationVersionTimesheets:
			{
				titlesArray = [NSArray arrayWithObjects:@"Timesheets", @"Products", @"Contacts", @"Projects",@"Settings", nil];
				break;
			}
				
			default:
				break;
		}
		
		for (int i = 1; i <= 5; i++)
		{
			BarButton * button = [[BarButton alloc] initWithFrame:CGRectMake(side_spacing + button_width * (i - 1), 2, button_width - button_spacing, 43) title:[titlesArray objectAtIndex:i -1] andTag:i];
			[button addTarget:DELEGATE action:@selector(goToTab:) forControlEvents:UIControlEventTouchUpInside];
			[self addSubview:button];
		}
	}
	
	return self;
}

-(void)selectButton:(int)tag
{
	for (BarButton * button in self.subviews)
	{
		if ([button isKindOfClass:[BarButton class]])
		{
			[button setSelected:NO];
		}
	}
	
	[(BarButton*)[self viewWithTag:tag] setSelected:YES];
}

@end