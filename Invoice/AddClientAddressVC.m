//
//  AddClientAddressVC.m
//  Invoice
//
//  Created by XGRoup5 on 8/21/13.
//  Copyright (c) 2013 XGRoup. All rights reserved.
//

#import "AddClientAddressVC.h"

#import "Defines.h"

@interface AddClientAddressVC () <UIScrollViewDelegate, UITextFieldDelegate>

@end

@implementation AddClientAddressVC

-(id)initWithAddresType:(kAddresType)type client:(ClientOBJ*)client
{
	self = [super init];
	
	if (self)
	{
		theType = type;
		theClient = client;
    
    _billingKey = client.billingKey?:kBillingAddressTitleKeyForNSUserDefaults;
    _shippingKey = client.shippingKey?:kShippingAddressTitleKeyForNSUserDefaults;
		
		switch (theType) {
			case kAddresTypeBilling: {
				address = [theClient billingAddress];
        [address setBillingTitle:[self billingTitle]];
				
				break;
			}
				
			case kAddresTypeShipping: {
				address = [theClient shippingAddress];
        [address setShippingTitle:[self shippingTitle]];
        
				break;
			}
				
			default:
				break;
		}
		
		same_as_billing_address = [[theClient shippingAddress] sameAsBilling];
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
	
	mainScrollView = [[ScrollWithShadow alloc] initWithFrame:CGRectMake(0, 42, dvc_width, dvc_height - 42)];
	[mainScrollView setDelegate:self];
	[mainScrollView setBackgroundColor:[UIColor clearColor]];
	[mainScrollView setContentSize:CGSizeMake(dvc_width, 42 * 7 + 20 + 52)];
	[theSelfView addSubview:mainScrollView];
	
	topBarView = [[TopBar alloc] initWithFrame:CGRectMake(0, 0, dvc_width, 42 + statusBarHeight) andTitle:@"Address"];
	[topBarView setBackgroundColor:app_bar_update_color];
	[self.view addSubview:topBarView];
	
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
		UIView * bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, dvc_width, 42)];
		[bgView setBackgroundColor:[UIColor clearColor]];
		[mainScrollView addSubview:bgView];
		
		UIImageView * bg = [[UIImageView alloc] initWithFrame:CGRectMake(10, 0, dvc_width - 20, 42)];
		[bg setImage:[[UIImage imageNamed:@"tableSingleCell"] stretchableImageWithLeftCapWidth:20 topCapHeight:15]];
		[bgView addSubview:bg];
		
		UILabel * titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, (dvc_width - 40) * 0.3, 42)];
		[titleLabel setText:@"Title"];
		[titleLabel setTextAlignment:NSTextAlignmentLeft];
		[titleLabel setTextColor:[UIColor grayColor]];
		[titleLabel setFont:HelveticaNeue(16)];
		[titleLabel setBackgroundColor:[UIColor clearColor]];
		[titleLabel setTag:10];
		[bgView addSubview:titleLabel];
		
		UITextField * valueTextField = [[UITextField alloc] initWithFrame:CGRectMake(25 + (dvc_width - 40) * 0.3, 0, (dvc_width - 40) * 0.66, 42)];
		[valueTextField setTextAlignment:NSTextAlignmentRight];
		[valueTextField setTextColor:[UIColor darkGrayColor]];
		[valueTextField setFont:HelveticaNeue(15)];
		[valueTextField setBackgroundColor:[UIColor clearColor]];
		[valueTextField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
		[valueTextField setReturnKeyType:UIReturnKeyDone];
		[valueTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
		[valueTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
		[valueTextField setTag:111];
		[valueTextField setDelegate:self];
		[bgView addSubview:valueTextField];
		
		if (theType == kAddresTypeBilling) {
      [valueTextField setText:[self billingTitle]];
		} else {
      [valueTextField setText:[self shippingTitle]];
		}
	}
	
	int x = 0;
	
	if (theType == kAddresTypeShipping)
	{
		x = -1;
		[mainScrollView setContentSize:CGSizeMake(dvc_width, 42 * 8 + 20 + 52)];
	}
	
	for (int i = x; i < 7; i++)
	{
		CGFloat y = 10 + 42 * i + 42;
		NSString * value = @"";
		
		if (x == -1 && i != -1)
		{
			y = 62 + 42 * i + 42;
		}
		else if (i == -1)
		{
			y = 10 + 42;
		}
		
		switch (i)
		{
			case 0:
			{
				value = [address addressLine1];
				break;
			}
				
			case 1:
			{
				value = [address addressLine2];
				break;
			}
				
			case 2:
			{
				value = [address addressLine3];
				break;
			}
				
			case 3:
			{
				value = [address city];
				break;
			}
				
			case 4:
			{
				value = [address state];
				break;
			}
				
			case 5:
			{
				value = [address ZIP];
				break;
			}
				
			case 6:
			{
				value = [address country];
				break;
			}
				
			default:
				break;
		}
		
		UIView * textField = [self textFieldViewWithType:i frame:CGRectMake(10, y, dvc_width - 20, 42) andVaue:value];
		[textField setTag:i + 1000];
		[mainScrollView addSubview:textField];
		
		if (theType == kAddresTypeShipping && same_as_billing_address && i > -1)
		{
			[textField setAlpha:0.0];
		}
	}
	
	theToolbar = [[ToolBarView alloc] initWithFrame:CGRectMake(0, dvc_height, dvc_width, 40)];
	[theToolbar.prevButton addTarget:self action:@selector(prevTextField:) forControlEvents:UIControlEventTouchUpInside];
	[theToolbar.nextButton addTarget:self action:@selector(nextTextField:) forControlEvents:UIControlEventTouchUpInside];
	[theToolbar.doneButton addTarget:self action:@selector(closeTextField:) forControlEvents:UIControlEventTouchUpInside];
	[theSelfView addSubview:theToolbar];
}

#pragma mark - FUNCTIONS

-(void)back:(UIButton*)sender {
	[self.navigationController popViewControllerAnimated:YES];
}

-(void)done:(UIButton*)sender {
	if (theType == kAddresTypeShipping) {
		if (same_as_billing_address) {
			AddressOBJ * temp = [[AddressOBJ alloc] initWithAddress:[theClient billingAddress]];
      [temp setShippingTitle:[CustomDefaults customObjectForKey:_shippingKey]];
      [temp setSameAsBilling:YES];
			
			[theClient setShippingAddress:[temp contentsDictionary]];
		}
		else
		{
      [address setSameAsBilling:NO];
			[theClient setShippingAddress:[address contentsDictionary]];
		}
	} else {
		[theClient setBillingAddress:[address contentsDictionary]];
	}
  
  if([_delegate respondsToSelector:@selector(didEditedClientAddress:)]) {
    [_delegate didEditedClientAddress:theClient];
  }
	
	[self.navigationController popViewControllerAnimated:YES];
}

-(UIView*)textFieldViewWithType:(kTextFieldType)type frame:(CGRect)frame andVaue:(NSString*)value
{
	UIView * theView = [[UIView alloc] initWithFrame:frame];
	[theView setBackgroundColor:[UIColor clearColor]];
	
	UIImageView * bg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
	[bg setImage:[[UIImage imageNamed:@"tableMiddleCellWhite.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10]];
	[theView addSubview:bg];
	
	UITextField * textField = [[UITextField alloc] initWithFrame:CGRectMake(10, 5, frame.size.width - 20, frame.size.height - 10)];
	[textField setTextAlignment:NSTextAlignmentLeft];
	[textField setTextColor:[UIColor grayColor]];
	[textField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
	[textField setFont:HelveticaNeue(15)];
	[textField setBackgroundColor:[UIColor clearColor]];
	[textField setAutocapitalizationType:UITextAutocapitalizationTypeWords];
	[textField setAutocorrectionType:UITextAutocorrectionTypeNo];
	[textField setReturnKeyType:UIReturnKeyNext];
	[textField setDelegate:self];
	[textField setTag:type + 1];
	[theView addSubview:textField];
	
	if (value)
	{
		[textField setText:value];
	}
	
	switch (type)
	{
		case kTextFieldTypeSwitch:
		{
			[bg setImage:[[UIImage imageNamed:@"tableSingleCellWhite.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10]];
			[textField setText:@"Same as billing"];
			[textField setUserInteractionEnabled:NO];
			
			UISwitch * isTheSame = [[UISwitch alloc] initWithFrame:CGRectZero];
			[isTheSame setOn:same_as_billing_address];
			[isTheSame setFrame:CGRectMake(dvc_width - 25 - isTheSame.frame.size.width, (42 - isTheSame.frame.size.height) / 2, isTheSame.frame.size.width, isTheSame.frame.size.height)];
			[isTheSame addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
			[theView addSubview:isTheSame];
			
			break;
		}
			
		case kTextFieldTypeAddressLine1:
		{
			[bg setImage:[[UIImage imageNamed:@"tableTopCellWhite.png"] stretchableImageWithLeftCapWidth:20 topCapHeight:15]];
			[textField setPlaceholder:@"Address Line 1"];
			
			break;
		}
			
		case kTextFieldTypeAddressLine2:
		{
			[textField setPlaceholder:@"Address Line 2"];
			
			break;
		}
			
		case kTextFieldTypeAddressLine3:
		{
			[textField setPlaceholder:@"Address Line 3"];
			
			break;
		}
			
		case kTextFieldTypeCity:
		{
			[textField setPlaceholder:@"City"];
			
			break;
		}
			
		case kTextFieldTypeState:
		{
			[textField setPlaceholder:@"State"];
			
			break;
		}
			
		case kTextFieldTypeZIP:
		{
			[textField setPlaceholder:@"ZIP"];
			[textField setKeyboardType:UIKeyboardTypeDefault];
			
			break;
		}
			
		case kTextFieldTypeCountry:
		{
			[bg setImage:[[UIImage imageNamed:@"tableBottomCellWhite.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10]];
			[textField setPlaceholder:@"Country"];
			[textField setReturnKeyType:UIReturnKeyDone];
			
			break;
		}
			
		default:
			break;
	}
	
	return theView;
}

-(void)switchChanged:(UISwitch*)sender {
	same_as_billing_address = sender.on;
	
	CGFloat alpha = 1.0;
	
	if (same_as_billing_address)
	{
		alpha = 0.0;
	}
	else
	{
		[address setAddressLine1:@""];
		[address setAddressLine2:@""];
		[address setAddressLine3:@""];
		[address setCity:@""];
		[address setState:@""];
		[address setZIP:@""];
		[address setCountry:@""];
		
		for (int i = 1; i < 8; i++)
		{
			[(UITextField*)[self.view viewWithTag:i] setText:@""];
		}
	}
	
	[UIView animateWithDuration:0.25 animations:^{
		
		for (int i = 1000; i < 1007; i++)
		{
			[[self.view viewWithTag:i] setAlpha:alpha];
		}
		
	}];
}

- (NSString *)billingTitle {
  if([[address billingTitle] length] > 0) {
    return [address billingTitle];
  } else {
    NSString *title = [CustomDefaults customObjectForKey:_billingKey];
    if([title length] == 0) {
      title = [CustomDefaults customObjectForKey:kBillingAddressTitleKeyForNSUserDefaults];
    }
    return title;
  }
}

- (NSString *)shippingTitle {
  if([[address shippingTitle] length] > 0) {
    return [address shippingTitle];
  } else {
    NSString *title = [CustomDefaults customObjectForKey:_shippingKey];
    if([title length] == 0) {
      title = [CustomDefaults customObjectForKey:kShippingAddressTitleKeyForNSUserDefaults];
    }
    return title;
  }
}

#pragma mark - SCROLL VIEW DELEGATE

-(void)scrollViewDidScroll:(UIScrollView*)scrollView
{
	if (mainScrollView && [mainScrollView respondsToSelector:@selector(didScroll)])
		[mainScrollView didScroll];
}

#pragma mark - TEXT FIELD DELEGATE

-(void)nextTextField:(UIButton*)sender
{
	[(UITextField*)[self.view viewWithTag:sender.tag + 1] becomeFirstResponder];
}

-(void)prevTextField:(UIButton*)sender
{
	[(UITextField*)[self.view viewWithTag:sender.tag - 1] becomeFirstResponder];
}

-(void)closeTextField:(UIButton*)sender
{
	[(UITextField*)[self.view viewWithTag:sender.tag] resignFirstResponder];
	
	[UIView animateWithDuration:0.25 animations:^{
		
		[theToolbar setFrame:CGRectMake(0, dvc_height, dvc_width, 40)];
		[mainScrollView setFrame:CGRectMake(mainScrollView.frame.origin.x, mainScrollView.frame.origin.y, dvc_width, dvc_height - 42)];
		if (mainScrollView && [mainScrollView respondsToSelector:@selector(didScroll)])
			[mainScrollView didScroll];
		
	}];
}

-(BOOL)textFieldShouldReturn:(UITextField*)textField
{
	[textField resignFirstResponder];
	
	if (textField.tag == 111)
	{
		return YES;
	}
	
	[(UITextField*)[self.view viewWithTag:textField.tag + 1] becomeFirstResponder];
	
	if (![self.view viewWithTag:textField.tag + 1])
	{
		[UIView animateWithDuration:0.25 animations:^{
			
			[theToolbar setFrame:CGRectMake(0, dvc_height, dvc_width, 40)];
			[mainScrollView setFrame:CGRectMake(mainScrollView.frame.origin.x, mainScrollView.frame.origin.y, dvc_width, dvc_height - 87)];
			if (mainScrollView && [mainScrollView respondsToSelector:@selector(didScroll)])
				[mainScrollView didScroll];
			
		}];
	}
	
	return YES;
}

-(BOOL)textFieldShouldEndEditing:(UITextField*)textField {
	if (textField.tag == 111) {
		if (theType == kAddresTypeBilling) {
      [address setBillingTitle:textField.text];
      [CustomDefaults setCustomObjects:textField.text forKey:_billingKey];
		} else {
      [address setShippingTitle:textField.text];
      [CustomDefaults setCustomObjects:textField.text forKey:_shippingKey];
		}
		
		return YES;
	}
	
	kTextFieldType type = (int)textField.tag - 1;
	
	switch (type)
	{
		case kTextFieldTypeAddressLine1:
		{
			[address setAddressLine1:textField.text];
			break;
		}
			
		case kTextFieldTypeAddressLine2:
		{
			[address setAddressLine2:textField.text];
			break;
		}
			
		case kTextFieldTypeAddressLine3:
		{
			[address setAddressLine3:textField.text];
			break;
		}
			
		case kTextFieldTypeCity:
		{
			[address setCity:textField.text];
			break;
		}
			
		case kTextFieldTypeState:
		{
			[address setState:textField.text];
			break;
		}
			
		case kTextFieldTypeZIP:
		{
			[address setZIP:textField.text];
			break;
		}
			
		case kTextFieldTypeCountry:
		{
			[address setCountry:textField.text];
			break;
		}
			
		default:
			break;
	}
	
	return YES;
}

-(BOOL)textFieldShouldBeginEditing:(UITextField*)textField
{
	if (textField.tag == 111)
	{
		return YES;
	}
	
	[theToolbar.prevButton setTag:textField.tag];
	[theToolbar.prevButton setUserInteractionEnabled:YES];
	[theToolbar.prevButton setAlpha:1.0];
	
	[theToolbar.nextButton setTag:textField.tag];
	[theToolbar.nextButton setUserInteractionEnabled:YES];
	[theToolbar.nextButton setAlpha:1.0];
	
	[theToolbar.doneButton setTag:textField.tag];
	
	if (![self.view viewWithTag:textField.tag + 1])
	{
		[theToolbar.nextButton setAlpha:0.5];
		[theToolbar.nextButton setUserInteractionEnabled:NO];
	}
	
	if (![[self.view viewWithTag:textField.tag - 1] isKindOfClass:[UITextField class]])
	{
		[theToolbar.prevButton setAlpha:0.5];
		[theToolbar.prevButton setUserInteractionEnabled:NO];
	}
	
	[UIView animateWithDuration:0.25 animations:^{
		
		[theToolbar setFrame:CGRectMake(0, dvc_height - keyboard_height - 40, dvc_width, 40)];
		[mainScrollView setFrame:CGRectMake(mainScrollView.frame.origin.x, mainScrollView.frame.origin.y, dvc_width, dvc_height - 82 - keyboard_height)];
		if (mainScrollView && [mainScrollView respondsToSelector:@selector(didScroll)])
			[mainScrollView didScroll];
		
	}];
	
	return YES;
}

-(BOOL)textField:(UITextField*)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString*)string
{
	if (textField.tag != 111)
		return YES;
	
	NSString * result = [textField.text stringByReplacingCharactersInRange:range withString:string];
	
	if (result.length > 25)
	{
		return NO;
	}
	
	return YES;
}

#pragma mark - VIEW CONTROLLER FUNCTIONS

-(void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
}

-(void)dealloc
{
	[mainScrollView setDelegate:nil];
}

@end