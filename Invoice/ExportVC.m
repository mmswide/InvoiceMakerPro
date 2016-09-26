//
//  ExportVC.m
//  Invoice
//
//  Created by Paul on 19/06/14.
//  Copyright (c) 2014 XGRoup. All rights reserved.
//

#import "ExportVC.h"

#import "Defines.h"

#import "CellWithPicker.h"

#import "AlertView.h"

#import "MKStoreManager.h"

@interface ExportVC () <UITableViewDataSource,UITableViewDelegate,UIPickerViewDataSource,UIPickerViewDelegate,MFMailComposeViewControllerDelegate,UIScrollViewDelegate>

@end

@implementation ExportVC

-(id)init
{
	self = [super init];
	
	if(self)
	{
		theExport = [[ExportOBJ alloc] init];
		
		categoriesArray = [[NSArray alloc] initWithArray:[data_manager generateExportCategories]];
		
		numberOfRows = 3;
	}
	
	return self;
}

-(void)viewDidLoad
{
	[super viewDidLoad];
	
	theSelfView = [[UIView alloc] initWithFrame:CGRectMake(0, statusBarHeight, dvc_width, dvc_height)];
	[theSelfView setBackgroundColor:[UIColor clearColor]];
	[self.view addSubview:theSelfView];
	
	[self.view setBackgroundColor:app_background_color];
	
	topBarView = [[TopBar alloc] initWithFrame:CGRectMake(0, 0, dvc_width, 42 + statusBarHeight) andTitle:@"Export CSV"];
	[topBarView setBackgroundColor:app_bar_update_color];
	
	UIButton * cancel = [[UIButton alloc] initWithFrame:CGRectMake(0, 42 + statusBarHeight - 40, 80, 40)];
	[cancel setTitle:@"Cancel" forState:UIControlStateNormal];
	[cancel setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[cancel setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
	[cancel.titleLabel setFont:HelveticaNeueLight(17)];
	[cancel addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
	[topBarView addSubview:cancel];
	
	exportButton = [[UIButton alloc] initWithFrame:CGRectMake(dvc_width - 80, 42 + statusBarHeight - 40, 80, 40)];
	[exportButton setTitle:@"Export" forState:UIControlStateNormal];
	[exportButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
	[exportButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
	[exportButton.titleLabel setFont:HelveticaNeueLight(17)];
	[exportButton setUserInteractionEnabled:NO];
	[exportButton addTarget:self action:@selector(done:) forControlEvents:UIControlEventTouchUpInside];
	[topBarView addSubview:exportButton];
			
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
	[theToolbar.prevButton addTarget:self action:@selector(prev:) forControlEvents:UIControlEventTouchUpInside];
	[theToolbar.nextButton addTarget:self action:@selector(next:) forControlEvents:UIControlEventTouchUpInside];
	[theToolbar.prevButton setAlpha:1.0];
	[theToolbar.nextButton setAlpha:1.0];
	[theToolbar.doneButton addTarget:self action:@selector(closePicker:) forControlEvents:UIControlEventTouchUpInside];
	[theSelfView addSubview:theToolbar];
	
	UIView * bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, dvc_width, dvc_height - 42)];
	[bgView setBackgroundColor:[UIColor clearColor]];
	[myTableView setBackgroundView:bgView];
	
	[self.view addSubview:topBarView];
}

#pragma mark - TABLE VIEW DATASOURCE

-(NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
	return numberOfRows;
}

-(UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
	UITableViewCell * theCell = [self exportCellAtRow:(int)indexPath.row];
	
	return theCell;
}

#pragma mark - TABLE VIEW DELEGATE

-(CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
	return 42.0f;
}

-(void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
	UITableViewCell * theCell = [tableView cellForRowAtIndexPath:indexPath];
	
	if ([theCell isKindOfClass:[CellWithPicker class]])
	{
		[(CellWithPicker*)theCell animateSelection];
	}
	
	[self selectExportCellAtRow:(int)indexPath.row];
}

-(UITableViewCell*)exportCellAtRow:(int)row
{
	UITableViewCell * theCell;
	
	switch (row)
	{
		case 0:
		{
			theCell = [myTableView dequeueReusableCellWithIdentifier:@"tableCellPicker"];
			
			if (!theCell)
			{
				theCell = [[CellWithPicker alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"tableCellPicker"];
			}
			
			if(numberOfRows == 3)
				[(CellWithPicker*)theCell loadTitle:@"Category" andValue:[theExport category] cellType:kCellTypeTop];
			else
				[(CellWithPicker*)theCell loadTitle:@"Category" andValue:[theExport category] cellType:kCellTypeSingle];
			
			break;
		}
			
		case 1:
		{
			theCell = [myTableView dequeueReusableCellWithIdentifier:@"tableCellPicker"];
			
			if (!theCell)
			{
				theCell = [[CellWithPicker alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"tableCellPicker"];
			}
			
			if([[theExport startDate] isEqual:@"01/01/70"])
			{
				[(CellWithPicker*)theCell loadTitle:@"Start Date" andValue:@"" cellType:kCellTypeMiddle];
			}
			else
			{
				[(CellWithPicker*)theCell loadTitle:@"Start Date" andValue:[theExport startDate] cellType:kCellTypeMiddle];
			}
						
			break;
		}
			
		case 2:
		{
			theCell = [myTableView dequeueReusableCellWithIdentifier:@"tableCellPicker"];
			
			if (!theCell)
			{
				theCell = [[CellWithPicker alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"tableCellPicker"];
			}
			
			if([[theExport endDate] isEqual:@"01/01/70"])
			{
				[(CellWithPicker*)theCell loadTitle:@"End Date" andValue:@"" cellType:kCellTypeBottom];
			}
			else
			{
				[(CellWithPicker*)theCell loadTitle:@"End Date" andValue:[theExport endDate] cellType:kCellTypeBottom];
			}
			
			break;
		}
									
		default:
			break;
	}
	
	return theCell;
}

-(void)selectExportCellAtRow:(int)row
{
	currentRow = row;
		
	[self checkButton];
	
	switch (row)
	{
		case 0:
		{
			[self openPickerForCase:kPickerCaseCategory];
			
			break;
		}
			
		case 1:
		{
			[self openPickerForCase:kPickerCaseStartDate];
			
			break;
		}
			
		case 2:
		{
			[self openPickerForCase:kPickerCaseEndDate];
			
			break;
		}
									
		default:
			break;
	}
}

#pragma mark - PICKERVIEW DATASOURCE

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView*)pickerView
{
	return 1;
}

-(NSInteger)pickerView:(UIPickerView*)pickerView numberOfRowsInComponent:(NSInteger)component
{
	return categoriesArray.count;
}

-(UIView*)pickerView:(UIPickerView*)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView*)view
{
	UIView * theView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, dvc_width, 30)];
	[theView setBackgroundColor:[UIColor clearColor]];
	
	UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(30, 0, dvc_width - 60, 30)];
	[label setTextAlignment:NSTextAlignmentLeft];
	[label setTextColor:[UIColor darkGrayColor]];
	[label setFont:HelveticaNeue(15)];
	[label setBackgroundColor:[UIColor clearColor]];
	[theView addSubview:label];
	
	if (row == [pickerView selectedRowInComponent:component])
	{
		[label setTextColor:[UIColor blackColor]];
	}
	
	[label setText:[categoriesArray objectAtIndex:row]];
	
	return theView;
}

#pragma mark - PICKERVIEW DELEGATE

-(CGFloat)pickerView:(UIPickerView*)pickerView rowHeightForComponent:(NSInteger)component
{
	return 30;
}

-(void)pickerView:(UIPickerView*)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
	[theExport setCategory:[categoriesArray objectAtIndex:row]];
	[theExport setStartDate:@"01/01/70"];
	[theExport setEndDate:@"01/01/70"];
	
	if([[theExport category] isEqual:@"Contacts"] || [[theExport category] isEqual:@"Products and Services"] || [[theExport category] isEqual:@"All Data"])
		numberOfRows = 1;
	else
		numberOfRows = 3;
	
	if(numberOfRows == 1)
	{
		theToolbar.nextButton.alpha = 0;
		theToolbar.prevButton.alpha = 0;
	}
	else
	{		
		[self checkButton];
	}
	
	[self checkValues];
	
	[myTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
}

-(void)pickerValueChanged:(UIDatePicker*)sender
{
	if (current_picker_type == kPickerCaseStartDate)
	{
		[date_formatter setDateFormat:[DELEGATE userSelectedDateFormat]];
			
		[theExport setStartDate:[date_formatter stringFromDate:((UIDatePicker*)[self.view viewWithTag:989898]).date]];
	}
	else if (current_picker_type == kPickerCaseEndDate)
	{
		[date_formatter setDateFormat:[DELEGATE userSelectedDateFormat]];
		
		[theExport setEndDate:[date_formatter stringFromDate:((UIDatePicker*)[self.view viewWithTag:989898]).date]];
	}
	
	[self checkValues];
	[myTableView reloadData];
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

#pragma mark - SCROLLVIEW DELEGATe

-(void)scrollViewDidScroll:(UIScrollView*)scrollView
{
	if (mainScrollView && [mainScrollView respondsToSelector:@selector(didScroll)])
		[mainScrollView didScroll];
}

#pragma mark - OPEN PICKER

-(void)openPickerForCase:(kPickerCase)type
{
	if ([self.view viewWithTag:101010] && current_picker_type == type)
		return;
				
	if(![theSelfView viewWithTag:123123])
	{
		UIButton * closeAll = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
		closeAll.backgroundColor = [UIColor clearColor];
		[closeAll addTarget:self action:@selector(cancelPicker:) forControlEvents:UIControlEventTouchUpInside];
		[closeAll setTag:123123];
		[theSelfView addSubview:closeAll];
		[theSelfView bringSubviewToFront:theToolbar];
	}
		
	UITableViewCell * theCell;
	
	[[self.view viewWithTag:101010] removeFromSuperview];
	[[self.view viewWithTag:999] removeFromSuperview];
			
	current_picker_type = type;
	
	UIView * viewWithPicker = [[UIView alloc] initWithFrame:CGRectMake(0, dvc_height + 60, dvc_width, keyboard_height)];
	[viewWithPicker setBackgroundColor:[UIColor clearColor]];
	[viewWithPicker setTag:101010];
	[viewWithPicker.layer setMasksToBounds:YES];
	[self.view addSubview:viewWithPicker];
	
	switch (type)
	{
		case kPickerCaseCategory:
		{
			UIPickerView * picker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 0, dvc_width, keyboard_height)];
			[picker setDelegate:self];
			picker.backgroundColor = [UIColor whiteColor];
			[picker setDataSource:self];
			
			if (!iPad)
			{
				[picker setTransform:CGAffineTransformMakeScale(1.09, 1.09)];
			}
			else
			{
				[picker setTransform:CGAffineTransformMakeScale(1.0, (float)(keyboard_height) / 216.0f)];
			}
			
			[picker setCenter:CGPointMake(dvc_width / 2, keyboard_height / 2)];
			[viewWithPicker addSubview:picker];
						
			UIView * indicator = [[UIView alloc] initWithFrame:CGRectMake(0, 0, dvc_width, 30)];
			[indicator setBackgroundColor:app_tab_selected_color];
			[indicator setCenter:CGPointMake(dvc_width / 2, keyboard_height / 2)];
			[indicator setAlpha:0.2];
			[indicator setUserInteractionEnabled:NO];
			[viewWithPicker addSubview:indicator];
			
			if(![[theExport category] isEqual:@""])
			{
				int pickerIndex = (int)[categoriesArray indexOfObject:[theExport category]];
				[picker selectRow:pickerIndex inComponent:0 animated:YES];
			}
			else
			{
				[theExport setCategory:[categoriesArray objectAtIndex:0]];
				[self checkValues];

				numberOfRows = 1;
				
				[myTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
			}

			if([[theExport category] isEqual:@"Contacts"] || [[theExport category] isEqual:@"Products and Services"] || [[theExport category] isEqual:@"All Data"])
			{
				theToolbar.nextButton.alpha = 0;
				theToolbar.prevButton.alpha = 0;
			}

			
			break;
		}
			
		case kPickerCaseStartDate:
		{
			UIDatePicker * picker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 0, dvc_width, keyboard_height)];
			[picker setCenter:CGPointMake(dvc_width / 2, keyboard_height / 2)];
			[picker setDatePickerMode:UIDatePickerModeDate];
			[picker setTag:989898];
			picker.backgroundColor = [UIColor whiteColor];
			[picker addTarget:self action:@selector(pickerValueChanged:) forControlEvents:UIControlEventValueChanged];
			[date_formatter setDateFormat:[DELEGATE userSelectedDateFormat]];
			
			if([[theExport startDate] isEqual:@"01/01/70"])
			{
				[picker setDate:[NSDate date]];
				
				[theExport setStartDate:[date_formatter stringFromDate:picker.date]];
				[myTableView reloadData];
				[self checkValues];
			}
			else
			{
				[picker setDate:[date_formatter dateFromString:[theExport startDate]]];
			}
			
			[viewWithPicker addSubview:picker];
			
			if (iPad)
			{
				[picker setTransform:CGAffineTransformMakeScale(1.0, (float)(keyboard_height) / 216.0f)];
			}
			
			break;
		}
			
		case kPickerCaseEndDate:
		{
			UIDatePicker * picker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 0, dvc_width, keyboard_height)];
			[picker setCenter:CGPointMake(dvc_width / 2, keyboard_height / 2)];
			picker.backgroundColor = [UIColor whiteColor];
			[picker setDatePickerMode:UIDatePickerModeDate];
			[picker setTag:989898];
			[picker addTarget:self action:@selector(pickerValueChanged:) forControlEvents:UIControlEventValueChanged];
			[date_formatter setDateFormat:[DELEGATE userSelectedDateFormat]];
			
			if([[theExport endDate] isEqual:@"01/01/70"])
			{
				[picker setDate:[NSDate date]];
				
				[theExport setEndDate:[date_formatter stringFromDate:picker.date]];
				[myTableView reloadData];
				[self checkValues];
			}
			else
			{
				[picker setDate:[date_formatter dateFromString:[theExport endDate]]];
			}
						
			[viewWithPicker addSubview:picker];
			
			if (iPad)
			{
				[picker setTransform:CGAffineTransformMakeScale(1.0, (float)(keyboard_height) / 216.0f)];
			}
			
			break;
		}
			
		default:
			break;
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
	[[self.view viewWithTag:123123] removeFromSuperview];
	
	[UIView animateWithDuration:0.25 animations:^{
		
		[[self.view viewWithTag:101010] setFrame:CGRectMake(0, dvc_height + 60, dvc_width, keyboard_height)];
		[theToolbar setFrame:CGRectMake(0, dvc_height, dvc_width, 40)];
		[mainScrollView setFrame:CGRectMake(mainScrollView.frame.origin.x, mainScrollView.frame.origin.y, dvc_width, dvc_height - 42)];
		
		if (mainScrollView && [mainScrollView respondsToSelector:@selector(didScroll)])
			[mainScrollView didScroll];
				
	} completion:^(BOOL finished) {
				
		[self checkValues];
		[[self.view viewWithTag:101010] removeFromSuperview];
		
	}];
}

