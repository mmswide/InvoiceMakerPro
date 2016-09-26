//
//  CreateTimesheetVC.m
//  Invoice
//
//  Created by XGRoup on 7/17/14.
//  Copyright (c) 2014 XGRoup. All rights reserved.
//

#import "CreateTimesheetVC.h"

#import "Defines.h"

#import "CellWithPicker.h"
#import "CellWithPush.h"
#import "CellWithText.h"

#import "ClientsVC.h"
#import "SelectProjectVC.h"
#import "SelectServiceTimeVC.h"

#import "AddNoteVC.h"

@interface CreateTimesheetVC ()

<
UIScrollViewDelegate,
UITableViewDelegate,
UITableViewDataSource,
UITextFieldDelegate,
TimeEditorDelegate,
SignatureAndDateCreatorDelegate,
MFMailComposeViewControllerDelegate
>

@end

@implementation CreateTimesheetVC

@synthesize delegate;

-(id)initForCreationWithDelegate:(id<TimesheetCreatorDelegate>)del
{
	self = [super init];
	
	if (self)
	{
		delegate = del;
	}
	
	return self;
}

-(id)initWithTimesheet:(TimeSheetOBJ *)sender delegate:(id<TimesheetCreatorDelegate>)del
{
	self = [super init];
	
	if (self)
	{
		delegate = del;
		theTimeSheet = [[TimeSheetOBJ alloc] initWithTimeSheet:sender];
	}
	
	return self;
}

#pragma mark - VIEW DID LOAD

