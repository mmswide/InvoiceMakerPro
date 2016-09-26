//
//  ProjectContactDetailVC.m
//  Invoice
//
//  Created by Paul on 17/06/14.
//  Copyright (c) 2014 XGRoup. All rights reserved.
//

#import "ProjectContactDetailVC.h"

#import "Defines.h"

@interface ProjectContactDetailVC () <UIScrollViewDelegate>

@end

@implementation ProjectContactDetailVC

-(id)initWithProject:(ProjectOBJ*)project
{
	self = [super init];
	
	if(self)
	{
		theProject = project;
	}
	
	return self;
}

#pragma mark - VIEW DID LOAD

-(void)viewDidLoad
{
	[super viewDidLoad];
	
	theSelfView = [[UIView alloc] initWithFrame:CGRectMake(0, statusBarHeight, dvc_width, dvc_height)];
	[theSelfView setBackgroundColor:[UIColor clearColor]];
	[self.view addSubview:theSelfView];
		
	[self.view setBackgroundColor:app_background_color];
	
	topBarView = [[TopBar alloc] initWithFrame:CGRectMake(0, 0, dvc_width, 42 + statusBarHeight) andTitle:@"Project Details"];
	[topBarView setBackgroundColor:app_bar_update_color];
	
	BackButton * backButton = [[BackButton alloc] initWithFrame:CGRectMake(0, 42 + statusBarHeight - 40, 70, 40) andTitle:@"Back"];
	[backButton addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
	[topBarView addSubview:backButton];
	
	mainScrollView = [[ScrollWithShadow alloc] initWithFrame:CGRectMake(0, 42, dvc_width, dvc_height - 87)];
	[mainScrollView setBackgroundColor:[UIColor clearColor]];
	[mainScrollView setDelegate:self];
	[theSelfView addSubview:mainScrollView];
	
	// PROJECT NAME
	{
		UIImageView *backgroundLabel = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, dvc_width - 20, 42)];
		[backgroundLabel setImage:[[UIImage imageNamed:@"tableTopCellWhite.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10]];
		[mainScrollView addSubview:backgroundLabel];
		
		UILabel *projectNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, dvc_width - 30, 42)];
		[projectNameLabel setBackgroundColor:[UIColor clearColor]];
		[projectNameLabel setText:@"Name"];
		[projectNameLabel setTextColor:[UIColor grayColor]];
		[projectNameLabel setFont:HelveticaNeue(16)];
		[mainScrollView addSubview:projectNameLabel];
		
		UILabel * text = [[UILabel alloc] initWithFrame:CGRectMake(100, 0, dvc_width - 130, 42)];
		[text setText:[theProject projectName]];
		[text setTextAlignment:NSTextAlignmentRight];
		[text setTextColor:[UIColor darkGrayColor]];
		[text setFont:HelveticaNeue(15)];
		[text setBackgroundColor:[UIColor clearColor]];
		[backgroundLabel addSubview:text];
	}
	
	// PROJECT NUMBER
	{
		UIImageView *backgroundLabel = [[UIImageView alloc] initWithFrame:CGRectMake(10, 52, dvc_width - 20, 42)];
		[backgroundLabel setImage:[[UIImage imageNamed:@"tableMiddleCellWhite.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10]];
		[mainScrollView addSubview:backgroundLabel];
		
		UILabel *projectNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 52, dvc_width - 30, 42)];
		[projectNameLabel setBackgroundColor:[UIColor clearColor]];
		[projectNameLabel setText:@"Number"];
		[projectNameLabel setTextColor:[UIColor grayColor]];
		[projectNameLabel setFont:HelveticaNeue(16)];
		[mainScrollView addSubview:projectNameLabel];
		
		UILabel * text = [[UILabel alloc] initWithFrame:CGRectMake(100, 0, dvc_width - 130, 42)];
		[text setText:[theProject projectNumber]];
		[text setTextAlignment:NSTextAlignmentRight];
		[text setTextColor:[UIColor darkGrayColor]];
		[text setFont:HelveticaNeue(15)];
		[text setBackgroundColor:[UIColor clearColor]];
		[backgroundLabel addSubview:text];
	}
	
	// CLIENT
	{
		UIImageView *backgroundLabel = [[UIImageView alloc] initWithFrame:CGRectMake(10, 94, dvc_width - 20, 42)];
		[backgroundLabel setImage:[[UIImage imageNamed:@"tableMiddleCellWhite.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10]];
		[mainScrollView addSubview:backgroundLabel];
		
		UILabel *projectNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 94, dvc_width - 30, 42)];
		[projectNameLabel setBackgroundColor:[UIColor clearColor]];
		[projectNameLabel setText:@"Client"];
		[projectNameLabel setTextColor:[UIColor grayColor]];
		[projectNameLabel setFont:HelveticaNeue(16)];
		[mainScrollView addSubview:projectNameLabel];
		
		UILabel * text = [[UILabel alloc] initWithFrame:CGRectMake(100, 0, dvc_width - 130, 42)];
		[text setText:[NSString stringWithFormat:@"%@ %@",[[theProject client] firstName],[[theProject client] lastName]]];
		[text setTextAlignment:NSTextAlignmentRight];
		[text setTextColor:[UIColor darkGrayColor]];
		[text setFont:HelveticaNeue(15)];
		[text setBackgroundColor:[UIColor clearColor]];
		[backgroundLabel addSubview:text];
	}
	
	// LOCATION
	{
		UIImageView *backgroundLabel = [[UIImageView alloc] initWithFrame:CGRectMake(10, 136, dvc_width - 20, 42)];
		[backgroundLabel setImage:[[UIImage imageNamed:@"tableMiddleCellWhite.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10]];
		[mainScrollView addSubview:backgroundLabel];
		
		UILabel *projectNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 136, dvc_width - 30, 42)];
		[projectNameLabel setBackgroundColor:[UIColor clearColor]];
		[projectNameLabel setText:@"Location"];
		[projectNameLabel setTextColor:[UIColor grayColor]];
		[projectNameLabel setFont:HelveticaNeue(16)];
		[mainScrollView addSubview:projectNameLabel];
		
		UILabel * text = [[UILabel alloc] initWithFrame:CGRectMake(100, 0, dvc_width - 130, 42)];
		[text setText:[theProject location]];
		[text setTextAlignment:NSTextAlignmentRight];
		[text setTextColor:[UIColor darkGrayColor]];
		[text setFont:HelveticaNeue(15)];
		[text setBackgroundColor:[UIColor clearColor]];
		[backgroundLabel addSubview:text];
	}
		
	// PAID
	{
		UIImageView *backgroundLabel = [[UIImageView alloc] initWithFrame:CGRectMake(10, 178, dvc_width - 20, 42)];
		[backgroundLabel setImage:[[UIImage imageNamed:@"tableMiddleCellWhite.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10]];
		[mainScrollView addSubview:backgroundLabel];
		
		UILabel *projectNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 178, dvc_width - 30, 42)];
		[projectNameLabel setBackgroundColor:[UIColor clearColor]];
		[projectNameLabel setText:@"Paid"];
		[projectNameLabel setTextColor:[UIColor grayColor]];
		[projectNameLabel setFont:HelveticaNeue(16)];
		[mainScrollView addSubview:projectNameLabel];

		if([[theProject paid] intValue] == 1)
		{
			UIImageView *arrow = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 16, 16)];
			[arrow setImage:[UIImage imageNamed:@"checkArrow.png"]];
			[arrow setCenter:CGPointMake(backgroundLabel.frame.size.width - 20, 21)];
			[backgroundLabel addSubview:arrow];
		}
	}
	
	// COMPLETED
	{
		UIImageView *backgroundLabel = [[UIImageView alloc] initWithFrame:CGRectMake(10, 220, dvc_width - 20, 42)];
		[backgroundLabel setImage:[[UIImage imageNamed:@"tableBottomCellWhite.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10]];
		[mainScrollView addSubview:backgroundLabel];
		
		UILabel *projectNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 220, dvc_width - 30, 42)];
		[projectNameLabel setBackgroundColor:[UIColor clearColor]];
		[projectNameLabel setText:@"Completed"];
		[projectNameLabel setTextColor:[UIColor grayColor]];
		[projectNameLabel setFont:HelveticaNeue(16)];
		[mainScrollView addSubview:projectNameLabel];
		
		if([[theProject completed] intValue] == 1)
		{
			UIImageView *arrow = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 16, 16)];
			[arrow setImage:[UIImage imageNamed:@"checkArrow.png"]];
			[arrow setCenter:CGPointMake(backgroundLabel.frame.size.width - 20, 21)];
			[backgroundLabel addSubview:arrow];
		}
	}
			
	[self.view addSubview:topBarView];
}

#pragma mark - FUNCTIONS

-(void)back:(UIButton*)sender
{
	[self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - SCROLLVIEW DELEGATE

-(void)scrollViewDidScroll:(UIScrollView*)scrollView
{
	if (mainScrollView && [mainScrollView respondsToSelector:@selector(didScroll)])
		[mainScrollView didScroll];
}

#pragma mark - VIEW CONTROLLER FUNCTIONS

-(void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
}

-(void)dealloc
{
	[mainScrollView setDelegate:nil];
}


@end
