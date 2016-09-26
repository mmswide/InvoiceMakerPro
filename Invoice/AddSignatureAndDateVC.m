//
//  AddSignatureAndDateVC.m
//  Work.
//
//  Created by Paul on 16/04/14.
//  Copyright (c) 2014 XGRoup. All rights reserved.
//

#import "AddSignatureAndDateVC.h"
#import "Defines.h"
#import "SignatureView.h"
#import "ColorPicker.h"

@interface AddSignatureAndDateVC () <UITextFieldDelegate, UITextViewDelegate>

@end

@implementation AddSignatureAndDateVC

-(id)initWithDelegate:(id<SignatureAndDateCreatorDelegate>)sender andInvoice:(InvoiceOBJ*)invoice type:(kSignatureType)type
{
	self = [super init];
	
	if (self)
	{
		_signatureType = type;
		_delegate = sender;
		[date_formatter setDateFormat:[DELEGATE userSelectedDateFormat]];
		
		switch (type)
		{
			case kSignatureTypeLeft:
			{
				theDate = [date_formatter dateFromString:[invoice leftSignatureDate]];
				break;
			}
				
			case kSignatureTypeRight:
			{
				theDate = [date_formatter dateFromString:[invoice rightSignatureDate]];
				break;
			}
		}
		
		theInvoice = invoice;
	}
	
	return self;
}

-(id)initWithDelegate:(id<SignatureAndDateCreatorDelegate>)sender andQuote:(QuoteOBJ*)quote type:(kSignatureType)type
{
	self = [super init];
	
	if (self)
	{
		_signatureType = type;
		_delegate = sender;
		[date_formatter setDateFormat:[DELEGATE userSelectedDateFormat]];
		
		switch (type)
		{
			case kSignatureTypeLeft:
			{
				theDate = [date_formatter dateFromString:[quote leftSignatureDate]];
				break;
			}
				
			case kSignatureTypeRight:
			{
				theDate = [date_formatter dateFromString:[quote rightSignatureDate]];
				break;
			}
		}
		
		theQuote = quote;
	}
	
	return self;
}

-(id)initWithDelegate:(id<SignatureAndDateCreatorDelegate>)sender andEstimate:(EstimateOBJ*)estimate type:(kSignatureType)type
{
	self = [super init];
	
	if (self)
	{
		_signatureType = type;
		_delegate = sender;
		[date_formatter setDateFormat:[DELEGATE userSelectedDateFormat]];
		
		switch (type)
		{
			case kSignatureTypeLeft:
			{
				theDate = [date_formatter dateFromString:[estimate leftSignatureDate]];
				break;
			}
				
			case kSignatureTypeRight:
			{
				theDate = [date_formatter dateFromString:[estimate rightSignatureDate]];
				break;
			}
		}
		
		theEstimate = estimate;
	}
	
	return self;
}

-(id)initWithDelegate:(id<SignatureAndDateCreatorDelegate>)sender andPurchaseOrder:(PurchaseOrderOBJ*)purchaseOrder type:(kSignatureType)type
{
	self = [super init];
	
	if (self)
	{
		_signatureType = type;
		_delegate = sender;
		[date_formatter setDateFormat:[DELEGATE userSelectedDateFormat]];
		
		switch (type)
		{
			case kSignatureTypeLeft:
			{
				theDate = [date_formatter dateFromString:[purchaseOrder leftSignatureDate]];
				break;
			}
				
			case kSignatureTypeRight:
			{
				theDate = [date_formatter dateFromString:[purchaseOrder rightSignatureDate]];
				break;
			}
		}
		
		thePurchaseOrder = purchaseOrder;
	}
	
	return self;
}

-(id)initWithDelegate:(id<SignatureAndDateCreatorDelegate>)sender andTimesheet:(TimeSheetOBJ*)timesheet type:(kSignatureType)type
{
	self = [super init];
	
	if(self)
	{
		_signatureType = type;
		_delegate = sender;
		
		[date_formatter setDateFormat:[DELEGATE userSelectedDateFormat]];
		
		switch (type)
		{
			case kSignatureTypeLeft:
			{
				theDate = [timesheet leftSignatureDate];
				
				break;
			}
				
			case kSignatureTypeRight:
			{
				theDate = [timesheet rightSignatureDate];
				
				break;
			}
				
			default:
				break;
		}
		
		theTimesheet = timesheet;
	}
	
	return self;
}

