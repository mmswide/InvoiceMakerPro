//
//  AddProductDescriptionVC.m
//  Invoice
//
//  Created by XGRoup5 on 8/19/13.
//  Copyright (c) 2013 XGRoup. All rights reserved.
//

#import "AddProductDescriptionVC.h"

#import "Defines.h"

@interface AddProductDescriptionVC () <UITextViewDelegate>

@end

@implementation AddProductDescriptionVC

-(id)initWithProduct:(ProductOBJ*)sender
{
	self = [super init];
	
	if (self)
	{
		theProduct = sender;
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
	
	topBarView = [[TopBar alloc] initWithFrame:CGRectMake(0, 0, dvc_width, 42 + statusBarHeight) andTitle:@"Product Description"];
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
	
	UIImageView * bgForText = [[UIImageView alloc] initWithFrame:CGRectMake(10, 52, dvc_width - 20, 40)];
	[bgForText setImage:[[UIImage imageNamed:@"tableSingleCellWhite.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10]];
	[theSelfView addSubview:bgForText];
	
	UITextView * textView = [[UITextView alloc] initWithFrame:CGRectMake(15, 57, dvc_width - 30, 30)];
	[textView setText:[theProduct note]];
	[textView setTextAlignment:NSTextAlignmentLeft];
	[textView setTextColor:[UIColor blackColor]];
	[textView setDelegate:self];
	[textView setFont:HelveticaNeue(13)];
	[textView setBackgroundColor:[UIColor clearColor]];
	[textView setTag:888];
	[textView setAutocapitalizationType:UITextAutocapitalizationTypeSentences];
	[textView setAutocorrectionType:UITextAutocorrectionTypeNo];
	[theSelfView addSubview:textView];
	
	[self.view addSubview:topBarView];
}

#pragma mark - FUNCTIONS

-(void)back:(UIButton*)sender
{
	[self.navigationController popViewControllerAnimated:YES];
}

-(void)done:(UIButton*)sender
{
	[theProduct setNote:((UITextView*)[self.view viewWithTag:888]).text];
	
	[self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - TEXT VIEW DELEGATE

-(void)closeTextView:(UIButton*)sender
{
	[(UITextView*)[self.view viewWithTag:888] resignFirstResponder];
}

-(BOOL)textViewShouldEndEditing:(UITextView*)textView
{
	[UIView animateWithDuration:0.25 animations:^{
		
		[[self.view viewWithTag:999] setFrame:CGRectMake(0, dvc_height - keyboard_height - 40, dvc_width, 40)];
		
	} completion:^(BOOL finished) {
		
		[[self.view viewWithTag:999] removeFromSuperview];
		
	}];
	
	return YES;
}

-(BOOL)textViewShouldBeginEditing:(UITextView*)textView
{
	ToolBarView * theTextfieldToolbar = [[ToolBarView alloc] initWithFrame:CGRectMake(0, dvc_height, dvc_width, 40)];
	[theTextfieldToolbar.prevButton setAlpha:0.0];
	[theTextfieldToolbar.nextButton setAlpha:0.0];
	[theTextfieldToolbar.doneButton addTarget:self action:@selector(closeTextView:) forControlEvents:UIControlEventTouchUpInside];
	[theTextfieldToolbar setTag:999];
	[theSelfView addSubview:theTextfieldToolbar];
	
	[UIView animateWithDuration:0.25 animations:^{
		
		[theTextfieldToolbar setFrame:CGRectMake(0, dvc_height - keyboard_height - 40, dvc_width, 40)];
		
	}];
	
	return YES;
}

-(BOOL)textView:(UITextView*)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString*)text
{
	NSString * result = [textView.text stringByReplacingCharactersInRange:range withString:text];
	
	if (result.length > 35)
		return NO;
	
	return YES;
}

#pragma mark - VIEW CONTROLLER FUNCTIONS

-(void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
}

@end