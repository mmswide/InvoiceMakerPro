//
//  ProjectDetailVC.m
//  Invoice
//
//  Created by Paul on 17/06/14.
//  Copyright (c) 2014 XGRoup. All rights reserved.
//

#import "ProjectDetailVC.h"

#import "CreateOrEditProjectVC.h"
#import "ProjectContactDetailVC.h"
#import "InvoicesStatusVC.h"
#import "QuotesStatusVC.h"
#import "EstimatesStatusVC.h"
#import "PurchaseOrdersStatusVC.h"
#import "ReceiptsStatusVC.h"
#import "TimesheetStatusVC.h"

@interface ProjectDetailVC () <ProjectCreatorDelegate,UIScrollViewDelegate>

@end

@implementation ProjectDetailVC

-(id)initWithProject:(ProjectOBJ*)project andIndex:(NSInteger)index
{
	self = [super init];
	
	if(self)
	{
		theProject = project;
		project_index = index;
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
	
	UIButton * edit = [[UIButton alloc] initWithFrame:CGRectMake(dvc_width - 60, 42 + statusBarHeight - 40, 60, 40)];
	[edit setTitle:@"Edit" forState:UIControlStateNormal];
	[edit setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[edit setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
	[edit.titleLabel setFont:HelveticaNeueLight(17)];
	[edit addTarget:self action:@selector(edit:) forControlEvents:UIControlEventTouchUpInside];
	[topBarView addSubview:edit];
	
	mainScrollView = [[ScrollWithShadow alloc] initWithFrame:CGRectMake(0, 42, dvc_width, dvc_height - 87)];
	[mainScrollView setBackgroundColor:[UIColor clearColor]];
	[mainScrollView setDelegate:self];
	[theSelfView addSubview:mainScrollView];
	
	//NAME AND COMPANY
	{
		UIImageView * bg = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, dvc_width - 20, 64)];
		[bg setImage:[[UIImage imageNamed:@"tableSingleCellWhite.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10]];
		[mainScrollView addSubview:bg];
		
		nameTextField = [[UITextField alloc] initWithFrame:CGRectMake(20, 10, dvc_width - 40, 32)];
		[nameTextField setText:[NSString stringWithFormat:@"%@", [theProject projectName]]];
		[nameTextField setTextAlignment:NSTextAlignmentLeft];
		[nameTextField setTextColor:[UIColor darkGrayColor]];
		[nameTextField setFont:HelveticaNeue(16)];
		[nameTextField setBackgroundColor:[UIColor clearColor]];
		[nameTextField setReturnKeyType:UIReturnKeyDone];
		[nameTextField setUserInteractionEnabled:NO];
		[mainScrollView addSubview:nameTextField];
		
		companyTextField = [[UITextField alloc] initWithFrame:CGRectMake(20, 42, dvc_width - 40, 32)];
		[companyTextField setText:[theProject projectNumber]];
		[companyTextField setTextAlignment:NSTextAlignmentLeft];
		[companyTextField setTextColor:[UIColor grayColor]];
		[companyTextField setFont:HelveticaNeue(15)];
		[companyTextField setBackgroundColor:[UIColor clearColor]];
		[companyTextField setReturnKeyType:UIReturnKeyDone];
		[companyTextField setUserInteractionEnabled:NO];
		[mainScrollView addSubview:companyTextField];
	}
	
	//CONTACT
	{
		UIButton * contactDetails = [[UIButton alloc] initWithFrame:CGRectMake(10, 88, dvc_width - 20, 42)];
		[contactDetails setBackgroundImage:[[UIImage imageNamed:@"tableSingleCellWhite.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10] forState:UIControlStateNormal];
		[contactDetails addTarget:self action:@selector(openContactDetails:) forControlEvents:UIControlEventTouchUpInside];
		[contactDetails setTitle:@"Project Details" forState:UIControlStateNormal];
		[contactDetails setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
		[contactDetails.titleLabel setFont:HelveticaNeue(16)];
		[contactDetails setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
		[contactDetails setTitleEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
		[mainScrollView addSubview:contactDetails];
		
		UIImageView * arrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cellArrow.png"]];
		[arrow setCenter:CGPointMake(dvc_width - 30, 21)];
		[contactDetails addSubview:arrow];
	}
	
	kApplicationVersion version = app_version;
	
	switch (version)
	{
		case kApplicationVersionInvoice:
		{
			[mainScrollView setContentSize:CGSizeMake(mainScrollView.frame.size.width, 440)];
			
			//INVOICES
			{
				UIButton * invoices = [[UIButton alloc] initWithFrame:CGRectMake(10, 144, dvc_width - 20, 42)];
				[invoices setBackgroundImage:[[UIImage imageNamed:@"tableTopCellWhite.png"] stretchableImageWithLeftCapWidth:20 topCapHeight:15] forState:UIControlStateNormal];
				[invoices addTarget:self action:@selector(openInvoices:) forControlEvents:UIControlEventTouchUpInside];
				[invoices setTitle:@"Invoices Status" forState:UIControlStateNormal];
				[invoices setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
				[invoices.titleLabel setFont:HelveticaNeue(16)];
				[invoices setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
				[invoices setTitleEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
				[mainScrollView addSubview:invoices];
				
				UIImageView * arrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cellArrow.png"]];
				[arrow setCenter:CGPointMake(dvc_width - 30, 21)];
				[invoices addSubview:arrow];
			}
			
			//QUOTES
			{
				UIButton * quotes = [[UIButton alloc] initWithFrame:CGRectMake(10, 186, dvc_width - 20, 42)];
				[quotes setBackgroundImage:[[UIImage imageNamed:@"tableMiddleCellWhite.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10] forState:UIControlStateNormal];
				[quotes addTarget:self action:@selector(openQuotes:) forControlEvents:UIControlEventTouchUpInside];
				[quotes setTitle:@"Quotes" forState:UIControlStateNormal];
				[quotes setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
				[quotes.titleLabel setFont:HelveticaNeue(16)];
				[quotes setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
				[quotes setTitleEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
				[mainScrollView addSubview:quotes];
				
				UIImageView * arrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cellArrow.png"]];
				[arrow setCenter:CGPointMake(dvc_width - 30, 21)];
				[quotes addSubview:arrow];
			}
			
			//ESTIMATES
			{
				UIButton * estimates = [[UIButton alloc] initWithFrame:CGRectMake(10, 228, dvc_width - 20, 42)];
				[estimates setBackgroundImage:[[UIImage imageNamed:@"tableMiddleCellWhite.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10] forState:UIControlStateNormal];
				[estimates addTarget:self action:@selector(openEstimates:) forControlEvents:UIControlEventTouchUpInside];
				[estimates setTitle:@"Estimates" forState:UIControlStateNormal];
				[estimates setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
				[estimates.titleLabel setFont:HelveticaNeue(16)];
				[estimates setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
				[estimates setTitleEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
				[mainScrollView addSubview:estimates];
				
				UIImageView * arrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cellArrow.png"]];
				[arrow setCenter:CGPointMake(dvc_width - 30, 21)];
				[estimates addSubview:arrow];
			}
			
			//PURCHASE ORDERS
			{
				UIButton * purchaseOrders = [[UIButton alloc] initWithFrame:CGRectMake(10, 270, dvc_width - 20, 42)];
				[purchaseOrders setBackgroundImage:[[UIImage imageNamed:@"tableMiddleCellWhite.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10] forState:UIControlStateNormal];
				[purchaseOrders addTarget:self action:@selector(openPurchaseOrders:) forControlEvents:UIControlEventTouchUpInside];
				[purchaseOrders setTitle:@"Purchase Orders" forState:UIControlStateNormal];
				[purchaseOrders setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
				[purchaseOrders.titleLabel setFont:HelveticaNeue(16)];
				[purchaseOrders setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
				[purchaseOrders setTitleEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
				[mainScrollView addSubview:purchaseOrders];
				
				UIImageView * arrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cellArrow.png"]];
				[arrow setCenter:CGPointMake(dvc_width - 30, 21)];
				[purchaseOrders addSubview:arrow];
			}
			
			//Receipts
			{
				UIButton * receipts = [[UIButton alloc] initWithFrame:CGRectMake(10, 312, dvc_width - 20, 42)];
				[receipts setBackgroundImage:[[UIImage imageNamed:@"tableMiddleCellWhite.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10] forState:UIControlStateNormal];
				[receipts addTarget:self action:@selector(openReceipts:) forControlEvents:UIControlEventTouchUpInside];
				[receipts setTitle:@"Receipts" forState:UIControlStateNormal];
				[receipts setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
				[receipts.titleLabel setFont:HelveticaNeue(16)];
				[receipts setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
				[receipts setTitleEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
				[mainScrollView addSubview:receipts];
				
				UIImageView * arrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cellArrow.png"]];
				[arrow setCenter:CGPointMake(dvc_width - 30, 21)];
				[receipts addSubview:arrow];
			}
			
			//Timesheets
			{
				UIButton * timesheets = [[UIButton alloc] initWithFrame:CGRectMake(10, 354, dvc_width - 20, 42)];
				[timesheets setBackgroundImage:[[UIImage imageNamed:@"tableBottomCellWhite.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10] forState:UIControlStateNormal];
				[timesheets addTarget:self action:@selector(openTimesheets:) forControlEvents:UIControlEventTouchUpInside];
				[timesheets setTitle:@"Timesheets" forState:UIControlStateNormal];
				[timesheets setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
				[timesheets.titleLabel setFont:HelveticaNeue(16)];
				[timesheets setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
				[timesheets setTitleEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
				[mainScrollView addSubview:timesheets];
				
				UIImageView * arrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cellArrow.png"]];
				[arrow setCenter:CGPointMake(dvc_width - 30, 21)];
				[timesheets addSubview:arrow];
			}
			
			break;
		}
			
		case kApplicationVersionQuote:
		{
			UIButton * quotes = [[UIButton alloc] initWithFrame:CGRectMake(10, 144, dvc_width - 20, 42)];
			[quotes setBackgroundImage:[[UIImage imageNamed:@"tableSingleCellWhite.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10] forState:UIControlStateNormal];
			[quotes addTarget:self action:@selector(openQuotes:) forControlEvents:UIControlEventTouchUpInside];
			[quotes setTitle:@"Quotes" forState:UIControlStateNormal];
			[quotes setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
			[quotes.titleLabel setFont:HelveticaNeue(16)];
			[quotes setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
			[quotes setTitleEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
			[mainScrollView addSubview:quotes];
			
			UIImageView * arrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cellArrow.png"]];
			[arrow setCenter:CGPointMake(dvc_width - 30, 21)];
			[quotes addSubview:arrow];
			
			break;
		}
			
		case kApplicationVersionEstimate:
		{
			UIButton * estimates = [[UIButton alloc] initWithFrame:CGRectMake(10, 144, dvc_width - 20, 42)];
			[estimates setBackgroundImage:[[UIImage imageNamed:@"tableSingleCellWhite.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10] forState:UIControlStateNormal];
			[estimates addTarget:self action:@selector(openEstimates:) forControlEvents:UIControlEventTouchUpInside];
			[estimates setTitle:@"Estimates" forState:UIControlStateNormal];
			[estimates setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
			[estimates.titleLabel setFont:HelveticaNeue(16)];
			[estimates setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
			[estimates setTitleEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
			[mainScrollView addSubview:estimates];
			
			UIImageView * arrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cellArrow.png"]];
			[arrow setCenter:CGPointMake(dvc_width - 30, 21)];
			[estimates addSubview:arrow];
			
			break;
		}
			
		case kApplicationVersionPurchase:
		{
			UIButton * purchaseOrders = [[UIButton alloc] initWithFrame:CGRectMake(10, 144, dvc_width - 20, 42)];
			[purchaseOrders setBackgroundImage:[[UIImage imageNamed:@"tableSingleCellWhite.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10] forState:UIControlStateNormal];
			[purchaseOrders addTarget:self action:@selector(openPurchaseOrders:) forControlEvents:UIControlEventTouchUpInside];
			[purchaseOrders setTitle:@"Purchase Orders" forState:UIControlStateNormal];
			[purchaseOrders setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
			[purchaseOrders.titleLabel setFont:HelveticaNeue(16)];
			[purchaseOrders setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
			[purchaseOrders setTitleEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
			[mainScrollView addSubview:purchaseOrders];
			
			UIImageView * arrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cellArrow.png"]];
			[arrow setCenter:CGPointMake(dvc_width - 30, 21)];
			[purchaseOrders addSubview:arrow];
			
			break;
		}
			
		case kApplicationVersionReceipts:
		{
			UIButton * receipts = [[UIButton alloc] initWithFrame:CGRectMake(10, 144, dvc_width - 20, 42)];
			[receipts setBackgroundImage:[[UIImage imageNamed:@"tableSingleCellWhite.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10] forState:UIControlStateNormal];
			[receipts addTarget:self action:@selector(openReceipts:) forControlEvents:UIControlEventTouchUpInside];
			[receipts setTitle:@"Receipts" forState:UIControlStateNormal];
			[receipts setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
			[receipts.titleLabel setFont:HelveticaNeue(16)];
			[receipts setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
			[receipts setTitleEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
			[mainScrollView addSubview:receipts];
			
			UIImageView * arrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cellArrow.png"]];
			[arrow setCenter:CGPointMake(dvc_width - 30, 21)];
			[receipts addSubview:arrow];
			
			break;
		}
			
		case kApplicationVersionTimesheets:
		{
			UIButton * timesheets = [[UIButton alloc] initWithFrame:CGRectMake(10, 144, dvc_width - 20, 42)];
			[timesheets setBackgroundImage:[[UIImage imageNamed:@"tableSingleCellWhite.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10] forState:UIControlStateNormal];
			[timesheets addTarget:self action:@selector(openTimesheets:) forControlEvents:UIControlEventTouchUpInside];
			[timesheets setTitle:@"Timesheets" forState:UIControlStateNormal];
			[timesheets setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
			[timesheets.titleLabel setFont:HelveticaNeue(16)];
			[timesheets setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
			[timesheets setTitleEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
			[mainScrollView addSubview:timesheets];
			
			UIImageView * arrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cellArrow.png"]];
			[arrow setCenter:CGPointMake(dvc_width - 30, 21)];
			[timesheets addSubview:arrow];
			
			break;
		}
			
		default:
			break;
	}
	
	[self.view addSubview:topBarView];
}

#pragma mark - FUNCTIONS

-(void)back:(UIButton*)sender
{
	NSMutableArray *projectsArray = [[NSMutableArray alloc] initWithArray:[data_manager loadProjectsArrayFromUserDefaultsAtKey:kProjectsKeyForNSUserDefaults]];
	NSMutableArray * array = [[NSMutableArray alloc] initWithArray:[self sortProjects:projectsArray]];
	
	[array replaceObjectAtIndex:project_index withObject:theProject];

	[data_manager saveProjectsArrayToUserDefaults:array forKey:kProjectsKeyForNSUserDefaults];
	
	[self.navigationController popViewControllerAnimated:YES];
}

-(void)edit:(UIButton*)sender
{
	CreateOrEditProjectVC * vc = [[CreateOrEditProjectVC alloc] initWithProject:theProject delegate:self];
	
	UINavigationController * nvc = [[UINavigationController alloc] initWithRootViewController:vc];
	[nvc setNavigationBarHidden:YES];
	[self.navigationController presentViewController:nvc animated:YES completion:nil];
}

-(void)openContactDetails:(UIButton*)sender
{
	ProjectContactDetailVC *contactView = [[ProjectContactDetailVC alloc] initWithProject:theProject];
	[self.navigationController pushViewController:contactView animated:YES];
}

-(void)openInvoices:(UIButton*)sender
{
	InvoicesStatusVC * vc = [[InvoicesStatusVC alloc] initWithProject:theProject];
	[self.navigationController pushViewController:vc animated:YES];
}

-(void)openQuotes:(UIButton*)sender
{
	QuotesStatusVC * vc = [[QuotesStatusVC alloc] initWithProject:theProject];
	[self.navigationController pushViewController:vc animated:YES];
}

-(void)openEstimates:(UIButton*)sender
{
	EstimatesStatusVC * vc = [[EstimatesStatusVC alloc] initWithProject:theProject];
	[self.navigationController pushViewController:vc animated:YES];
}

-(void)openPurchaseOrders:(UIButton*)sender
{
	PurchaseOrdersStatusVC * vc = [[PurchaseOrdersStatusVC alloc] initWithProject:theProject];
	[self.navigationController pushViewController:vc animated:YES];
}

-(void)openReceipts:(UIButton*)sender
{
	ReceiptsStatusVC *vc = [[ReceiptsStatusVC alloc] initWithProject:theProject];
	[self.navigationController pushViewController:vc animated:YES];
}

-(void)openTimesheets:(UIButton*)sender
{
	TimesheetStatusVC *vc = [[TimesheetStatusVC alloc] initWithProject:theProject];
	[self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - CLIENT CREATOR DELEGATE

-(void)creatorViewController:(CreateOrEditProjectVC *)viewController createdProject:(ProjectOBJ *)project
{
	NSMutableArray *projectsArray = [[NSMutableArray alloc] initWithArray:[data_manager loadProjectsArrayFromUserDefaultsAtKey:kProjectsKeyForNSUserDefaults]];
	NSMutableArray * array = [[NSMutableArray alloc] initWithArray:[self sortProjects:projectsArray]];
	
	[sync_manager updateCloud:[project contentsDictionary] andPurposeForDelete:0];
	[array replaceObjectAtIndex:project_index withObject:project];
	
	[data_manager saveProjectsArrayToUserDefaults:array forKey:kProjectsKeyForNSUserDefaults];
	
	theProject = project;
	
	[nameTextField setText:[project projectName]];
	[companyTextField setText:[project projectNumber]];
}

#pragma mark - SCROLLVIEW DELEGATE

-(void)scrollViewDidScroll:(UIScrollView*)scrollView
{
	if (mainScrollView && [mainScrollView respondsToSelector:@selector(didScroll)])
		[mainScrollView didScroll];
}

#pragma mark - VIEW CONTROLLER FUNCTIONS

-(void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	[nameTextField setText:[theProject projectName]];
	[companyTextField setText:[theProject projectNumber]];
}

-(NSArray*)sortProjects:(NSMutableArray*)sender
{
	NSComparisonResult (^myComparator)(id, id) = ^NSComparisonResult(ProjectOBJ * obj1, ProjectOBJ * obj2) {
		
		return [[[obj1 projectName] uppercaseString] compare:[[obj2 projectName] uppercaseString]];
		
	};
	
	[sender sortUsingComparator:myComparator];
	
	return sender;
}


-(void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
}

-(void)dealloc
{
	[mainScrollView setDelegate:nil];
}

@end
