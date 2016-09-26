//
//  CreateOrEditClientVC.m
//  Invoice
//
//  Created by XGRoup5 on 8/19/13.
//  Copyright (c) 2013 XGRoup. All rights reserved.
//

#import "CreateOrEditClientVC.h"

#import "Defines.h"
#import "CellWithPicker.h"
#import "CellWithPush.h"
#import "CellWithText.h"
#import "AddClientAddressVC.h"
#import "AddNoteToClientVC.h"
#import "InvoiceOBJ.h"

@interface CreateOrEditClientVC () <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate> {
    InvoiceOBJ *invoiceForClient;
}

@end

@implementation CreateOrEditClientVC

@synthesize delegate;

-(id)initWithClient:(ClientOBJ*)sender delegate:(id<ClientCreatorDelegate>)del
{
	self = [super init];
	
	if (self)
	{
		editState = (sender == nil) ? 0 : 1;
		
		firstTime = YES;
		delegate = del;
		theClient = [[ClientOBJ alloc] initWithClient:sender];
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
	
	NSString *topBarString = (editState == 0) ? @"New Contact" : @"Edit Contact";
	
	topBarView = [[TopBar alloc] initWithFrame:CGRectMake(0, 0, dvc_width, 42 + statusBarHeight) andTitle:topBarString];
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
	
	mainScrollView = [[ScrollWithShadow alloc] initWithFrame:CGRectMake(0, 42, dvc_width, dvc_height - 42)];
	[mainScrollView setBackgroundColor:[UIColor clearColor]];
	[mainScrollView setDelegate:self];
	[theSelfView addSubview:mainScrollView];
	
	myTableView = [[TableWithShadow alloc] initWithFrame:CGRectMake(0, 0, dvc_width, dvc_height - 42) style:UITableViewStyleGrouped];
	[myTableView setDataSource:self];
	[myTableView setDelegate:self];
	[myTableView setBackgroundColor:[UIColor clearColor]];
	[myTableView setSeparatorColor:[UIColor clearColor]];
	myTableView.scrollEnabled = NO;
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
	[theToolbar.doneButton addTarget:self action:@selector(closePicker:) forControlEvents:UIControlEventTouchUpInside];
	[theSelfView addSubview:theToolbar];
	
	UIView * bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, dvc_width, dvc_height - 42)];
	[bgView setBackgroundColor:[UIColor clearColor]];
	[myTableView setBackgroundView:bgView];
	
	if (!theClient)
	{
		theClient = [[ClientOBJ alloc] init];
	}
	
	[self.view addSubview:topBarView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if([[[invoiceForClient client]firstName] length] > 0) {
        theClient = [[ClientOBJ alloc] initWithClient:invoiceForClient.client];
    }
    
    [myTableView reloadData];
}

#pragma mark - FUNCTIONS

-(void)cancel:(UIButton*)sender
{
	[self dismissViewControllerAnimated:YES completion:nil];
}

