//
//  CategorySelectVC.m
//  Invoice
//
//  Created by XGRoup on 7/15/14.
//  Copyright (c) 2014 XGRoup. All rights reserved.
//

#import "CategorySelectVC.h"

#import "Defines.h"
#import "CellWithPush.h"
#import "CellWithText.h"

@interface CategorySelectVC ()
<

UITextFieldDelegate,
UIScrollViewDelegate,
UITableViewDataSource,
UITableViewDelegate

>
@end

@implementation CategorySelectVC

-(id)initWithReceipt:(ReceiptOBJ*)sender
{
	self = [super init];
	
	if(self)
	{
		theReceipt = sender;
		categoriesArray = [[NSMutableArray alloc] initWithArray:[data_manager getReceiptCategories]];
	}
	
	return self;
}

-(void)viewDidLoad
{
	[super viewDidLoad];
	
	categoryAdded = NO;
	
	theSelfView = [[UIView alloc] initWithFrame:CGRectMake(0, statusBarHeight, dvc_width, dvc_height)];
	[theSelfView setBackgroundColor:[UIColor clearColor]];
	[self.view addSubview:theSelfView];
	
	[self.view setBackgroundColor:app_background_color];
	
	TopBar * topBarView = [[TopBar alloc] initWithFrame:CGRectMake(0, 0, dvc_width, 42 + statusBarHeight) andTitle:@"Edit Invoice"];
	[topBarView setText:@"Categories"];
	[topBarView setBackgroundColor:app_bar_update_color];
	
	BackButton * backButton = [[BackButton alloc] initWithFrame:CGRectMake(0, 42 + statusBarHeight - 40, 70, 40) andTitle:@"Back"];
	[backButton addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
	[topBarView addSubview:backButton];
				
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
				
	UIView * bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, dvc_width, dvc_height - 42)];
	[bgView setBackgroundColor:[UIColor clearColor]];
	[myTableView setBackgroundView:bgView];
	
	[self.view addSubview:topBarView];
	
	theToolbar = [[ToolBarView alloc] initWithFrame:CGRectMake(0, dvc_height, dvc_width, 40)];
	[theToolbar.prevButton setAlpha:0.0];
	[theToolbar.nextButton setAlpha:0.0];
	[theToolbar.doneButton addTarget:self action:@selector(closePicker:) forControlEvents:UIControlEventTouchUpInside];
	[theSelfView addSubview:theToolbar];

}

#pragma mark - TABLE VIEW DATASOURCE

-(NSInteger)numberOfSectionsInTableView:(UITableView*)tableView
{
	return 2;
}

-(NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
	if(section == 0)
	{
		if(categoryAdded == YES)
			return 2;
		
		return 1;
	}

	return categoriesArray.count;
}

-(UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
	UITableViewCell * theCell = [self cellInSection:(int)indexPath.section atRow:(int)indexPath.row];
	
	return theCell;
}

-(UIView*)tableView:(UITableView*)tableView viewForHeaderInSection:(NSInteger)section
{
	UIView * view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, dvc_width, 20)];
	[view setBackgroundColor:[UIColor clearColor]];
	
	return view;
}

#pragma mark - TABLE VIEW DELEGATE

-(CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
	return 42.0f;
}

