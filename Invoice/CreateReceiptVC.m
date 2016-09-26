//
//  CreateReceiptVC2.m
//  Invoice
//
//  Created by XGRoup on 7/15/14.
//  Copyright (c) 2014 XGRoup. All rights reserved.
//

#import "CreateReceiptVC.h"

#import "Defines.h"
#import "ClientsVC.h"
#import "SelectProjectVC.h"
#import "CellWithPush.h"
#import "CellWithText.h"
#import "CellWithPicker.h"
#import "EditTitleVC.h"
#import "CategorySelectVC.h"
#import "CreateObjectiveVC.h"
#import "EditObjectiveVC.h"
#import "PhotoCell.h"

@interface CreateReceiptVC ()

<
UITableViewDelegate,
UITableViewDataSource,
UIScrollViewDelegate,
UITextFieldDelegate,
AlertViewDelegate,
ObjectiveCreatorDelegate,
ObjectiveEditorDelegate,
UIImagePickerControllerDelegate,
UINavigationControllerDelegate
>

@end

@implementation CreateReceiptVC

@synthesize delegate;

-(id)initForCreationWithDelegate:(id<ReceiptCreatorDelegate>)del
{
	self = [super init];
	
	if (self)
	{
		delegate = del;		
	}
	
	return self;
}

-(id)initWithReceipt:(ReceiptOBJ *)sender delegate:(id<ReceiptCreatorDelegate>)del
{
	self = [super init];
	
	if (self)
	{
		delegate = del;
		theReceipt = [[ReceiptOBJ alloc] initWithReceipt:sender];
	}
	
	return self;
}

#pragma mark - VIEW DID LOAD

-(void)viewDidLoad {
	[super viewDidLoad];

	theSelfView = [[UIView alloc] initWithFrame:CGRectMake(0, statusBarHeight, dvc_width, dvc_height)];
	[theSelfView setBackgroundColor:[UIColor clearColor]];
	[self.view addSubview:theSelfView];
	
	[self.view setBackgroundColor:app_background_color];
	
	topBarView = [[TopBar alloc] initWithFrame:CGRectMake(0, 0, dvc_width, 42 + statusBarHeight) andTitle:@"Create Receipt"];
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
	
	if (!theReceipt)
	{
		[topBarView setText:@"New Receipt"];
		
		theReceipt = [[ReceiptOBJ alloc] init];
	}
	else
	{
		[topBarView setText:@"Edit Receipt"];
	}
	
	currentRow = -1;
	
	typeOfTax = 1;
	
	if(![[theReceipt tax2Name] isEqual:@""])
	{
		typeOfTax++;
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
	[value setTitle:[NSString stringWithFormat:@"%@", [theReceipt sign]] forState:UIControlStateNormal];
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
	return 3;
}

-(NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
	if(section == 0)
		return 1;
	
	if(section == 1)
		return 9 + typeOfTax;
	
	if(section == 2)
		return 2;
	
	return 0;
}

-(UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
	UITableViewCell * theCell = [self cellInSection:(int)indexPath.section atRow:(int)indexPath.row];
	
	return theCell;
}

-(UIView*)tableView:(UITableView*)tableView viewForHeaderInSection:(NSInteger)section
{
	UIView * view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, dvc_width, 30)];
	[view setBackgroundColor:[UIColor clearColor]];
	
	UILabel * title = [[UILabel alloc] initWithFrame:CGRectMake(22, 0, dvc_width - 44, 30)];
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
		[title setText:@"Project (Optional)"];
	}
	
	return view;
}

#pragma mark - TABLE VIEW DELEGATE

-(CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
	if(indexPath.row == 8 + typeOfTax && ![theReceipt.imageString isEqual:@""])
	{
		return [PhotoCell heightForImage:[theReceipt getImage]];
	}
	
	return 42.0f;
}

-(CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section
{
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
	if (indexPath.section == 1 && indexPath.row == 8 + typeOfTax && ![[theReceipt imageString] isEqual:@""])
	{
		return YES;
	}
	
	return NO;
}

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"Delete"  handler:^(UITableViewRowAction *action, NSIndexPath *indexPath)
    {
        [theReceipt setImage:nil];
        
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
		[theReceipt setImage:nil];
			
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
			return [self cellForTitle:row];
			break;
		}
			
		case 1:
		{
			return [self cellForDetails:row];
			break;
		}
			
		case 2:
		{
			return [self cellForProject:row];
			break;
		}
	}
	
	return nil;
}

