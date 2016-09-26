//
//  SelectProjectVC.m
//  Invoice
//
//  Created by Paul on 18/06/14.
//  Copyright (c) 2014 XGRoup. All rights reserved.
//

#import "SelectProjectVC.h"

#import "Defines.h"
#import "CreateOrEditProjectVC.h"
#import "CellWithClient.h"
#import "ProjectDetailVC.h"

@interface SelectProjectVC () <UITableViewDataSource,UITableViewDelegate,ProjectCreatorDelegate,CategorySelectDelegate>

@end

@implementation SelectProjectVC

-(id)initWithInvoice:(InvoiceOBJ*)sender
{
	self = [super init];
	
	if (self)
	{
		theInvoice = sender;
		
		array_with_projects = [[NSMutableArray alloc] initWithArray:[data_manager loadProjectsArrayFromUserDefaultsAtKey:kProjectsKeyForNSUserDefaults]];
		array_with_open_projects = [[NSMutableArray alloc] init];
		array_with_completed_projects = [[NSMutableArray alloc] init];
		
		[self createArray];
	}
	
	return self;
}

-(id)initWithEstimate:(EstimateOBJ*)sender
{
	self = [super init];
	
	if (self)
	{
		theEstimate = sender;

		array_with_projects = [[NSMutableArray alloc] initWithArray:[data_manager loadProjectsArrayFromUserDefaultsAtKey:kProjectsKeyForNSUserDefaults]];
		array_with_open_projects = [[NSMutableArray alloc] init];
		array_with_completed_projects = [[NSMutableArray alloc] init];
		
		[self createArray];
	}
	
	return self;
}

-(id)initWithQuote:(QuoteOBJ*)sender
{
	self = [super init];
	
	if (self)
	{
		theQuote = sender;

		array_with_projects = [[NSMutableArray alloc] initWithArray:[data_manager loadProjectsArrayFromUserDefaultsAtKey:kProjectsKeyForNSUserDefaults]];
		array_with_open_projects = [[NSMutableArray alloc] init];
		array_with_completed_projects = [[NSMutableArray alloc] init];
		
		[self createArray];
	}
	
	return self;
}

-(id)initWithPO:(PurchaseOrderOBJ*)sender
{
	self = [super init];
	
	if (self)
	{
		thePurchareOrder = sender;

		array_with_projects = [[NSMutableArray alloc] initWithArray:[data_manager loadProjectsArrayFromUserDefaultsAtKey:kProjectsKeyForNSUserDefaults]];
		array_with_open_projects = [[NSMutableArray alloc] init];
		array_with_completed_projects = [[NSMutableArray alloc] init];
		
		[self createArray];
	}
	
	return self;
}

-(id)initWithReceipt:(ReceiptOBJ *)sender
{
	self = [super init];
	
	if(self)
	{
		theReceipt = sender;
		
		array_with_projects = [[NSMutableArray alloc] initWithArray:[data_manager loadProjectsArrayFromUserDefaultsAtKey:kProjectsKeyForNSUserDefaults]];
		array_with_open_projects = [[NSMutableArray alloc] init];
		array_with_completed_projects = [[NSMutableArray alloc] init];
		
		[self createArray];
	}
	
	return self;
}

-(id)initWithTimesheet:(TimeSheetOBJ*)sender
{
	self = [super init];
	
	if(self)
	{
		theTimesheet = sender;
		
		array_with_projects = [[NSMutableArray alloc] initWithArray:[data_manager loadProjectsArrayFromUserDefaultsAtKey:kProjectsKeyForNSUserDefaults]];
		array_with_open_projects = [[NSMutableArray alloc] init];
		array_with_completed_projects = [[NSMutableArray alloc] init];
		
		[self createArray];
	}
	
	return self;
}

