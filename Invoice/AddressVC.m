//
//  AddressVC.m
//  Invoice
//
//  Created by XGRoup5 on 8/15/13.
//  Copyright (c) 2013 XGRoup. All rights reserved.
//

#import "AddressVC.h"

#import "Defines.h"

@interface AddressVC () <UIScrollViewDelegate, UITextFieldDelegate>

@end

@implementation AddressVC

-(id)init
{
	self = [super init];
	
	if (self)
	{
		if ([CustomDefaults customObjectForKey:kAddressKeyForNSUserDefaults] && [[CustomDefaults customObjectForKey:kAddressKeyForNSUserDefaults] isKindOfClass:[NSDictionary class]])
		{
			address = [[AddressOBJ alloc] initWithContentsDictionary:[CustomDefaults customObjectForKey:kAddressKeyForNSUserDefaults]];
		}
		else
		{
			address = [[AddressOBJ alloc] init];
			
			[CustomDefaults setCustomObjects:[address contentsDictionary] forKey:kAddressKeyForNSUserDefaults];
		}
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
	
	mainScrollView = [[ScrollWithShadow alloc] initWithFrame:CGRectMake(0, 42, dvc_width, dvc_height - 87)];
	[mainScrollView setDelegate:self];
	[mainScrollView setBackgroundColor:[UIColor clearColor]];
	[mainScrollView setContentSize:CGSizeMake(dvc_width, 42 * 7 + 20)];
	[theSelfView addSubview:mainScrollView];
	
	topBarView = [[TopBar alloc] initWithFrame:CGRectMake(0, 0, dvc_width, 42 + statusBarHeight) andTitle:@"Address"];
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
	
	for (int i = 0; i < 7; i++)
	{
		NSString * value = @"";
		kTextFieldType type = i;
		
		switch (type)
		{
			case kTextFieldTypeAddressLine1:
			{
				value = [address addressLine1];
				break;
			}
				
			case kTextFieldTypeAddressLine2:
			{
				value = [address addressLine2];
				break;
			}
				
			case kTextFieldTypeAddressLine3:
			{
				value = [address addressLine3];
				break;
			}
				
			case kTextFieldTypeCity:
			{
				value = [address city];
				break;
			}
				
			case kTextFieldTypeState:
			{
				value = [address state];
				break;
			}
				
			case kTextFieldTypeZIP:
			{
				value = [address ZIP];
				break;
			}
				
			case kTextFieldTypeCountry:
			{
				value = [address country];
				break;
			}
				
			default:
				break;
		}
		
		UIView * textField = [self textFieldViewWithType:i frame:CGRectMake(10, 10 + 42 * i, dvc_width - 20, 42) andVaue:value];
		[mainScrollView addSubview:textField];
	}
	
	theToolbar = [[ToolBarView alloc] initWithFrame:CGRectMake(0, dvc_height, dvc_width, 40)];
	[theToolbar.prevButton addTarget:self action:@selector(prevTextField:) forControlEvents:UIControlEventTouchUpInside];
	[theToolbar.nextButton addTarget:self action:@selector(nextTextField:) forControlEvents:UIControlEventTouchUpInside];
	[theToolbar.doneButton addTarget:self action:@selector(closeTextField:) forControlEvents:UIControlEventTouchUpInside];
	[theSelfView addSubview:theToolbar];
	
	[self.view addSubview:topBarView];
}

#pragma mark - FUNCTIONS

-(void)back:(UIButton*)sender {
  [currentTextField resignFirstResponder];
  
	[self.navigationController popViewControllerAnimated:YES];
}

-(void)done:(UIButton*)sender {
  [currentTextField resignFirstResponder];
  
	[CustomDefaults setCustomObjects:[address contentsDictionary] forKey:kAddressKeyForNSUserDefaults];
	
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
	[textField setTextColor:[UIColor darkGrayColor]];
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
		[mainScrollView setFrame:CGRectMake(mainScrollView.frame.origin.x, mainScrollView.frame.origin.y, dvc_width, dvc_height - 87)];
		if (mainScrollView && [mainScrollView respondsToSelector:@selector(didScroll)])
			[mainScrollView didScroll];
		
	}];
}

-(BOOL)textFieldShouldReturn:(UITextField*)textField
{
	[textField resignFirstResponder];
	
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

-(BOOL)textFieldShouldEndEditing:(UITextField*)textField
{
  currentTextField = nil;
  
	kTextFieldType type = textField.tag - 1;
	
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

-(BOOL)textFieldShouldBeginEditing:(UITextField*)textField {
  currentTextField = textField;
  
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
