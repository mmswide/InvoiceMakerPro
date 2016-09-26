//
//  AddNoteVC.m
//  Invoice
//
//  Created by XGRoup5 on 8/23/13.
//  Copyright (c) 2013 XGRoup. All rights reserved.
//

#import "AddNoteVC.h"

#import "Defines.h"

@interface AddNoteVC () <UITextViewDelegate>

@end

@implementation AddNoteVC

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
		thePurchaseOrder = sender;
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
  
  alwaysShowType = AlwaysShowTypeNote;
	
	theSelfView = [[UIView alloc] initWithFrame:CGRectMake(0, statusBarHeight, dvc_width, dvc_height)];
	[theSelfView setBackgroundColor:[UIColor clearColor]];
	[self.view addSubview:theSelfView];
		
	[self.view setBackgroundColor:app_background_color];
	
	NSString * title = @"Invoice Note";
	
	if (theEstimate)
	{
		title = @"Estimate Note";
	}
	else if (theQuote)
	{
		title = @"Quote Note";
	}
	else if (thePurchaseOrder)
	{
		title = @"Purchase Order Note";
	}
	else if (theTimesheet)
	{
		title = @"Timesheet Note";
	}
	
	topBarView = [[TopBar alloc] initWithFrame:CGRectMake(0, 0, dvc_width, 42 + statusBarHeight) andTitle:title];
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
	
  theToolbar = [[ToolBarView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height, dvc_width, 40)];
  [theToolbar.prevButton setAlpha:0.0];
  [theToolbar.nextButton setAlpha:0.0];
  [theToolbar.doneButton addTarget:self action:@selector(closeTextView:) forControlEvents:UIControlEventTouchUpInside];
  [self.view addSubview:theToolbar];
  
	//FIRST PAGE NOTE
	{
		firstPageView = [[UIView alloc] initWithFrame:CGRectMake(10, 52, dvc_width - 20, 140)];
		[firstPageView setBackgroundColor:[UIColor clearColor]];
		[theSelfView addSubview:firstPageView];
		
		UILabel * titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, dvc_width - 20, 20)];
		[titleLabel setText:@"1st page"];
		[titleLabel setTextAlignment:NSTextAlignmentLeft];
		[titleLabel setTextColor:app_title_color];
		[titleLabel setFont:HelveticaNeueMedium(14)];
		[titleLabel setBackgroundColor:[UIColor clearColor]];
		[firstPageView addSubview:titleLabel];
		
		UIImageView * bgForText = [[UIImageView alloc] initWithFrame:CGRectMake(0, 20, dvc_width - 20, 120)];
		[bgForText setImage:[[UIImage imageNamed:@"tableSingleCellWhite.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10]];
		[firstPageView addSubview:bgForText];
		
		UITextView * textView = [[UITextView alloc] initWithFrame:CGRectMake(5, 25, dvc_width - 20, 110)];
		if (theInvoice)
			[textView setText:[theInvoice note]];
		else if (theEstimate)
			[textView setText:[theEstimate note]];
		else if (theQuote)
			[textView setText:[theQuote note]];
		else if (thePurchaseOrder)
			[textView setText:[thePurchaseOrder note]];
		else if (theTimesheet)
			[textView setText:[theTimesheet note]];
		
		[textView setTextAlignment:NSTextAlignmentLeft];
		[textView setTextColor:[UIColor grayColor]];
		[textView setDelegate:self];
		[textView setFont:HelveticaNeue(16)];
		[textView setBackgroundColor:[UIColor clearColor]];
		[textView setTag:888];
		[textView setAutocapitalizationType:UITextAutocapitalizationTypeSentences];
		[textView setAutocorrectionType:UITextAutocorrectionTypeYes];
		[firstPageView addSubview:textView];
	}
	
	//SECOND PAGE NOTE
	{
		secondPageView = [[UIView alloc] initWithFrame:CGRectMake(10, 200, dvc_width - 20, dvc_height - 210 - ALWAYS_SHOW_HEIGHT - 20)];
		[secondPageView setBackgroundColor:[UIColor clearColor]];
		[theSelfView addSubview:secondPageView];
		
		UILabel * titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, dvc_width - 20, 20)];
		[titleLabel setText:@"2nd page"];
		[titleLabel setTextAlignment:NSTextAlignmentLeft];
		[titleLabel setTextColor:app_title_color];
		[titleLabel setFont:HelveticaNeueMedium(14)];
		[titleLabel setBackgroundColor:[UIColor clearColor]];
		[secondPageView addSubview:titleLabel];
		
		secondBgForText = [[UIImageView alloc] initWithFrame:CGRectMake(0, 20, dvc_width - 20, secondPageView.frame.size.height - 20)];
		[secondBgForText setImage:[[UIImage imageNamed:@"tableSingleCellWhite.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10]];
		[secondPageView addSubview:secondBgForText];
		
		secondTextView = [[UITextView alloc] initWithFrame:CGRectMake(5, 25, dvc_width - 30, secondBgForText.frame.size.height - 10)];
		if (theInvoice)
			[secondTextView setText:[theInvoice bigNote]];
		else if (theEstimate)
			[secondTextView setText:[theEstimate bigNote]];
		else if (theQuote)
			[secondTextView setText:[theQuote bigNote]];
		else if (thePurchaseOrder)
			[secondTextView setText:[thePurchaseOrder bigNote]];
		else if (theTimesheet)
			[secondTextView setText:[theTimesheet bigNote]];
		
		[secondTextView setTextAlignment:NSTextAlignmentLeft];
		[secondTextView setTextColor:[UIColor grayColor]];
		[secondTextView setDelegate:self];
		[secondTextView setFont:HelveticaNeue(16)];
		[secondTextView setBackgroundColor:[UIColor clearColor]];
		[secondTextView setTag:889];
		[secondTextView setAutocapitalizationType:UITextAutocapitalizationTypeSentences];
		[secondTextView setAutocorrectionType:UITextAutocorrectionTypeYes];
		[secondPageView addSubview:secondTextView];
	}
  
  //always show
  [self addAlwaysShowSwitchAfterY:CGRectGetMaxY(secondPageView.frame)];
	
	[self.view addSubview:topBarView];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardFrameChanged:) name:UIKeyboardDidChangeFrameNotification object:nil];
}

