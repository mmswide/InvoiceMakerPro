//
//  PasscodeLockVC.m
//  Invoice
//
//  Created by XGRoup5 on 8/16/13.
//  Copyright (c) 2013 XGRoup. All rights reserved.
//

#import "PasscodeLockVC.h"

#import "Defines.h"

@interface PasscodeLockVC () <PinViewDelegate, AlertViewDelegate>

@end

@implementation PasscodeLockVC

-(id)init
{
	self = [super init];
	
	if (self)
	{
		
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
	
	tempPin = @"";
	
	settingsDictionary = [[NSMutableDictionary alloc] initWithDictionary:[CustomDefaults customObjectForKey:kSettingsKeyForNSUserDefaults]];
	
	topBarView = [[TopBar alloc] initWithFrame:CGRectMake(0, 0, dvc_width, 42 + statusBarHeight) andTitle:@"PIN Management"];
	[topBarView setBackgroundColor:app_bar_update_color];
	
	BackButton * backButton = [[BackButton alloc] initWithFrame:CGRectMake(0, 42 + statusBarHeight - 40, 70, 40) andTitle:@"Back"];
	[backButton addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
	[topBarView addSubview:backButton];
	
	if ([CustomDefaults customObjectForKey:kPinKeyForNSUserDefaults])
	{
		UIButton * turnPinOff = [[UIButton alloc] initWithFrame:CGRectMake(40, 72, dvc_width - 80, 42)];
		[turnPinOff setBackgroundImage:[[UIImage imageNamed:@"tableSingleCellWhite.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10] forState:UIControlStateNormal];
		[turnPinOff setBackgroundImage:[[UIImage imageNamed:@"selectedSingleCell.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10] forState:UIControlStateHighlighted];
		[turnPinOff setTitle:@"Turn Passcode Lock Off" forState:UIControlStateNormal];
		[turnPinOff setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
		[turnPinOff setTitleColor:app_pressed_selected_color forState:UIControlStateHighlighted];
		[turnPinOff.titleLabel setFont:HelveticaNeue(16)];
		[turnPinOff addTarget:self action:@selector(turnPinOff:) forControlEvents:UIControlEventTouchUpInside];
		[theSelfView addSubview:turnPinOff];
		
		UIButton * changePinCode = [[UIButton alloc] initWithFrame:CGRectMake(40, 124, dvc_width - 80, 42)];
		[changePinCode setBackgroundImage:[[UIImage imageNamed:@"tableSingleCellWhite.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10] forState:UIControlStateNormal];
		[changePinCode setBackgroundImage:[[UIImage imageNamed:@"selectedSingleCell.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10] forState:UIControlStateHighlighted];
		[changePinCode setTitle:@"Change PIN" forState:UIControlStateNormal];
		[changePinCode setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
		[changePinCode setTitleColor:app_pressed_selected_color forState:UIControlStateHighlighted];
		[changePinCode.titleLabel setFont:HelveticaNeue(16)];
		[changePinCode addTarget:self action:@selector(changePinCode:) forControlEvents:UIControlEventTouchUpInside];
		[theSelfView addSubview:changePinCode];
		
		[self.view addSubview:topBarView];
	}
	else
	{
		[self.view addSubview:topBarView];
		
		pin_state = kPinStateFirstEnter;
		
		currentPinView = [[PinView alloc] initWithTitle:@"Select PIN" backButtonType:kBackButtonTypeBack];
		currentPinView.backgroundColor = app_background_color;
		[currentPinView.backButton addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
		[currentPinView setDelegate:self];
		[self.view addSubview:currentPinView];
	}
}

#pragma mark - FUNCTIONS

-(void)back:(UIButton*)sender
{
	[self.navigationController popViewControllerAnimated:YES];
}

-(void)cancel:(UIButton*)sender
{
	[currentPinView resignFirstResponder];
	
	[UIView animateWithDuration:0.25 animations:^{
		
		[sender.superview setFrame:CGRectMake(0, dvc_height, sender.superview.frame.size.width, sender.superview.frame.size.height)];
		
	} completion:^(BOOL finished) {
		
		[sender.superview removeFromSuperview];
		
	}];
}

-(void)changePinCode:(UIButton*)sender
{
	pin_state = kPinStateEnterForChange;
	
	currentPinView = [[PinView alloc] initWithTitle:@"Enter PIN" backButtonType:kBackButtonTypeCancel];
	[currentPinView.backButton addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
	currentPinView.backgroundColor = app_background_color;
	[currentPinView setDelegate:self];
	[currentPinView setFrame:CGRectMake(0, dvc_width, currentPinView.frame.size.width, currentPinView.frame.size.height)];
	[self.view addSubview:currentPinView];
	
	[UIView animateWithDuration:0.25 animations:^{
		
		[currentPinView setFrame:CGRectMake(0, statusBarHeight, currentPinView.frame.size.width, currentPinView.frame.size.height)];
		
	}];
}

-(void)turnPinOff:(UIButton*)sender
{
	pin_state = kPinStateEnterForRemove;
	
	currentPinView = [[PinView alloc] initWithTitle:@"Enter PIN" backButtonType:kBackButtonTypeCancel];
	[currentPinView.backButton addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
	currentPinView.backgroundColor = app_background_color;
	[currentPinView setDelegate:self];
	[currentPinView setFrame:CGRectMake(0, dvc_width, currentPinView.frame.size.width, currentPinView.frame.size.height)];
	[self.view addSubview:currentPinView];
	
	[UIView animateWithDuration:0.25 animations:^{
		
		[currentPinView setFrame:CGRectMake(0, statusBarHeight, currentPinView.frame.size.width, currentPinView.frame.size.height)];
		
	}];
}

#pragma mark - PIN VIEW DELEGATE

-(void)pinView:(PinView*)view FinishedEnteringPin:(NSString*)pin
{
	switch (pin_state)
	{
		case kPinStateFirstEnter:
		{
			[view removeFromSuperview];
			
			tempPin = pin;
			
			pin_state = kPinStateConfirm;
			
			currentPinView = [[PinView alloc] initWithTitle:@"Re-enter PIN" backButtonType:kBackButtonTypeBack];
			currentPinView.backgroundColor = app_background_color;
			[currentPinView.backButton addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
			[currentPinView setDelegate:self];
			[self.view addSubview:currentPinView];
			
			break;
		}
			
		case kPinStateConfirm:
		{
			[view removeFromSuperview];
			
			if ([tempPin isEqual:pin])
			{
				[settingsDictionary setObject:@"1" forKey:@"passwordLock"];
				
				[CustomDefaults setCustomObjects:settingsDictionary forKey:kSettingsKeyForNSUserDefaults];
				[CustomDefaults setCustomObjects:pin forKey:kPinKeyForNSUserDefaults];
				
				[self back:nil];
			}
			else
			{
				[[[AlertView alloc] initWithTitle:@"Wrong PIN. Try again" message:@"" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
				
				pin_state = kPinStateConfirm;
				
				currentPinView = [[PinView alloc] initWithTitle:@"Re-enter PIN" backButtonType:kBackButtonTypeBack];
				currentPinView.backgroundColor = app_background_color;
				[currentPinView.backButton addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
				[currentPinView setDelegate:self];
				[self.view addSubview:currentPinView];
				
				[currentPinView resignFirstResponder];
			}
			
			break;
		}
			
		case kPinStateEnterForChange:
		{
			[view removeFromSuperview];
			
			if ([[CustomDefaults customObjectForKey:kPinKeyForNSUserDefaults] isEqual:pin])
			{
				pin_state = kPinStateSelectNewPin;
				
				currentPinView = [[PinView alloc] initWithTitle:@"Select PIN" backButtonType:kBackButtonTypeCancel];
				currentPinView.backgroundColor = app_background_color;
				[currentPinView.backButton addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
				[currentPinView setDelegate:self];
				[self.view addSubview:currentPinView];
			}
			else
			{
				[[[AlertView alloc] initWithTitle:@"Wrong PIN. Try again" message:@"" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
				
				pin_state = kPinStateEnterForChange;
				
				currentPinView = [[PinView alloc] initWithTitle:@"Enter PIN" backButtonType:kBackButtonTypeCancel];
				currentPinView.backgroundColor = app_background_color;
				[currentPinView.backButton addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
				[currentPinView setDelegate:self];
				[self.view addSubview:currentPinView];
				
				[currentPinView resignFirstResponder];
			}
			
			break;
		}
			
		case kPinStateEnterForRemove:
		{
			if ([[CustomDefaults customObjectForKey:kPinKeyForNSUserDefaults] isEqual:pin])
			{
				[settingsDictionary setObject:@"0" forKey:@"passwordLock"];
				
				[CustomDefaults removeCustomObjectForKey:kPinKeyForNSUserDefaults];
				[CustomDefaults setCustomObjects:settingsDictionary forKey:kSettingsKeyForNSUserDefaults];
				
				[view resignFirstResponder];
				
				[UIView animateWithDuration:0.25 animations:^{
					
					[view setFrame:CGRectMake(0, dvc_height, view.frame.size.width, view.frame.size.height)];
					
				} completion:^(BOOL finished) {
					
					[view removeFromSuperview];
					[self back:nil];
					
				}];				
			}
			else
			{
				[view removeFromSuperview];
				
				[[[AlertView alloc] initWithTitle:@"Wrong PIN. Try again" message:@"" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
				
				pin_state = kPinStateEnterForRemove;
				
				currentPinView = [[PinView alloc] initWithTitle:@"Enter PIN" backButtonType:kBackButtonTypeCancel];
				currentPinView.backgroundColor = app_background_color;
				[currentPinView.backButton addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
				[currentPinView setDelegate:self];
				[self.view addSubview:currentPinView];
				
				[currentPinView resignFirstResponder];
			}
			
			break;
		}
			
		case kPinStateSelectNewPin:
		{
			[view removeFromSuperview];
			
			tempPin = pin;
			
			pin_state = kPinStateConfirmNewPin;
			
			currentPinView = [[PinView alloc] initWithTitle:@"Re-enter PIN" backButtonType:kBackButtonTypeCancel];
			currentPinView.backgroundColor = app_background_color;
			[currentPinView.backButton addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
			[currentPinView setDelegate:self];
			[self.view addSubview:currentPinView];
			
			break;
		}
			
		case kPinStateConfirmNewPin:
		{
			if ([tempPin isEqual:pin])
			{
				[CustomDefaults setCustomObjects:pin forKey:kPinKeyForNSUserDefaults];
				
				[view resignFirstResponder];
				
				[UIView animateWithDuration:0.25 animations:^{
					
					[view setFrame:CGRectMake(0, dvc_height, view.frame.size.width, view.frame.size.height)];
					
				} completion:^(BOOL finished) {
					
					[view removeFromSuperview];
					
				}];
			}
			else
			{
				[view removeFromSuperview];
				
				[[[AlertView alloc] initWithTitle:@"Wrong PIN. Try again" message:@"" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
				
				pin_state = kPinStateConfirm;
				
				currentPinView = [[PinView alloc] initWithTitle:@"Re-enter PIN" backButtonType:kBackButtonTypeBack];
				currentPinView.backgroundColor = app_background_color;
				[currentPinView.backButton addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
				[currentPinView setDelegate:self];
				[self.view addSubview:currentPinView];
				
				[currentPinView resignFirstResponder];
			}
			
			break;
		}
			
		default:
			break;
	}
}

#pragma mark - ALERTVIEW DELEGATE

-(void)alertView:(AlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	[currentPinView becomeFirstResponder];
}

#pragma mark - VIEW CONTROLLER FUNCTIONS

-(void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
}

@end