-(void)viewDidLoad {
	[super viewDidLoad];
	
	currentRow = -1;
	service_time_index = -1;
		
	theSelfView = [[UIView alloc] initWithFrame:CGRectMake(0, statusBarHeight, dvc_width, dvc_height)];
	[theSelfView setBackgroundColor:[UIColor clearColor]];
	[self.view addSubview:theSelfView];
	
	[self.view setBackgroundColor:app_background_color];
	
	topBarView = [[TopBar alloc] initWithFrame:CGRectMake(0, 0, dvc_width, 42 + statusBarHeight) andTitle:@"Create Timesheet"];
	[topBarView setBackgroundColor:app_bar_update_color];
	
	UIButton * cancel = [[UIButton alloc] initWithFrame:CGRectMake(0, 42 + statusBarHeight - 40, 80, 40)];
	[cancel setTitle:@"Cancel" forState:UIControlStateNormal];
	[cancel setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[cancel setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
	[cancel.titleLabel setFont:HelveticaNeueLight(17)];
	[cancel addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
	[topBarView addSubview:cancel];
	
	UIButton * done = [[UIButton alloc] initWithFrame:CGRectMake(dvc_width - 60, 42 + statusBarHeight - 40, 60, 40)];
	[done setTitle:@"Done" forState:UIControlStateNormal];
	[done setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[done setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
	[done.titleLabel setFont:HelveticaNeueLight(17)];
	[done addTarget:self action:@selector(done:) forControlEvents:UIControlEventTouchUpInside];
	[topBarView addSubview:done];
	
	if (!theTimeSheet)
	{
		[topBarView setText:@"New Timesheet"];
		
		theTimeSheet = [[TimeSheetOBJ alloc] init];
	}
	else
	{
		[topBarView setText:@"Edit Timesheet"];
	}
	
	mainScrollView = [[ScrollWithShadow alloc] initWithFrame:CGRectMake(0, 42, dvc_width, dvc_height - 42)];
	[mainScrollView setBackgroundColor:[UIColor clearColor]];
	[mainScrollView setDelegate:self];
	[theSelfView addSubview:mainScrollView];
	
	myTableView = [[TableWithShadow alloc] initWithFrame:CGRectMake(0, 0, dvc_width, dvc_height - 42) style:UITableViewStyleGrouped];
	[myTableView setDataSource:self];
	[myTableView setDelegate:self];
	myTableView.scrollEnabled = NO;
	[myTableView setBackgroundColor:[UIColor clearColor]];
	[myTableView setSeparatorColor:[UIColor clearColor]];
	[myTableView layoutIfNeeded];
	
	if (sys_version >= 7)
	{
		[myTableView setContentInset:UIEdgeInsetsZero];
		[mainScrollView setContentInset:UIEdgeInsetsMake(-20, 0, 0, 0)];
	}
	
	[mainScrollView setContentSize:myTableView.contentSize];
	[myTableView setFrame:CGRectMake(0, 0, mainScrollView.contentSize.width, mainScrollView.contentSize.height)];
	
	[mainScrollView addSubview:myTableView];
	
	theToolbar = [[ToolBarView alloc] initWithFrame:CGRectMake(0, dvc_height, dvc_width, 40)];
	[theToolbar.prevButton setAlpha:1.0];
	[theToolbar.nextButton setAlpha:1.0];
	[theToolbar.prevButton addTarget:self action:@selector(prev:) forControlEvents:UIControlEventTouchUpInside];
	[theToolbar.nextButton addTarget:self action:@selector(next:) forControlEvents:UIControlEventTouchUpInside];
	[theToolbar.doneButton addTarget:self action:@selector(closePicker:) forControlEvents:UIControlEventTouchUpInside];
	[theSelfView addSubview:theToolbar];
	
	percentage = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
	[percentage setTitle:[NSString stringWithFormat:@"%c", '%'] forState:UIControlStateNormal];
	[percentage setTitleColor:app_tab_selected_color forState:UIControlStateSelected];
	[percentage setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	[percentage.titleLabel setFont:HelveticaNeueLight(17)];
	[percentage addTarget:self action:@selector(percentage:) forControlEvents:UIControlEventTouchUpInside];
	[theToolbar addSubview:percentage];
	
	value = [[UIButton alloc] initWithFrame:CGRectMake(40, 0, 40, 40)];
	[value setTitle:[NSString stringWithFormat:@"%@", [data_manager currency]] forState:UIControlStateNormal];
	[value setTitleColor:app_tab_selected_color forState:UIControlStateSelected];
	[value setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	[value.titleLabel setFont:HelveticaNeueLight(17)];
	[value setSelected:YES];
	[value addTarget:self action:@selector(value:) forControlEvents:UIControlEventTouchUpInside];
	[theToolbar addSubview:value];
	
	UIView * bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, dvc_width, dvc_height - 42)];
	[bgView setBackgroundColor:[UIColor clearColor]];
	[myTableView setBackgroundView:bgView];
	
	[self.view addSubview:topBarView];
}

#pragma mark - TABLE VIEW DATASOURCE

-(NSInteger)numberOfSectionsInTableView:(UITableView*)tableView
{
	return 6;
}

-(NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
	if(section == 0)
	{
		return 1;
	}
	
	if(section == 1)
	{
		return 3;
	}
		
	if(section == 2)
	{
		return 1 + [theTimeSheet services].count;
	}
	
	if(section == 3)
	{
		return 3;
	}
	
	if(section == 4)
	{
		return 2;
	}
	
	if(section == 5)
	{
		return 5;
	}
	
	return 0;
}

-(UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
	UITableViewCell * theCell = [self cellInSection:(int)indexPath.section atRow:(int)indexPath.row];
	
	return theCell;
}

-(UIView*)tableView:(UITableView*)tableView viewForHeaderInSection:(NSInteger)section
{
	int height = (section == 3) ? 5 : 30;
	
	UIView * view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, dvc_width, height)];
	[view setBackgroundColor:[UIColor clearColor]];
	
	UILabel * title = [[UILabel alloc] initWithFrame:CGRectMake(22, 0, dvc_width - 44, height)];
	[title setTextAlignment:NSTextAlignmentLeft];
	[title setTextColor:app_title_color];
	[title setFont:HelveticaNeueMedium(15)];
	[title setBackgroundColor:[UIColor clearColor]];
	[view addSubview:title];

	if(section == 0)
	{
		[title setText:@"Title"];
	}
	else
	if(section == 1)
	{
		[title setText:@"Details"];
	}
	else
	if(section == 2)
	{
		[title setText:@"Services"];
	}
	else
	if(section == 4)
	{
		[title setText:@"Project (Optional)"];
	}

	if(section == 5)
	{
		[title setText:@"Optional Info"];
	}
	
	return view;
}

#pragma mark - TABLE VIEW DELEGATE

-(CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
	return 42.0f;
}

-(CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section
{
	if(section == 3)
		return 5.0f;
	
	return 30.0f;
}

-(void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
	UITableViewCell * theCell = [tableView cellForRowAtIndexPath:indexPath];
	
	if ([theCell isKindOfClass:[CellWithPush class]])
	{
		[(CellWithPush*)theCell animateSelection];
	}
	else if ([theCell isKindOfClass:[CellWithPicker class]])
	{
		[(CellWithPicker*)theCell animateSelection];
	}
	else if ([theCell isKindOfClass:[CellWithText class]])
	{
		[(CellWithText*)theCell animateSelection];
	}
	
	[self selectedCellInSection:(int)indexPath.section atRow:(int)indexPath.row];
}

-(BOOL)tableView:(UITableView*)tableView canEditRowAtIndexPath:(NSIndexPath*)indexPath
{
	if(indexPath.section == 2 && indexPath.row > 0)
	{
		return YES;
	}
	
	return NO;
}

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"Delete"  handler:^(UITableViewRowAction *action, NSIndexPath *indexPath)
    {
        [theTimeSheet removeServiceTimeAtIndex:(int)indexPath.row - 1];
        
        float total = 0;
        
        for(int i=0;i<[theTimeSheet services].count;i++)
        {
            ServiceTimeOBJ *time = [theTimeSheet serviceTimeAtIndex:i];
            total += [time getTotal];
        }
        
        [theTimeSheet setSubtotal:total];
        
        if(total == 0)
        {
            [theTimeSheet setDiscount:0.0];
        }
        
        [myTableView reloadData];
        
        [myTableView layoutIfNeeded];
        [mainScrollView setContentSize:myTableView.contentSize];
        [myTableView setFrame:CGRectMake(0, 0, mainScrollView.contentSize.width, mainScrollView.contentSize.height)];
        
    }];
    
    return @[deleteAction];
}

-(void)tableView:(UITableView*)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath*)indexPath
{
	if (editingStyle == UITableViewCellEditingStyleDelete)
	{
		[theTimeSheet removeServiceTimeAtIndex:(int)indexPath.row - 1];
		
		float total = 0;
		
		for(int i=0;i<[theTimeSheet services].count;i++)
		{
			ServiceTimeOBJ *time = [theTimeSheet serviceTimeAtIndex:i];
			total += [time getTotal];
		}
			
		[theTimeSheet setSubtotal:total];
		
		if(total == 0)
		{
			[theTimeSheet setDiscount:0.0];
		}

		[myTableView reloadData];
		
		[myTableView layoutIfNeeded];
		[mainScrollView setContentSize:myTableView.contentSize];
		[myTableView setFrame:CGRectMake(0, 0, mainScrollView.contentSize.width, mainScrollView.contentSize.height)];
	}
}

#pragma mark - SCROLL VIEW DELEGATE

-(void)scrollViewDidScroll:(UIScrollView*)scrollView
{
	if (mainScrollView && [mainScrollView respondsToSelector:@selector(didScroll)])
		[mainScrollView didScroll];
}

#pragma mark - CELL GENERATION

-(UITableViewCell*)cellInSection:(int)section atRow:(int)row
{
	switch (section)
	{
		case 0:
		{
			return [self titleCellAtRow:row];
			
			break;
		}
			
		case 1:
		{
			return [self detailsCellAtRow:row];
			
			break;
		}
						
		case 2:
		{
			return [self serviceCellAtRow:row];
			
			break;
		}
			
		case 3:
		{
			return [self valuesCellAtRow:row];
			
			break;
		}
			
		case 4:
		{
			return [self projectCellAtRow:row];
			
			break;
		}
			
		case 5:
		{
			return [self optionalCellAtRow:row];
			
			break;
		}
			
		default:
			break;
	}
	
	return nil;
}

-(UITableViewCell*)titleCellAtRow:(int)row
{
	UITableViewCell * theCell;
	
	switch (row)
	{
		case 0:
		{
			theCell = [myTableView dequeueReusableCellWithIdentifier:@"tableCellPush"];
			
			if (!theCell)
			{
				theCell = [[CellWithPush alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"tableCellPush"];
			}
			
			[(CellWithPush*)theCell loadTitle:@"Title" andValue:[theTimeSheet title] cellType:kCellTypeSingle andSize:0.0];
			[theCell setUserInteractionEnabled:YES];
			
			break;
		}
	}
	
	return theCell;
}

-(UITableViewCell*)detailsCellAtRow:(int)row
{
	UITableViewCell * theCell;
	
	switch (row)
	{
		case 0:
		{
			theCell = [myTableView dequeueReusableCellWithIdentifier:@"tableCellText"];
			
			if (!theCell)
			{
				theCell = [[CellWithText alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"tableCellText"];
			}
			
			int temp = (int)[CustomDefaults customIntegerForKey:kNumberOfTimesheetKeyForNSUserDefaults];
			
			NSString * valueSTR = [theTimeSheet number];
			
			if ([valueSTR isEqual:@"TS00001"])
			{
				if (temp < 10)
				{
					valueSTR = [NSString stringWithFormat:@"TS0000%d", temp];
				}
				else if (temp < 100)
				{
					valueSTR = [NSString stringWithFormat:@"TS000%d", temp];
				}
				else if (temp < 1000)
				{
					valueSTR = [NSString stringWithFormat:@"TS00%d", temp];
				}
				else if (temp < 10000)
				{
					valueSTR = [NSString stringWithFormat:@"TS0%d", temp];
				}
				else
				{
					valueSTR = [NSString stringWithFormat:@"TS%d", temp];
				}
			}
			
			[(CellWithText*)theCell loadTitle:@"Timesheet No." andValue:valueSTR tag:111 textFieldDelegate:self cellType:kCellTypeTop andKeyboardType:UIKeyboardTypeDefault];
						
			break;
		}
			
		case 1:
		{
			theCell = [myTableView dequeueReusableCellWithIdentifier:@"tableCellPush"];
			
			if(!theCell)
			{
				theCell = [[CellWithPush alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"tableCellPush"];
			}
			
			NSString *clientName = [[theTimeSheet client] firstName];
			
			if([clientName isEqual:@""])
			{
				clientName = [[theTimeSheet client] lastName];
			}
			else
			{
				clientName = [NSString stringWithFormat:@"%@ %@",clientName,[[theTimeSheet client] lastName]];
			}
			
			[(CellWithPush*)theCell loadTitle:@"Client" andValue:clientName cellType:kCellTypeMiddle andSize:20.0];
			
			break;
		}
			
		case 2:
		{
			theCell = [myTableView dequeueReusableCellWithIdentifier:@"tableCellPicker"];
			
			if (!theCell)
			{
				theCell = [[CellWithPicker alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"tableCellPicker"];
			}
			
			[date_formatter setDateFormat:[DELEGATE userSelectedDateFormat]];
			
			[(CellWithPicker*)theCell loadTitle:@"Date" andValue:[date_formatter stringFromDate:[theTimeSheet date]] cellType:kCellTypeBottom];
			[theCell setUserInteractionEnabled:YES];

			break;
		}
						
		default:
			break;
	}
	
	return theCell;
}

-(UITableViewCell*)projectCellAtRow:(int)row
{
	UITableViewCell *theCell;
	
	switch (row)
	{
		case 0:
		{
			theCell = [myTableView dequeueReusableCellWithIdentifier:@"tableCellPush"];
			
			if(!theCell)
			{
				theCell = [[CellWithPush alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"tableCellPush"];
			}
			
			[(CellWithPush*)theCell loadTitle:@"Project Name" andValue:[[theTimeSheet project] projectName] cellType:kCellTypeTop andSize:20.0];
			[theCell setUserInteractionEnabled:YES];
			
			break;
		}
			
		case 1:
		{
			theCell = [myTableView dequeueReusableCellWithIdentifier:@"tableCellPush"];
			
			if(!theCell)
			{
				theCell = [[CellWithPush alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"tableCellPush"];
			}
			
			[(CellWithPush*)theCell loadTitle:@"Project No." andValue:[[theTimeSheet project] projectNumber] cellType:kCellTypeBottom andSize:20.0];
			[theCell setUserInteractionEnabled:YES];
			
			break;
		}
			
		default:
			break;
	}
	
	return theCell;
}

-(UITableViewCell*)serviceCellAtRow:(int)row
{
	UITableViewCell * theCell;
	
	switch (row)
	{
		case 0:
		{
			theCell = [myTableView dequeueReusableCellWithIdentifier:@"tableCellPush"];
			
			if(!theCell)
			{
				theCell = [[CellWithPush alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"tableCellPush"];
			}
			
			kCellType type = kCellTypeTop;
			
			if([theTimeSheet services].count == 0)
				type = kCellTypeSingle;
			
			[(CellWithPush*)theCell loadTitle:@"Add Service" andValue:@"" cellType:type andSize:20.0];
			
			break;
		}
			
		default:
		{
			ServiceTimeOBJ *service = [theTimeSheet serviceTimeAtIndex:row - 1];
			
			theCell = [myTableView dequeueReusableCellWithIdentifier:@"tableCellText"];
			 
			if(!theCell)
			{
				theCell = [[CellWithText alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"tableCellText"];
			}
			
			kCellType type = kCellTypeMiddle;
			
			if(row == [theTimeSheet services].count)
				type = kCellTypeBottom;
			
			[(CellWithText*)theCell loadTitle:[[service product] name] andValue:[data_manager currencyAdjustedValue:[service getTotal]] tag:0 textFieldDelegate:nil cellType:type andKeyboardType:UIKeyboardTypeDefault];
			[(CellWithText*)theCell setTextFieldEditable:NO];
			
			break;
		}
	}
	
	return theCell;
}

-(UITableViewCell*)valuesCellAtRow:(int)row
{
	UITableViewCell *theCell;
	
	switch (row)
	{
		case 0:
		{
			theCell = [myTableView dequeueReusableCellWithIdentifier:@"tableCellText"];
			
			if (!theCell)
			{
				theCell = [[CellWithText alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"tableCellText"];
			}
			
			[(CellWithText*)theCell loadTitle:@"Subtotal" andValue:[data_manager currencyAdjustedValue:[theTimeSheet subtotal]] tag:0 textFieldDelegate:self cellType:kCellTypeTop andKeyboardType:UIKeyboardTypeDefault];
			[(CellWithText*)theCell setTextFieldEditable:NO];
			
			break;
		}
			
		case 1:
		{
			theCell = [myTableView dequeueReusableCellWithIdentifier:@"tableCellText"];
			
			if(!theCell)
			{
				theCell = [[CellWithText alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"tableCellText"];
			}
			
			[(CellWithText*)theCell loadTitle:[NSString stringWithFormat:@"Discount (%@%c)",[data_manager valueAdjusted:[theTimeSheet getDiscountShowValue]],'%'] andValue:[data_manager currencyAdjustedValue:[theTimeSheet discount]] tag:222 textFieldDelegate:self cellType:kCellTypeMiddle andKeyboardType:UIKeyboardTypeDecimalPad];
			[(CellWithText*)theCell setTextFieldEditable:YES];
			
			break;
		}
			
		case 2:
		{
			theCell = [myTableView dequeueReusableCellWithIdentifier:@"tableCellText"];
			
			if(!theCell)
			{
				theCell = [[CellWithText alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"tableCellText"];
			}
			
			[(CellWithText*)theCell loadTitle:@"Total" andValue:[data_manager currencyAdjustedValue:[theTimeSheet getTotalValue]] tag:0 textFieldDelegate:self cellType:kCellTypeBottom andKeyboardType:UIKeyboardTypeDefault];
			[(CellWithText*)theCell setTextFieldEditable:NO];
			
			break;
		}
			
		default:
			break;
	}
	
	return theCell;
}

-(UITableViewCell*)optionalCellAtRow:(int)row
{
	
	UITableViewCell * theCell;
	
	switch (row)
	{
		case 0:
		{
			theCell = [myTableView dequeueReusableCellWithIdentifier:@"tableCellPush"];
			
			if (!theCell)
			{
				theCell = [[CellWithPush alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"tableCellPush"];
			}
			
			[(CellWithPush*)theCell loadTitle:[theTimeSheet otherCommentsTitle] andValue:[theTimeSheet otherComments] cellType:kCellTypeTop andSize:0.0];
			[theCell setUserInteractionEnabled:YES];
			
			break;
		}
			
		case 1:
		{
			theCell = [myTableView dequeueReusableCellWithIdentifier:@"tableCellPush"];
			
			if (!theCell)
			{
				theCell = [[CellWithPush alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"tableCellPush"];
			}
			
			[(CellWithPush*)theCell loadTitle:[theTimeSheet rightSignatureTitle] andValue:@"" cellType:kCellTypeMiddle andSize:0.0];
			[theCell setUserInteractionEnabled:YES];
			
			break;
		}
			
		case 2:
		{
			theCell = [myTableView dequeueReusableCellWithIdentifier:@"tableCellPush"];
			
			if (!theCell)
			{
				theCell = [[CellWithPush alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"tableCellPush"];
			}
			
			[(CellWithPush*)theCell loadTitle:[theTimeSheet leftSignatureTitle] andValue:@"" cellType:kCellTypeMiddle andSize:0.0];
			[theCell setUserInteractionEnabled:YES];
			
			break;
		}
			
		case 3:
		{
			theCell = [myTableView dequeueReusableCellWithIdentifier:@"tableCellPush"];
			
			if (!theCell)
			{
				theCell = [[CellWithPush alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"tableCellPush"];
			}
			
			[(CellWithPush*)theCell loadTitle:@"Note" andValue:[theTimeSheet note] cellType:kCellTypeMiddle andSize:0.0];
			[theCell setUserInteractionEnabled:YES];
			
			break;
		}
			
		case 4:
		{
			theCell = [myTableView dequeueReusableCellWithIdentifier:@"tableCellPush"];
			
			if (!theCell)
			{
				theCell = [[CellWithPush alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"tableCellPush"];
			}
			
			[(CellWithPush*)theCell loadTitle:@"Send as invoice" andValue:@"" cellType:kCellTypeBottom andSize:0.0];
			[theCell setUserInteractionEnabled:YES];
			
			break;
		}
			
		default:
			break;
	}
	
	return theCell;
}

#pragma mark - CELL SELECTION

-(void)selectedCellInSection:(int)section atRow:(int)row
{
	switch (section)
	{
		case 0:
		{
			[self selectedTitleCellAtRow:row];
			break;
		}
			
		case 1:
		{
			[self selectedDetailCellAtRow:row];
			break;
		}
						
		case 2:
		{
			[self selectedServiceCellAtRow:row];
			break;
		}
			
		case 3:
		{
			[self selectedValuesCellAtRow:row];
			
			break;
		}
			
		case 4:
		{
			[self selectedProjectCellAtRow:row];
			break;
		}
			
		case 5:
		{
			[self selectedOptionalCellAtRow:row];
			
			break;
		}
						
		default:
			break;
	}
}

-(void)selectedTitleCellAtRow:(int)row
{
	switch (row)
	{
		case 0:
		{
			EditTitleVC * vc = [[EditTitleVC alloc] initWithTimesheet:theTimeSheet];
			[self.navigationController pushViewController:vc animated:YES];
			
			break;
		}
	}
}

-(void)selectedDetailCellAtRow:(int)row
{
	switch (row)
	{
		case 1:
		{
			ClientsVC *vc= [[ClientsVC alloc] initWithTimesheet:theTimeSheet];
			[self.navigationController pushViewController:vc animated:YES];
			
			break;
		}
			
		case 2:
		{
			[self openPicker];
			
			break;
		}
						
		default:
			break;
	}
}

-(void)selectedProjectCellAtRow:(int)row
{
	switch (row)
	{
		case 0:
		{
			SelectProjectVC *vc = [[SelectProjectVC alloc] initWithTimesheet:theTimeSheet];
			[self.navigationController pushViewController:vc animated:YES];
			
			break;
		}
			
		case 1:
		{
			SelectProjectVC *vc = [[SelectProjectVC alloc] initWithTimesheet:theTimeSheet];
			[self.navigationController pushViewController:vc animated:YES];
			
			break;
		}
			
		default:
			break;
	}
}

-(void)selectedServiceCellAtRow:(int)row
{
	switch (row)
	{
		case 0:
		{
			service_time_index = -1;
			
			SelectServiceTimeVC *vc = [[SelectServiceTimeVC alloc] initWithEditorDelegate:self serviceTime:[[ServiceTimeOBJ alloc] init] andTitle:@"Add Service"];
			[self.navigationController pushViewController:vc animated:YES];
			
			break;
		}
			
		default:
		{
			service_time_index = row - 1;
			
			SelectServiceTimeVC *vc = [[SelectServiceTimeVC alloc] initWithEditorDelegate:self serviceTime:[theTimeSheet serviceTimeAtIndex:service_time_index] andTitle:@"Edit Service"];
			[self.navigationController pushViewController:vc animated:YES];
			
			break;
		}
	}
}

-(void)selectedValuesCellAtRow:(int)row
{
	switch (row)
	{
		case 0:
		{
			
			break;
		}
			
		default:
			break;
	}
}

-(void)selectedOptionalCellAtRow:(int)row
{
	switch (row)
	{
		case 0:
		{
			//Other comments
			OtherCommentsVC * vc = [[OtherCommentsVC alloc] initWithTimesheet:theTimeSheet];
			[self.navigationController pushViewController:vc animated:YES];
			
			break;
		}
			
		case 1:
		{
			//Signature Left
			AddSignatureAndDateVC * vc = [[AddSignatureAndDateVC alloc] initWithDelegate:self andTimesheet:theTimeSheet type:kSignatureTypeRight];
			[self.navigationController pushViewController:vc animated:YES];
			
			break;
		}
			
		case 2:
		{
			//Signature Right
			AddSignatureAndDateVC * vc = [[AddSignatureAndDateVC alloc] initWithDelegate:self andTimesheet:theTimeSheet type:kSignatureTypeLeft];
			[self.navigationController pushViewController:vc animated:YES];
		
			break;
		}
			
		case 3:
		{
			//Note
			AddNoteVC * vc = [[AddNoteVC alloc] initWithTimesheet:theTimeSheet];
			[self.navigationController pushViewController:vc animated:YES];
			
			break;
		}
			
		case 4:
		{
			InvoiceOBJ * newInvoice = [[InvoiceOBJ alloc] initWithTimesheet:theTimeSheet];
			
			int number = (int)[CustomDefaults customIntegerForKey:kNumberOfInvoicesKeyForNSUserDefaults];
			[newInvoice setNumber:number];
			number++;
			
			[CustomDefaults setCustomInteger:number forKey:kNumberOfInvoicesKeyForNSUserDefaults];
			
			id mySort = ^(InvoiceOBJ * obj1, InvoiceOBJ * obj2)
			{
				NSComparisonResult result = [obj1 status] > [obj2 status];
				
				return result;
			};
			
			NSMutableArray * array_with_invoices = [[NSMutableArray alloc] initWithArray:[data_manager loadInvoicesArrayFromUserDefaultsAtKey:kInvoicesKeyForNSUserDefaults]];
			
			[array_with_invoices insertObject:newInvoice atIndex:0];
			[array_with_invoices sortUsingComparator:mySort];
			
			[data_manager saveInvoicesArrayToUserDefaults:array_with_invoices forKey:kInvoicesKeyForNSUserDefaults];
						
			if ([MFMailComposeViewController canSendMail])
			{
				NSString * fileName = [NSString stringWithFormat:@"%@.pdf", [newInvoice number]];
				
				MFMailComposeViewController * vc = [[MFMailComposeViewController alloc] init];
				[vc setSubject:[NSString stringWithFormat:@"%@", [newInvoice number]]];
				[vc setToRecipients:[NSArray arrayWithObject:[[newInvoice client] email]]];
				[vc setMailComposeDelegate:self];
				[vc addAttachmentData:[PDFCreator PDFDataFromUIView:[PDFCreator PDFViewFromInvoice:newInvoice]] mimeType:@"application/pdf" fileName:fileName];
				[self presentViewController:vc animated:YES completion:nil];
			}
			else
			{
				[[[AlertView alloc] initWithTitle:@"" message:@"You must configure an email account in the device settings to be able to send emails." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
			}
			
			break;
		}

			
		default:
			break;
	}

}

#pragma mark - OPEN PICKER

-(void)openPicker
{
	if ([self.navigationController.view viewWithTag:101010])
		return;
	
	[self showBoth];
	
	currentRow = 1;
	
	UIButton * closeAll = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
	[closeAll setBackgroundColor:[UIColor clearColor]];
	[closeAll addTarget:self action:@selector(cancelPicker:) forControlEvents:UIControlEventTouchUpInside];
	[closeAll setTag:123123];
	[theSelfView addSubview:closeAll];
	[theSelfView bringSubviewToFront:theToolbar];
	
	UITableViewCell * theCell;
	
	[[self.navigationController.view viewWithTag:101010] removeFromSuperview];
	[[self.view viewWithTag:999] removeFromSuperview];
	
	[(UITextField*)[self.view viewWithTag:111] resignFirstResponder];
	
	UIView * viewWithPicker = [[UIView alloc] initWithFrame:CGRectMake(0, dvc_height + 60, dvc_width, keyboard_height)];
	[viewWithPicker setBackgroundColor:[UIColor clearColor]];
	[viewWithPicker setTag:101010];
	[viewWithPicker.layer setMasksToBounds:YES];
	[self.navigationController.view addSubview:viewWithPicker];
	
	UIDatePicker * picker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 0, dvc_width, keyboard_height)];
	[picker setCenter:CGPointMake(dvc_width / 2, keyboard_height / 2)];
	[picker setDatePickerMode:UIDatePickerModeDate];
	[picker setTag:989898];
	picker.backgroundColor = [UIColor whiteColor];
	[date_formatter setDateFormat:[DELEGATE userSelectedDateFormat]];
	[picker setDate:[theTimeSheet date]];
	[viewWithPicker addSubview:picker];
	
	if (iPad)
	{
		[picker setTransform:CGAffineTransformMakeScale(1.0, (float)(keyboard_height) / 216.0f)];
	}
	
	[UIView animateWithDuration:0.25 animations:^{
		
		[viewWithPicker setFrame:CGRectMake(0, dvc_height - keyboard_height + 20, dvc_width, keyboard_height)];
		[theToolbar setFrame:CGRectMake(0, dvc_height - keyboard_height - 40, dvc_width, 40)];
		[mainScrollView setFrame:CGRectMake(mainScrollView.frame.origin.x, mainScrollView.frame.origin.y, dvc_width, dvc_height - 42 - keyboard_height)];
		if (mainScrollView && [mainScrollView respondsToSelector:@selector(didScroll)])
			[mainScrollView didScroll];
		
	} completion:^(BOOL finished) {
		
		if (mainScrollView.contentOffset.y > theCell.frame.origin.y)
		{
			[mainScrollView scrollRectToVisible:CGRectMake(0, theCell.frame.origin.y, theCell.frame.size.width, theCell.frame.size.height) animated:YES];
		}
		else
		{
			[mainScrollView scrollRectToVisible:CGRectMake(0, theCell.frame.origin.y + 42, theCell.frame.size.width, theCell.frame.size.height) animated:YES];
		}
		
	}];
}

-(void)cancelPicker:(UIButton*)sender
{
	currentRow = -1;
	
	[(UITextField*)[self.view viewWithTag:111] resignFirstResponder];
	
	[[self.view viewWithTag:123123] removeFromSuperview];
	
	[UIView animateWithDuration:0.25 animations:^{
		
		[[self.navigationController.view viewWithTag:101010] setFrame:CGRectMake(0, dvc_height + 60, dvc_width, keyboard_height)];
		[theToolbar setFrame:CGRectMake(0, dvc_height, dvc_width, 40)];
		[mainScrollView setFrame:CGRectMake(mainScrollView.frame.origin.x, mainScrollView.frame.origin.y, dvc_width, dvc_height - 42)];
		if (mainScrollView && [mainScrollView respondsToSelector:@selector(didScroll)])
			[mainScrollView didScroll];
		
	} completion:^(BOOL finished) {
		
		[myTableView reloadData];
		[[self.navigationController.view viewWithTag:101010] removeFromSuperview];
		
	}];
}

-(void)closePicker:(UIButton*)sender
{
	currentRow = -1;
	
	if ([self.navigationController.view viewWithTag:989898] &&
	    [[self.navigationController.view viewWithTag:989898] isKindOfClass:[UIDatePicker class]])
	{
		[theTimeSheet setDate:((UIDatePicker*)[self.navigationController.view viewWithTag:989898]).date];
	}
	
	[(UITextField*)[self.view viewWithTag:111] resignFirstResponder];
	
	[[self.view viewWithTag:123123] removeFromSuperview];
	
	[UIView animateWithDuration:0.25 animations:^{
		
		[[self.navigationController.view viewWithTag:101010] setFrame:CGRectMake(0, dvc_height + 60, dvc_width, keyboard_height)];
		[theToolbar setFrame:CGRectMake(0, dvc_height, dvc_width, 40)];
		[mainScrollView setFrame:CGRectMake(mainScrollView.frame.origin.x, mainScrollView.frame.origin.y, dvc_width, dvc_height - 42)];
		if (mainScrollView && [mainScrollView respondsToSelector:@selector(didScroll)])
			[mainScrollView didScroll];
		
	} completion:^(BOOL finished) {
		
		[myTableView reloadData];
		[[self.navigationController.view viewWithTag:101010] removeFromSuperview];
		
	}];
}

#pragma mark - TEXTFIELD DELEGATE

-(void)textFieldDidBeginEditing:(UITextField*)textField
{
	if(textField.tag == 111)
	{
		[self showNext];
		currentRow = 0;
	}
	else
	if(textField.tag == 222)
	{
		[self showPercentage];
		currentRow = 2;
	}

	UIButton * closeAll = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
	[closeAll setBackgroundColor:[UIColor clearColor]];
	[closeAll addTarget:self action:@selector(cancelPicker:) forControlEvents:UIControlEventTouchUpInside];
	[closeAll setTag:123123];
	[theSelfView addSubview:closeAll];
	[theSelfView bringSubviewToFront:theToolbar];
}

-(BOOL)textFieldShouldBeginEditing:(UITextField*)textField
{
	[[self.navigationController.view viewWithTag:101010] removeFromSuperview];
		
	if(textField.tag != 111)
	{
		[textField setText:@""];
	}
	
	[UIView animateWithDuration:0.25 animations:^{
		
		[theToolbar setFrame:CGRectMake(0, dvc_height - keyboard_height - 40, dvc_width, 40)];
		[mainScrollView setFrame:CGRectMake(mainScrollView.frame.origin.x, mainScrollView.frame.origin.y, dvc_width, dvc_height - 82 - keyboard_height)];
		
		if (mainScrollView && [mainScrollView respondsToSelector:@selector(didScroll)])
			[mainScrollView didScroll];
		
	} completion:^(BOOL finished) {
		
		CGRect frame = textField.superview.frame;
		
		if (sys_version >= 7)
        {
			frame = textField.superview.superview.frame;
        }
        
        if(sys_version >= 8)
        {
            frame = textField.superview.frame;
        }
		
		[mainScrollView scrollRectToVisible:frame animated:YES];
		
	}];
	
	return YES;
}

-(void)textFieldDidEndEditing:(UITextField*)textField
{
	if (has_alertview)
		return;
	
	switch (textField.tag)
	{
		case 111:
		{
			[theTimeSheet setNumber:textField.text];
			break;
		}
			
		case 222:
		{
			if(percentage.selected == YES)
			{
				float textValue = [textField.text floatValue];
				float discount = ([theTimeSheet subtotal] * textValue) / 100;
				
				[theTimeSheet setDiscount:discount];
			}
			else
				if(value.selected == YES)
				{
					float textValue = [textField.text floatValue];
					[theTimeSheet setDiscount:textValue];
				}
			
			break;
		}
			
		default:
			break;
	}
}

-(BOOL)textFieldShouldReturn:(UITextField*)textField
{
	currentRow = -1;
	
	[textField resignFirstResponder];
	
	return YES;
}

#pragma mark - MAIL COMPOSER DELEGATE

-(void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
	[controller dismissViewControllerAnimated:YES completion:nil];
	
	if(result == MFMailComposeResultFailed && error != nil)
	{
		[[[UIAlertView alloc] initWithTitle:@"Failed to send email" message:error.localizedDescription delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
	}
}

#pragma mark
#pragma mark SIGNATURE DELEGATE

-(void)creatorViewController:(AddSignatureAndDateVC *)viewController createdSignature:(UIImage *)signature withFrame:(CGRect)frame title:(NSString *)title andDate:(NSDate *)date
{
	switch (viewController.signatureType)
	{
		case kSignatureTypeLeft:
		{
			[theTimeSheet setLeftSignature:signature];
			[theTimeSheet setLeftSignatureDate:date];
			[theTimeSheet setLeftSignatureTitle:title];
			[theTimeSheet setLeftSignatureFrame:frame];
						
			break;
		}
			
		case kSignatureTypeRight:
		{			
			[theTimeSheet setRightSignature:signature];
			[theTimeSheet setRightSignatureDate:date];
			[theTimeSheet setRightSignatureTitle:title];
			[theTimeSheet setRightSignatureFrame:frame];
			
			break;
		}
	}
}

#pragma mark
#pragma mark TIME EDITOR DELEGATE

-(void)editorViewController:(SelectServiceTimeVC *)viewController editedTime:(ServiceTimeOBJ *)time
{
	if(service_time_index == -1)
	{
		[theTimeSheet addServiceTime:time];
	}
	else
	{
		[theTimeSheet replaceServiceTime:time atIndex:service_time_index];
	}
	
	float total = 0.0f;
	
	for(int i=0;i<[theTimeSheet services].count;i++)
	{
		ServiceTimeOBJ *time = [theTimeSheet serviceTimeAtIndex:i];
		total += [time getTotal];
	}
	
	[theTimeSheet setSubtotal:total];
		
	service_time_index = -1;
}

#pragma mark
#pragma mark ACTIONS

-(void)next:(UIButton*)sender
{
	switch (currentRow)
	{
		case 0:
		{
			[(UITextField*)[self.view viewWithTag:111] resignFirstResponder];
			[self performSelector:@selector(openPicker) withObject:nil afterDelay:0.3];
			break;
		}
			
		case 1:
		{
			[self closePicker:nil];
			
			[(UITextField*)[self.view viewWithTag:222] performSelector:@selector(becomeFirstResponder) withObject:nil afterDelay:0.3];
			
			break;
		}
			
		default:
			break;
	}
}

-(void)prev:(UIButton*)sender
{
	switch (currentRow)
	{
		case 1:
		{
			[self closePicker:nil];
			
			[(UITextField*)[self.view viewWithTag:111] performSelector:@selector(becomeFirstResponder) withObject:nil afterDelay:0.3];
			
			break;
		}
			
		default:
			break;
	}
}

-(void)cancel:(UIButton*)sender
{
	[self dismissViewControllerAnimated:YES completion:nil];
}

-(void)done:(UIButton*)sender
{
	NSString * message = @"";
		
	if ([[[[theTimeSheet client] contentsDictionary] objectForKey:@"firstName"] isEqual:@""])
	{
		message = @"Please select a client.";
	}
	
	if ([theTimeSheet services].count == 0 && [message isEqual:@""])
	{
		message = @"Please select at least one product or service.";
	}
	
	if (![message isEqual:@""])
	{
		[[[AlertView alloc] initWithTitle:@"Error" message:message delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] showInWindow];
		return;
	}

	
	if ([delegate respondsToSelector:@selector(creatorViewController:createdTimesheet:)])
	{
		[delegate creatorViewController:self createdTimesheet:theTimeSheet];
	}
	
	[self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark
#pragma mark TOOLBAR BUTTONS

-(void)showBoth
{
	percentage.alpha = 0.0;
	value.alpha = 0.0;
	
	theToolbar.nextButton.alpha = 1.0;
	theToolbar.prevButton.alpha = 1.0;
}

-(void)showNext
{
	percentage.alpha = 0.0;
	value.alpha = 0.0;
	
	theToolbar.nextButton.alpha = 1.0;
	theToolbar.prevButton.alpha = 0.5;
}

-(void)showPrev
{
	percentage.alpha = 0.0;
	value.alpha = 0.0;
	
	theToolbar.nextButton.alpha = 0.5;
	theToolbar.prevButton.alpha = 1.0;
}

-(void)percentage:(UIButton*)sender
{
	[percentage setSelected:YES];
	[value setSelected:NO];
}

-(void)value:(UIButton*)sender
{
	[percentage setSelected:NO];
	[value setSelected:YES];
}

-(void)showPercentage
{
	theToolbar.nextButton.alpha = 0.0;
	theToolbar.prevButton.alpha = 0.0;
	
	percentage.alpha = 1.0;
	value.alpha = 1.0;
}

#pragma mark - VIEW CONTROLLER FUNCTIONS

-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	[myTableView reloadData];
	
	[myTableView layoutIfNeeded];
	[mainScrollView setContentSize:myTableView.contentSize];
	[myTableView setFrame:CGRectMake(0, 0, mainScrollView.contentSize.width, mainScrollView.contentSize.height)];
}

-(void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
}

-(void)dealloc
{
	[mainScrollView setDelegate:nil];

	[myTableView setDelegate:nil];
	[myTableView setDataSource:nil];
}

@end