-(CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section
{
	if(section == 1)
		return 10.0f;
	
	return 20.0f;
}

-(void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
	UITableViewCell * theCell = [tableView cellForRowAtIndexPath:indexPath];
	
	if ([theCell isKindOfClass:[CellWithText class]])
	{
		[(CellWithText*)theCell animateSelection];
	}
	
	[self selectedCellInSection:(int)indexPath.section atRow:(int)indexPath.row];
}

-(BOOL)tableView:(UITableView*)tableView canEditRowAtIndexPath:(NSIndexPath*)indexPath
{
	if (indexPath.section == 1)
	{
		return YES;
	}
	
	return NO;
}

-(NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"Delete"  handler:^(UITableViewRowAction *action, NSIndexPath *indexPath)
    {
        [categoriesArray removeObjectAtIndex:indexPath.row];
        [data_manager saveReceiptsCategories:categoriesArray];
        
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
		[categoriesArray removeObjectAtIndex:indexPath.row];
		[data_manager saveReceiptsCategories:categoriesArray];
		
		[myTableView reloadData];
		
		[myTableView layoutIfNeeded];
		[mainScrollView setContentSize:myTableView.contentSize];
		[myTableView setFrame:CGRectMake(0, 0, mainScrollView.contentSize.width, mainScrollView.contentSize.height)];
	}
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
  if([cell respondsToSelector:@selector(setCellWidth:)])
    [(BaseTableCell *)cell setCellWidth:tableView.frame.size.width];
}

#pragma mark - CELL GENERATION

-(UITableViewCell*)cellInSection:(int)section atRow:(int)row
{
	switch (section)
	{
		case 0:
		{
			return [self newCategoryCell:row];
			break;
		}
			
		case 1:
		{
			return [self categoryCell:row];
			break;
		}
	}
	
	return nil;
}

-(UITableViewCell*)newCategoryCell:(int)row
{
	UITableViewCell * theCell;
	
	switch (row)
	{
		case 0:
		{
			theCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
			theCell.selectionStyle = UITableViewCellSelectionStyleNone;
			
			UIView * bg = [[UIView alloc] initWithFrame:CGRectMake(0, 0, dvc_width, 44)];
			[bg setBackgroundColor:[UIColor clearColor]];
			
			[theCell setBackgroundView:bg];
			[theCell setBackgroundColor:[UIColor clearColor]];
			
			UIImageView * bgImg = [[UIImageView alloc] initWithFrame:CGRectMake(10, 0, dvc_width - 20, 42)];
			[theCell addSubview:bgImg];
			
			if (sys_version < 7)
			{
				[bgImg setFrame:CGRectMake(10, 0, dvc_width - 20, 43)];
			}
			
			if (categoryAdded == NO)
			{
				[bgImg setImage:[[UIImage imageNamed:@"tableSingleCellWhite.png"] stretchableImageWithLeftCapWidth:20 topCapHeight:15]];
			}
			else
			{
				[bgImg setImage:[[UIImage imageNamed:@"tableTopCellWhite.png"] stretchableImageWithLeftCapWidth:20 topCapHeight:15]];
			}
			
			UILabel * nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, dvc_width - 10 - 35, 44)];
			[nameLabel setText:@"New Category"];
			[nameLabel setTextAlignment:NSTextAlignmentLeft];
			[nameLabel setFont:HelveticaNeue(16)];
			[nameLabel setBackgroundColor:[UIColor clearColor]];
			[nameLabel setTextColor:[UIColor grayColor]];
			[theCell addSubview:nameLabel];
			
			UIImageView * plus = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
			[plus setImage:[UIImage imageNamed:@"plus.png"]];
			[plus setCenter:CGPointMake(dvc_width - 30, 21)];
			[theCell addSubview:plus];

			
			break;
		}
			
		case 1:
		{
			theCell = [[CellWithText alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
			
			[(CellWithText*)theCell loadTitle:@"Title" andValue:@"" tag:111 textFieldDelegate:self cellType:kCellTypeBottom andKeyboardType:UIKeyboardTypeDefault];
			
			[self performSelector:@selector(appearTextField:) withObject:[(CellWithText*)theCell valueTextField] afterDelay:0.3];

			break;
		}
			
			
		default:
			break;
	}
	
	return theCell;

}

-(UITableViewCell*)categoryCell:(int)row
{
	UITableViewCell *theCell = [myTableView dequeueReusableCellWithIdentifier:@"tableCellText"];
	
	if (!theCell)
	{
		theCell = [[CellWithText alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"tableCellText"];
	}
		
	kCellType type = kCellTypeTop;

	if(row > 0)
	{
		type = kCellTypeMiddle;
	}
	
	if(row == categoriesArray.count - 1)
	{
		type = kCellTypeBottom;
	}
	
	if(categoriesArray.count == 1)
	{
		type = kCellTypeSingle;
	}
	
	[(CellWithText*)theCell loadTitle:[categoriesArray objectAtIndex:row] andValue:@"" tag:555 textFieldDelegate:self cellType:type andKeyboardType:UIKeyboardTypeDefault];
	[(CellWithText*)theCell setTextFieldEditable:NO];
	
	return theCell;
}

#pragma mark - CELL SELECTION

-(void)selectedCellInSection:(int)section atRow:(int)row
{	
	switch (section)
	{
		case 0:
		{
			if(categoryAdded == NO)
			{
				[self selectedNewCategory:row];
			}
			
			break;
		}
			
		case 1:
		{
			[theReceipt setCategory:[categoriesArray objectAtIndex:row]];
			[self back:nil];
			
			break;
		}
			
		default:
			break;
	}
}

-(void)selectedNewCategory:(int)row
{
	switch (row)
	{
		case 0:
		{
			categoryAdded = YES;
			[myTableView reloadData];
			
			[myTableView layoutIfNeeded];
			[mainScrollView setContentSize:myTableView.contentSize];
			[myTableView setFrame:CGRectMake(0, 0, mainScrollView.contentSize.width, mainScrollView.contentSize.height)];
						
			break;
		}
			
		default:
			break;
	}
}

#pragma mark 
#pragma mark TEXT FIELD DELEGATE
-(void)textFieldDidBeginEditing:(UITextField*)textField
{
	[theSelfView bringSubviewToFront:theToolbar];
}

-(BOOL)textFieldShouldBeginEditing:(UITextField*)textField
{
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
	if(![textField.text isEqual:@""])
	{
		[categoriesArray insertObject:textField.text atIndex:0];
		[data_manager saveReceiptsCategories:categoriesArray];
	}
	
	categoryAdded = NO;
	[myTableView reloadData];
	
	[myTableView layoutIfNeeded];
	[mainScrollView setContentSize:myTableView.contentSize];
	[myTableView setFrame:CGRectMake(0, 0, mainScrollView.contentSize.width, mainScrollView.contentSize.height)];
}

-(BOOL)textFieldShouldEndEditing:(UITextField*)textField
{
	return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField*)textField
{
	[textField resignFirstResponder];
	
	return YES;
}

-(void)appearTextField:(UITextField*)sender
{
	[sender becomeFirstResponder];
}

#pragma mark
#pragma mark SCROLL VIEW DELEGATE

-(void)scrollViewDidScroll:(UIScrollView*)scrollView
{
	if ([scrollView isKindOfClass:[ScrollWithShadow class]])
		[(ScrollWithShadow*)scrollView didScroll];
}

#pragma mark 
#pragma mark TOOLBAR ACTIONS

-(void)closePicker:(UIButton*)button
{
	[(UITextField*)[self.view viewWithTag:111] resignFirstResponder];
	
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

#pragma mark
#pragma mark ACTIONS

-(void)back:(UIButton*)button
{
	[self.navigationController popViewControllerAnimated:YES];
}

-(void)dealloc
{
	[mainScrollView setDelegate:nil];
}

@end
