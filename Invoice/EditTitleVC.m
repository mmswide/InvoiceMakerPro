//
//  EditTitleVC.m
//  Invoice
//
//  Created by Paul on 24/03/14.
//  Copyright (c) 2014 XGRoup. All rights reserved.
//

#import "EditTitleVC.h"

#import "Defines.h"

@interface EditTitleVC () <UITextFieldDelegate>

@end

@implementation EditTitleVC

-(id)initWithInvoice:(InvoiceOBJ*)sender
{
	self = [super init];
	
	if (self)
	{
		theInvoice = sender;
	}
	
	return self;
}

-(id)initWithEstimate:(EstimateOBJ*)sender
{
	self = [super init];
	
	if (self)
	{
		theEstimate = sender;
	}
	
	return self;
}

-(id)initWithQuote:(QuoteOBJ*)sender
{
	self = [super init];
	
	if (self)
	{
		theQuote = sender;
	}
	
	return self;
}

-(id)initWithPO:(PurchaseOrderOBJ*)sender
{
	self = [super init];
	
	if (self)
	{
		thePurchareOrder = sender;
	}
	
	return self;
}

-(id)initWithReceipt:(ReceiptOBJ *)sender
{
	self = [super init];
	
	if(self)
	{
		theReceipt = sender;
	}
	
	return self;
}

-(id)initWithTimesheet:(TimeSheetOBJ *)sender
{
	self = [super init];
	
	if(self)
	{
		theTimesheet = sender;
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
	
	topBarView = [[TopBar alloc] initWithFrame:CGRectMake(0, 0, dvc_width, 42 + statusBarHeight) andTitle:@"Title"];
	[topBarView setBackgroundColor:app_bar_update_color];
	
	BackButton * backButton = [[BackButton alloc] initWithFrame:CGRectMake(0, 42 + statusBarHeight - 40, 70, 40) andTitle:@"Back"];
	[backButton addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
	[topBarView addSubview:backButton];
	
	UIButton * done = [[UIButton alloc] initWithFrame:CGRectMake(dvc_width - 60, 42 + statusBarHeight - 40, 60, 40)];
	[done setTitle:@"Done" forState:UIControlStateNormal];
	[done setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[done setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
	[done.titleLabel setFont:HelveticaNeueLight(17)];
	[done addTarget:self action:@selector(done:) forControlEvents:UIControlEventTouchUpInside];
	[topBarView addSubview:done];
	
	UIImageView * bgForText = [[UIImageView alloc] initWithFrame:CGRectMake(10, 52, dvc_width - 20, 44)];
	[bgForText setImage:[[UIImage imageNamed:@"tableSingleCellWhite.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10]];
	[theSelfView addSubview:bgForText];
	
	UITextField * textField = [[UITextField alloc] initWithFrame:CGRectMake(15, 57, dvc_width - 30, 34)];
	if (theInvoice)
		[textField setText:[theInvoice title]];
	else if (theEstimate)
		[textField setText:[theEstimate title]];
	else if (theQuote)
		[textField setText:[theQuote title]];
	else if (thePurchareOrder)
		[textField setText:[thePurchareOrder title]];
	else if(theReceipt)
		[textField setText:[theReceipt title]];
	else if(theTimesheet)
		[textField setText:[theTimesheet title]];
	
	[textField setTextAlignment:NSTextAlignmentLeft];
	[textField setTextColor:[UIColor grayColor]];
	[textField setDelegate:self];
	[textField setFont:HelveticaNeue(16)];
	[textField setBackgroundColor:[UIColor clearColor]];
	[textField setTag:888];
	[textField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
	[textField setAutocorrectionType:UITextAutocorrectionTypeNo];
	[textField setReturnKeyType:UIReturnKeyDone];
	[theSelfView addSubview:textField];
	
	[self.view addSubview:topBarView];
}

#pragma mark - FUNCTIONS

-(void)back:(UIButton*)sender
{
	[self.navigationController popViewControllerAnimated:YES];
}

-(void)done:(UIButton*)sender
{
	[theInvoice setTitle:((UITextField*)[self.view viewWithTag:888]).text];
	[theEstimate setTitle:((UITextField*)[self.view viewWithTag:888]).text];
	[theQuote setTitle:((UITextField*)[self.view viewWithTag:888]).text];
	[thePurchareOrder setTitle:((UITextField*)[self.view viewWithTag:888]).text];
	[theReceipt setTitle:((UITextField*)[self.view viewWithTag:888]).text];
	[theTimesheet setTitle:((UITextField*)[self.view viewWithTag:888]).text];
	
	[self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - TEXT FIELD DELEGATE

-(void)closeTextField:(UIButton*)sender
{
	[(UITextField*)[self.view viewWithTag:888] resignFirstResponder];
}

-(BOOL)textField:(UITextField*)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString*)string
{
	NSString * result = [textField.text stringByReplacingCharactersInRange:range withString:string];
	
	if (result.length > 14)
	{
		return NO;
	}
	
	return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField*)textField
{
	[textField resignFirstResponder];
	return YES;
}

#pragma mark - VIEW CONTROLLER FUNCTIONS

-(void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
}

@end
