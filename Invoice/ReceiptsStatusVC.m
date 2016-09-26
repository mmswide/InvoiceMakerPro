//
//  ReceiptsStatusVC.m
//  Invoice
//
//  Created by XGRoup on 7/22/14.
//  Copyright (c) 2014 XGRoup. All rights reserved.
//

#import "ReceiptsStatusVC.h"

#import "Defines.h"
#import "ReceiptCell.h"

@interface ReceiptsStatusVC () <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, CategorySelectDelegate>

@end

@implementation ReceiptsStatusVC

-(id)initWithClient:(ClientOBJ*)sender
{
	self = [super init];
	
	if (self)
	{
		theClient = sender;
		
		array_with_receipts = [[NSMutableArray alloc] initWithArray:[data_manager allReceiptsForClient:theClient]];
		
		weekReceipts = [[NSMutableArray alloc] init];
		monthReceipts = [[NSMutableArray alloc] init];
		yearReceipts = [[NSMutableArray alloc] init];
	}
	
	return self;
}

-(id)initWithProject:(ProjectOBJ*)sender
{
	self = [super init];
	
	if(self)
	{
		theProject = sender;
		
		array_with_receipts = [[NSMutableArray alloc] initWithArray:[data_manager allReceiptsForProject:theProject]];
		
		weekReceipts = [[NSMutableArray alloc] init];
		monthReceipts = [[NSMutableArray alloc] init];
		yearReceipts = [[NSMutableArray alloc] init];
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
	
	topBarView = [[TopBar alloc] initWithFrame:CGRectMake(0, 0, dvc_width, 42 + statusBarHeight) andTitle:@"Receipts Status"];
	[topBarView setBackgroundColor:app_bar_update_color];
	
	BackButton * backButton = [[BackButton alloc] initWithFrame:CGRectMake(0, 42 + statusBarHeight - 40, 70, 40) andTitle:@"Back"];
	[backButton addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
	[topBarView addSubview:backButton];
			
	[self createArrays];
	
	receiptTableView = [[TableWithShadow alloc] initWithFrame:CGRectMake(0, theSelfView.frame.origin.y + 82 - statusBarHeight, dvc_width, dvc_height - 87 - 40) style:UITableViewStyleGrouped];
	[receiptTableView setDelegate:self];
	[receiptTableView setDataSource:self];
	[receiptTableView setSeparatorColor:[UIColor clearColor]];
	[receiptTableView setBackgroundColor:[UIColor clearColor]];
	[receiptTableView setBackgroundView:nil];
	[receiptTableView setTableHeaderView:[[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)]];
	[theSelfView addSubview:receiptTableView];
	
	[(TableWithShadow*)receiptTableView setUpperShadowAlpha:1.0];
	
	[self.view addSubview:topBarView];
	
	categoryBar = [[CategorySelectV alloc] initWithFrame:CGRectMake(0, theSelfView.frame.origin.y + 52 - statusBarHeight, dvc_width, 30) andType:kReceiptSelect andDelegate:self];
	categoryBar.backgroundColor = [UIColor clearColor];
	[theSelfView addSubview:categoryBar];
}

-(void)createArrays
{
	[weekReceipts removeAllObjects];
	[monthReceipts removeAllObjects];
	[yearReceipts removeAllObjects];
	
	for(ReceiptOBJ *receipt in array_with_receipts)
	{
		NSDate *receiptDate = [receipt date];
		
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
					[weekReceipts addObject:receipt];
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
					[monthReceipts addObject:receipt];
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
					[yearReceipts addObject:receipt];
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
			nrRows = weekReceipts.count;
			break;
		}
			
		case kSectionMonth:
		{
			nrRows = monthReceipts.count;
			break;
		}
			
		case kSectionYear:
		{
			nrRows = yearReceipts.count;
			break;
		}
			
		default:
			break;
	}
	
	return nrRows;
}

-(UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
	ReceiptCell * theCell = [tableView dequeueReusableCellWithIdentifier:nil];
	
	if (!theCell)
	{
		theCell = [[ReceiptCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
	}
	
	switch (selected_section)
	{
		case kSectionWeek:
		{
			kCellType type = kCellTypeMiddle;
			
			if (indexPath.row == 0)
			{
				if (weekReceipts.count == 1)
				{
					type = kCellTypeSingle;
				}
				else
				{
					type = kCellTypeTop;
				}
			}
			else if (indexPath.row == weekReceipts.count - 1)
			{
				type = kCellTypeBottom;
			}
			
			[theCell loadReceipt:[weekReceipts objectAtIndex:indexPath.row] withCellType:type];
			
			break;
		}
			
		case kSectionMonth:
		{
			kCellType type = kCellTypeMiddle;
			
			if (indexPath.row == 0)
			{
				if (monthReceipts.count == 1)
				{
					type = kCellTypeSingle;
				}
				else
				{
					type = kCellTypeTop;
				}
			}
			else if (indexPath.row == monthReceipts.count - 1)
			{
				type = kCellTypeBottom;
			}
			
			[theCell loadReceipt:[monthReceipts objectAtIndex:indexPath.row] withCellType:type];
			
			break;
		}
			
		case kSectionYear:
		{
			kCellType type = kCellTypeMiddle;
			
			if (indexPath.row == 0)
			{
				if (yearReceipts.count == 1)
				{
					type = kCellTypeSingle;
				}
				else
				{
					type = kCellTypeTop;
				}
			}
			else if (indexPath.row == yearReceipts.count - 1)
			{
				type = kCellTypeBottom;
			}
			
			[theCell loadReceipt:[yearReceipts objectAtIndex:indexPath.row] withCellType:type];
			
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
			[(ReceiptCell*)cell resize];
		}
	}
}

#pragma mark - TABLE VIEW DELEGATE

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
	
	[receiptTableView reloadData];
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
	
	[receiptTableView reloadData];
}

-(void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
}

-(void)dealloc
{
	[receiptTableView setDelegate:nil];
}

@end
