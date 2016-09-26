//
//  TimesheetStatusVC.m
//  Invoice
//
//  Created by XGRoup on 7/22/14.
//  Copyright (c) 2014 XGRoup. All rights reserved.
//

#import "TimesheetStatusVC.h"

#import "Defines.h"
#import "TimesheetCell.h"
#import "CategorySelectV.h"

@interface TimesheetStatusVC () <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, CategorySelectDelegate>

@end

@implementation TimesheetStatusVC

-(id)initWithClient:(ClientOBJ *)client
{
	self = [super init];
	
	if(self)
	{
		array_with_timesheets = [[NSMutableArray alloc] initWithArray:[data_manager allTimesheetsForClient:client]];
				
		weekTimesheets  = [[NSMutableArray alloc] init];
		monthTimesheets = [[NSMutableArray alloc] init];
		yearTimesheets  = [[NSMutableArray alloc] init];
	}
	
	return self;
}

-(id)initWithProject:(ProjectOBJ *)project
{
	self = [super init];
	
	if(self)
	{
		array_with_timesheets = [[NSMutableArray alloc] initWithArray:[data_manager allTimesheetsForProject:project]];
		
		weekTimesheets	= [[NSMutableArray alloc] init];
		monthTimesheets	= [[NSMutableArray alloc] init];
		yearTimesheets	= [[NSMutableArray alloc] init];
	}
	
	return self;
}

#pragma mark - VIEW DID LOAD