#pragma mark - FUNCTIONS

-(void)back:(UIButton*)sender
{
	[self.navigationController popViewControllerAnimated:YES];
}

-(void)done:(UIButton*)sender
{
	[theInvoice setNote:((UITextView*)[self.view viewWithTag:888]).text];
  [theInvoice setBigNote:((UITextView*)[self.view viewWithTag:889]).text];
  [theQuote setNote:((UITextView*)[self.view viewWithTag:888]).text];
  [theQuote setBigNote:((UITextView*)[self.view viewWithTag:889]).text];
	[theEstimate setNote:((UITextView*)[self.view viewWithTag:888]).text];
	[theEstimate setBigNote:((UITextView*)[self.view viewWithTag:889]).text];
	[thePurchaseOrder setNote:((UITextView*)[self.view viewWithTag:888]).text];
	[thePurchaseOrder setBigNote:((UITextView*)[self.view viewWithTag:889]).text];
  
  if([theInvoice alwaysShowNote] || [theQuote alwaysShowNote] ||
     [theEstimate alwaysShowNote] || [thePurchaseOrder alwaysShowNote]) {
    
    [theInvoice saveNote:((UITextView*)[self.view viewWithTag:888]).text];
    [theInvoice saveBigNote:((UITextView*)[self.view viewWithTag:889]).text];
    [theQuote saveNote:((UITextView*)[self.view viewWithTag:888]).text];
    [theQuote saveBigNote:((UITextView*)[self.view viewWithTag:889]).text];
    [theEstimate saveNote:((UITextView*)[self.view viewWithTag:888]).text];
    [theEstimate saveBigNote:((UITextView*)[self.view viewWithTag:889]).text];
    [thePurchaseOrder saveNote:((UITextView*)[self.view viewWithTag:888]).text];
    [thePurchaseOrder saveBigNote:((UITextView*)[self.view viewWithTag:889]).text];
  } else {
    [theInvoice saveNote:@"Thanks for your business!"];
    [theInvoice saveBigNote:@""];
    [theQuote saveNote:@"Thanks for your business!"];
    [theQuote saveBigNote:@""];
    [theEstimate saveNote:@"Thanks for your business!"];
    [theEstimate saveBigNote:@""];
    [thePurchaseOrder saveNote:@"Thanks for your business!"];
    [thePurchaseOrder saveBigNote:@""];
  }
  
  [theTimesheet setNote:((UITextView*)[self.view viewWithTag:888]).text];
	[theTimesheet setBigNote:((UITextView*)[self.view viewWithTag:889]).text];

	[self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - TEXT VIEW DELEGATE

-(void)closeTextView:(UIButton*)sender
{
    [(UITextView*)[self.view viewWithTag:888] resignFirstResponder];
    [(UITextView*)[self.view viewWithTag:889] resignFirstResponder];
}

-(BOOL)textViewShouldEndEditing:(UITextView*)textView {
    [UIView animateWithDuration:0.25 animations:^{
      [firstPageView setFrame:CGRectMake(10, 52, dvc_width - 20, 140)];
      [secondPageView setFrame:CGRectMake(10, 200, dvc_width - 20, dvc_height - 210 - ALWAYS_SHOW_HEIGHT - 20)];
      [firstPageView setAlpha:1.0];
      [secondPageView setAlpha:1.0];
      [oAlwaysView setAlpha:1.f];
      
      [secondBgForText setFrame:CGRectMake(0, 20, dvc_width - 20, secondPageView.frame.size.height - 20)];
      [secondTextView setFrame:CGRectMake(5, 25, dvc_width - 30, secondBgForText.frame.size.height - 10)];
      
      [theToolbar setFrame:CGRectMake(0, self.view.frame.size.height, dvc_width, 40)];
    }];
    return YES;
}

-(BOOL)textViewShouldBeginEditing:(UITextView*)textView {
    UIView * activeView;
    UIView * inactiveView;
    
    if (textView.tag == 888) {
        activeView = firstPageView;
        inactiveView = secondPageView;
    } else if (textView.tag == 889) {
        activeView = secondPageView;
        inactiveView = firstPageView;
    }
    
    realActiveView = activeView;
    
    [UIView animateWithDuration:0.25 animations:^{
      if (textView.tag == 888) {
        [activeView setFrame:CGRectMake(10, 52, activeView.frame.size.width, activeView.frame.size.height)];
        [inactiveView setAlpha:0.0];
      } else if (textView.tag == 889) {
        [activeView setFrame:CGRectMake(10, 52, activeView.frame.size.width, dvc_height - 52 - keyboard_height - 44)];
        
        [secondBgForText setFrame:CGRectMake(0, 20, dvc_width - 20, secondPageView.frame.size.height - 20)];
        [secondTextView setFrame:CGRectMake(5, 25, dvc_width - 30, secondBgForText.frame.size.height - 10)];
        
        [inactiveView setAlpha:0.0];
      }
      [oAlwaysView setAlpha:0.f];
      [theToolbar setFrame:CGRectMake(0, dvc_height - keyboard_height - 20, dvc_width, 40)];
    }];
    
    return YES;
}

-(BOOL)textView:(UITextView*)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString*)text {
	if (textView.tag == 889)
		return YES;
	
	NSString * result = [textView.text stringByReplacingCharactersInRange:range withString:text];
	
	if (result.length > 250) {
		return NO;
	}
	
	return YES;
}

#pragma mark - Notification Center

-(void)keyboardFrameChanged:(NSNotification*)notification {
    NSDictionary* info = [notification userInfo];
    
    CGPoint to = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].origin;
    
    if(to.y == dvc_height + 20) {
        return;
    }
    
    [UIView animateWithDuration:0.25 animations:^{
        
        theToolbar.frame = CGRectMake(theToolbar.frame.origin.x, to.y - theToolbar.frame.size.height, theToolbar.frame.size.width, theToolbar.frame.size.height);
        
        float height = theSelfView.frame.size.height - 72 -  (theSelfView.frame.size.height - theToolbar.frame.origin.y);
        
        if(realActiveView == firstPageView && height <= 140) {
            realActiveView.frame = CGRectMake(realActiveView.frame.origin.x, realActiveView.frame.origin.y, realActiveView.frame.size.width, height);
            
            [[firstPageView viewWithTag:8889] setFrame:CGRectMake(0, 20, dvc_width - 20, height - 20)];
            [[firstPageView viewWithTag:888] setFrame:CGRectMake(5, 25, dvc_width - 30, height - 30)];
        } else if(realActiveView == secondPageView && height <= dvc_height - 210)
            {
                realActiveView.frame = CGRectMake(realActiveView.frame.origin.x, realActiveView.frame.origin.y, realActiveView.frame.size.width, height);
                
                [secondBgForText setFrame:CGRectMake(0, 20, dvc_width - 20, secondPageView.frame.size.height - 20)];
                [secondTextView setFrame:CGRectMake(5, 25, dvc_width - 30, secondBgForText.frame.size.height - 10)];
            }
        
        
    } completion:^(BOOL finished) {
        
    }];
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end