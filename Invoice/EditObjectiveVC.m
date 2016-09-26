//
//  EditObjectiveVC.m
//  Meeting.
//
//  Created by XGRoup5 on 31/10/13.
//  Copyright (c) 2013 XGRoup. All rights reserved.
//

#import "EditObjectiveVC.h"

#import "Defines.h"

@interface EditObjectiveVC () <UITextViewDelegate>

@end

@implementation EditObjectiveVC

@synthesize delegate;

-(id)initWithDelegate:(id<ObjectiveEditorDelegate>)sender andObjective:(NSString*)obj
{
	self = [super init];
	
	if (self)
	{
		if (!obj)
			obj = @"";
		
		delegate = sender;
		theObjective = [[NSMutableString alloc] initWithString:obj];
		titleString = [[NSMutableString alloc] initWithString:@"Description"];
	}
	
	return self;
}

#pragma mark
#pragma mark VIEW DID LOAD

-(void)viewDidLoad
{
	[super viewDidLoad];
	
	theSelfView = [[UIView alloc] initWithFrame:CGRectMake(0, statusBarHeight, dvc_width, (dvc_height + 20))];
	[theSelfView setBackgroundColor:[UIColor clearColor]];
	[self.view addSubview:theSelfView];
	
	[self.view setBackgroundColor:app_background_color];
	
	topBarView = [[TopBar alloc] initWithFrame:CGRectMake(0, 0, dvc_width, 42 + statusBarHeight) andTitle:@"Description"];
	[topBarView setTag:111];
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
	
	UIImageView * bgForText = [[UIImageView alloc] initWithFrame:CGRectMake(10, 52, dvc_width - 20, 90)];
	[bgForText setImage:[[UIImage imageNamed:@"tableSingleCellWhite.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10]];
	[theSelfView addSubview:bgForText];
	
	UITextView * textView = [[UITextView alloc] initWithFrame:CGRectMake(15, 57, dvc_width - 30, 80)];
	[textView setText:@""];
	[textView setTextAlignment:NSTextAlignmentLeft];
	[textView setTextColor:[UIColor darkGrayColor]];
	[textView setDelegate:self];
	[textView setFont:HelveticaNeue(16)];
	[textView setBackgroundColor:[UIColor clearColor]];
	[textView setTag:888];
	[textView setText:theObjective];
	[textView setAutocapitalizationType:UITextAutocapitalizationTypeSentences];
	[textView setAutocorrectionType:UITextAutocorrectionTypeYes];
	[theSelfView addSubview:textView];
	
	NSUInteger numLines = textView.contentSize.height / textView.font.lineHeight;
	
	if (numLines > 3)
	{
		textView.text = [textView.text substringToIndex:textView.text.length - 1];
		[textView resignFirstResponder];
	}
	
	[self.view addSubview:topBarView];
}

#pragma mark
#pragma mark FUNCTIONS

-(void)changeTitleTo:(NSString*)sender
{
	[titleString setString:sender];
}

-(void)back:(UIButton*)sender
{
	[(UITextView*)[self.view viewWithTag:888] resignFirstResponder];
	[self.navigationController popViewControllerAnimated:YES];
}

-(void)done:(UIButton*)sender
{
	[(UITextView*)[self.view viewWithTag:888] resignFirstResponder];
	
	if (delegate && [delegate respondsToSelector:@selector(editorViewController:editedObjective:)])
	{
		[delegate editorViewController:self editedObjective:theObjective];
	}
	
	[self.navigationController popViewControllerAnimated:YES];
}

#pragma mark
#pragma mark TEXT VIEW DELEGATE

-(void)closeTextView:(UIButton*)sender
{
	[(UITextView*)[self.view viewWithTag:888] resignFirstResponder];
}

-(BOOL)textViewShouldEndEditing:(UITextView*)textView
{
	[UIView animateWithDuration:0.25 animations:^{
		
		[[self.view viewWithTag:999] setFrame:CGRectMake(0, (dvc_height + 20), dvc_width, 40)];
		
	} completion:^(BOOL finished) {
		
		[[self.view viewWithTag:999] removeFromSuperview];
		
	}];
	
	return YES;
}

-(BOOL)textViewShouldBeginEditing:(UITextView*)textView
{
	ToolBarView * theTextfieldToolbar = [[ToolBarView alloc] initWithFrame:CGRectMake(0, (dvc_height + 20), dvc_width, 40)];
	[theTextfieldToolbar.prevButton setAlpha:0.0];
	[theTextfieldToolbar.nextButton setAlpha:0.0];
	[theTextfieldToolbar.doneButton addTarget:self action:@selector(closeTextView:) forControlEvents:UIControlEventTouchUpInside];
	[theTextfieldToolbar setTag:999];
	[theSelfView addSubview:theTextfieldToolbar];
	
	[UIView animateWithDuration:0.25 animations:^{
		
		[theTextfieldToolbar setFrame:CGRectMake(0, (dvc_height + 20) - keyboard_height - 60, dvc_width, 40)];
		
	}];
	
	return YES;
}

-(void)textViewDidEndEditing:(UITextView*)textView
{
	NSUInteger numLines = textView.contentSize.height / textView.font.lineHeight;
	
	if (numLines > 3)
	{
		textView.text = [textView.text substringToIndex:textView.text.length - 1];
	}
	
	[theObjective setString:textView.text];
}

-(void)textViewDidChange:(UITextView *)textView
{
	NSUInteger numLines = textView.contentSize.height / textView.font.lineHeight;
	
	if (numLines > 3)
	{
		[textView resignFirstResponder];
	}
}

#pragma mark
#pragma mark VIEW CONTROLLER FUNCTIONS

-(void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	[(TopBar*)[theSelfView viewWithTag:111] setText:titleString];
}

-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[(TopBar*)[theSelfView viewWithTag:111] setText:titleString];
}

-(void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
}

@end