-(UITableViewCell*)cellForTitle:(int)row
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
			
			[(CellWithPush*)theCell loadTitle:@"Title" andValue:[theReceipt title] cellType:kCellTypeSingle andSize:0.0];
			[theCell setUserInteractionEnabled:YES];
			
			break;
		}
	}
	
	return theCell;
}

-(UITableViewCell*)cellForDetails:(int)row
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
			
			int temp = (int)[CustomDefaults customIntegerForKey:kNumberOfRecipeKeyForNSUserDefaults];
			
			NSString * valueSTR = [theReceipt number];
			
			if ([valueSTR isEqual:@"RT00001"])
			{
				if (temp < 10)
				{
					valueSTR = [NSString stringWithFormat:@"RT0000%d", temp];
				}
				else if (temp < 100)
				{
					valueSTR = [NSString stringWithFormat:@"RT000%d", temp];
				}
				else if (temp < 1000)
				{
					valueSTR = [NSString stringWithFormat:@"RT00%d", temp];
				}
				else if (temp < 10000)
				{
					valueSTR = [NSString stringWithFormat:@"RT0%d", temp];
				}
				else
				{
					valueSTR = [NSString stringWithFormat:@"RT%d", temp];
				}
			}
			
			[(CellWithText*)theCell loadTitle:@"Receipt No." andValue:valueSTR tag:222 textFieldDelegate:self cellType:kCellTypeTop andKeyboardType:UIKeyboardTypeDefault];
			
			break;
		}
			
		case 1:
		{
			theCell = [myTableView dequeueReusableCellWithIdentifier:@"tableCellPush"];
			
			if (!theCell)
			{
				theCell = [[CellWithPush alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"tableCellPush"];
			}
						
			[(CellWithPush*)theCell loadTitle:@"Category" andValue:[theReceipt category] cellType:kCellTypeMiddle andSize:20.0];
			[theCell setUserInteractionEnabled:YES];
			
			break;
		}
						
		case 2:
		{
			theCell = [myTableView dequeueReusableCellWithIdentifier:@"tableCellPush"];
			
			if(!theCell)
			{
				theCell = [[CellWithPush alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"tableCellPush"];
			}
			
			[(CellWithPush*)theCell loadTitle:@"Vendor" andValue:[NSString stringWithFormat:@"%@ %@",[[theReceipt client] firstName],[[theReceipt client] lastName]] cellType:kCellTypeMiddle andSize:20.0];
			
			break;
		}
			
		case 3:
		{
			theCell = [myTableView dequeueReusableCellWithIdentifier:@"tableCellPicker"];
			
			if (!theCell)
			{
				theCell = [[CellWithPicker alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"tableCellPicker"];
			}
			
			[date_formatter setDateFormat:[DELEGATE userSelectedDateFormat]];
			
			[(CellWithPicker*)theCell loadTitle:@"Date" andValue:[date_formatter stringFromDate:[theReceipt date]] cellType:kCellTypeMiddle];
			[theCell setUserInteractionEnabled:YES];
			
			break;
		}
			
		case 4:
		{
			theCell = [myTableView dequeueReusableCellWithIdentifier:@"tableCellText"];
			
			if (!theCell)
			{
				theCell = [[CellWithText alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"tableCellText"];
			}
								
			
			NSString *valueSTR = [data_manager currencyAdjustedValue:[theReceipt total] forSign:[theReceipt sign]];
			[(CellWithText*)theCell loadTitle:@"Subtotal" andValue:valueSTR tag:111 textFieldDelegate:self cellType:kCellTypeMiddle andKeyboardType:UIKeyboardTypeDecimalPad];

			
			break;
		}
			
		case 5:
		{
			theCell = [myTableView dequeueReusableCellWithIdentifier:@"tableCellText"];
			
			if (!theCell)
			{
				theCell = [[CellWithText alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"tableCellText"];
			}
						
			[(CellWithText*)theCell loadTitle:@"Currency sign" andValue:[theReceipt sign] tag:333 textFieldDelegate:self cellType:kCellTypeMiddle andKeyboardType:UIKeyboardTypeDefault];

			break;
		}
			
		case 6:
		{
			theCell = [myTableView dequeueReusableCellWithIdentifier:@"tableCellText"];
			
			if (!theCell)
			{
				theCell = [[CellWithText alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"tableCellText"];
			}
			
			NSString * title = [NSString stringWithFormat:@"Tax (%@%c)",[data_manager valueAdjusted:[theReceipt tax1ShowValue]],'%'];
			
			if(![[theReceipt tax1Name] isEqual:@""])
			{
				title = [NSString stringWithFormat:@"%@ (%@%c)", [theReceipt tax1Name], [data_manager valueAdjusted:[theReceipt tax1ShowValue]], '%'];
			}
			
			NSString *valueString = [data_manager currencyAdjustedValue:[theReceipt tax1Percentage] forSign:[theReceipt sign]];
									
			[(CellWithText*)theCell loadTitle:title andValue:valueString tag:444 textFieldDelegate:self cellType:kCellTypeMiddle andKeyboardType:UIKeyboardTypeDecimalPad];
			[theCell setUserInteractionEnabled:YES];
			
			break;
		}
			
		case 7:
		{
			if(typeOfTax == 2)
			{
				theCell = [myTableView dequeueReusableCellWithIdentifier:@"tableCellText"];
				
				if (!theCell)
				{
					theCell = [[CellWithText alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"tableCellText"];
				}
				
				NSString * title = [NSString stringWithFormat:@"%@ (%@%c)", [theReceipt tax2Name], [data_manager valueAdjusted:[theReceipt tax2ShowValue]], '%'];
				
				NSString *valueString = [data_manager currencyAdjustedValue:[theReceipt tax2Percentage] forSign:[theReceipt sign]];
								
				[(CellWithText*)theCell loadTitle:title andValue:valueString tag:555 textFieldDelegate:self cellType:kCellTypeMiddle andKeyboardType:UIKeyboardTypeDecimalPad];
				[theCell setUserInteractionEnabled:YES];
			}
			else
			{
				theCell = [myTableView dequeueReusableCellWithIdentifier:@"tableCellText"];
				
				if(!theCell)
				{
					theCell = [[CellWithText alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"tableCellText"];
				}
				
				[(CellWithText*)theCell loadTitle:@"Total" andValue:[data_manager currencyAdjustedValue:[theReceipt getTotal] forSign:[theReceipt sign]] tag:0 textFieldDelegate:nil cellType:kCellTypeMiddle andKeyboardType:UIKeyboardTypeDefault];
				[(CellWithText*)theCell setTextFieldEditable:NO];
			}
			
			break;
		}
			
		case 8:
		{
			if(typeOfTax == 2)
			{
				theCell = [myTableView dequeueReusableCellWithIdentifier:@"tableCellText"];
				
				if(!theCell)
				{
					theCell = [[CellWithText alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"tableCellText"];
				}
				
				[(CellWithText*)theCell loadTitle:@"Total" andValue:[data_manager currencyAdjustedValue:[theReceipt getTotal] forSign:[theReceipt sign]] tag:0 textFieldDelegate:nil cellType:kCellTypeMiddle andKeyboardType:UIKeyboardTypeDefault];
				[(CellWithText*)theCell setTextFieldEditable:NO];

				
			}
			else
			{
				theCell = [myTableView dequeueReusableCellWithIdentifier:@"tableCellPush"];
				
				if (!theCell)
				{
					theCell = [[CellWithPush alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"tableCellPush"];
				}
				
				[(CellWithPush*)theCell loadTitle:@"Description" andValue:[theReceipt receiptDescription] cellType:kCellTypeMiddle andSize:0.0];
				[theCell setUserInteractionEnabled:YES];
			}
			
			break;
		}
			
		case 9:
		{
			if(typeOfTax == 2)
			{
				theCell = [myTableView dequeueReusableCellWithIdentifier:@"tableCellPush"];
				
				if (!theCell)
				{
					theCell = [[CellWithPush alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"tableCellPush"];
				}
				
				[(CellWithPush*)theCell loadTitle:@"Description" andValue:[theReceipt receiptDescription] cellType:kCellTypeMiddle andSize:0.0];
				[theCell setUserInteractionEnabled:YES];
			}
			else
			{
				UITableViewCell * theCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
				
				UIView * empty = [[UIView alloc] initWithFrame:CGRectMake(0, 0, dvc_width, 42)];
				[empty setBackgroundColor:[UIColor clearColor]];
				[theCell setBackgroundView:empty];
				
				if([[theReceipt imageString] isEqual:@""])
				{
					theCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
					[theCell setSelectionStyle:UITableViewCellSelectionStyleNone];
					
					UIImageView * bgImg = [[UIImageView alloc] initWithFrame:CGRectMake(10, 0, dvc_width - 20, 42)];
					[bgImg setImage:[[UIImage imageNamed:@"tableBottomCellWhite.png"] stretchableImageWithLeftCapWidth:20 topCapHeight:15]];
					[theCell addSubview:bgImg];
					
					if (row == 0)
					{
						[bgImg setImage:[[UIImage imageNamed:@"tableSingleCellWhite.png"] stretchableImageWithLeftCapWidth:20 topCapHeight:15]];
					}
					
					UIView * bg = [[UIView alloc] initWithFrame:CGRectMake(0, 0, dvc_width, 42)];
					[bg setBackgroundColor:[UIColor clearColor]];
					
					[theCell setBackgroundView:bg];
					[theCell setBackgroundColor:[UIColor clearColor]];
					
					UILabel * nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, dvc_width - 10 - 55, 42)];
					[nameLabel setText:@"Photo"];
					[nameLabel setTextAlignment:NSTextAlignmentLeft];
					[nameLabel setFont:HelveticaNeue(16)];
					[nameLabel setBackgroundColor:[UIColor clearColor]];
					[nameLabel setTextColor:[UIColor grayColor]];
					[theCell addSubview:nameLabel];
					
					UIImageView * plus = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
					[plus setImage:[UIImage imageNamed:@"plus.png"]];
					[plus setCenter:CGPointMake(dvc_width - 30, 21)];
					[theCell addSubview:plus];
				}
				else
				{
					theCell = [myTableView dequeueReusableCellWithIdentifier:@"photo_cell"];
					
					if (!theCell)
					{
						theCell = [[PhotoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"photo_cell"];
					}
					
					[theCell setBackgroundColor:[UIColor clearColor]];
					[theCell setSelectionStyle:UITableViewCellSelectionStyleNone];
					
					[(PhotoCell*)theCell loadImage:[theReceipt getImage] withType:kCellTypeBottom];
					
				}
				
				return theCell;
			}
						
			break;
		}
			
		case 10:
		{
			UITableViewCell * theCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
			
			UIView * empty = [[UIView alloc] initWithFrame:CGRectMake(0, 0, dvc_width, 42)];
			[empty setBackgroundColor:[UIColor clearColor]];
			[theCell setBackgroundView:empty];
			
			if([theReceipt.imageString isEqual:@""])
			{
				theCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
				[theCell setSelectionStyle:UITableViewCellSelectionStyleNone];
				
				UIImageView * bgImg = [[UIImageView alloc] initWithFrame:CGRectMake(10, 0, dvc_width - 20, 42)];
				[bgImg setImage:[[UIImage imageNamed:@"tableBottomCellWhite.png"] stretchableImageWithLeftCapWidth:20 topCapHeight:15]];
				[theCell addSubview:bgImg];
				
				if (row == 0)
				{
					[bgImg setImage:[[UIImage imageNamed:@"tableSingleCellWhite.png"] stretchableImageWithLeftCapWidth:20 topCapHeight:15]];
				}
				
				UIView * bg = [[UIView alloc] initWithFrame:CGRectMake(0, 0, dvc_width, 42)];
				[bg setBackgroundColor:[UIColor clearColor]];
				
				[theCell setBackgroundView:bg];
				[theCell setBackgroundColor:[UIColor clearColor]];
				
				UILabel * nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, dvc_width - 10 - 55, 42)];
				[nameLabel setText:@"Photo"];
				[nameLabel setTextAlignment:NSTextAlignmentLeft];
				[nameLabel setFont:HelveticaNeue(16)];
				[nameLabel setBackgroundColor:[UIColor clearColor]];
				[nameLabel setTextColor:[UIColor grayColor]];
				[theCell addSubview:nameLabel];
				
				UIImageView * plus = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
				[plus setImage:[UIImage imageNamed:@"plus.png"]];
				[plus setCenter:CGPointMake(dvc_width - 30, 21)];
				[theCell addSubview:plus];
			}
			else
			{
				theCell = [myTableView dequeueReusableCellWithIdentifier:@"photo_cell"];
				
				if (!theCell)
				{
					theCell = [[PhotoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"photo_cell"];
				}
				
				[theCell setBackgroundColor:[UIColor clearColor]];
				[theCell setSelectionStyle:UITableViewCellSelectionStyleNone];
				
				[(PhotoCell*)theCell loadImage:[theReceipt getImage] withType:kCellTypeBottom];
				
			}
			
			return theCell;
		}
							
		default:
			break;
	}
	
	return theCell;

}

-(UITableViewCell*)cellForProject:(int)row
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
			
			[(CellWithPush*)theCell loadTitle:@"Project Name" andValue:[[theReceipt project] projectName] cellType:kCellTypeTop andSize:20.0];
			
			break;
		}
			
		case 1:
		{
			theCell = [myTableView dequeueReusableCellWithIdentifier:@"tableCellPush"];
			
			if(!theCell)
			{
				theCell = [[CellWithPush alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"tableCellPush"];
			}
			
			[(CellWithPush*)theCell loadTitle:@"Project No." andValue:[[theReceipt project] projectNumber] cellType:kCellTypeBottom andSize:20.0];
			
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
			[self selectedDetailsCellRow:row];
			break;
		}
			
		case 2:
		{
			[self selectedProjectCellRow:row];
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
			EditTitleVC * vc = [[EditTitleVC alloc] initWithReceipt:theReceipt];
			[self.navigationController pushViewController:vc animated:YES];
			
			break;
		}
	}

}

-(void)selectedDetailsCellRow:(int)row
{
	switch (row)
	{
		case 1:
		{
			CategorySelectVC *vc = [[CategorySelectVC alloc] initWithReceipt:theReceipt];
			[self.navigationController pushViewController:vc animated:YES];
			
			break;
		}
						
		case 2:
		{
			ClientsVC *vc = [[ClientsVC alloc] initWithReceipt:theReceipt];
			[self.navigationController pushViewController:vc animated:YES];
			
			break;
		}
			
		case 3:
		{
			[self openPicker];
			
			break;
		}
			
		case 8:
		{
			if(typeOfTax == 1)
			{
				if([theReceipt receiptDescription].length == 0)
				{
					CreateObjectiveVC * vc = [[CreateObjectiveVC alloc] initWithDelegate:self];
					[self.navigationController pushViewController:vc animated:YES];
				}
				else
				{
					EditObjectiveVC * vc = [[EditObjectiveVC alloc] initWithDelegate:self andObjective:theReceipt.receiptDescription];
					[self.navigationController pushViewController:vc animated:YES];
				}
			}
			
			break;
		}
						
		case 9:
		{
			if(typeOfTax == 2)
			{
				if([theReceipt receiptDescription].length == 0)
				{
					CreateObjectiveVC * vc = [[CreateObjectiveVC alloc] initWithDelegate:self];
					[self.navigationController pushViewController:vc animated:YES];
				}
				else
				{
					EditObjectiveVC * vc = [[EditObjectiveVC alloc] initWithDelegate:self andObjective:theReceipt.receiptDescription];
					[self.navigationController pushViewController:vc animated:YES];
				}
			}
			else
			{
				NSMutableArray * btns = [[NSMutableArray alloc] initWithArray:[NSArray arrayWithObject:@"Photo Library"]];
				
				if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
				{
					[btns addObject:@"Camera"];
				}
				
				AlertView * alert = [[AlertView alloc] initWithTitle:@"Select source:" message:@"" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:btns];
				[alert setTag:-1];
				[alert showInWindow];
			}

			break;
		}
			
		case 10:
		{
			NSMutableArray * btns = [[NSMutableArray alloc] initWithArray:[NSArray arrayWithObject:@"Photo Library"]];
			
			if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
			{
				[btns addObject:@"Camera"];
			}
			
			AlertView * alert = [[AlertView alloc] initWithTitle:@"Select source:" message:@"" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:btns];
			[alert setTag:-1];
			[alert showInWindow];
			
			break;
		}
			
		default:
			break;
	}
}

-(void)selectedProjectCellRow:(int)row
{
	switch (row)
	{
		case 0:
		{
			SelectProjectVC *vc = [[SelectProjectVC alloc] initWithReceipt:theReceipt];
			[self.navigationController pushViewController:vc animated:YES];
			
			break;
		}
			
		case 1:
		{
			SelectProjectVC *vc = [[SelectProjectVC alloc] initWithReceipt:theReceipt];
			[self.navigationController pushViewController:vc animated:YES];
			
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
	[(UITextField*)[self.view viewWithTag:222] resignFirstResponder];
	[(UITextField*)[self.view viewWithTag:333] resignFirstResponder];
	[(UITextField*)[self.view viewWithTag:444] resignFirstResponder];
	[(UITextField*)[self.view viewWithTag:555] resignFirstResponder];
	
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
	[picker setDate:[theReceipt date]];
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
	[(UITextField*)[self.view viewWithTag:222] resignFirstResponder];
	[(UITextField*)[self.view viewWithTag:333] resignFirstResponder];
	[(UITextField*)[self.view viewWithTag:444] resignFirstResponder];
	[(UITextField*)[self.view viewWithTag:555] resignFirstResponder];
	
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
		[theReceipt setDate:((UIDatePicker*)[self.navigationController.view viewWithTag:989898]).date];
	}
	
	[(UITextField*)[self.view viewWithTag:111] resignFirstResponder];
	[(UITextField*)[self.view viewWithTag:222] resignFirstResponder];
	[(UITextField*)[self.view viewWithTag:333] resignFirstResponder];
	[(UITextField*)[self.view viewWithTag:444] resignFirstResponder];
	[(UITextField*)[self.view viewWithTag:555] resignFirstResponder];
	
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
	if(textField.tag == 222)
	{
		[self showNext];
		currentRow = 0;
	}
	else
	if(textField.tag == 111)
	{
		[self showBoth];
		currentRow = 2;
	}
	else
	if(textField.tag == 333)
	{
		[self showBoth];
		currentRow = 3;
	}
	if(textField.tag == 444)
	{
		[self showPercentage];
		
		currentRow = 4;
	}
	else
	if(textField.tag == 555)
	{
		[self showPercentage];

		currentRow = 5;
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
	
	if (textField.tag != 222 && textField.tag != 333)
		[textField setText:[data_manager currencyStrippedString:textField.text]];
	
	if ([textField.text floatValue] == 0.0f && textField.tag != 222 && textField.tag != 333)
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
		case 222:
		{
			[theReceipt setNumber:textField.text];
			break;
		}
			
		case 111:
		{
			[theReceipt setTotal:[textField.text floatValue]];
			break;
		}
			
		case 333:
		{
			[theReceipt setSign:textField.text];
			
			[value setTitle:[NSString stringWithFormat:@"%@", [theReceipt sign]] forState:UIControlStateNormal];
			[value setTitle:[NSString stringWithFormat:@"%@", [theReceipt sign]] forState:UIControlStateSelected];
			[value setSelected:value.selected];
			
			break;
		}
			
		case 444:
		{
			if(percentage.selected)
			{
				float total = [theReceipt total];
				
				if(total != 0)
				{
					float temp = ([textField.text floatValue] * total) / 100;
					[theReceipt setTax1Percentage:temp];
				}
			}
			else
			{
				[theReceipt setTax1Percentage:[textField.text floatValue]];
			}
			
			break;
		}
			
		case 555:
		{
			if(percentage.selected)
			{
				float total = [theReceipt total];
				
				if(total != 0)
				{
					float temp = ([textField.text floatValue] * total) / 100;
					[theReceipt setTax2Percentage:temp];
				}
			}
			else
			{
				[theReceipt setTax2Percentage:[textField.text floatValue]];
			}
			
			break;
		}
			
		default:
			break;
	}
	
	if (textField.tag != 222 && textField.tag != 333 && textField.tag != 444 && textField.tag != 555)
		[textField setText:[data_manager currencyAdjustedValue:[textField.text floatValue] forSign:[theReceipt sign]]];
}

-(BOOL)textFieldShouldReturn:(UITextField*)textField
{
	currentRow = -1;
		
	[textField resignFirstResponder];
	
	return YES;
}

-(BOOL)textField:(UITextField*)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString*)string
{
	if (textField.tag != 222 && textField.tag != 333 && textField.tag != 444 && textField.tag != 555)
		return YES;
	
	NSString * result = [textField.text stringByReplacingCharactersInRange:range withString:string];
	
	if (result.length > 14)
		return NO;
	
	return YES;
}

#pragma mark
#pragma mark OBJECTIVE DELEGATES

-(void)creatorViewController:(CreateObjectiveVC *)viewController createdObjective:(NSString *)objective
{
	[theReceipt setReceiptDescription:objective];
}

-(void)editorViewController:(EditObjectiveVC *)viewController editedObjective:(NSString *)objective
{
	[theReceipt setReceiptDescription:objective];
}

#pragma mark
#pragma mark IMAGE PICKER DELEGATE

-(void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary*)info
{
	dispatch_async(dispatch_get_main_queue(), ^{
		
		[DELEGATE addLoadingView];
		
	});
	
	float delayInSeconds = 0.1;
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
	dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
		
		UIImage * selectedImage = [[UIImage alloc] initWithData:UIImagePNGRepresentation([data_manager scaleAndRotateImage:[info objectForKey:UIImagePickerControllerOriginalImage] andResolution:640])];

		[theReceipt setImage:UIImageJPEGRepresentation(selectedImage, 1.0)];
				
		[myTableView reloadData];
		
		[picker dismissViewControllerAnimated:YES completion:nil];
		
		[DELEGATE removeLoadingView];
		
	});
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController*)picker
{
	[picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark
#pragma mark ALERT VIEW DELEGATE

-(void)alertView:(AlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	has_alertview = NO;
	
	if (buttonIndex == 1)
	{
		UIImagePickerController * picker = [[UIImagePickerController alloc] init];
		[picker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
		[picker setDelegate:self];
		[self.navigationController presentViewController:picker animated:YES completion:nil];
	}
	else if (buttonIndex == 2)
	{
		UIImagePickerController * picker = [[UIImagePickerController alloc] init];
		[picker setSourceType:UIImagePickerControllerSourceTypeCamera];
		
		[picker setDelegate:self];
		[self.navigationController presentViewController:picker animated:YES completion:nil];
	}
}

#pragma mark 
#pragma mark ACTIONS

-(void)next:(UIButton*)sender
{
	switch (currentRow)
	{
		case 0:
		{
			[(UITextField*)[self.view viewWithTag:222] resignFirstResponder];
			[self performSelector:@selector(openPicker) withObject:nil afterDelay:0.3];
			
			break;
		}
			
		case 1:
		{
			[self closePicker:nil];
			[(UITextField*)[self.view viewWithTag:111] performSelector:@selector(becomeFirstResponder) withObject:nil afterDelay:0.3];
			
			break;
		}
			
		case 2:
		{
			[(UITextField*)[self.view viewWithTag:333] becomeFirstResponder];
			
			break;
		}
			
		case 3:
		{
			[(UITextField*)[self.view viewWithTag:444] becomeFirstResponder];
			
			break;
		}
			
		case 4:
		{
			[(UITextField*)[self.view viewWithTag:555] becomeFirstResponder];
			
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
			[(UITextField*)[self.view viewWithTag:222] performSelector:@selector(becomeFirstResponder) withObject:nil afterDelay:0.3];
			
			break;
		}
			
		case 2:
		{
			[(UITextField*)[self.view viewWithTag:111] resignFirstResponder];
			[self performSelector:@selector(openPicker) withObject:nil afterDelay:0.3];
			
			break;
		}
			
		case 3:
		{
			[(UITextField*)[self.view viewWithTag:111] becomeFirstResponder];
			break;
		}
			
		case 4:
		{
			[(UITextField*)[self.view viewWithTag:333] becomeFirstResponder];
			
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
	if ([delegate respondsToSelector:@selector(creatorViewController:createdReceipt:)])
	{
		[delegate creatorViewController:self createdReceipt:theReceipt];
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
	[myTableView setDelegate:nil];
	[myTableView setDataSource:nil];
	
	[mainScrollView setDelegate:nil];
}

@end