-(void)closePicker:(UIButton*)sender
{
	[[self.view viewWithTag:123123] removeFromSuperview];
		
	[UIView animateWithDuration:0.25 animations:^{
		
		[[self.view viewWithTag:101010] setFrame:CGRectMake(0, dvc_height + 60, dvc_width, keyboard_height)];
		[theToolbar setFrame:CGRectMake(0, dvc_height, dvc_width, 40)];
		[mainScrollView setFrame:CGRectMake(mainScrollView.frame.origin.x, mainScrollView.frame.origin.y, dvc_width, dvc_height - 42)];
		
		if (mainScrollView && [mainScrollView respondsToSelector:@selector(didScroll)])
			[mainScrollView didScroll];
		
	} completion:^(BOOL finished) {
		
		[self checkValues];
		[[self.view viewWithTag:101010] removeFromSuperview];
		
	}];
}

-(void)checkValues
{
	[UIView animateWithDuration:0.2 animations:^{
		[exportButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
		[exportButton setUserInteractionEnabled:NO];
	}];

	if([[theExport category] isEqual:@""])
		return;
	
	if([[theExport category] isEqual:@"Contacts"] || [[theExport category] isEqual:@"Products and Services"] || [[theExport category] isEqual:@"All Data"])
	{
		[UIView animateWithDuration:0.2 animations:^{
			[exportButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
			[exportButton setUserInteractionEnabled:YES];
		}];
		
		return;
	}
	
	if([[theExport startDate] isEqual:@"01/01/70"])
		return;
	
	if([[theExport endDate] isEqual:@"01/01/70"])
		return;
	
	[exportButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[exportButton setUserInteractionEnabled:YES];
}

#pragma mark
#pragma mark AlertView
-(void)alertView:(AlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (alertView.tag == 11)
	{
		if (buttonIndex == 0)
		{
			//cancel
		}
		else if (buttonIndex == 1)
		{
			//ok
			
			if (DELEGATE.purchase_in_progres)
			{
				[[[AlertView alloc] initWithTitle:@"" message:@"Another purchase is in progress" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil] showInWindow];
			}
			else
			{
				[[DELEGATE storeManager] buyCSVExport];
			}
		}
		else if (buttonIndex == 2)
		{
			//restore
			
			if (DELEGATE.purchase_in_progres)
			{
				[[[AlertView alloc] initWithTitle:@"" message:@"Another purchase is in progress" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil] showInWindow];
			}
			else
			{
				[[DELEGATE storeManager] restorePurchases];
			}
		}
		
		return;
	}
}

#pragma mark - ACTIONS

-(void)prev:(UIButton*)sender
{
	if(currentRow == 0)
		return;
	
	[self selectExportCellAtRow:currentRow - 1];
}

-(void)checkButton
{
	theToolbar.nextButton.alpha = 1.0;
	theToolbar.prevButton.alpha = 1.0;
	
	theToolbar.prevButton.userInteractionEnabled = YES;
	theToolbar.nextButton.userInteractionEnabled = YES;
	
	if(currentRow == 2)
	{
		theToolbar.nextButton.alpha = 0.5;
		theToolbar.nextButton.userInteractionEnabled = NO;
	}
	else
	if(currentRow == 0)
	{
		theToolbar.prevButton.alpha = 0.5;
		theToolbar.prevButton.userInteractionEnabled = NO;
	}
}

-(void)next:(UIButton*)sender
{
	if(currentRow == 2)
		return;
	
	[self selectExportCellAtRow:currentRow + 1];
}

-(void)cancel:(UIButton*)sender
{
	[UIView animateWithDuration:0.3 animations:^{
		
		[self.navigationController.view setFrame:CGRectMake(-dvc_width, 0, self.view.frame.size.width, self.navigationController.view.frame.size.height)];
		
	} completion:^(BOOL finished) {
	
		[self.navigationController.view removeFromSuperview];
	}];
}

-(void)done:(UIButton*)sender
{
	if(!isFullCSVVersion)
	{
		NSArray * otherButtons = [NSArray arrayWithObjects:@"Ok", @"Restore", nil];
		
		AlertView * alert = [[AlertView alloc] initWithTitle:@"" message:@"Would you like to purchase the CSV exporting feature?" delegate:self cancelButtonTitle:@"Not now" otherButtonTitles:otherButtons];
		[alert setTag:11];
		[alert showInWindow];
		
		return;
	} 
	
	[date_formatter setDateFormat:[DELEGATE userSelectedDateFormat]];
	
	NSDate *startDate = [date_formatter dateFromString:[theExport startDate]];
	NSDate *endDate = [date_formatter dateFromString:[theExport endDate]];
	
	int result = [data_manager compareDate:startDate withEndDate:endDate];
		
	if(result == 1)
	{
		[[[AlertView alloc] initWithTitle:@"" message:@"Start date cannot be greater than end date" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] showInWindow];
		return;
	}
	
	if([[theExport category] isEqual:@"All Data"])
	{
		[self sendAllData];
		
		return;
	}
		
	if([[theExport category] isEqual:@"Invoices"])
	{
		[DELEGATE addLoadingView];
		
		NSArray *invoicesArray = [[NSArray alloc] initWithArray:[data_manager getInvoiceArrayFromDate:startDate toEndDate:endDate]];
		
		if(invoicesArray.count == 0)
		{
			[[[AlertView alloc] initWithTitle:@"" message:@"No Invoices found" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] showInWindow];
			[DELEGATE removeLoadingView];
			
			return;
		}
		
		[theExport setFilePath:[csv_manager createInvoiceCSVFile:invoicesArray]];

		[DELEGATE removeLoadingView];
	}
	else
	if([[theExport category] isEqual:@"Quotes"])
	{
		[DELEGATE addLoadingView];
		
		NSArray *quotesArray = [[NSArray alloc] initWithArray:[data_manager getQuotesArrayFromDate:startDate toEndDate:endDate]];
		
		if(quotesArray.count == 0)
		{
			[[[AlertView alloc] initWithTitle:@"" message:@"No Quotes found" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] showInWindow];
			[DELEGATE removeLoadingView];
			
			return;
		}
		
		[theExport setFilePath:[csv_manager createQuoteCSVFile:quotesArray]];
		
		[DELEGATE removeLoadingView];
	}
	else
	if([[theExport category] isEqual:@"Estimates"])
	{
		[DELEGATE addLoadingView];
		
		NSArray *estimateArray = [[NSArray alloc] initWithArray:[data_manager getEstimatesArrayFromDate:startDate toEndDate:endDate]];
		
		if(estimateArray.count == 0)
		{
			[[[AlertView alloc] initWithTitle:@"" message:@"No Estimates found" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] showInWindow];
			[DELEGATE removeLoadingView];
			
			return;
		}
		
		[theExport setFilePath:[csv_manager createEstimateCSVFile:estimateArray]];
		
		[DELEGATE removeLoadingView];
	}
	else
	if([[theExport category] isEqual:@"Purchase Orders"])
	{
		[DELEGATE addLoadingView];
		
		NSArray *poArray = [[NSArray alloc] initWithArray:[data_manager getPurchaseArrayFromDate:startDate toEndDate:endDate]];
		
		if(poArray.count == 0)
		{
			[[[AlertView alloc] initWithTitle:@"" message:@"No Purchase Orders found" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] showInWindow];
			[DELEGATE removeLoadingView];
			
			return;
		}
		
		[theExport setFilePath:[csv_manager createPurchaseOrderCSVFile:poArray]];
		
		[DELEGATE removeLoadingView];
	}
	else
	if ([[theExport category] isEqual:@"Receipts"])
	{
		[DELEGATE addLoadingView];
		
		NSArray *receiptsArray = [[NSArray alloc] initWithArray:[data_manager getReceiptsArrayFromDate:startDate toEndDate:endDate]];
		
		if(receiptsArray.count == 0)
		{
			[[[AlertView alloc] initWithTitle:@"" message:@"No Receipts found" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] showInWindow];
			[DELEGATE removeLoadingView];
			
			return;
		}
		
		[theExport setFilePath:[csv_manager createReceiptsCSVFile:receiptsArray]];
		
		[DELEGATE removeLoadingView];
	}
	else
	if([[theExport category] isEqual:@"Timesheets"])
	{
		[DELEGATE addLoadingView];
		
		NSArray *timesheetsArray = [[NSArray alloc] initWithArray:[data_manager getTimesheetsArrayFromDate:startDate toEndDate:endDate]];
	
		if(timesheetsArray.count == 0)
		{
			[[[AlertView alloc] initWithTitle:@"" message:@"No Timesheets found" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] showInWindow];
			[DELEGATE removeLoadingView];
			
			return;
		}		
		[theExport setFilePath:[csv_manager createTimesheetsCSVFile:timesheetsArray]];
		
		[DELEGATE removeLoadingView];
	}
	else
	if([[theExport category] isEqual:@"Products and Services"])
	{
		[DELEGATE addLoadingView];
		
		NSArray *productsArray = [[NSArray alloc] initWithArray:[data_manager getProductsFromDate:startDate toEndDate:endDate]];
		
		if(productsArray.count == 0)
		{
			[[[AlertView alloc] initWithTitle:@"" message:@"No Products and Services found" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] showInWindow];
			[DELEGATE removeLoadingView];
			
			return;
		}
		
		[theExport setFilePath:[csv_manager createProductsCSVFile:productsArray]];
		
		[DELEGATE removeLoadingView];
	}
	else
	if([[theExport category] isEqual:@"Contacts"])
	{
		[DELEGATE addLoadingView];
		
		NSArray *contactsArray = [[NSArray alloc] initWithArray:[data_manager getContactsFromDate:startDate toEndDate:endDate]];
		
		if(contactsArray.count == 0)
		{
			[[[AlertView alloc] initWithTitle:@"" message:@"No Contacts found" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] showInWindow];
			[DELEGATE removeLoadingView];
			
			return;
		}
		
		[theExport setFilePath:[csv_manager createContactsCSVFile:contactsArray]];
		
		[DELEGATE removeLoadingView];
	}
	else
	if([[theExport category] isEqual:@"Projects"])
	{
		[DELEGATE addLoadingView];
		
		NSArray *projectsArray = [[NSArray alloc] initWithArray:[data_manager getProjectsFromDate:startDate toEndDate:endDate]];
		
		if(projectsArray.count == 0)
		{
			[[[AlertView alloc] initWithTitle:@"" message:@"No Projects found" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] showInWindow];
			[DELEGATE removeLoadingView];
			
			return;
		}
		
		[theExport setFilePath:[csv_manager createProjectsCSVFile:projectsArray]];
		
		[DELEGATE removeLoadingView];
	}
	
	if ([MFMailComposeViewController canSendMail])
	{
		NSData *contentData = [[NSData alloc] initWithContentsOfFile:[theExport filePath]];
				
		NSString *sendString = ([[theExport category] isEqual:@"Contacts"] || [[theExport category] isEqual:@"Products and Services"]) ? [theExport category] : [NSString stringWithFormat:@"%@ between %@ and %@",[theExport category],[theExport startDate],[theExport endDate]];
		
		MFMailComposeViewController * vc = [[MFMailComposeViewController alloc] init];
		[vc setSubject:sendString];
		[vc setMailComposeDelegate:self];
		[vc addAttachmentData:contentData mimeType:@"text/csv" fileName:[NSString stringWithFormat:@"%@CSV.csv",[theExport category]]];
		[self presentViewController:vc animated:YES completion:nil];
	}
	else
	{
		[[[AlertView alloc] initWithTitle:@"" message:@"You must configure an email account in the device settings to be able to send emails." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
	}
}

-(void)sendAllData
{
	if ([MFMailComposeViewController canSendMail])
	{
		MFMailComposeViewController * vc = [[MFMailComposeViewController alloc] init];
		[vc setSubject:@"All Data CSV"];
		[vc setMailComposeDelegate:self];
	
		BOOL dataLoaded = NO;
		
		for(int i=0;i<categoriesArray.count;i++)
		{
			if([[categoriesArray objectAtIndex:i] isEqual:@"Invoices"])
			{
				NSArray *invoicesArray = [[NSArray alloc] initWithArray:[data_manager loadInvoicesArrayFromUserDefaultsAtKey:kInvoicesKeyForNSUserDefaults]];

				if(invoicesArray.count != 0)
				{
					NSString *filePath = [csv_manager createInvoiceCSVFile:invoicesArray];
					NSData *contentData = [[NSData alloc] initWithContentsOfFile:filePath];
					
					[vc addAttachmentData:contentData mimeType:@"text/csv" fileName:[NSString stringWithFormat:@"Invoices.csv"]];
					
					dataLoaded = YES;
				}
			}
			else
			if([[categoriesArray objectAtIndex:i] isEqual:@"Quotes"])
			{
				NSArray *quotesArray = [[NSArray alloc] initWithArray:[data_manager loadQuotesArrayFromUserDefaultsAtKey:kQuotesKeyForNSUserDefaults]];
				
				if(quotesArray.count != 0)
				{
					NSString *filePath = [csv_manager createQuoteCSVFile:quotesArray];
					NSData *contentData = [[NSData alloc] initWithContentsOfFile:filePath];
					
					[vc addAttachmentData:contentData mimeType:@"text/csv" fileName:[NSString stringWithFormat:@"Quotes.csv"]];
					
					dataLoaded = YES;
				}
			}
			else
			if([[categoriesArray objectAtIndex:i] isEqual:@"Estimates"])
			{
				NSArray *estimatesArray = [[NSArray alloc] initWithArray:[data_manager loadEstimatesArrayFromUserDefaultsAtKey:kEstimatesKeyForNSUserDefaults]];
				
				if(estimatesArray.count != 0)
				{
					NSString *filePath = [csv_manager createEstimateCSVFile:estimatesArray];
					NSData *contentData = [[NSData alloc] initWithContentsOfFile:filePath];
					
					[vc addAttachmentData:contentData mimeType:[NSString stringWithFormat:@"text/csv"] fileName:[NSString stringWithFormat:@"Estimates.csv"]];
					
					dataLoaded = YES;
				}
			}
			else
			if([[categoriesArray objectAtIndex:i] isEqual:@"Purchase Orders"])
			{
				NSArray *purchase = [[NSArray alloc] initWithArray:[data_manager loadPurchaseOrdersArrayFromUserDefaultsAtKey:kPurchaseOrdersKeyForNSUserDefaults]];
				
				if(purchase.count != 0)
				{
					NSString *filePath = [csv_manager createPurchaseOrderCSVFile:purchase];
					NSData *contentData = [[NSData alloc] initWithContentsOfFile:filePath];
					
					[vc addAttachmentData:contentData mimeType:@"text/csv" fileName:@"PurchaseOrders.csv"];
					
					dataLoaded = YES;
				}
			}
			else
			if([[categoriesArray objectAtIndex:i] isEqual:@"Receipts"])
			{
				NSArray *receipts = [[NSArray alloc] initWithArray:[data_manager loadReceiptsArrayFromUserDefaultsAtKey:kReceiptsKeyForNSUserDefaults]];
				
				if(receipts.count != 0)
				{
					NSString *filePath = [csv_manager createReceiptsCSVFile:receipts];
					NSData *contentData = [[NSData alloc] initWithContentsOfFile:filePath];
					
					[vc addAttachmentData:contentData mimeType:@"text/csv" fileName:@"Receipts.csv"];
					
					dataLoaded = YES;
				}
			}
			else
			if([[categoriesArray objectAtIndex:i] isEqual:@"Timesheets"])
			{
				NSArray *timesheets = [[NSArray alloc] initWithArray:[data_manager loadTimesheetsArrayFromUserDefaultsAtKey:kTimeSheetKeyForNSUserDefaults]];
				
				if(timesheets.count != 0)
				{
					NSString *filePath = [csv_manager createTimesheetsCSVFile:timesheets];
					NSData *contentData = [[NSData alloc] initWithContentsOfFile:filePath];
					
					[vc addAttachmentData:contentData mimeType:@"text/csv" fileName:@"Timesheets.csv"];
					
					dataLoaded = YES;
				}
			}
			else
			if([[categoriesArray objectAtIndex:i] isEqual:@"Products and Services"])
			{
				NSArray *productsArray = [[NSArray alloc] initWithArray:[data_manager loadProductsArrayFromUserDefaultsAtKey:kProductsKeyForNSUserDefaults]];
				
				if(productsArray.count != 0)
				{
					NSString *filePath = [csv_manager createProductsCSVFile:productsArray];
					NSData *contentData = [[NSData alloc] initWithContentsOfFile:filePath];
					
					[vc addAttachmentData:contentData mimeType:@"text/csv" fileName:@"ProductsAndServices.csv"];
					
					dataLoaded = YES;
				}
			}
			else
			if([[categoriesArray objectAtIndex:i] isEqual:@"Contacts"])
			{
				NSArray *contactsArray = [[NSArray alloc] initWithArray:[data_manager loadClientsArrayFromUserDefaultsAtKey:kClientsKeyForNSUserDefaults]];
				
				if(contactsArray.count != 0)
				{
					NSString *filePath = [csv_manager createContactsCSVFile:contactsArray];
					NSData *contentData = [[NSData alloc] initWithContentsOfFile:filePath];
					
					[vc addAttachmentData:contentData mimeType:@"text/csv" fileName:@"Contacts.csv"];
					
					dataLoaded = YES;
				}
			}
			else
			if([[categoriesArray objectAtIndex:i] isEqual:@"Projects"])
			{
				NSArray *projectsArray = [[NSArray alloc] initWithArray:[data_manager loadProjectsArrayFromUserDefaultsAtKey:kProjectsKeyForNSUserDefaults]];
				
				if(projectsArray.count != 0)
				{
					NSString *filePath = [csv_manager createProjectsCSVFile:projectsArray];
					NSData *contentData = [[NSData alloc] initWithContentsOfFile:filePath];
					
					[vc addAttachmentData:contentData mimeType:@"text/csv" fileName:@"Projects.csv"];
					
					dataLoaded = YES;
				}
			}
		}

		if(dataLoaded == YES)
			[self presentViewController:vc animated:YES completion:nil];
		else
		{
			[[[AlertView alloc] initWithTitle:@"" message:@"There is nothing to export yet" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] showInWindow];
		}
	}
	else
	{
		[[[AlertView alloc] initWithTitle:@"" message:@"You must configure an email account in the device settings to be able to send emails." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
	}
}

@end
