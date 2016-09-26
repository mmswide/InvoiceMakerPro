//
//  ToolBarView.m
//  Invoice
//
//  Created by XGRoup5 on 8/16/13.
//  Copyright (c) 2013 XGRoup. All rights reserved.
//

#import "ToolBarView.h"

#import "Defines.h"


@implementation ToolBarView

@synthesize prevButton;
@synthesize nextButton;
@synthesize doneButton;

-(id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	
	if (self)
	{
		[self setBackgroundColor:[UIColor whiteColor]];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
		
		UIImageView * shadowView = [[UIImageView alloc] initWithFrame:CGRectMake(0, -5, frame.size.width, 5)];
		[shadowView setImage:[[UIImage imageNamed:@"shadowDown.png"] stretchableImageWithLeftCapWidth:5 topCapHeight:0]];
		[shadowView setAlpha:0.4];
		[self addSubview:shadowView];
		
		prevButton = [[BackButtonNormal alloc] initWithFrame:CGRectMake(0, 0, 70, 40) andTitle:@"Prev"];
		[self addSubview:prevButton];
		
		nextButton = [[BackButtonNormal alloc] initWithFrame:CGRectMake(70, 0, 70, 40) andTitle:@"Next"];
		[nextButton setBackgroundImage:[[UIImage imageNamed:@"forwardButton.png"] stretchableImageWithLeftCapWidth:22 topCapHeight:0] forState:UIControlStateNormal];
		[nextButton setTitleEdgeInsets:UIEdgeInsetsMake(0, -18, 0, 0)];
		[self addSubview:nextButton];
		
		doneButton = [[UIButton alloc] initWithFrame:CGRectMake(dvc_width - 60, 0, 60, 40)];
		[doneButton setTitle:@"Done" forState:UIControlStateNormal];
		[doneButton setTitleColor:app_tab_selected_color forState:UIControlStateNormal];
		[doneButton setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
		[doneButton.titleLabel setFont:HelveticaNeueLight(17)];
		[self addSubview:doneButton];
	}
	
	return self;
}

-(void)keyboardWillHide:(NSNotification*)sender
{
	[doneButton sendActionsForControlEvents:UIControlEventTouchUpInside];
}

-(void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end