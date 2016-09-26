//
//  OtherCommentsVC.m
//  Invoice
//
//  Created by Paul on 16/04/14.
//  Copyright (c) 2014 XGRoup. All rights reserved.
//

#import "OtherCommentsVC.h"
#import "Defines.h"

@interface OtherCommentsVC () <UITextViewDelegate>

@end

@implementation OtherCommentsVC

-(id)initWithInvoice:(InvoiceOBJ*)sender
{
	self = [super init];
	
	if (self)
	{
		theInvoice = sender;
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

-(id)initWithEstimate:(EstimateOBJ*)sender
{
	self = [super init];
	
	if (self)
	{
		theEstimate = sender;
	}
	
	return self;
}

-(id)initWithPurchaseOrder:(PurchaseOrderOBJ*)sender
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

-(void)viewDidLoad
{
  [super viewDidLoad];
  
  alwaysShowType = AlwaysShowTypeOtherComment;
  
  theSelfView = [[UIView alloc] initWithFrame:CGRectMake(0, statusBarHeight, dvc_width, dvc_height)];
  [theSelfView setBackgroundColor:[UIColor clearColor]];
  [self.view addSubview:theSelfView];
  
  [self.view setBackgroundColor:app_background_color];
  
  topBarView = [[TopBar alloc] initWithFrame:CGRectMake(0, 0, dvc_width, 42 + statusBarHeight) andTitle:@"Other Comments"];
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
    
  //TITLE
  {
    oTitleView = [[UIView alloc] initWithFrame:CGRectMake(10, 52, dvc_width - 20, 60)];
    [oTitleView setBackgroundColor:[UIColor clearColor]];
    [theSelfView addSubview:oTitleView];
    
    UILabel * titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, dvc_width - 20, 20)];
    [titleLabel setText:@"Title"];
    [titleLabel setTextAlignment:NSTextAlignmentLeft];
    [titleLabel setTextColor:app_title_color];
    [titleLabel setFont:HelveticaNeueMedium(14)];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [oTitleView addSubview:titleLabel];
    
    UIImageView * bgForText = [[UIImageView alloc] initWithFrame:CGRectMake(0, 20, dvc_width - 20, 40)];
    [bgForText setImage:[[UIImage imageNamed:@"tableSingleCellWhite.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10]];
    [oTitleView addSubview:bgForText];
    
    UITextView * txtView = [[UITextView alloc] initWithFrame:CGRectMake(5, 22, dvc_width - 30, 30)];
    if (theInvoice)
        [txtView setText:[theInvoice otherCommentsTitle]];
    else if (theQuote)
        [txtView setText:[theQuote otherCommentsTitle]];
    else if (theEstimate)
        [txtView setText:[theEstimate otherCommentsTitle]];
    else if (thePurchaseOrder)
        [txtView setText:[thePurchaseOrder otherCommentsTitle]];
    else if(theTimesheet)
        [txtView setText:[theTimesheet otherCommentsTitle]];
    
    [txtView setTextAlignment:NSTextAlignmentLeft];
    [txtView setTextColor:[UIColor grayColor]];
    [txtView setDelegate:self];
    [txtView setFont:HelveticaNeue(14)];
    [txtView setBackgroundColor:[UIColor clearColor]];
    [txtView setTag:888];
    [txtView setAutocapitalizationType:UITextAutocapitalizationTypeSentences];
    [txtView setAutocorrectionType:UITextAutocorrectionTypeNo];
    txtView.scrollEnabled = NO;
    [oTitleView addSubview:txtView];
  }
  
  //TEXT
  {
    oTextView = [[UIView alloc] initWithFrame:CGRectMake(10, 120, dvc_width - 20, 130)];
    [oTextView setBackgroundColor:[UIColor clearColor]];
    [theSelfView addSubview:oTextView];
    
    UILabel * titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, dvc_width - 20, 20)];
    [titleLabel setText:@"Comment"];
    [titleLabel setTextAlignment:NSTextAlignmentLeft];
    [titleLabel setTextColor:app_title_color];
    [titleLabel setFont:HelveticaNeueMedium(14)];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [oTextView addSubview:titleLabel];
    
    //		secondBgForText = [[UIImageView alloc] initWithFrame:CGRectMake(0, 20, dvc_width - 20, (oTextView.frame.size.height - 20) / 2)];
    secondBgForText = [[UIImageView alloc] initWithFrame:CGRectMake(0, 20, dvc_width - 20, 110)];
    [secondBgForText setImage:[[UIImage imageNamed:@"tableSingleCellWhite.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10]];
    secondBgForText.backgroundColor = [UIColor clearColor];
    [oTextView addSubview:secondBgForText];
    
    //		secondTextView = [[UITextView alloc] initWithFrame:CGRectMake(5, 25, dvc_width - 30, secondBgForText.frame.size.height - 10)];
    secondTextView = [[UITextView alloc] initWithFrame:CGRectMake(5, 25, dvc_width - 30, secondBgForText.frame.size.height - 20)];
    if (theInvoice)
        [secondTextView setText:[theInvoice otherCommentsText]];
    else if (theQuote)
        [secondTextView setText:[theQuote otherCommentsText]];
    else if (theEstimate)
        [secondTextView setText:[theEstimate otherCommentsText]];
    else if (thePurchaseOrder)
        [secondTextView setText:[thePurchaseOrder otherCommentsText]];
    else if (theTimesheet)
        [secondTextView setText:[theTimesheet otherComments]];
    [secondTextView setTextAlignment:NSTextAlignmentLeft];
    [secondTextView setTextColor:[UIColor grayColor]];
    [secondTextView setDelegate:self];
    [secondTextView setFont:HelveticaNeue(14)];
    [secondTextView setBackgroundColor:[UIColor clearColor]];
    [secondTextView setTag:889];
    [secondTextView setAutocapitalizationType:UITextAutocapitalizationTypeSentences];
    [secondTextView setAutocorrectionType:UITextAutocorrectionTypeYes];
    [oTextView addSubview:secondTextView];
  }
  
  //Always show
  [self addAlwaysShowSwitchAfterY:CGRectGetMaxY(oTextView.frame)];
  
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

-(void)done:(UIButton*)sender {
	[theInvoice setOtherCommentsTitle:((UITextView*)[self.view viewWithTag:888]).text];
	[theInvoice setOtherCommentsText:((UITextView*)[self.view viewWithTag:889]).text];
	[theQuote setOtherCommentsTitle:((UITextView*)[self.view viewWithTag:888]).text];
	[theQuote setOtherCommentsText:((UITextView*)[self.view viewWithTag:889]).text];
	[theEstimate setOtherCommentsTitle:((UITextView*)[self.view viewWithTag:888]).text];
	[theEstimate setOtherCommentsText:((UITextView*)[self.view viewWithTag:889]).text];
	[thePurchaseOrder setOtherCommentsTitle:((UITextView*)[self.view viewWithTag:888]).text];
	[thePurchaseOrder setOtherCommentsText:((UITextView*)[self.view viewWithTag:889]).text];
  
  if([theInvoice alwaysShowOtherComments] || [theQuote alwaysShowOtherComments] ||
     [theEstimate alwaysShowOtherComments] || [thePurchaseOrder alwaysShowOtherComments]) {
    [theInvoice saveOtherCommentsTitle:((UITextView*)[self.view viewWithTag:888]).text];
    [theInvoice saveOtherCommentsText:((UITextView*)[self.view viewWithTag:889]).text];
    [theQuote saveOtherCommentsTitle:((UITextView*)[self.view viewWithTag:888]).text];
    [theQuote saveOtherCommentsText:((UITextView*)[self.view viewWithTag:889]).text];
    [theEstimate saveOtherCommentsTitle:((UITextView*)[self.view viewWithTag:888]).text];
    [theEstimate saveOtherCommentsText:((UITextView*)[self.view viewWithTag:889]).text];
    [thePurchaseOrder saveOtherCommentsTitle:((UITextView*)[self.view viewWithTag:888]).text];
    [thePurchaseOrder saveOtherCommentsText:((UITextView*)[self.view viewWithTag:889]).text];
  } else {
    [theInvoice saveOtherCommentsTitle:@"Other Comments"];
    [theInvoice saveOtherCommentsText:@""];
    [theQuote saveOtherCommentsTitle:@"Other Comments"];
    [theQuote saveOtherCommentsText:@""];
    [theEstimate saveOtherCommentsTitle:@"Other Comments"];
    [theEstimate saveOtherCommentsText:@""];
    [thePurchaseOrder saveOtherCommentsTitle:@"Other Comments"];
    [thePurchaseOrder saveOtherCommentsText:@""];
  }
  
	[theTimesheet setOtherCommentsTitle:((UITextView*)[self.view viewWithTag:888]).text];
	[theTimesheet setOtherCommentsText:((UITextView*)[self.view viewWithTag:889]).text];
	
	[self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - TEXT VIEW DELEGATE

-(void)closeTextView:(UIButton*)sender
{
    [(UITextView*)[self.view viewWithTag:888] resignFirstResponder];
    [(UITextView*)[self.view viewWithTag:889] resignFirstResponder];
}

-(BOOL)textViewShouldEndEditing:(UITextView*)textView
{
    [UIView animateWithDuration:0.25 animations:^{
      [oTitleView setFrame:CGRectMake(10, 52, dvc_width - 20, 60)];
      [oTextView setFrame:CGRectMake(10, 120, dvc_width - 20, 130)];
      [oTitleView setAlpha:1.0];
      [oTextView setAlpha:1.0];
      [oAlwaysView setAlpha:1.f];
        
      [secondBgForText setFrame:CGRectMake(0, 20, dvc_width - 20, 110)];
      //		[secondBgForText setFrame:CGRectMake(0, 20, dvc_width - 20, (oTextView.frame.size.height - 20) / 2)];
      
      [secondTextView setFrame:CGRectMake(5, 25, dvc_width - 30, secondBgForText.frame.size.height - 10)];
      
      [[self.view viewWithTag:999] setFrame:CGRectMake(0, dvc_height, dvc_width, 40)];
    } completion:^(BOOL finished) {
        [[self.view viewWithTag:999] removeFromSuperview];
    }];
    
    return YES;
}

-(BOOL)textViewShouldBeginEditing:(UITextView*)textView {
    ToolBarView * theTextfieldToolbar = [[ToolBarView alloc] initWithFrame:CGRectMake(0, dvc_height, dvc_width, 40)];
    [theTextfieldToolbar.prevButton setAlpha:0.0];
    [theTextfieldToolbar.nextButton setAlpha:0.0];
    [theTextfieldToolbar.doneButton addTarget:self action:@selector(closeTextView:) forControlEvents:UIControlEventTouchUpInside];
    [theTextfieldToolbar setTag:999];
    [self.view addSubview:theTextfieldToolbar];
    
    UIView * activeView;
    UIView * inactiveView;
    
    if (textView.tag == 888) {
        activeView = oTitleView;
        inactiveView = oTextView;
    } else if (textView.tag == 889) {
        activeView = oTextView;
        inactiveView = oTitleView;
    }
    
    [UIView animateWithDuration:0.25 animations:^{
        if (textView.tag == 888) {
            [activeView setFrame:CGRectMake(10, 52, activeView.frame.size.width, activeView.frame.size.height)];
            [inactiveView setAlpha:0.0];
        } else if (textView.tag == 889) {
            [activeView setFrame:CGRectMake(10, 52, activeView.frame.size.width, dvc_height - 52 - keyboard_height - 44)];
            
            [secondBgForText setFrame:CGRectMake(0, 20, dvc_width - 20, 110)];
            [secondTextView setFrame:CGRectMake(5, 25, dvc_width - 30, secondBgForText.frame.size.height - 10)];
            
            [inactiveView setAlpha:0.0];
        }
      [oAlwaysView setAlpha:0.f];
        
        [theToolbar setFrame:CGRectMake(0, dvc_height - keyboard_height - 20, dvc_width, 40)];
    }];
    
    return YES;
}

-(BOOL)textView:(UITextView*)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString*)text
{
	NSString * result = [textView.text stringByReplacingCharactersInRange:range withString:text];
	
	if (textView.tag == 888)
	{
		if (result.length > 50)
		{
			return NO;
		}
	}
	else if (textView.tag == 889)
	{
		float difference = (dvc_width > 568) ? 30 : 10;
		CGSize textSize = [[DataManager sharedManager] sizeForString:result withFont:secondTextView.font constrainedToSize:CGSizeMake(secondTextView.frame.size.width - difference, 10000)];
		
		if(textSize.height > 90)
		{
			return NO;
		}
				
		int lineCount = (int)[[result componentsSeparatedByString:@"\n"] count];
		
		if(lineCount > 5)
		{
			return NO;
		}
		
		if (result.length > 240)
		{
			return NO;
		}
	}
	
	return YES;
}

#pragma mark - Notification Center

-(void)keyboardFrameChanged:(NSNotification*)notification
{
    NSDictionary* info = [notification userInfo];
    
    CGPoint to = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].origin;
    
    if(to.y == dvc_height + 20)
    {
        return;
    }
    
    ToolBarView *toolbar = (ToolBarView*)[self.view viewWithTag:999];
    
    [UIView animateWithDuration:0.25 animations:^{
        
        toolbar.frame = CGRectMake(toolbar.frame.origin.x, to.y - toolbar.frame.size.height, toolbar.frame.size.width, toolbar.frame.size.height);
        
    } completion:^(BOOL finished) {
        
    }];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end