-(void)done:(UIButton*)sender
{
	if ([[theClient firstName] isEqual:@""])
	{
		[[[AlertView alloc] initWithTitle:@"" message:@"The client must have a first name." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] showInWindow];
		return;
	}
			
	if ([delegate respondsToSelector:@selector(creatorViewController:createdClient:)])
	{
		[delegate creatorViewController:self createdClient:theClient];
	}
	
	[self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - TABLE VIEW DATASOURCE

-(NSInteger)numberOfSectionsInTableView:(UITableView*)tableView
{
	return 4;
}

-(NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section {
	switch (section) {
		case 0: {
			return 5;
			break;
		}
			
		case 1: {
			return 4;
			
			break;
		}
			
		case 2: {
			return 2;
			break;
		}
			
		case 3: {
			return 2;
			break;
		}
			
		default:
			break;
	}
	
	return 0;
}

-(UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath {
//	if ([tableView isKindOfClass:[TableWithShadow class]])
//	{
//		[(TableWithShadow*)tableView didScroll];
//	}
	
	return [self cellInSection:(int)indexPath.section atRow:(int)indexPath.row];
}

-(UIView*)tableView:(UITableView*)tableView viewForHeaderInSection:(NSInteger)section {
	UIView * view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, dvc_width, 30)];
	[view setBackgroundColor:[UIColor clearColor]];
	
	UILabel * title = [[UILabel alloc] initWithFrame:CGRectMake(22, 0, dvc_width - 44, 30)];
	[title setTextAlignment:NSTextAlignmentLeft];
	[title setTextColor:app_title_color];
	[title setFont:HelveticaNeueMedium(15)];
	[title setBackgroundColor:[UIColor clearColor]];
	[view addSubview:title];
	
	switch (section)
	{
		case 0:
		{
			[title setText:@"Company"];
			break;
		}
			
		case 1:
		{
			[title setText:@"Client"];
			break;
		}
			
		case 2:
		{
			[title setText:@"Address"];
			break;
		}
			
		case 3:
		{
			[title setText:@"Other Details"];
			break;
		}
			
		default:
			break;
	}
	
	return view;
}

#pragma mark - TABLE VIEW DELEGATE

-(CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath {
//	if (indexPath.row == 0)
//	{
//		return 52.0f;
//	}
//	else
	{
		return 42.0f;
	}
}

-(CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section
{
	return 42.0f;
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
			return [self companyCellAtRow:row];
			break;
		}
			
		case 1:
		{
			return [self clientCellAtRow:row];
			break;
		}
			
		case 2:
		{
			return [self addressCellAtRow:row];
			break;
		}
			
		case 3:
		{
			return [self otherCellAtRow:row];
			break;
		}
			
		default:
			break;
	}
	
	return nil;
}

-(UITableViewCell*)companyCellAtRow:(int)row {
	BaseTableCell * theCell;
	
	switch (row) {
		case 0: {
			theCell = [myTableView dequeueReusableCellWithIdentifier:@"tableCellText"];
			
			if (!theCell) {
				theCell = [[CellWithText alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"tableCellText"];
			}
			
			[(CellWithText*)theCell loadTitle:@"Name" andValue:[theClient company] tag:111 textFieldDelegate:self cellType:kCellTypeTop andKeyboardType:UIKeyboardTypeDefault];
			[(CellWithText*)theCell setReturnkeyType:UIReturnKeyNext];
			[(CellWithText*)theCell setAutoCorrectionType:UITextAutocorrectionTypeNo];
			[(CellWithText*)theCell setAutoCapitalizationType:UITextAutocapitalizationTypeWords];
			
			break;
		}
			
		case 1:
		{
			theCell = [myTableView dequeueReusableCellWithIdentifier:@"tableCellText"];
			
			if (!theCell)
			{
				theCell = [[CellWithText alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"tableCellText"];
			}
			
			[(CellWithText*)theCell loadTitle:@"Website" andValue:[theClient website] tag:222 textFieldDelegate:self cellType:kCellTypeMiddle andKeyboardType:UIKeyboardTypeURL];
			[(CellWithText*)theCell setReturnkeyType:UIReturnKeyNext];
			[(CellWithText*)theCell setAutoCorrectionType:UITextAutocorrectionTypeNo];
			[(CellWithText*)theCell setAutoCapitalizationType:UITextAutocapitalizationTypeNone];
			
			break;
		}
			
		case 2:
		{
			theCell = [myTableView dequeueReusableCellWithIdentifier:@"tableCellText"];
			
			if (!theCell)
			{
				theCell = [[CellWithText alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"tableCellText"];
			}
			
			[(CellWithText*)theCell loadTitle:@"Email" andValue:[theClient email] tag:333 textFieldDelegate:self cellType:kCellTypeMiddle andKeyboardType:UIKeyboardTypeEmailAddress];
			[(CellWithText*)theCell setReturnkeyType:UIReturnKeyNext];
			[(CellWithText*)theCell setAutoCorrectionType:UITextAutocorrectionTypeNo];
			[(CellWithText*)theCell setAutoCapitalizationType:UITextAutocapitalizationTypeNone];
			
			break;
		}
			
		case 3:
		{
			theCell = [myTableView dequeueReusableCellWithIdentifier:@"tableCellText"];
			
			if (!theCell)
			{
				theCell = [[CellWithText alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"tableCellText"];
			}
			
			[(CellWithText*)theCell loadTitle:@"Phone" andValue:[theClient phone] tag:444 textFieldDelegate:self cellType:kCellTypeMiddle andKeyboardType:UIKeyboardTypeNumbersAndPunctuation];
			
			break;
		}
			
		case 4:
		{
			theCell = [myTableView dequeueReusableCellWithIdentifier:@"tableCellText"];
			
			if (!theCell)
			{
				theCell = [[CellWithText alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"tableCellText"];
			}
			
			[(CellWithText*)theCell loadTitle:@"Fax" andValue:[theClient fax] tag:555 textFieldDelegate:self cellType:kCellTypeBottom andKeyboardType:UIKeyboardTypeNumbersAndPunctuation];
			
			break;
		}
			
		default:
			break;
	}
	
    [theCell setTitleEditableLayout];
    [theCell setAutolayoutForValueField];
    
	return theCell;
}

-(UITableViewCell*)clientCellAtRow:(int)row
{
	BaseTableCell * theCell;
	
	switch (row)
	{
		case 0:
		{
			theCell = [myTableView dequeueReusableCellWithIdentifier:@"tableCellText"];
			
			if (!theCell)
			{
				theCell = [[CellWithText alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"tableCellText"];
			}
			
			[(CellWithText*)theCell loadTitle:@"First Name" andValue:[theClient firstName] tag:666 textFieldDelegate:self cellType:kCellTypeTop andKeyboardType:UIKeyboardTypeDefault];
			[(CellWithText*)theCell setAutoCorrectionType:UITextAutocorrectionTypeNo];
			[(CellWithText*)theCell setAutoCapitalizationType:UITextAutocapitalizationTypeWords];

			break;
		}
			
		case 1:
		{
			theCell = [myTableView dequeueReusableCellWithIdentifier:@"tableCellText"];
			
			if (!theCell)
			{
				theCell = [[CellWithText alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"tableCellText"];
			}
			
			[(CellWithText*)theCell loadTitle:@"Last Name" andValue:[theClient lastName] tag:777 textFieldDelegate:self cellType:kCellTypeMiddle andKeyboardType:UIKeyboardTypeDefault];
			[(CellWithText*)theCell setAutoCorrectionType:UITextAutocorrectionTypeNo];
			[(CellWithText*)theCell setAutoCapitalizationType:UITextAutocapitalizationTypeWords];
			
			break;
		}
			
		case 2:
		{
			theCell = [myTableView dequeueReusableCellWithIdentifier:@"tableCellPicker"];
			
			if (!theCell)
			{
				theCell = [[CellWithPicker alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"tableCellPicker"];
			}
			
			[(CellWithPicker*)theCell loadTitle:@"Title" andValue:[theClient title] cellType:kCellTypeMiddle];
			[theCell setTag:111111];
			
			break;
			
			break;
		}
			
		case 3:
		{
			theCell = [myTableView dequeueReusableCellWithIdentifier:@"tableCellText"];
			
			if (!theCell)
			{
				theCell = [[CellWithText alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"tableCellText"];
			}
			
			[(CellWithText*)theCell loadTitle:@"Mobile" andValue:[theClient mobile] tag:888 textFieldDelegate:self cellType:kCellTypeBottom andKeyboardType:UIKeyboardTypeNumbersAndPunctuation];
			
			
			break;
		}
			
		default:
			break;
	}
    
    [theCell setTitleEditableLayout];
    [theCell setAutolayoutForValueField];
	
	return theCell;
}

-(UITableViewCell*)addressCellAtRow:(int)row {
	BaseTableCell * theCell;
	
	switch (row) {
		case 0: {
			theCell = [myTableView dequeueReusableCellWithIdentifier:@"tableCellPush"];
			
			if (!theCell) {
				theCell = [[CellWithPush alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"tableCellPush"];
			}
			
			[(CellWithPush*)theCell loadTitle:[CustomDefaults customObjectForKey:kBillingAddressTitleKeyForNSUserDefaults]
							 andValue:[[theClient billingAddress] fullStringRepresentation] cellType:kCellTypeTop andSize:0.0];
			
			break;
		}
			
		case 1: {
			theCell = [myTableView dequeueReusableCellWithIdentifier:@"tableCellPush"];
			
			if (!theCell) {
				theCell = [[CellWithPush alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"tableCellPush"];
			}
			
			[(CellWithPush*)theCell loadTitle:[CustomDefaults customObjectForKey:kShippingAddressTitleKeyForNSUserDefaults]
							 andValue:[[theClient shippingAddress] fullStringRepresentation] cellType:kCellTypeBottom andSize:0.0];
			
			break;
		}
			
		default:
			break;
	}
    
    [theCell setTitleEditableLayout];
    [theCell setAutolayoutForValueField];
	
	return theCell;
}

-(UITableViewCell*)otherCellAtRow:(int)row {
	BaseTableCell * theCell;
	
	switch (row) {
		case 0: {
			theCell = [myTableView dequeueReusableCellWithIdentifier:@"tableCellPicker"];
			
			if (!theCell) {
				theCell = [[CellWithPicker alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"tableCellPicker"];
			}
			
			[(CellWithPicker*)theCell loadTitle:@"Terms" andValue:[TermsManager termsString:[theClient terms]] cellType:kCellTypeTop];
			[theCell setTag:121212];
			
			break;
		}
			
		case 1: {
			theCell = [myTableView dequeueReusableCellWithIdentifier:@"tableCellPush"];
			
			if (!theCell) {
				theCell = [[CellWithPush alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"tableCellPush"];
			}
			
			[(CellWithPush*)theCell loadTitle:@"Note" andValue:[theClient note] cellType:kCellTypeBottom andSize:0.0];
			
			break;
		}
			
		default:
			break;
	}
    
    [theCell setTitleEditableLayout];
    [theCell setAutolayoutForValueField];
	
	return theCell;
}

#pragma mark - CELL SELECTION

-(void)selectedCellInSection:(int)section atRow:(int)row
{
	switch (section)
	{
		case 0:
		{
			[self selectedCompanyCellAtRow:row];
			break;
		}
			
		case 1:
		{
			[self selectedClientCellAtRow:row];
			break;
		}
			
		case 2:
		{
			[self selectedAddressCellAtRow:row];
			break;
		}
			
		case 3:
		{
			[self selectedOtherCellAtRow:row];
			break;
		}
			
		default:
			break;
	}
}

-(void)selectedCompanyCellAtRow:(int)row
{
	switch (row)
	{
		case 0:
		{
			//Company Name
			[(UITextField*)[self.view viewWithTag:111] becomeFirstResponder];
			
			break;
		}
			
		case 1:
		{
			//Website
			[(UITextField*)[self.view viewWithTag:222] becomeFirstResponder];
			
			break;
		}
			
		case 2:
		{
			//Email
			[(UITextField*)[self.view viewWithTag:333] becomeFirstResponder];
			
			break;
		}
			
		case 3:
		{
			//Phone
			[(UITextField*)[self.view viewWithTag:444] becomeFirstResponder];
			
			break;
		}
			
		case 4:
		{
			//Fax
			[(UITextField*)[self.view viewWithTag:555] becomeFirstResponder];
			
			break;
		}
			
		default:
			break;
	}
}

-(void)selectedClientCellAtRow:(int)row
{
	switch (row)
	{
		case 0:
		{
			//First Name
			[(UITextField*)[self.view viewWithTag:666] becomeFirstResponder];
			
			break;
		}
			
		case 1:
		{
			//Last Name
			[(UITextField*)[self.view viewWithTag:777] becomeFirstResponder];
			
			break;
		}
			
		case 2:
		{
			//Title
			[self openPickerForCase:kPickerCaseClientTitle];
			
			break;
		}
			
		case 3:
		{
			//Mobile
			[(UITextField*)[self.view viewWithTag:888] becomeFirstResponder];
			
			break;
		}
			
		default:
			break;
	}
}

-(void)selectedAddressCellAtRow:(int)row
{
	switch (row)
	{
		case 0:
		{
			//Billing Address
			AddClientAddressVC * vc = [[AddClientAddressVC alloc] initWithAddresType:kAddresTypeBilling client:theClient];
			[self.navigationController pushViewController:vc animated:YES];
			
			break;
		}
			
		case 1:
		{
			//Shipping Address
			AddClientAddressVC * vc = [[AddClientAddressVC alloc] initWithAddresType:kAddresTypeShipping client:theClient];
			[self.navigationController pushViewController:vc animated:YES];
			
			break;
		}
			
		default:
			break;
	}
}

-(void)selectedOtherCellAtRow:(int)row
{
	switch (row)
	{
		case 0:
		{
			//Terms
			[self openPickerForCase:kPickerCaseClientTerms];
			
			break;
		}
			
		case 1:
		{
			//Note
			AddNoteToClientVC * vc = [[AddNoteToClientVC alloc] initWithClient:theClient];
			[self.navigationController pushViewController:vc animated:YES];
			
			break;
		}
			
		default:
			break;
	}
}

#pragma mark - OPEN PICKER

-(void)openPickerForCase:(kPickerCaseClient)type
{
	if ([self.navigationController.view viewWithTag:101010] && current_picker_type == type)
		return;
	
	[(UITextField*)[self.view viewWithTag:111] resignFirstResponder];
	[(UITextField*)[self.view viewWithTag:222] resignFirstResponder];
	[(UITextField*)[self.view viewWithTag:333] resignFirstResponder];
	[(UITextField*)[self.view viewWithTag:444] resignFirstResponder];
	[(UITextField*)[self.view viewWithTag:555] resignFirstResponder];
	[(UITextField*)[self.view viewWithTag:666] resignFirstResponder];
	[(UITextField*)[self.view viewWithTag:777] resignFirstResponder];
	[(UITextField*)[self.view viewWithTag:888] resignFirstResponder];
	
	double delayInSeconds = 0.26f;
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
	dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
		
		UITableViewCell * theCell;
		
		[theToolbar.nextButton setAlpha:1.0];
		[theToolbar.nextButton setUserInteractionEnabled:YES];
		
		[theToolbar.prevButton setAlpha:1.0];
		[theToolbar.prevButton setUserInteractionEnabled:YES];
		
		switch (type)
		{
			case kPickerCaseClientTerms:
			{
				active_field = kActiveFieldTerms;
				
				[theToolbar.nextButton setAlpha:0.5];
				[theToolbar.nextButton setUserInteractionEnabled:NO];
				
				theCell = (UITableViewCell*)[self.view viewWithTag:121212];
				break;
			}
				
			case kPickerCaseClientTitle:
			{
				active_field = kActiveFieldTitle;
				theCell = (UITableViewCell*)[self.view viewWithTag:111111];
				break;
			}
				
			default:
				break;
		}
		
		[[self.navigationController.view viewWithTag:101010] removeFromSuperview];
		[[self.view viewWithTag:999] removeFromSuperview];
				
		current_picker_type = type;
		
		UIView * viewWithPicker = [[UIView alloc] initWithFrame:CGRectMake(0, dvc_height + 60, dvc_width, keyboard_height)];
		[viewWithPicker setBackgroundColor:[UIColor clearColor]];
		[viewWithPicker setTag:101010];
		[viewWithPicker.layer setMasksToBounds:YES];
		[self.navigationController.view addSubview:viewWithPicker];
		
		UIPickerView * picker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 0, dvc_width, keyboard_height)];
		picker.backgroundColor = [UIColor whiteColor];
		[picker setDelegate:self];
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
		
	});
}

-(void)closePicker:(UIButton*)sender
{
	[(UITextField*)[self.view viewWithTag:111] resignFirstResponder];
	[(UITextField*)[self.view viewWithTag:222] resignFirstResponder];
	[(UITextField*)[self.view viewWithTag:333] resignFirstResponder];
	[(UITextField*)[self.view viewWithTag:444] resignFirstResponder];
	[(UITextField*)[self.view viewWithTag:555] resignFirstResponder];
	[(UITextField*)[self.view viewWithTag:666] resignFirstResponder];
	[(UITextField*)[self.view viewWithTag:777] resignFirstResponder];
	[(UITextField*)[self.view viewWithTag:888] resignFirstResponder];
	
	[UIView animateWithDuration:0.25 animations:^{
		
		[[self.navigationController.view viewWithTag:101010] setFrame:CGRectMake(0, dvc_height + 60, dvc_width, keyboard_height)];
		[theToolbar setFrame:CGRectMake(0, dvc_height, dvc_width, 40)];
		[mainScrollView setFrame:CGRectMake(mainScrollView.frame.origin.x, mainScrollView.frame.origin.y, dvc_width, dvc_height - 42)];
		if (mainScrollView && [mainScrollView respondsToSelector:@selector(didScroll)])
			[mainScrollView didScroll];
		
	} completion:^(BOOL finished) {
		
		[[self.navigationController.view viewWithTag:101010] removeFromSuperview];
		
	}];
}

#pragma mark - PICKERVIEW DATASOURCE

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView*)pickerView
{
	return 1;
}

-(NSInteger)pickerView:(UIPickerView*)pickerView numberOfRowsInComponent:(NSInteger)component
{
	switch (current_picker_type)
	{
		case kPickerCaseClientTerms:
		{
			return 8;
			break;
		}
			
		case kPickerCaseClientTitle:
		{
			return 5;
			break;
		}
			
		default:
			break;
	}
	
	return 0;
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
	
	switch (current_picker_type)
	{
		case kPickerCaseClientTerms:
		{
			[label setText:[TermsManager termsString:(int)row]];
			break;
		}
			
		case kPickerCaseClientTitle:
		{
			[label setText:[ClientOBJ titleStringForType:(int)row]];
			break;
		}
		
		default:
			break;
	}
	
	return theView;
}

#pragma mark - PICKERVIEW DELEGATE

-(CGFloat)pickerView:(UIPickerView*)pickerView rowHeightForComponent:(NSInteger)component
{
	return 30;
}

-(void)pickerView:(UIPickerView*)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
	[pickerView reloadAllComponents];
	
	switch (current_picker_type)
	{
		case kPickerCaseClientTerms:
		{
			[theClient setTerms:(int)row];
			[myTableView reloadData];
			
			break;
		}
			
		case kPickerCaseClientTitle:
		{
			[theClient setTitle:(int)row];
			[myTableView reloadData];
			
			break;
		}
			
		default:
			break;
	}
}

#pragma mark - TEXTFIELD DELEGATE

-(void)next:(UIButton*)sender
{
	switch (active_field)
	{
		case kActiveFieldCompanyName:
		{
			[(UITextField*)[self.view viewWithTag:222] becomeFirstResponder];
			break;
		}
			
		case kActiveFieldWebsite:
		{
			[(UITextField*)[self.view viewWithTag:333] becomeFirstResponder];
			break;
		}
			
		case kActiveFieldEmail:
		{
			[(UITextField*)[self.view viewWithTag:444] becomeFirstResponder];
			break;
		}
			
		case kActiveFieldPhone:
		{
			[(UITextField*)[self.view viewWithTag:555] becomeFirstResponder];
			break;
		}
			
		case kActiveFieldFax:
		{
			[(UITextField*)[self.view viewWithTag:666] becomeFirstResponder];
			break;
		}
			
		case kActiveFieldFirstName:
		{
			[(UITextField*)[self.view viewWithTag:777] becomeFirstResponder];
			break;
		}
			
		case kActiveFieldLastName:
		{
			[self openPickerForCase:kPickerCaseClientTitle];
			break;
		}
			
		case kActiveFieldTitle:
		{
			[(UITextField*)[self.view viewWithTag:888] becomeFirstResponder];
			break;
		}
			
		case kActiveFieldMobile:
		{
			[self openPickerForCase:kPickerCaseClientTerms];
			break;
		}
			
		case kActiveFieldTerms:
		{
			break;
		}
			
		default:
			break;
	}
}

-(void)prev:(UIButton*)sender
{
	switch (active_field)
	{
		case kActiveFieldCompanyName:
		{
			break;
		}
			
		case kActiveFieldWebsite:
		{
			[(UITextField*)[self.view viewWithTag:111] becomeFirstResponder];
			break;
		}
			
		case kActiveFieldEmail:
		{
			[(UITextField*)[self.view viewWithTag:222] becomeFirstResponder];
			break;
		}
			
		case kActiveFieldPhone:
		{
			[(UITextField*)[self.view viewWithTag:333] becomeFirstResponder];
			break;
		}
			
		case kActiveFieldFax:
		{
			[(UITextField*)[self.view viewWithTag:444] becomeFirstResponder];
			break;
		}
			
		case kActiveFieldFirstName:
		{
			[(UITextField*)[self.view viewWithTag:555] becomeFirstResponder];
			break;
		}
			
		case kActiveFieldLastName:
		{
			[(UITextField*)[self.view viewWithTag:666] becomeFirstResponder];
			break;
		}
			
		case kActiveFieldTitle:
		{
			[(UITextField*)[self.view viewWithTag:777] becomeFirstResponder];
			break;
		}
			
		case kActiveFieldMobile:
		{
			[self openPickerForCase:kPickerCaseClientTitle];
			break;
		}
			
		case kActiveFieldTerms:
		{
			[(UITextField*)[self.view viewWithTag:888] becomeFirstResponder];
			break;
		}
			
		default:
			break;
	}
}

-(void)textFieldDidBeginEditing:(UITextField*)textField
{
	[theToolbar.prevButton setAlpha:1.0];
	[theToolbar.prevButton setUserInteractionEnabled:YES];
	
	[theToolbar.nextButton setAlpha:1.0];
	[theToolbar.nextButton setUserInteractionEnabled:YES];
	
	switch (textField.tag)
	{
		case 111:
		{
			active_field = kActiveFieldCompanyName;
			[theToolbar.prevButton setAlpha:0.5];
			[theToolbar.prevButton setUserInteractionEnabled:NO];
			break;
		}
			
		case 222:
		{
			active_field = kActiveFieldWebsite;
			break;
		}
			
		case 333:
		{
			active_field = kActiveFieldEmail;
			break;
		}
			
		case 444:
		{
			active_field = kActiveFieldPhone;
			break;
		}
			
		case 555:
		{
			active_field = kActiveFieldFax;
			break;
		}
			
		case 666:
		{
			active_field = kActiveFieldFirstName;
			break;
		}
			
		case 777:
		{
			active_field = kActiveFieldLastName;
			break;
		}
			
		case 888:
		{
			active_field = kActiveFieldMobile;
			break;
		}
			
		default:
			break;
	}
}

-(BOOL)textFieldShouldBeginEditing:(UITextField*)textField
{	
	another_textfield_takes_over = YES;
	
	[[self.navigationController.view viewWithTag:101010] removeFromSuperview];
	
	[UIView animateWithDuration:0.25 animations:^{
		
		[theToolbar setFrame:CGRectMake(0, dvc_height - keyboard_height - 40, dvc_width, 40)];
		[mainScrollView setFrame:CGRectMake(mainScrollView.frame.origin.x, mainScrollView.frame.origin.y, dvc_width, dvc_height - 82 - keyboard_height)];
        
		if (mainScrollView && [mainScrollView respondsToSelector:@selector(didScroll)])
        {
			[mainScrollView didScroll];
        }
		
	} completion:^(BOOL finished) {
//		CGRect frame = textField.superview.frame;
//        
//		if (sys_version >= 7)
//        {
//			frame = textField.superview.superview.frame;
//        }
//        
//        if(sys_version >= 8)
//        {
//            frame = textField.superview.frame;
//        }
//                
//		[mainScrollView scrollRectToVisible:frame animated:YES];
//		
	}];
	
	return YES;
}

-(BOOL)textFieldShouldEndEditing:(UITextField*)textField
{
	if (!another_textfield_takes_over)
	{
		[[self.navigationController.view viewWithTag:101010] removeFromSuperview];
		
		[UIView animateWithDuration:0.25 animations:^{
			
			[mainScrollView setFrame:CGRectMake(mainScrollView.frame.origin.x, mainScrollView.frame.origin.y, dvc_width, dvc_height - 87)];
			if (mainScrollView && [mainScrollView respondsToSelector:@selector(didScroll)])
				[mainScrollView didScroll];
			
		}];
	}
	
	another_textfield_takes_over = NO;
	
	switch (textField.tag)
	{
		case 111:
		{
			[theClient setCompany:textField.text];
			break;
		}
			
		case 222:
		{
			[theClient setWebsite:textField.text];
			break;
		}
			
		case 333:
		{
			[theClient setEmail:textField.text];
			break;
		}
			
		case 444:
		{
			[theClient setPhone:textField.text];
			break;
		}
			
		case 555:
		{
			[theClient setFax:textField.text];
			break;
		}
			
		case 666:
		{
			[theClient setFirstName:textField.text];
			break;
		}
			
		case 777:
		{
			[theClient setLastName:textField.text];
			break;
		}
			
		case 888:
		{
			[theClient setMobile:textField.text];
			break;
		}
			
		default:
			break;
	}
	
	return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField*)textField
{
	if (textField.tag < 555)
	{
		[(UITextField*)[self.view viewWithTag:textField.tag + 111] becomeFirstResponder];
	}
	
	if (textField.tag == 666)
	{
		[(UITextField*)[self.view viewWithTag:777] becomeFirstResponder];
	}
	
	if (textField.tag == 777)
	{
		[self openPickerForCase:kPickerCaseClientTitle];
	}
	
	[textField resignFirstResponder];
	
	return YES;
}

#pragma mark - VIEW CONTROLLER FUNCTIONS

-(void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];

	if(firstTime == NO)
	{
		[myTableView reloadData];
	}
	
	firstTime = NO;
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
