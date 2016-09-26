//
//  InvoicesStatusVC.m
//  Invoice
//
//  Created by XGRoup5 on 8/22/13.
//  Copyright (c) 2013 XGRoup. All rights reserved.
//

#import "InvoicesStatusVC.h"

#import "Defines.h"
#import "INVCell.h"

@interface InvoicesStatusVC () <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, CategorySelectDelegate>

@end

@implementation InvoicesStatusVC

-(id)initWithClient:(ClientOBJ*)sender
{
	self = [super init];
	
	if (self)
	{
		theClient = sender;

		overdue_invoices_array = [[NSArray alloc] initWithArray:[data_manager overdueInvoicesForClient:theClient]];
		current_invoices_array = [[NSArray alloc] initWithArray:[data_manager currentInvoicesForClient:theClient]];
		paid_invoices_array = [[NSArray alloc] initWithArray:[data_manager paidInvoicesForClient:theClient]];
	}
	
	return self;
}

-(id)initWithProject:(ProjectOBJ*)sender
{
	self = [super init];
	
	if(self)
	{
		theProject = sender;
		
		overdue_invoices_array = [[NSArray alloc] initWithArray:[data_manager overdueInvoicesForProject:theProject]];
		current_invoices_array = [[NSArray alloc] initWithArray:[data_manager currentInvoicesForProject:theProject]];
		paid_invoices_array = [[NSArray alloc] initWithArray:[data_manager paidInvoicesForProject:theProject]];
	}
	
	return self;
}

#pragma mark - VIEW DID LOAD

-(void)viewDidLoad
{
	[super viewDidLoad];
	
	categorySelected = 1;
	
	theSelfView = [[UIView alloc] initWithFrame:CGRectMake(0, statusBarHeight, dvc_width, dvc_height)];
	[theSelfView setBackgroundColor:[UIColor clearColor]];
	[self.view addSubview:theSelfView];
		
	[self.view setBackgroundColor:app_background_color];
	
	topBarView = [[TopBar alloc] initWithFrame:CGRectMake(0, 0, dvc_width, 42 + statusBarHeight) andTitle:@"Invoices Status"];
	[topBarView setBackgroundColor:app_bar_update_color];
	
	BackButton * backButton = [[BackButton alloc] initWithFrame:CGRectMake(0, 42 + statusBarHeight - 40, 70, 40) andTitle:@"Back"];
	[backButton addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
	[topBarView addSubview:backButton];
	
	mainTableView = [[TableWithShadow alloc] initWithFrame:CGRectMake(0, 42 + 40, dvc_width, dvc_height - 87 - 40) style:UITableViewStylePlain];
	[mainTableView setDelegate:self];
	[mainTableView setDataSource:self];
	[mainTableView setBackgroundColor:[UIColor clearColor]];
	[mainTableView setSeparatorColor:[UIColor clearColor]];
	[theSelfView addSubview:mainTableView];
	
	UIView * bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, dvc_width, dvc_height - 87)];
	[bgView setBackgroundColor:[UIColor clearColor]];
	[mainTableView setBackgroundView:bgView];
	
	[self.view addSubview:topBarView];
	
	categoryBar = [[CategorySelectV alloc] initWithFrame:CGRectMake(0, theSelfView.frame.origin.y + 52 - statusBarHeight, dvc_width, 30) andType:kInvoiceSelect andDelegate:self];
	categoryBar.backgroundColor = [UIColor clearColor];
	[theSelfView addSubview:categoryBar];
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
	if(categorySelected == 1)
		return overdue_invoices_array.count;
	
	if(categorySelected == 2)
		return current_invoices_array.count;
	
	return paid_invoices_array.count;
}

-(UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
	INVCell * theCell = [tableView dequeueReusableCellWithIdentifier:@"invoiceCell"];
	
	if (!theCell)
	{
		theCell = [[INVCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"invoiceCell"];
	}
	
	if(categorySelected == 1)
	{
		kInvoiceCellType type = kInvoiceCellTypeMiddle;
		
		if (indexPath.row == 0)
		{
			if (overdue_invoices_array.count == 1)
			{
				type = kInvoiceCellTypeSingle;
			}
			else
			{
				type = kInvoiceCellTypeTop;
			}
		}
		else if (indexPath.row == overdue_invoices_array.count - 1)
		{
			type = kInvoiceCellTypeBottom;
		}
		
		[theCell loadInvoice:[overdue_invoices_array objectAtIndex:indexPath.row] withCellType:type];
	}
	else
	if(categorySelected == 2)
	{
		kInvoiceCellType type = kInvoiceCellTypeMiddle;
		
		if (indexPath.row == 0)
		{
			if (current_invoices_array.count == 1)
			{
				type = kInvoiceCellTypeSingle;
			}
			else
			{
				type = kInvoiceCellTypeTop;
			}
		}
		else if (indexPath.row == current_invoices_array.count - 1)
		{
			type = kInvoiceCellTypeBottom;
		}
		
		[theCell loadInvoice:[current_invoices_array objectAtIndex:indexPath.row] withCellType:type];
	}
	else
	{
		kInvoiceCellType type = kInvoiceCellTypeMiddle;
		
		if (indexPath.row == 0)
		{
			if (paid_invoices_array.count == 1)
			{
				type = kInvoiceCellTypeSingle;
			}
			else
			{
				type = kInvoiceCellTypeTop;
			}
		}
		else if (indexPath.row == paid_invoices_array.count - 1)
		{
			type = kInvoiceCellTypeBottom;
		}
		
		[theCell loadInvoice:[paid_invoices_array objectAtIndex:indexPath.row] withCellType:type];

	}
	
		
	if ([tableView isKindOfClass:[TableWithShadow class]])
	{
		[(TableWithShadow*)tableView didScroll];
	}
	
	return theCell;
}

#pragma mark - CATEGORY BAR DELEGATE

-(void)categorySelectDelegate:(CategorySelectV *)view selectedCategory:(int)category
{
	categorySelected = category;
		
	[mainTableView reloadData];
}

#pragma mark - TABLEVIEW DELEGATE

-(void)tableView:(UITableView*)tableView willDisplayCell:(UITableViewCell*)cell forRowAtIndexPath:(NSIndexPath*)indexPath
{
	if (indexPath.row == 0)
	{
		if ([cell respondsToSelector:@selector(resize)])
		{
			[(INVCell*)cell resize];
		}
	}
}

-(CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
	if(indexPath.row == 0)
		return 94.0f;
	
	return 84.0f;
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