- (void)viewDidLoad
{
	[super viewDidLoad];

	categorySelected = 1;
	
	theSelfView = [[UIView alloc] initWithFrame:CGRectMake(0, statusBarHeight, dvc_width, dvc_height)];
	[theSelfView setBackgroundColor:[UIColor clearColor]];
	[self.view addSubview:theSelfView];
		
	[self.view setBackgroundColor:app_background_color];
	
	topBarView = [[TopBar alloc] initWithFrame:CGRectMake(0, 0, dvc_width, 42 + statusBarHeight) andTitle:@"Projects"];
	[topBarView setBackgroundColor:app_bar_update_color];
	
	BackButton * backButton = [[BackButton alloc] initWithFrame:CGRectMake(0, 42 + statusBarHeight - 40, 70, 40) andTitle:@"Back"];
	[backButton addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
	[topBarView addSubview:backButton];
	
	UIButton * addProject = [[UIButton alloc] initWithFrame:CGRectMake(dvc_width - 40, 42 + statusBarHeight - 40, 40, 40)];
	[addProject setTitle:@"+" forState:UIControlStateNormal];
	[addProject setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[addProject setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
	[addProject.titleLabel setFont:HelveticaNeueBold(33)];
	[addProject setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 10, 0)];
	[addProject addTarget:self action:@selector(createProject:) forControlEvents:UIControlEventTouchUpInside];
	[topBarView addSubview:addProject];
	
	projectsTableView = [[TableWithShadow alloc] initWithFrame:CGRectMake(0, 42 + 40, dvc_width, dvc_height - 87 - 40) style:UITableViewStyleGrouped];
	[projectsTableView setDelegate:self];
	[projectsTableView setDataSource:self];
	[projectsTableView setBackgroundView:nil];
	[projectsTableView setSeparatorColor:[UIColor clearColor]];
	[projectsTableView setTableHeaderView:[[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)]];
	[projectsTableView setBackgroundColor:[UIColor clearColor]];
	[theSelfView addSubview:projectsTableView];
	
	[self.view addSubview:topBarView];
	
	categoryBar = [[CategorySelectV alloc] initWithFrame:CGRectMake(0, theSelfView.frame.origin.y + 52 - statusBarHeight, dvc_width, 30) andType:kProjectSelect andDelegate:self];
	categoryBar.backgroundColor = [UIColor clearColor];
	[theSelfView addSubview:categoryBar];
}

-(void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	[array_with_projects removeAllObjects];
	[array_with_completed_projects removeAllObjects];
	[array_with_open_projects removeAllObjects];
	
	[array_with_projects addObjectsFromArray:[data_manager loadProjectsArrayFromUserDefaultsAtKey:kProjectsKeyForNSUserDefaults]];
	
	[self createArray];
	[projectsTableView reloadData];
}

#pragma mark - TABLE VIEW DATA SOURCE

-(NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
	if(categorySelected == 1)
		return array_with_open_projects.count;
	
	return array_with_completed_projects.count;
}

-(UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
	CellWithClient * theCell = [tableView dequeueReusableCellWithIdentifier:@"clientCell"];
	
	if (!theCell)
	{
		theCell = [[CellWithClient alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"clientCell"];
	}
	
	kClientCellType cellType = [self getCellType:indexPath.section andRow:indexPath.row];
	
	if(categorySelected == 1)
		[theCell loadProject:[array_with_open_projects objectAtIndex:indexPath.row] withType:cellType];
	else
		[theCell loadProject:[array_with_completed_projects objectAtIndex:indexPath.row] withType:cellType];
	
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
			[(CellWithClient*)cell resize];
		}
	}
}

-(kClientCellType)getCellType:(NSInteger)section andRow:(NSInteger)row
{
	if(categorySelected == 1)
	{
		if(row == 0 && array_with_open_projects.count == 1)
			return kClientCellTypeSingle;
		
		if(row == 0 && array_with_open_projects.count > 1)
			return kClientCellTypeTop;
		
		if(row > 0 && row < array_with_open_projects.count - 1)
			return kClientCellTypeMiddle;
		
		return kClientCellTypeBottom;
	}
	
	if(row == 0 && array_with_completed_projects.count == 1)
		return kClientCellTypeSingle;
	
	if(row == 0 && array_with_completed_projects.count > 1)
		return kClientCellTypeTop;
	
	if(row > 0 && row < array_with_completed_projects.count - 1)
		return kClientCellTypeMiddle;
	
	return kClientCellTypeBottom;
}

#pragma mark - TABLEVIEW DELEGATE

-(NSInteger)numberOfSectionsInTableView:(UITableView*)tableView
{
	return 1;
}

-(CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
	if(indexPath.row == 0)
		return 62.0f;
	
	return 52.0;
}

-(void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
	ProjectOBJ *project = (categorySelected == 1) ? [array_with_open_projects objectAtIndex:indexPath.row] : [array_with_completed_projects objectAtIndex:indexPath.row];

	[theInvoice setProject:[project contentsDictionary]];
	[theEstimate setProject:[project contentsDictionary]];
	[theQuote setProject:[project contentsDictionary]];
	[thePurchareOrder setProject:[project contentsDictionary]];
	[theReceipt setProject:project];
	[theTimesheet setProject:project];
	
	[self back:nil];
}

-(BOOL)tableView:(UITableView*)tableView canEditRowAtIndexPath:(NSIndexPath*)indexPath
{
	return YES;
}

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"Delete"  handler:^(UITableViewRowAction *action, NSIndexPath *indexPath)
    {
        if(categorySelected == 1)
        {
            [sync_manager updateCloud:[(ProjectOBJ*)[array_with_open_projects objectAtIndex:indexPath.row] contentsDictionary] andPurposeForDelete:-1];
            [array_with_open_projects removeObjectAtIndex:indexPath.row];
        }
        else
        {
            [sync_manager updateCloud:[(ProjectOBJ*)[array_with_completed_projects objectAtIndex:indexPath.row] contentsDictionary] andPurposeForDelete:-1];
            [array_with_completed_projects removeObjectAtIndex:indexPath.row];
        }
        
        [array_with_projects removeAllObjects];
        [array_with_projects addObjectsFromArray:array_with_open_projects];
        [array_with_projects addObjectsFromArray:array_with_completed_projects];
        
        [projectsTableView reloadData];
        
        [data_manager saveProjectsArrayToUserDefaults:array_with_projects forKey:kProjectsKeyForNSUserDefaults];
    }];
    
    return @[deleteAction];
}

