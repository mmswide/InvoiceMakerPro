//
//  EstimatesStatusVC.m
//  Invoice
//
//  Created by XGRoup5 on 8/22/13.
//  Copyright (c) 2013 XGRoup. All rights reserved.
//

#import "EstimatesStatusVC.h"

#import "Defines.h"
#import "ESTCell.h"

@interface EstimatesStatusVC () <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate>

@end

@implementation EstimatesStatusVC

-(id)initWithClient:(ClientOBJ*)sender
{
	self = [super init];
	
	if (self)
	{
		theClient = sender;		
		estimates_array = [[NSArray alloc] initWithArray:[data_manager allEstimatesForClient:theClient]];
	}
	
	return self;
}
-(id)initWithProject:(ProjectOBJ *)sender
{
	self = [super init];
	
	if(self)
	{
		theProject = sender;
		estimates_array = [[NSArray alloc] initWithArray:[data_manager allEstimatesForProject:theProject]];
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
	
	topBarView = [[TopBar alloc] initWithFrame:CGRectMake(0, 0, dvc_width, 42 + statusBarHeight) andTitle:@"Estimates Status"];
	[topBarView setBackgroundColor:app_bar_update_color];
	
	BackButton * backButton = [[BackButton alloc] initWithFrame:CGRectMake(0, 42 + statusBarHeight - 40, 70, 40) andTitle:@"Back"];
	[backButton addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
	[topBarView addSubview:backButton];
	
	mainTableView = [[TableWithShadow alloc] initWithFrame:CGRectMake(0, 42, dvc_width, dvc_height - 87) style:UITableViewStyleGrouped];
	[mainTableView setDelegate:self];
	[mainTableView setDataSource:self];
	[mainTableView setBackgroundColor:[UIColor clearColor]];
	[mainTableView setSeparatorColor:[UIColor clearColor]];
	[theSelfView addSubview:mainTableView];
	
	UIView * bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, dvc_width, dvc_height - 87)];
	[bgView setBackgroundColor:[UIColor clearColor]];
	[mainTableView setBackgroundView:bgView];
	
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
	if (mainTableView && [mainTableView respondsToSelector:@selector(didScroll)])
		[mainTableView didScroll];
}

#pragma mark - TABLEVIEW DATASOURCE

-(NSInteger)numberOfSectionsInTableView:(UITableView*)tableView
{
	return 1;
}

-(NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
	return estimates_array.count;
}

-(UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
	ESTCell * theCell = [tableView dequeueReusableCellWithIdentifier:@"estimateCell"];
	
	if (!theCell)
	{
		theCell = [[ESTCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"estimateCell"];
	}
	
	kEstimateCellType type = kEstimateCellTypeMiddle;
	
	if (indexPath.row == 0)
	{
		if (estimates_array.count == 1)
		{
			type = kEstimateCellTypeSingle;
		}
		else
		{
			type = kEstimateCellTypeTop;
		}
	}
	else if (indexPath.row == estimates_array.count - 1)
	{
		type = kEstimateCellTypeBottom;
	}
	
	[theCell loadEstimate:[estimates_array objectAtIndex:indexPath.row] withCellType:type];
	
	if ([tableView isKindOfClass:[TableWithShadow class]])
	{
		[(TableWithShadow*)tableView didScroll];
	}
	
	theCell.backgroundColor = [UIColor clearColor];
	return theCell;
}

-(UIView*)tableView:(UITableView*)tableView viewForHeaderInSection:(NSInteger)section
{
	UIView * view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, dvc_width, 30)];
	[view setBackgroundColor:[UIColor clearColor]];
	
	UILabel * title = [[UILabel alloc] initWithFrame:CGRectMake(22, 0, dvc_width - 44, 30)];
	[title setText:@"Estimates"];
	[title setTextAlignment:NSTextAlignmentLeft];
	[title setTextColor:app_title_color];
	[title setFont:HelveticaNeueMedium(15)];
	[title setBackgroundColor:[UIColor clearColor]];
	[view addSubview:title];
	
	if (estimates_array.count == 0)
		[title setText:@"Estimates (none for now)"];
	
	return view;
}

#pragma mark - TABLEVIEW DELEGATE

-(CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
	return 84.0f;
}

-(CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section
{
	return 42.0f;
}

#pragma mark - VIEW CONTROLLER FUNCTIONS

-(void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
}

-(void)dealloc
{
	[mainTableView setDelegate:nil];
}

@end