-(void)viewDidLoad
{
	[super viewDidLoad];
	
	selected_section = kSectionWeek;
	
	theSelfView = [[UIView alloc] initWithFrame:CGRectMake(0, statusBarHeight, dvc_width, dvc_height)];
	[theSelfView setBackgroundColor:[UIColor clearColor]];
	[self.view addSubview:theSelfView];
	
	[self.view setBackgroundColor:app_background_color];
	
	topBarView = [[TopBar alloc] initWithFrame:CGRectMake(0, 0, dvc_width, 42 + statusBarHeight) andTitle:@"Timesheets Status"];
	[topBarView setBackgroundColor:app_bar_update_color];
	
	BackButton * backButton = [[BackButton alloc] initWithFrame:CGRectMake(0, 42 + statusBarHeight - 40, 70, 40) andTitle:@"Back"];
	[backButton addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
	[topBarView addSubview:backButton];
			
	[self createArrays];
	
	timesheetTableView = [[TableWithShadow alloc] initWithFrame:CGRectMake(0, theSelfView.frame.origin.y + 82 - statusBarHeight, dvc_width, dvc_height - 87 - 40) style:UITableViewStyleGrouped];
	[timesheetTableView setDelegate:self];
	[timesheetTableView setDataSource:self];
	[timesheetTableView setSeparatorColor:[UIColor clearColor]];
	[timesheetTableView setBackgroundColor:[UIColor clearColor]];
	[timesheetTableView setBackgroundView:nil];
	[timesheetTableView setTableHeaderView:[[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)]];
	[theSelfView addSubview:timesheetTableView];
	
	[(TableWithShadow*)timesheetTableView setUpperShadowAlpha:1.0];
	
	[self.view addSubview:topBarView];
	
	categoryBar = [[CategorySelectV alloc] initWithFrame:CGRectMake(0, theSelfView.frame.origin.y + 52 - statusBarHeight, dvc_width, 30) andType:kTimesheetSelect andDelegate:self];
	categoryBar.backgroundColor = [UIColor clearColor];
	[theSelfView addSubview:categoryBar];
}

-(void)createArrays
{
	[weekTimesheets removeAllObjects];
	[monthTimesheets removeAllObjects];
	[yearTimesheets removeAllObjects];
	
	for(TimeSheetOBJ *timesheet in array_with_timesheets)
	{
		NSDate *receiptDate = [timesheet date];
		
		switch (selected_section)
		{
			case kSectionWeek:
			{
				NSDate *firstDay = [data_manager getFirstDayOfWeek];
				NSDate *lastDay = [data_manager getLastDayOfWeek];
				
				int firstCompare = [data_manager compareDate:firstDay withEndDate:receiptDate];
				int secondCompare = [data_manager compareDate:receiptDate withEndDate:lastDay];
				
				if((firstCompare == -1 && secondCompare == -1) || firstCompare == 0 || secondCompare == 0)
				{
					[weekTimesheets addObject:timesheet];
				}
				
				break;
			}
				
			case kSectionMonth:
			{
				NSDate *firstDay = [data_manager getFirstDayOfMonth];
				NSDate *lastDay = [data_manager getLastDayOfMonth];
				
				int firstCompare = [data_manager compareDate:firstDay withEndDate:receiptDate];
				int secondCompare = [data_manager compareDate:receiptDate withEndDate:lastDay];
				
				if((firstCompare == -1 && secondCompare == -1) || firstCompare == 0 || secondCompare == 0)
				{
					[monthTimesheets addObject:timesheet];
				}
				
				break;
			}
				
			case kSectionYear:
			{
				NSDate *firstDay = [data_manager getFirstDayOfYear];
				NSDate *lastDay = [data_manager getLastDayOfYear];
				
				int firstCompare = [data_manager compareDate:firstDay withEndDate:receiptDate];
				int secondCompare = [data_manager compareDate:receiptDate withEndDate:lastDay];
				
				if((firstCompare == -1 && secondCompare == -1) || firstCompare == 0 || secondCompare == 0)
				{
					[yearTimesheets addObject:timesheet];
				}
				
				break;
			}
				
			default:
				break;
		}
	}
}

#pragma mark - TABLE VIEW DATASOURCE

-(NSInteger)numberOfSectionsInTableView:(UITableView*)tableView
{
	return 1;
}

-(NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
	NSInteger nrRows = 0;
	
	switch (selected_section)
	{
		case kSectionWeek:
		{
			nrRows = weekTimesheets.count;
			break;
		}
			
		case kSectionMonth:
		{
			nrRows = monthTimesheets.count;
			break;
		}
			
		case kSectionYear:
		{
			nrRows = yearTimesheets.count;
			break;
		}
			
		default:
			break;
	}
	
	return nrRows;
}

-(UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
	TimesheetCell * theCell = [tableView dequeueReusableCellWithIdentifier:nil];
	
	if (!theCell)
	{
		theCell = [[TimesheetCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
	}
	
	switch (selected_section)
	{
		case kSectionWeek:
		{
			kCellType type = kCellTypeMiddle;
			
			if (indexPath.row == 0)
			{
				if (weekTimesheets.count == 1)
				{
					type = kCellTypeSingle;
				}
				else
				{
					type = kCellTypeTop;
				}
			}
			else if (indexPath.row == weekTimesheets.count - 1)
			{
				type = kCellTypeBottom;
			}
			
			[theCell loadTimesheet:[weekTimesheets objectAtIndex:indexPath.row] withCellType:type];
			
			break;
		}
			
		case kSectionMonth:
		{
			kCellType type = kCellTypeMiddle;
			
			if (indexPath.row == 0)
			{
				if (monthTimesheets.count == 1)
				{
					type = kCellTypeSingle;
				}
				else
				{
					type = kCellTypeTop;
				}
			}
			else if (indexPath.row == monthTimesheets.count - 1)
			{
				type = kCellTypeBottom;
			}
			
			[theCell loadTimesheet:[monthTimesheets objectAtIndex:indexPath.row] withCellType:type];
			
			break;
		}
			
		case kSectionYear:
		{
			kCellType type = kCellTypeMiddle;
			
			if (indexPath.row == 0)
			{
				if (yearTimesheets.count == 1)
				{
					type = kCellTypeSingle;
				}
				else
				{
					type = kCellTypeTop;
				}
			}
			else if (indexPath.row == yearTimesheets.count - 1)
			{
				type = kCellTypeBottom;
			}
			
			[theCell loadTimesheet:[yearTimesheets objectAtIndex:indexPath.row] withCellType:type];
			
			break;
		}
			
		default:
			break;
	}
	
	if ([tableView isKindOfClass:[TableWithShadow class]])
	{
		[(TableWithShadow*)tableView didScroll];
	}
	
	return theCell;
}

-(void)tableView:(UITableView*)tableView willDisplayCell:(UITableViewCell*)cell forRowAtIndexPath:(NSIndexPath*)indexPath
{
	if (indexPath.row == 0)
	{
		if ([cell respondsToSelector:@selector(resize)])
		{
			[(TimesheetCell*)cell resize];
		}
	}
}

#pragma mark - TABLE VIEW DELEGATE

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	if(selected_section == kSectionWeek)
	{
		if(weekTimesheets.count == 0)
			return 0.0f;
	}
	else
		if(selected_section == kSectionMonth)
		{
			if(monthTimesheets.count == 0)
				return 0.0f;
		}
		else
			if(selected_section == kSectionYear)
			{
				if(yearTimesheets.count == 0)
					return 0.0f;
			}
	
	return 30.0f;
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 30)];
	view.backgroundColor = [UIColor clearColor];
	
	UILabel * title = [[UILabel alloc] initWithFrame:CGRectMake(22, 10, dvc_width - 44, 20)];
	[title setTextAlignment:NSTextAlignmentLeft];
	[title setTextColor:app_title_color];
	[title setFont:HelveticaNeueMedium(15)];
	[title setBackgroundColor:[UIColor clearColor]];
	[view addSubview:title];
	
	NSString *timeWorked = @"";
	
	if(selected_section == kSectionWeek)
	{
		timeWorked = [data_manager getTotalHoursForThisWeek:array_with_timesheets];
	}
	else
	if(selected_section == kSectionMonth)
	{
		timeWorked = [data_manager getTotalHoursForThisMonth:array_with_timesheets];
	}
	else
	if(selected_section == kSectionYear)
	{
		timeWorked = [data_manager getTotalHoursForThisYear:array_with_timesheets];
	}
	
	timeWorked = [NSString stringWithFormat:@"Total time worked: %@",timeWorked];
	
	[title setText:timeWorked];
	
	return view;
}

-(CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
	if (indexPath.row == 0)
	{
		return 94.0f;
	}
	else
	{
		return 84.0f;
	}
}

#pragma mark - SCROLL VIEW DELEGATE

-(void)scrollViewDidScroll:(UIScrollView*)scrollView
{
	if ([scrollView isKindOfClass:[TableWithShadow class]])
		[(TableWithShadow*)scrollView didScroll];
}

#pragma mark - CATEGORY SELECT DELEGATE

-(void)categorySelectDelegate:(CategorySelectV*)view selectedCategory:(int)category
{
	if(category == 1)
		selected_section = kSectionWeek;
	else
		if(category == 2)
			selected_section = kSectionMonth;
		else
			if(category == 3)
				selected_section = kSectionYear;
	
	[self createArrays];
	
	[timesheetTableView reloadData];
}

#pragma mark - FUNCTIONS

-(void)back:(UIButton*)sender
{
	[self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - VIEW CONTROLLER FUNCTIONS

-(void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	[self createArrays];
	
	[timesheetTableView reloadData];
}

-(void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
}

-(void)dealloc
{
	[timesheetTableView setDelegate:nil];
}

@end