-(void)tableView:(UITableView*)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath*)indexPath
{
	if (editingStyle == UITableViewCellEditingStyleDelete)
	{
		if(categorySelected == 1)
		{
			[sync_manager updateCloud:[(ProjectOBJ*)[array_with_open_projects objectAtIndex:indexPath.row] contentsDictionary] andPurposeForDelete:-1];
			[array_with_open_projects removeObjectAtIndex:indexPath.row];
		}
		else
		{
			[sync_manager updateCloud:[(ProjectOBJ*)[array_with_completed_projects objectAtIndex:indexPath.row] contentsDictionary] andPurposeForDelete:-1];
			[array_with_completed_projects removeObjectAtIndex:indexPath.row];
		}
		
		[array_with_projects removeAllObjects];
		[array_with_projects addObjectsFromArray:array_with_open_projects];
		[array_with_projects addObjectsFromArray:array_with_completed_projects];
		
		[projectsTableView reloadData];
		
		[data_manager saveProjectsArrayToUserDefaults:array_with_projects forKey:kProjectsKeyForNSUserDefaults];
	}
}

#pragma mark - CLIENT CREATOR DELEGATE

-(void)creatorViewController:(CreateOrEditProjectVC*)viewController createdProject:(ProjectOBJ *)project
{
	[sync_manager updateCloud:[project contentsDictionary] andPurposeForDelete:1];
	
	[array_with_projects addObject:project];
	[self sortProjects];
	
	[data_manager saveProjectsArrayToUserDefaults:array_with_projects forKey:kProjectsKeyForNSUserDefaults];
	[projectsTableView reloadData];
	
}

#pragma mark - SCROLL VIEW DELEGATE

-(void)scrollViewDidScroll:(UIScrollView*)scrollView
{
	if ([scrollView isKindOfClass:[TableWithShadow class]])
		[(TableWithShadow*)scrollView didScroll];
}

#pragma mark - ACTIONS

-(void)createProject:(UIButton*)button
{
	CreateOrEditProjectVC * vc = [[CreateOrEditProjectVC alloc] initWithProject:nil delegate:self];
	
	UINavigationController * nvc = [[UINavigationController alloc] initWithRootViewController:vc];
	[nvc setNavigationBarHidden:YES];
	[self.navigationController presentViewController:nvc animated:YES completion:nil];
}
-(void)back:(UIButton*)button
{
	[self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - CATEGORY BAR DELEGATE

-(void)categorySelectDelegate:(CategorySelectV *)view selectedCategory:(int)category
{
	categorySelected = category;
	
	[self createArray];
	
	[projectsTableView reloadData];
}

#pragma mark - ADDITIONALLY FUNCTIONS

-(void)sortProjects
{
	NSComparisonResult (^myComparator)(id, id) = ^NSComparisonResult(ProjectOBJ * obj1, ProjectOBJ * obj2) {
		
		return [[[obj1 projectName] uppercaseString] compare:[[obj2 projectName] uppercaseString]];
		
	};
	
	[array_with_projects sortUsingComparator:myComparator];
}

-(void)createArray
{
	[array_with_completed_projects removeAllObjects];
	[array_with_open_projects removeAllObjects];
	
	for(ProjectOBJ * project in array_with_projects)
	{
		if([[project completed] intValue] == 0 || [[project completed] isEqual:@""])
			[array_with_open_projects addObject:project];
		else
			[array_with_completed_projects addObject:project];
	}
}

@end
