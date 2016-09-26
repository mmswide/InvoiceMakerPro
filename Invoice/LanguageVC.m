//
//  LanguageVC.m
//  Invoice
//
//  Created by XGRoup on 8/6/14.
//  Copyright (c) 2014 XGRoup. All rights reserved.
//

#import "LanguageVC.h"

#import "Defines.h"
#import "CellWithPush.h"
#import "CellWithPicker.h"
#import "CellWithText.h"
#import "ProfileVC.h"
#import "TemplatesVC.h"

@interface LanguageVC ()
<
UITableViewDataSource,
UITableViewDelegate,
UIScrollViewDelegate,
UITextFieldDelegate,
AlertViewDelegate
>

@end

@implementation LanguageVC

-(id)init {
	self = [super init];
	
	if (self) {
		invoiceDict		= [[NSMutableDictionary alloc] initWithDictionary:[[CustomDefaults customObjectForKey:kLanguageKeyForNSUserDefaults] objectForKey:@"invoice"]];
		quoteDict		= [[NSMutableDictionary alloc] initWithDictionary:[[CustomDefaults customObjectForKey:kLanguageKeyForNSUserDefaults] objectForKey:@"quote"]];
		estimateDict	= [[NSMutableDictionary alloc] initWithDictionary:[[CustomDefaults customObjectForKey:kLanguageKeyForNSUserDefaults] objectForKey:@"estimate"]];
		purchaseDict	= [[NSMutableDictionary alloc] initWithDictionary:[[CustomDefaults customObjectForKey:kLanguageKeyForNSUserDefaults] objectForKey:@"purchase"]];
		receiptDict		= [[NSMutableDictionary alloc] initWithDictionary:[[CustomDefaults customObjectForKey:kLanguageKeyForNSUserDefaults] objectForKey:@"receipt"]];
		timesheetDict	= [[NSMutableDictionary alloc] initWithDictionary:[[CustomDefaults customObjectForKey:kLanguageKeyForNSUserDefaults] objectForKey:@"timesheet"]];
		
		invoiceKeys		= [[NSMutableArray alloc] initWithArray:[[invoiceDict allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]];
		quoteKeys		= [[NSMutableArray alloc] initWithArray:[[quoteDict allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]];
		estimateKeys	= [[NSMutableArray alloc] initWithArray:[[estimateDict allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]];
		purchaseKeys	= [[NSMutableArray alloc] initWithArray:[[purchaseDict allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]];
		receiptsKeys	= [[NSMutableArray alloc] initWithArray:[[receiptDict allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]];
		timesheetKeys	= [[NSMutableArray alloc] initWithArray:[[timesheetDict allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]];
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
	
	topBarView = [[TopBar alloc] initWithFrame:CGRectMake(0, 0, dvc_width, 42 + statusBarHeight) andTitle:@"Language"];
	[topBarView setBackgroundColor:app_bar_update_color];
	
	BackButton * backButton = [[BackButton alloc] initWithFrame:CGRectMake(0, 42 + statusBarHeight - 40, 70, 40) andTitle:@"Back"];
	[backButton addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
	[topBarView addSubview:backButton];
	
	UIButton * done = [[UIButton alloc] initWithFrame:CGRectMake(dvc_width - 60, 42 + statusBarHeight - 40, 60, 40)];
	[done setTitle:@"Done" forState:UIControlStateNormal];
	[done setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[done setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
	[done.titleLabel setFont:HelveticaNeueLight(17)];
	[done addTarget:self action:@selector(done:) forControlEvents:UIControlEventTouchUpInside];
	[topBarView addSubview:done];
	
	currentRow = -1;
		
	mainScrollView = [[ScrollWithShadow alloc] initWithFrame:CGRectMake(0, 42, dvc_width, dvc_height - 82)];
	[mainScrollView setBackgroundColor:[UIColor clearColor]];
	[mainScrollView setDelegate:self];
	[theSelfView addSubview:mainScrollView];
	
	mainTableView = [[TableWithShadow alloc] initWithFrame:CGRectMake(0, 0, dvc_width, dvc_height - 82) style:UITableViewStyleGrouped];
	[mainTableView setDataSource:self];
	[mainTableView setDelegate:self];
	mainTableView.scrollEnabled = NO;
	[mainTableView setBackgroundColor:[UIColor clearColor]];
	[mainTableView setSeparatorColor:[UIColor clearColor]];
	[mainTableView layoutIfNeeded];
	
	if (sys_version >= 7) {
		[mainTableView setContentInset:UIEdgeInsetsZero];
		[mainScrollView setContentInset:UIEdgeInsetsMake(-20, 0, 0, 0)];
	}
	
	[mainScrollView setContentSize:mainTableView.contentSize];
	[mainTableView setFrame:CGRectMake(0, 0, mainScrollView.contentSize.width, mainScrollView.contentSize.height)];
	
	[mainScrollView addSubview:mainTableView];
	
	theToolbar = [[ToolBarView alloc] initWithFrame:CGRectMake(0, dvc_height, dvc_width, 40)];
	[theToolbar.prevButton setAlpha:1.0];
	[theToolbar.nextButton setAlpha:1.0];
	[theToolbar.prevButton addTarget:self action:@selector(prev:) forControlEvents:UIControlEventTouchUpInside];
	[theToolbar.nextButton addTarget:self action:@selector(next:) forControlEvents:UIControlEventTouchUpInside];
	[theToolbar.doneButton addTarget:self action:@selector(closePicker:) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:theToolbar];
	
	UIView * bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, dvc_width, dvc_height - 42)];
	[bgView setBackgroundColor:[UIColor clearColor]];
	[mainTableView setBackgroundView:bgView];
	
	[self.view addSubview:topBarView];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [mainTableView layoutIfNeeded];
    [mainScrollView setContentSize:mainTableView.contentSize];
    [mainTableView setFrame:CGRectMake(0, 0, mainScrollView.contentSize.width, mainScrollView.contentSize.height)];
    
    [mainTableView reloadData];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [mainTableView performSelector:@selector(reloadData) withObject:nil afterDelay:0.3];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardFrameChanged:) name:UIKeyboardDidChangeFrameNotification object:nil];
}

-(int)getCountOfObjects {
	int total = 0;
	
	switch (app_version) {
		case 0: {
			total = (int)(invoiceKeys.count + quoteKeys.count + estimateKeys.count + purchaseKeys.count + receiptsKeys.count + timesheetKeys.count + 100);
			break;
		}
			
		case 1: {
			total = quoteKeys.count + 100;
			break;
		}
			
		case 2: {
			total = estimateKeys.count + 100;
			break;
		}
			
		case 3: {
			total = purchaseKeys.count + 100;
			break;
		}
			
		case 4: {
			total = receiptsKeys.count + 100;
			break;
		}
			
		case 5: {
			total = timesheetKeys.count + 100;
			break;
		}
			
		default:
			break;
	}
		
	return total;
}

#pragma mark - TABLE VIEW DATASOURCE

-(NSInteger)numberOfSectionsInTableView:(UITableView*)tableView {
	int numberOfSections = 0;
	
	switch (app_version) {
		case 0: {
			numberOfSections = 6;
			break;
		}
			
		case 1: {
			numberOfSections = 1;
			break;
		}
			
		case 2: {
			numberOfSections = 1;
			break;
		}
			
		case 3: {
			numberOfSections = 1;
			break;
		}
			
		case 4: {
			numberOfSections = 1;
			break;
		}
			
		case 5: {
			numberOfSections = 1;
			break;
		}
			
		default:
			break;
	}
	
	return numberOfSections;
}

-(NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section {
	switch (app_version) {
		case 0: {
			switch (section) {
					// Invoice
				case 0: {
					return invoiceKeys.count;
					break;
				}
					
					// Quotes
				case 1: {
					return quoteKeys.count;
					break;
				}
					
					// Estimate
				case 2: {
					return estimateKeys.count;
					break;
				}
					
					// P.O.
				case 3: {
					return purchaseKeys.count;
					break;
				}
					
					// Receipt
				case 4: {
					return receiptsKeys.count;
					break;
				}
					
					// Timesheet
				case 5: {
					return timesheetKeys.count;
					break;
				}
					
				default:
					break;
			}
			
			break;
		}
			
		case 1: {
			return quoteKeys.count;
			break;
		}
			
		case 2: {
			return estimateKeys.count;
			break;
		}
			
		case 3: {
			return purchaseKeys.count;
			break;
		}
			
		case 4: {
			return receiptsKeys.count;
			break;
		}
			
		case 5: {
			return timesheetKeys.count;
			break;
		}
			
		default:
			break;
	}
	
	return 0;
}

-(UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath {
	return [self cellInSection:(int)indexPath.section atRow:(int)indexPath.row];
}

-(UIView*)tableView:(UITableView*)tableView viewForHeaderInSection:(NSInteger)section {
	UIView * view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, dvc_width, 42)];
	[view setBackgroundColor:[UIColor clearColor]];
	
	UILabel * title = [[UILabel alloc] initWithFrame:CGRectMake(22, 0, dvc_width - 44, 42)];
	[title setTextAlignment:NSTextAlignmentLeft];
	[title setTextColor:app_title_color];
	[title setFont:HelveticaNeueMedium(15)];
	[title setBackgroundColor:[UIColor clearColor]];
	[view addSubview:title];
	
	switch (app_version) {
		case 0: {
			switch (section) {
				case 0: {
					[title setText:@"Invoice Terms"];
					break;
				}
					
				case 1: {
					[title setText:@"Quote Terms"];
					break;
				}
					
				case 2: {
					[title setText:@"Estimate Terms"];
					break;
				}
					
				case 3: {
					[title setText:@"P.O Terms"];
					break;
				}
					
				case 4: {
					[title setText:@"Receipt Terms"];
					break;
				}
					
				case 5: {
					[title setText:@"Timesheet Terms"];
					break;
				}
					
				default:
					break;
			}
			
			break;
		}
			
		case 1: {
			[title setText:@"Quote Terms"];
			break;
		}
			
		case 2: {
			[title setText:@"Estimate Terms"];
			break;
		}
			
		case 3: {
			[title setText:@"P.O Terms"];
			break;
		}
			
		case 4: {
			[title setText:@"Receipt Terms"];
			break;
		}
			
		case 5: {
			[title setText:@"Timesheet Terms"];
			break;
		}
			
		default:
			break;
	}
	
	return view;
}

#pragma mark - TABLE VIEW DELEGATE

-(CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath {
	return 42.0f;
}

-(CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section {
	return 42.0f;
}

#pragma mark - SCROLL VIEW DELEGATE

-(void)scrollViewDidScroll:(UIScrollView*)scrollView {
	if ([scrollView isKindOfClass:[ScrollWithShadow class]])
		[(ScrollWithShadow*)scrollView didScroll];
}

#pragma mark - CELL GENERATION

-(UITableViewCell*)cellInSection:(int)section atRow:(int)row {
	switch (app_version) {
		case 0: {
			switch (section) {
				case 0: {
					return [self invoiceCellAtRow:row];
					break;
				}
					
				case 1: {
					return [self quoteCellAtRow:row];
					break;
				}
					
				case 2: {
					return [self estimateCellAtRow:row];
					break;
				}
					
				case 3: {
					return [self purchaseCellAtRow:row];
					break;
				}
					
				case 4: {
					return [self receiptCellAtRow:row];
					break;
				}
					
				case 5: {
					return [self timesheetCellAtRow:row];
					break;
				}
					
				default:
					break;
			}
			break;
		}
			
		case 1: {
			return [self quoteCellAtRow:row];
			break;
		}
			
		case 2: {
			return [self estimateCellAtRow:row];
			break;
		}
			
		case 3: {
			return [self purchaseCellAtRow:row];
			break;
		}
			
		case 4: {
			return [self receiptCellAtRow:row];
			break;
		}
			
		case 5: {
			return [self timesheetCellAtRow:row];
			break;
		}
		default:
			break;
	}
	
	return nil;
}

-(UITableViewCell*)invoiceCellAtRow:(int)row {
	BaseTableCell *theCell = [mainTableView dequeueReusableCellWithIdentifier:@"tableCellText"];
	
	if (!theCell) {
		theCell = [[CellWithText alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"tableCellText"];
	}
	
	NSString *value = [invoiceDict objectForKey:[invoiceKeys objectAtIndex:row]];
	NSString *title = [invoiceKeys objectAtIndex:row];
	
	kCellType type = kCellTypeMiddle;
	
	if(row == 0) {
		type = kCellTypeTop;
	} else if(row == invoiceKeys.count - 1) {
			type = kCellTypeBottom;
		}
	
	[(CellWithText*)theCell loadTitle:title andValue:value tag:100 + row textFieldDelegate:self cellType:type andKeyboardType:UIKeyboardTypeDefault];
	[(CellWithText*)theCell setAutoCorrectionType:UITextAutocorrectionTypeDefault];
	[(CellWithText*)theCell setAutoCapitalizationType:UITextAutocapitalizationTypeSentences];
	
    [theCell setTitleEditableLayout];
    [theCell setAutolayoutForValueField];
    
	return theCell;
}

-(UITableViewCell*)quoteCellAtRow:(int)row {
	BaseTableCell *theCell = [mainTableView dequeueReusableCellWithIdentifier:@"tableCellText"];
	
	if (!theCell) {
		theCell = [[CellWithText alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"tableCellText"];
	}
	
	NSString *value = [quoteDict objectForKey:[quoteKeys objectAtIndex:row]];
	NSString *title = [quoteKeys objectAtIndex:row];
	
	kCellType type = kCellTypeMiddle;
	
	if(row == 0) {
		type = kCellTypeTop;
	} else if(row == quoteKeys.count - 1) {
			type = kCellTypeBottom;
		}
	
	int tag = row + 100;
	
	if(app_version == 0) {
		tag = (int)(invoiceKeys.count + row + 100);
	}
		
	[(CellWithText*)theCell loadTitle:title andValue:value tag:tag textFieldDelegate:self cellType:type andKeyboardType:UIKeyboardTypeDefault];
	[(CellWithText*)theCell setAutoCorrectionType:UITextAutocorrectionTypeDefault];
	[(CellWithText*)theCell setAutoCapitalizationType:UITextAutocapitalizationTypeSentences];
	
    [theCell setTitleEditableLayout];
    [theCell setAutolayoutForValueField];
    
	return theCell;
	
}

-(UITableViewCell*)estimateCellAtRow:(int)row {
	BaseTableCell *theCell = [mainTableView dequeueReusableCellWithIdentifier:@"tableCellText"];
	
	if (!theCell) {
		theCell = [[CellWithText alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"tableCellText"];
	}
	
	NSString *value = [estimateDict objectForKey:[estimateKeys objectAtIndex:row]];
	NSString *title = [estimateKeys objectAtIndex:row];
	
	kCellType type = kCellTypeMiddle;
	
	if(row == 0) {
		type = kCellTypeTop;
	} else if(row == estimateKeys.count - 1) {
			type = kCellTypeBottom;
		}
	
	int tag = row + 100;
	
	if(app_version == 0) {
		tag = (int)(invoiceKeys.count + quoteKeys.count + row + 100);
	}
	
	[(CellWithText*)theCell loadTitle:title andValue:value tag:tag textFieldDelegate:self cellType:type andKeyboardType:UIKeyboardTypeDefault];
	[(CellWithText*)theCell setAutoCorrectionType:UITextAutocorrectionTypeDefault];
	[(CellWithText*)theCell setAutoCapitalizationType:UITextAutocapitalizationTypeSentences];
	
    [theCell setTitleEditableLayout];
    [theCell setAutolayoutForValueField];
    
	return theCell;
}

-(UITableViewCell*)purchaseCellAtRow:(int)row {
	BaseTableCell *theCell = [mainTableView dequeueReusableCellWithIdentifier:@"tableCellText"];
	
	if (!theCell) {
		theCell = [[CellWithText alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"tableCellText"];
	}
	
	NSString *value = [purchaseDict objectForKey:[purchaseKeys objectAtIndex:row]];
	NSString *title = [purchaseKeys objectAtIndex:row];
	
	kCellType type = kCellTypeMiddle;
	
	if(row == 0) {
		type = kCellTypeTop;
	} else if(row == purchaseKeys.count - 1) {
			type = kCellTypeBottom;
		}
	
	int tag = row + 100;
	
	if(app_version == 0) {
		tag = (int)(invoiceKeys.count + quoteKeys.count + estimateKeys.count + row + 100);
	}
	
	[(CellWithText*)theCell loadTitle:title andValue:value tag:tag textFieldDelegate:self cellType:type andKeyboardType:UIKeyboardTypeDefault];
	[(CellWithText*)theCell setAutoCorrectionType:UITextAutocorrectionTypeDefault];
	[(CellWithText*)theCell setAutoCapitalizationType:UITextAutocapitalizationTypeSentences];
	
    [theCell setTitleEditableLayout];
    [theCell setAutolayoutForValueField];
    
	return theCell;
}

-(UITableViewCell*)receiptCellAtRow:(int)row {
	BaseTableCell *theCell = [mainTableView dequeueReusableCellWithIdentifier:@"tableCellText"];
	
	if (!theCell) {
		theCell = [[CellWithText alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"tableCellText"];
	}
	
	NSString *value = [receiptDict objectForKey:[receiptsKeys objectAtIndex:row]];
	NSString *title = [receiptsKeys objectAtIndex:row];
	
	kCellType type = kCellTypeMiddle;
	
	if(row == 0) {
		type = kCellTypeTop;
	} else if(row == receiptsKeys.count - 1) {
			type = kCellTypeBottom;
		}
	
	int tag = row + 100;
	
	if(app_version == 0) {
		tag = (int)(invoiceKeys.count + quoteKeys.count + estimateKeys.count + purchaseKeys.count + row + 100);
	}
	
	[(CellWithText*)theCell loadTitle:title andValue:value tag:tag textFieldDelegate:self cellType:type andKeyboardType:UIKeyboardTypeDefault];
	[(CellWithText*)theCell setAutoCorrectionType:UITextAutocorrectionTypeDefault];
	[(CellWithText*)theCell setAutoCapitalizationType:UITextAutocapitalizationTypeSentences];
	
    [theCell setTitleEditableLayout];
    [theCell setAutolayoutForValueField];
    
	return theCell;
}

-(UITableViewCell*)timesheetCellAtRow:(int)row {
	BaseTableCell *theCell = [mainTableView dequeueReusableCellWithIdentifier:@"tableCellText"];
	
	if (!theCell) {
		theCell = [[CellWithText alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"tableCellText"];
	}
	
	NSString *value = [timesheetDict objectForKey:[timesheetKeys objectAtIndex:row]];
	NSString *title = [timesheetKeys objectAtIndex:row];
	
	kCellType type = kCellTypeMiddle;
	
	if(row == 0) {
		type = kCellTypeTop;
	} else if(row == timesheetKeys.count - 1) {
			type = kCellTypeBottom;
		}
	
	int tag = row + 100;
	
	if(app_version == 0) {
		tag = (int)(invoiceKeys.count + quoteKeys.count + estimateKeys.count + purchaseKeys.count + receiptsKeys.count + row + 100);
	}
	
	[(CellWithText*)theCell loadTitle:title andValue:value tag:tag textFieldDelegate:self cellType:type andKeyboardType:UIKeyboardTypeDefault];
	[(CellWithText*)theCell setAutoCorrectionType:UITextAutocorrectionTypeDefault];
	[(CellWithText*)theCell setAutoCapitalizationType:UITextAutocapitalizationTypeSentences];
	
    [theCell setTitleEditableLayout];
    [theCell setAutolayoutForValueField];
    
	return theCell;
	
}

#pragma mark - OPEN PICKER

-(void)cancelPicker:(UIButton*)sender
{
	if(currentRow == -1)
	{
		return;
	}
	
	NSString *textFieldString = [[NSString alloc] initWithString:[(UITextField*)[self.view viewWithTag:currentRow] text]];
		
	AlertView *alertView;
	
	if([[data_manager stripString:textFieldString] isEqual:@""])
	{
		alertView = [[AlertView alloc] initWithTitle:@"" message:@"All fields are mandatory!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
		alertView.tag = currentRow;
	}
	
	currentRow = -1;
		
	[[self.view viewWithTag:123123] removeFromSuperview];
	
	[UIView animateWithDuration:0.25 animations:^{
		
		[theToolbar setFrame:CGRectMake(0, dvc_height, dvc_width, 40)];
		[mainScrollView setFrame:CGRectMake(mainScrollView.frame.origin.x, mainScrollView.frame.origin.y, dvc_width, dvc_height - 86)];
		
		if (mainScrollView && [mainScrollView respondsToSelector:@selector(didScroll)])
			[mainScrollView didScroll];
		
	} completion:^(BOOL finished) {
		
		if(alertView != nil)
		{
			[alertView showInWindow];
		}
				
		[mainTableView reloadData];
		
	}];
}

-(void)closePicker:(UIButton*)sender
{
	if(currentRow == -1)
	{
		return;
	}
	
	NSString *textFieldString = [[NSString alloc] initWithString:[(UITextField*)[self.view viewWithTag:currentRow] text]];
	
	AlertView *alertView;
	
	if([[data_manager stripString:textFieldString] isEqual:@""])
	{
		alertView = [[AlertView alloc] initWithTitle:@"" message:@"All fields are mandatory!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
		alertView.tag = currentRow;
	}
	
	currentRow = -1;
		
	[[self.view viewWithTag:123123] removeFromSuperview];
	
	[UIView animateWithDuration:0.25 animations:^{
		
		[theToolbar setFrame:CGRectMake(0, dvc_height, dvc_width, 40)];
		[mainScrollView setFrame:CGRectMake(mainScrollView.frame.origin.x, mainScrollView.frame.origin.y, dvc_width, dvc_height - 86)];
	
		if (mainScrollView && [mainScrollView respondsToSelector:@selector(didScroll)])
			[mainScrollView didScroll];
		
	} completion:^(BOOL finished) {
		
		if(alertView != nil)
		{
			[alertView showInWindow];
		}
		
		[mainTableView reloadData];
				
	}];
}

#pragma mark - TEXTFIELD DELEGATE

-(void)textFieldDidBeginEditing:(UITextField*)textField
{
	currentRow = (int)textField.tag;
		
	if([self.view viewWithTag:123123] != nil)
	{
		[[self.view viewWithTag:123123] removeFromSuperview];
	}
	
	UIButton * closeAll = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
	[closeAll setBackgroundColor:[UIColor clearColor]];
	[closeAll addTarget:self action:@selector(cancelPicker:) forControlEvents:UIControlEventTouchUpInside];
	[closeAll setTag:123123];
	[self.view addSubview:closeAll];

	[self.view bringSubviewToFront:theToolbar];
}

-(BOOL)textFieldShouldBeginEditing:(UITextField*)textField
{
    currentTextField = textField;
    
    if(textField.tag == 100)
    {
        [self showNext];
    }
    else
        if(textField.tag == [self getCountOfObjects] - 1)
        {
            [self showPrev];
        }
        else
        {
            [self showBoth];
        }
    
    [UIView animateWithDuration:0.25 animations:^{
        
        if(theToolbar.frame.origin.y >= dvc_height)
        {
            [theToolbar setFrame:CGRectMake(0, dvc_height - keyboard_height - 20, dvc_width, 40)];
        }
        
        [mainScrollView setFrame:CGRectMake(mainScrollView.frame.origin.x, mainScrollView.frame.origin.y, dvc_width, dvc_height - 82 - (dvc_height - theToolbar.frame.origin.y - 20))];
        
        if (mainScrollView && [mainScrollView respondsToSelector:@selector(didScroll)])
        {
            [mainScrollView didScroll];
        }
        
    } completion:^(BOOL finished) {
        if (sys_version < 8) {
            UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(mainScrollView.frame.origin.x,
                                                                           mainScrollView.frame.origin.y,
                                                                           mainScrollView.frame.size.width,
                                                                           mainScrollView.contentSize.height)];
            
            CGRect frame = CGRectMake(0, theSelfView.frame.size.height + 50, theSelfView.frame.size.width, 30);
            frame = [contentView convertRect:textField.superview.superview.superview.frame toView:contentView];
            [mainScrollView scrollRectToVisible:frame animated:YES];
        }
    }];
    
    return YES;
}

-(void)textFieldDidEndEditing:(UITextField*)textField {
	int index = (int)textField.tag;
	
	switch (app_version) {
		case 0: {
			if(index < invoiceKeys.count + 100) {
				[invoiceDict setObject:textField.text forKey:[invoiceKeys objectAtIndex:index - 100]];
			} else if(index >= invoiceKeys.count + 100 && index < invoiceKeys.count + quoteKeys.count + 100) {
				int temp = (int)(index - invoiceKeys.count - 100);
				[quoteDict setObject:textField.text forKey:[quoteKeys objectAtIndex:temp]];
			} else if(index >= invoiceKeys.count + quoteKeys.count + 100 && index < invoiceKeys.count + quoteKeys.count + estimateKeys.count + 100) {
				int temp = (int)(index - invoiceKeys.count - quoteKeys.count - 100);
				[estimateDict setObject:textField.text forKey:[estimateKeys objectAtIndex:temp]];
			} else if(index >= invoiceKeys.count + quoteKeys.count + estimateKeys.count + 100 && index < invoiceKeys.count + quoteKeys.count + estimateKeys.count + purchaseKeys.count + 100) {
				int temp =(int)( index - invoiceKeys.count - quoteKeys.count - estimateKeys.count - 100);
				[purchaseDict setObject:textField.text forKey:[purchaseKeys objectAtIndex:temp]];
			} else if(index >= invoiceKeys.count + quoteKeys.count + estimateKeys.count + purchaseKeys.count + 100 && index < invoiceKeys.count + quoteKeys.count + estimateKeys.count + purchaseKeys.count + receiptsKeys.count + 100) {
				int temp = (int)(index - invoiceKeys.count - quoteKeys.count - estimateKeys.count - purchaseKeys.count - 100);
				[receiptDict setObject:textField.text forKey:[receiptsKeys objectAtIndex:temp]];
			} else {
				int temp = (int)(index - invoiceKeys.count - quoteKeys.count - estimateKeys.count - purchaseKeys.count - receiptsKeys.count - 100);
				[timesheetDict setObject:textField.text forKey:[timesheetKeys objectAtIndex:temp]];
			}
	
			break;
		}
			
		case 1: {
			[quoteDict setObject:textField.text forKey:[quoteKeys objectAtIndex:index - 100]];
			break;
		}
			
		case 2: {
			[estimateDict setObject:textField.text forKey:[estimateKeys objectAtIndex:index - 100]];
						
			break;
		}
			
		case 3: {
			[purchaseDict setObject:textField.text forKey:[purchaseKeys objectAtIndex:index - 100]];
					
			break;
		}
			
		case 4: {
			[receiptDict setObject:textField.text forKey:[receiptsKeys objectAtIndex:index - 100]];
						
			break;
		}
			
		case 5: {
			[timesheetDict setObject:textField.text forKey:[timesheetKeys objectAtIndex:index - 100]];
					
			break;
		}
			
		default:
			break;
	}
}

-(BOOL)textFieldShouldReturn:(UITextField*)textField {
    [self closePicker:nil];
    
    currentRow = -1;
    
    [textField resignFirstResponder];
    
    return YES;
}

#pragma mark - ALERTVIEW DELEGATE

-(void)alertView:(AlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	UITextField *currentLocalTextField = (UITextField*)[self.view viewWithTag:alertView.tag];
	[currentLocalTextField becomeFirstResponder];
}

#pragma mark - ACTIONS

-(void)next:(UIButton*)sender {
	if(sender.alpha != 1.0) {
		return;
	}
	
	NSString *textFieldText = [(UITextField*)[self.view viewWithTag:currentRow] text];
	
	if([[data_manager stripString:textFieldText] isEqual:@""]) {
		[self closePicker:nil];
		return;
	}
	
	int total = [self getCountOfObjects];
		
	[self showBoth];
	
	if(currentRow + 1 < total) {
		if(currentRow + 1 == total - 1) {
			[self showPrev];
		}
						
		[(UITextField*)[self.view viewWithTag:currentRow + 1] becomeFirstResponder];
	}
}

-(void)prev:(UIButton*)sender {
	if(sender.alpha != 1.0)
		return;
	
	NSString *textFieldText = [(UITextField*)[self.view viewWithTag:currentRow] text];
	
	if([[data_manager stripString:textFieldText] isEqual:@""]) {
		[self closePicker:nil];
		return;
	}
	
	[self showBoth];
	
	if(currentRow - 1 > 99) {
		if(currentRow - 1 == 100) {
			[self showNext];
		}
		
		[(UITextField*)[self.view viewWithTag:currentRow - 1] becomeFirstResponder];
	}
}

-(void)cancel:(UIButton*)sender {
	[self.navigationController popViewControllerAnimated:YES];
}

-(void)done:(UIButton*)sender {
	NSMutableDictionary *languageDict = [[NSMutableDictionary alloc] initWithDictionary:[CustomDefaults customObjectForKey:kLanguageKeyForNSUserDefaults]];
	
	[languageDict setObject:invoiceDict  forKey:@"invoice"];
	[languageDict setObject:quoteDict    forKey:@"quote"];
	[languageDict setObject:estimateDict forKey:@"estimate"];
	[languageDict setObject:purchaseDict forKey:@"purchase"];
	[languageDict setObject:receiptDict  forKey:@"receipt"];
	[languageDict setObject:timesheetDict forKey:@"timesheet"];
	
	[CustomDefaults setCustomObjects:[invoiceDict objectForKey:@"Invoice"] forKey:kInvoiceTitleKeyForNSUserDefaults];
	[CustomDefaults setCustomObjects:[quoteDict objectForKey:@"Quote"] forKey:kQuoteTitleKeyForNSUserDefaults];
	[CustomDefaults setCustomObjects:[estimateDict objectForKey:@"Estimate"] forKey:kEstimateTitleKeyForNSUserDefaults];
	[CustomDefaults setCustomObjects:[purchaseDict objectForKey:@"Purchase Order"] forKey:kPurchaseOrderTitleKeyForNSUserDefaults];

	[CustomDefaults setCustomObjects:[receiptDict objectForKey:@"Receipt"] forKey:kReceiptTitleKeyForNSUserDefaults];
	[CustomDefaults setCustomObjects:[timesheetDict objectForKey:@"Timesheet"] forKey:kTimesheetTitleKeyForNSUserDefaults];
	
	[CustomDefaults setCustomObjects:languageDict forKey:kLanguageKeyForNSUserDefaults];
	
	[self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - TOOLBAR BUTTONS

-(void)showBoth {
	theToolbar.nextButton.alpha = 1.0;
	theToolbar.prevButton.alpha = 1.0;
}

-(void)showNext {
	theToolbar.nextButton.alpha = 1.0;
	theToolbar.prevButton.alpha = 0.5;
}

-(void)showPrev {
	theToolbar.nextButton.alpha = 0.5;
	theToolbar.prevButton.alpha = 1.0;
}

#pragma mark - NSNotifcation Center

-(void)keyboardFrameChanged:(NSNotification*)notification {
    NSDictionary* info = [notification userInfo];
    
    CGPoint to = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].origin;
    
    if(to.y == dvc_height + 20) {
        return;
    }
    
    [UIView animateWithDuration:0.25 animations:^{
        
        theToolbar.frame = CGRectMake(theToolbar.frame.origin.x, to.y - theToolbar.frame.size.height, theToolbar.frame.size.width, theToolbar.frame.size.height);
        
        [mainScrollView setFrame:CGRectMake(mainScrollView.frame.origin.x, mainScrollView.frame.origin.y, dvc_width, dvc_height - (dvc_height - to.y) - 87 - 14)];
        
        if(mainScrollView && [mainScrollView respondsToSelector:@selector(didScroll)]) {
            [mainScrollView didScroll];
        }
        
    } completion:^(BOOL finished) {
        if(currentTextField) {
            if(sys_version < 8) {
                CGRect frame = currentTextField.superview.frame;
                if (sys_version >= 7) {
                    frame = currentTextField.superview.superview.frame;
                }
                [mainScrollView scrollRectToVisible:frame animated:YES];
            }
            
        }
    }];
}

-(void)dealloc {
	[mainTableView setDelegate:nil];
	[mainTableView setDataSource:nil];
    
	[mainScrollView setDelegate:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