#pragma mark - VIEW DID LOAD

-(void)viewDidLoad
{
	[super viewDidLoad];
  
  alwaysShowType = _signatureType == kSignatureTypeLeft?AlwaysShowTypeSignatyreLeft:AlwaysShowTypeSignatyreRight;
	
  //top bar
	topBarView = [[TopBar alloc] initWithFrame:CGRectMake(0, 0, dvc_width, 42 + statusBarHeight) andTitle:@"Signature"];
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
  
  //main content
  mainScrollView = [[ScrollWithShadow alloc] initWithFrame:CGRectMake(0,
                                                                      CGRectGetMaxY(topBarView.frame) - statusBarHeight,
                                                                      dvc_width,
                                                                      dvc_height - CGRectGetMaxY(topBarView.frame) + 2 * statusBarHeight)];
  
  theSelfView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, dvc_width, mainScrollView.frame.size.height)];
  [theSelfView setBackgroundColor:[UIColor clearColor]];
  [self.view addSubview:mainScrollView];
  
  [mainScrollView addSubview:theSelfView];
  [mainScrollView setContentSize:theSelfView.frame.size];
  
  [self.view setBackgroundColor:app_background_color];
	
	//SIGNATURE TITLE
	{
		signatureTitleView = [[UIView alloc] initWithFrame:CGRectMake(10, 10, dvc_width - 20, 100)];
		[signatureTitleView setBackgroundColor:[UIColor clearColor]];
		[theSelfView addSubview:signatureTitleView];
		
		UILabel * titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, dvc_width - 20, 20)];
		[titleLabel setText:@"Title"];
		[titleLabel setTextAlignment:NSTextAlignmentLeft];
		[titleLabel setTextColor:app_title_color];
		[titleLabel setFont:HelveticaNeueMedium(14)];
		[titleLabel setBackgroundColor:[UIColor clearColor]];
		[signatureTitleView addSubview:titleLabel];
		
		UIImageView * bgForText = [[UIImageView alloc] initWithFrame:CGRectMake(0, 20, dvc_width - 20, 80)];
		[bgForText setImage:[[UIImage imageNamed:@"tableSingleCellWhite.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10]];
		[signatureTitleView addSubview:bgForText];
		
		titleTextView = [[UITextView alloc] initWithFrame:CGRectMake(5, 25, dvc_width - 30, 70)];
		[titleTextView setTextAlignment:NSTextAlignmentLeft];
		[titleTextView setTextColor:[UIColor grayColor]];
		[titleTextView setDelegate:self];
		[titleTextView setFont:HelveticaNeue(16)];
		[titleTextView setBackgroundColor:[UIColor clearColor]];
		[titleTextView setTag:888];
		[titleTextView setAutocapitalizationType:UITextAutocapitalizationTypeSentences];
		[titleTextView setAutocorrectionType:UITextAutocorrectionTypeNo];
//		[titleTextView setReturnKeyType:UIReturnKeyDone];
        [titleTextView setText:@"Signature"];
		[signatureTitleView addSubview:titleTextView];
		
		switch (_signatureType) {
			case kSignatureTypeLeft: {
          NSString *sigtatureTitle = @"Signature";
          if (theInvoice) {
              sigtatureTitle = [[theInvoice leftSignatureTitle] stringByReplacingOccurrencesOfString:@"(Left)" withString:@""];
          } else if (theQuote) {
    sigtatureTitle = [[theQuote leftSignatureTitle] stringByReplacingOccurrencesOfString:@"(Left)" withString:@""];
          } else if (theEstimate) {
    sigtatureTitle = [[theEstimate leftSignatureTitle] stringByReplacingOccurrencesOfString:@"(Left)" withString:@""];
          } else if (thePurchaseOrder) {
    sigtatureTitle = [[thePurchaseOrder leftSignatureTitle] stringByReplacingOccurrencesOfString:@"(Left)" withString:@""];
          } else if(theTimesheet) {
    sigtatureTitle = [[theTimesheet leftSignatureTitle] stringByReplacingOccurrencesOfString:@"(Left)" withString:@""];
          }
          [titleTextView setText:sigtatureTitle];
				
				break;
			}
				
			case kSignatureTypeRight: {
          NSString *sigtatureTitle = @"Signature";
          if (theInvoice) {
              sigtatureTitle = [[theInvoice rightSignatureTitle] stringByReplacingOccurrencesOfString:@"(Right)" withString:@""];
          } else if (theQuote) {
    sigtatureTitle = [[theQuote rightSignatureTitle] stringByReplacingOccurrencesOfString:@"(Right)" withString:@""];
          } else if (theEstimate) {
    sigtatureTitle = [[theEstimate rightSignatureTitle] stringByReplacingOccurrencesOfString:@"(Right)" withString:@""];
          } else if (thePurchaseOrder) {
    sigtatureTitle = [[thePurchaseOrder rightSignatureTitle] stringByReplacingOccurrencesOfString:@"(Right)" withString:@""];
          } else if (theTimesheet) {
    sigtatureTitle = [[theTimesheet rightSignatureTitle] stringByReplacingOccurrencesOfString:@"(Right)" withString:@""];
          }
          [titleTextView setText:sigtatureTitle];
				
				break;
			}
		}
	}
	
	//SIGNATURE IMAGE
	{
		UILabel * titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(signatureTitleView.frame) + 10, dvc_width - 20, 20)];
		[titleLabel setText:@"Signature"];
		[titleLabel setTextAlignment:NSTextAlignmentLeft];
		[titleLabel setTextColor:app_title_color];
		[titleLabel setFont:HelveticaNeueMedium(14)];
		[titleLabel setBackgroundColor:[UIColor clearColor]];
		[theSelfView addSubview:titleLabel];
		
		UIImageView * bg = [[UIImageView alloc] init];
		[bg setImage:[[UIImage imageNamed:@"tableSingleCellWhite.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10]];
		[bg setFrame:CGRectMake(10, CGRectGetMaxY(titleLabel.frame), dvc_width - 20, dvc_width - 150)];
		[theSelfView addSubview:bg];
		
		UIImage * sign;
		CGRect sFrame;
		
		switch (_signatureType)
		{
			case kSignatureTypeLeft:
			{
				if (theInvoice)
				{
					sign = [theInvoice leftSignature];
					sFrame = [theInvoice leftSignatureFrame];
				}
				else if (theQuote)
				{
					sign = [theQuote leftSignature];
					sFrame = [theQuote leftSignatureFrame];
				}
				else if (theEstimate)
				{
					sign = [theEstimate leftSignature];
					sFrame = [theEstimate leftSignatureFrame];
				}
				else if (thePurchaseOrder)
				{
					sign = [thePurchaseOrder leftSignature];
					sFrame = [thePurchaseOrder leftSignatureFrame];
				}
				else if (theTimesheet)
				{
					sign = [theTimesheet leftSignature];
					sFrame = [theTimesheet leftSignatureFrame];
				}
				
				break;
			}
				
			case kSignatureTypeRight:
			{
				if (theInvoice)
				{
					sign = [theInvoice rightSignature];
					sFrame = [theInvoice rightSignatureFrame];
				}
				else if (theQuote)
				{
					sign = [theQuote rightSignature];
					sFrame = [theQuote rightSignatureFrame];
				}
				else if (theEstimate)
				{
					sign = [theEstimate rightSignature];
					sFrame = [theEstimate rightSignatureFrame];
				}
				else if (thePurchaseOrder)
				{
					sign = [thePurchaseOrder rightSignature];
					sFrame = [thePurchaseOrder rightSignatureFrame];
				}
				else if (theTimesheet)
				{
					sign = [theTimesheet rightSignature];
					sFrame = [theTimesheet rightSignatureFrame];
				}
				
				break;
			}
		}
			
		signatureView = [[SignatureView alloc] initWithFrame:bg.frame signature:sign andSignatureFrame:sFrame];
		[signatureView setCenter:bg.center];
		[signatureView setBackgroundColor:[UIColor clearColor]];
		[theSelfView addSubview:signatureView];
		
		UIButton * clearSignature = [[UIButton alloc] initWithFrame:CGRectMake(theSelfView.frame.size.width - 80, signatureView.frame.size.height + signatureView.frame.origin.y + 10, 60, 40)];
		[clearSignature setBackgroundImage:[[UIImage imageNamed:@"tableSingleCellWhite.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10] forState:UIControlStateNormal];
		[clearSignature setTitle:@"Clear" forState:UIControlStateNormal];
		[clearSignature setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
		[clearSignature.titleLabel setFont:HelveticaNeue(15)];
		[clearSignature addTarget:self action:@selector(clearSignature:) forControlEvents:UIControlEventTouchUpInside];
		[theSelfView addSubview:clearSignature];
	}
	
	//SIGNATURE DATE
	{
		UILabel * titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, signatureView.frame.size.height + signatureView.frame.origin.y + 40, dvc_width - 20, 20)];
		[titleLabel setText:@"Date"];
		[titleLabel setTextAlignment:NSTextAlignmentLeft];
		[titleLabel setTextColor:app_title_color];
		[titleLabel setFont:HelveticaNeueMedium(14)];
		[titleLabel setBackgroundColor:[UIColor clearColor]];
		[theSelfView addSubview:titleLabel];
		
		[date_formatter setDateFormat:[DELEGATE userSelectedDateFormat]];
		
		dateSelectorButton = [[UIButton alloc] initWithFrame:CGRectMake(10, titleLabel.frame.origin.y + titleLabel.frame.size.height, signatureView.frame.size.width, 40)];
		[dateSelectorButton setBackgroundImage:[[UIImage imageNamed:@"tableSingleCellWhite.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10] forState:UIControlStateNormal];
		[dateSelectorButton setTitle:[date_formatter stringFromDate:theDate] forState:UIControlStateNormal];
		[dateSelectorButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
		[dateSelectorButton.titleLabel setFont:HelveticaNeue(16)];
		[dateSelectorButton addTarget:self action:@selector(openDatePicker:) forControlEvents:UIControlEventTouchUpInside];
		[theSelfView addSubview:dateSelectorButton];
		
		theToolbar = [[ToolBarView alloc] initWithFrame:CGRectMake(0, dvc_height + statusBarHeight, dvc_width, 40)];
		[theToolbar.prevButton setAlpha:0.0];
		[theToolbar.nextButton setAlpha:0.0];
		[theToolbar.doneButton addTarget:self action:@selector(closePicker:) forControlEvents:UIControlEventTouchUpInside];
		[self.view addSubview:theToolbar];
	}
  
  if([self addAlwaysShowSwitchAfterY:CGRectGetMaxY(dateSelectorButton.frame)] &&
     CGRectGetMaxY(dateSelectorButton.frame) + 20 + ALWAYS_SHOW_HEIGHT > theSelfView.frame.size.height) {
    CGRect viewFrame = theSelfView.frame;
    viewFrame.size.height = CGRectGetMaxY(dateSelectorButton.frame) + 20 + ALWAYS_SHOW_HEIGHT;
    theSelfView.frame = viewFrame;
    
    [mainScrollView setContentSize:theSelfView.frame.size];
  } else {
    mainScrollView.scrollEnabled = NO;
  }
  
	//	ColorPicker * picker = [[ColorPicker alloc] initWithFrame:CGRectMake(10, bg.frame.size.height + 70, 40, 40) andColor:[UIColor blueColor]];
	//	[picker setBackgroundColor:picker.bgColor];
	//	[picker setParent:signatureView];
	//	[theSelfView addSubview:picker];
	
	[self.view addSubview:topBarView];
}

#pragma mark - FUNCTIONS

-(void)cancel:(UIButton*)sender {
    [titleTextView resignFirstResponder];
	[self.navigationController popViewControllerAnimated:YES];
}

-(void)done:(UIButton*)sender {
	if (_delegate && [_delegate respondsToSelector:@selector(creatorViewController:createdSignature:withFrame:title:andDate:)]) {
		CGRect frame = CGRectMake(signatureView.topLeftPoint.x, signatureView.topLeftPoint.y, signatureView.bottomRightPoint.x - signatureView.topLeftPoint.x, signatureView.bottomRightPoint.y - signatureView.topLeftPoint.y);
		
		[_delegate creatorViewController:self createdSignature:[signatureView theSignature] withFrame:frame title:[titleTextView text] andDate:theDate];
	}
	
  [titleTextView resignFirstResponder];
	[self.navigationController popViewControllerAnimated:YES];
}

-(void)clearSignature:(UIButton*)sender {
	[signatureView clear];
}

-(void)openDatePicker:(UIButton*)sender {
	UIButton * closeAll = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
	[closeAll setBackgroundColor:[UIColor clearColor]];
	[closeAll addTarget:self action:@selector(cancelPicker:) forControlEvents:UIControlEventTouchUpInside];
	[closeAll setTag:123123];
	[theSelfView addSubview:closeAll];
	[theSelfView bringSubviewToFront:theToolbar];
	
	[[self.navigationController.view viewWithTag:101010] removeFromSuperview];
	[[self.view viewWithTag:999] removeFromSuperview];
	
	UIView * viewWithPicker = [[UIView alloc] initWithFrame:CGRectMake(0, dvc_height + 60, dvc_width, keyboard_height)];
	[viewWithPicker setBackgroundColor:[UIColor clearColor]];
	[viewWithPicker setTag:101010];
	[viewWithPicker.layer setMasksToBounds:YES];
	[self.navigationController.view addSubview:viewWithPicker];
	
	datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 0, dvc_width, keyboard_height)];
	[datePicker setBackgroundColor:[UIColor whiteColor]];
	[datePicker setCenter:CGPointMake(dvc_width / 2, keyboard_height / 2)];
	[datePicker setDatePickerMode:UIDatePickerModeDate];
	[datePicker setTag:989898];
	[date_formatter setDateFormat:[DELEGATE userSelectedDateFormat]];
	[datePicker setDate:theDate];
	[viewWithPicker addSubview:datePicker];
	
	if (iPad) {
		[datePicker setTransform:CGAffineTransformMakeScale(1.0, (float)(keyboard_height) / 216.0f)];
	}
	
	[UIView animateWithDuration:0.25 animations:^{
		[viewWithPicker setFrame:CGRectMake(0, dvc_height - keyboard_height + 20, dvc_width, keyboard_height)];
		[theToolbar setFrame:CGRectMake(0, dvc_height - keyboard_height - 40 + statusBarHeight, dvc_width, 40)];
	} completion:^(BOOL finished) {
	}];
}

-(void)cancelPicker:(UIButton*)sender {
	[[self.view viewWithTag:123123] removeFromSuperview];
	
	[UIView animateWithDuration:0.25 animations:^{
		[[self.navigationController.view viewWithTag:101010] setFrame:CGRectMake(0, dvc_height + 60, dvc_width, keyboard_height)];
		[theToolbar setFrame:CGRectMake(0, dvc_height + statusBarHeight, dvc_width, 40)];
	} completion:^(BOOL finished) {
		[[self.navigationController.view viewWithTag:101010] removeFromSuperview];
	}];
}

-(void)closePicker:(UIButton*)sender {
    [titleTextView resignFirstResponder];
    
	if (!datePicker)
		return;
	
	theDate = datePicker.date;
	[dateSelectorButton setTitle:[date_formatter stringFromDate:theDate] forState:UIControlStateNormal];
	
	[[self.view viewWithTag:123123] removeFromSuperview];
	
	[UIView animateWithDuration:0.25 animations:^{
		[[self.navigationController.view viewWithTag:101010] setFrame:CGRectMake(0, dvc_height + 60, dvc_width, keyboard_height)];
		[theToolbar setFrame:CGRectMake(0, dvc_height + statusBarHeight, dvc_width, 40)];
	} completion:^(BOOL finished) {
		[[self.navigationController.view viewWithTag:101010] removeFromSuperview];
	}];
}

#pragma mark - TEXTFIELD DELEGATE

-(BOOL)textFieldShouldReturn:(UITextField*)textField {
	[textField resignFirstResponder];
	return YES;
}

#pragma mark - UITextViewDelegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    [UIView animateWithDuration:0.25 animations:^{
        [theToolbar setFrame:CGRectMake(0, dvc_height - keyboard_height - 40 + statusBarHeight, dvc_width, 40)];
    } completion:^(BOOL finished) {
    }];
    
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
    [UIView animateWithDuration:0.25 animations:^{
        [theToolbar setFrame:CGRectMake(0, dvc_height + statusBarHeight, dvc_width, 40)];
    } completion:^(BOOL finished) {
        [[self.navigationController.view viewWithTag:101010] removeFromSuperview];
    }];
    
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    NSString * result = [textView.text stringByReplacingCharactersInRange:range withString:text];
    CGFloat textHeight = [result sizeWithFont:HelveticaNeue(16) constrainedToSize:CGSizeMake(textView.frame.size.width - 10, 9999) lineBreakMode:NSLineBreakByWordWrapping].height;
    
    BOOL shouldReturn = textHeight < 60.f;
    if(!shouldReturn) {
        [textView resignFirstResponder];
    }
    
    return shouldReturn;
}

#pragma mark - VIEW CONTROLLER FUNCTIONS

-(void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

@end