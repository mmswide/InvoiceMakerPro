//
//  ContactDetailsVC.m
//  Invoice
//
//  Created by XGRoup5 on 8/22/13.
//  Copyright (c) 2013 XGRoup. All rights reserved.
//

#import "ContactDetailsVC.h"

#import "Defines.h"

@interface ContactDetailsVC () <AlertViewDelegate, MFMailComposeViewControllerDelegate, UIScrollViewDelegate>

@end

@implementation ContactDetailsVC

-(id)initWithClient:(ClientOBJ*)sender
{
	self = [super init];
	
	if (self)
	{
		theClient = sender;
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
	
	topBarView = [[TopBar alloc] initWithFrame:CGRectMake(0, 0, dvc_width, 42 + statusBarHeight) andTitle:@"Contact Details"];
	[topBarView setBackgroundColor:app_bar_update_color];
	
	BackButton * backButton = [[BackButton alloc] initWithFrame:CGRectMake(0, 42 + statusBarHeight - 40, 70, 40) andTitle:@"Back"];
	[backButton addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
	[topBarView addSubview:backButton];
	
	mainScrollView = [[ScrollWithShadow alloc] initWithFrame:CGRectMake(0, 42, dvc_width, dvc_height - 87)];
	[mainScrollView setBackgroundColor:[UIColor clearColor]];
	[mainScrollView setDelegate:self];
	[theSelfView addSubview:mainScrollView];
	
	//WEBSITE
	{
		UIButton * button = [[UIButton alloc] initWithFrame:CGRectMake(10, 10, dvc_width - 20, 42)];
		[button setBackgroundImage:[[UIImage imageNamed:@"tableTopCellWhite.png"] stretchableImageWithLeftCapWidth:20 topCapHeight:15] forState:UIControlStateNormal];
		[button addTarget:self action:@selector(website:) forControlEvents:UIControlEventTouchUpInside];
		[button setTitle:@"Website" forState:UIControlStateNormal];
		[button setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
		[button.titleLabel setFont:HelveticaNeue(16)];
		[button setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
		[button setTitleEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
		[mainScrollView addSubview:button];
		
		UILabel * text = [[UILabel alloc] initWithFrame:CGRectMake(100, 0, dvc_width - 130, 42)];
		[text setText:[theClient website]];
		[text setTextAlignment:NSTextAlignmentRight];
		[text setTextColor:[UIColor darkGrayColor]];
		[text setFont:HelveticaNeue(15)];
		[text setBackgroundColor:[UIColor clearColor]];
		[button addSubview:text];
	}
	
	//EMAIL
	{
		UIButton * button = [[UIButton alloc] initWithFrame:CGRectMake(10, 52, dvc_width - 20, 42)];
		[button setBackgroundImage:[[UIImage imageNamed:@"tableMiddleCellWhite.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10] forState:UIControlStateNormal];
		[button addTarget:self action:@selector(email:) forControlEvents:UIControlEventTouchUpInside];
		[button setTitle:@"Email" forState:UIControlStateNormal];
		[button setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
		[button.titleLabel setFont:HelveticaNeue(16)];
		[button setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
		[button setTitleEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
		[mainScrollView addSubview:button];
		
		UILabel * text = [[UILabel alloc] initWithFrame:CGRectMake(100, 0, dvc_width - 130, 42)];
		[text setText:[theClient email]];
		[text setTextAlignment:NSTextAlignmentRight];
		[text setTextColor:[UIColor darkGrayColor]];
		[text setFont:HelveticaNeue(15)];
		[text setBackgroundColor:[UIColor clearColor]];
		[button addSubview:text];
	}
	
	//PHONE
	{
		UIButton * button = [[UIButton alloc] initWithFrame:CGRectMake(10, 94, dvc_width - 20, 42)];
		[button setBackgroundImage:[[UIImage imageNamed:@"tableMiddleCellWhite.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10] forState:UIControlStateNormal];
		[button addTarget:self action:@selector(phone:) forControlEvents:UIControlEventTouchUpInside];
		[button setTitle:@"Phone" forState:UIControlStateNormal];
		[button setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
		[button.titleLabel setFont:HelveticaNeue(16)];
		[button setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
		[button setTitleEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
		[mainScrollView addSubview:button];
		
		UILabel * text = [[UILabel alloc] initWithFrame:CGRectMake(100, 0, dvc_width - 130, 42)];
		[text setText:[theClient phone]];
		[text setTextAlignment:NSTextAlignmentRight];
		[text setTextColor:[UIColor darkGrayColor]];
		[text setFont:HelveticaNeue(15)];
		[text setBackgroundColor:[UIColor clearColor]];
		[button addSubview:text];
	}
	
	//MOBILE
	{
		UIButton * button = [[UIButton alloc] initWithFrame:CGRectMake(10, 136, dvc_width - 20, 42)];
		[button setBackgroundImage:[[UIImage imageNamed:@"tableMiddleCellWhite.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10] forState:UIControlStateNormal];
		[button addTarget:self action:@selector(mobile:) forControlEvents:UIControlEventTouchUpInside];
		[button setTitle:@"Mobile" forState:UIControlStateNormal];
		[button setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
		[button.titleLabel setFont:HelveticaNeue(16)];
		[button setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
		[button setTitleEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
		[mainScrollView addSubview:button];
		
		UILabel * text = [[UILabel alloc] initWithFrame:CGRectMake(100, 0, dvc_width - 130, 42)];
		[text setText:[theClient mobile]];
		[text setTextAlignment:NSTextAlignmentRight];
		[text setTextColor:[UIColor darkGrayColor]];
		[text setFont:HelveticaNeue(15)];
		[text setBackgroundColor:[UIColor clearColor]];
		[button addSubview:text];
	}
	
	//FAX
	{
		UIButton * button = [[UIButton alloc] initWithFrame:CGRectMake(10, 178, dvc_width - 20, 42)];
		[button setBackgroundImage:[[UIImage imageNamed:@"tableBottomCellWhite.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10] forState:UIControlStateNormal];
		[button setTitle:@"Fax" forState:UIControlStateNormal];
		[button setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
		[button.titleLabel setFont:HelveticaNeue(16)];
		[button setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
		[button setTitleEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
		[button setUserInteractionEnabled:NO];
		[mainScrollView addSubview:button];
		
		UILabel * text = [[UILabel alloc] initWithFrame:CGRectMake(100, 0, dvc_width - 130, 42)];
		[text setText:[theClient fax]];
		[text setTextAlignment:NSTextAlignmentRight];
		[text setTextColor:[UIColor darkGrayColor]];
		[text setFont:HelveticaNeue(15)];
		[text setBackgroundColor:[UIColor clearColor]];
		[button addSubview:text];
	}
	
	CGFloat height = 230;
	
	//BILLING ADDRESS
	{
		NSString * string = [[theClient billingAddress] fullStringRepresentation];
		CGSize billing_size = [data_manager sizeForString:string withFont:HelveticaNeue(15) constrainedToSize:CGSizeMake(dvc_width - 40, MAXFLOAT)];
		
		UIImageView * bg = [[UIImageView alloc] initWithFrame:CGRectMake(10, height, dvc_width - 20, billing_size.height + 40)];
		[bg setImage:[[UIImage imageNamed:@"tableTopCellWhite.png"] stretchableImageWithLeftCapWidth:20 topCapHeight:15]];
		[mainScrollView addSubview:bg];
		
		UILabel * titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, dvc_width - 40, 20)];
		[titleLabel setText:[CustomDefaults customObjectForKey:kBillingAddressTitleKeyForNSUserDefaults]];
		[titleLabel setTextAlignment:NSTextAlignmentLeft];
		[titleLabel setTextColor:[UIColor grayColor]];
		[titleLabel setFont:HelveticaNeue(16)];
		[titleLabel setBackgroundColor:[UIColor clearColor]];
		[bg addSubview:titleLabel];
		
		UILabel * textLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 35, dvc_width - 40, billing_size.height)];
		[textLabel setText:[[theClient billingAddress] fullStringRepresentation]];
		[textLabel setTextColor:[UIColor darkGrayColor]];
		[textLabel setTextAlignment:NSTextAlignmentRight];
		[textLabel setFont:HelveticaNeue(15)];
		[textLabel setBackgroundColor:[UIColor clearColor]];
		[textLabel setNumberOfLines:0];
		[bg addSubview:textLabel];
		
		height += bg.frame.size.height;
	}
	
	//SHIPPING ADDRESS
	{
		NSString * string = [[theClient shippingAddress] fullStringRepresentation];
		CGSize shipping_size = [data_manager sizeForString:string withFont:HelveticaNeue(15) constrainedToSize:CGSizeMake(dvc_width - 40, MAXFLOAT)];
		
		UIImageView * bg = [[UIImageView alloc] initWithFrame:CGRectMake(10, height, dvc_width - 20, shipping_size.height + 40)];
		[bg setImage:[[UIImage imageNamed:@"tableBottomCellWhite.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10]];
		[mainScrollView addSubview:bg];
		
		UILabel * titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, dvc_width - 40, 20)];
		[titleLabel setText:[CustomDefaults customObjectForKey:kShippingAddressTitleKeyForNSUserDefaults]];
		[titleLabel setTextAlignment:NSTextAlignmentLeft];
		[titleLabel setTextColor:[UIColor grayColor]];
		[titleLabel setFont:HelveticaNeue(16)];
		[titleLabel setBackgroundColor:[UIColor clearColor]];
		[bg addSubview:titleLabel];
		
		UILabel * textLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 35, dvc_width - 40, shipping_size.height)];
		[textLabel setText:[[theClient shippingAddress] fullStringRepresentation]];
		[textLabel setTextAlignment:NSTextAlignmentRight];
		[textLabel setTextColor:[UIColor darkGrayColor]];
		[textLabel setFont:HelveticaNeue(15)];
		[textLabel setBackgroundColor:[UIColor clearColor]];
		[textLabel setNumberOfLines:0];
		[bg addSubview:textLabel];
		
		[mainScrollView setContentSize:CGSizeMake(dvc_width, height + shipping_size.height + 50)];
		if (mainScrollView && [mainScrollView respondsToSelector:@selector(didScroll)])
			[mainScrollView didScroll];
	}
	
	[self.view addSubview:topBarView];
}

#pragma mark - FUNCTIONS

-(void)back:(UIButton*)sender
{
	[self.navigationController popViewControllerAnimated:YES];
}

-(void)website:(UIButton*)sender
{
	[[[AlertView alloc] initWithTitle:[theClient website] message:@"Open URL?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:[NSArray arrayWithObject:@"Yes"]] show];
}

-(void)email:(UIButton*)sender
{
	if ([MFMailComposeViewController canSendMail])
	{
		MFMailComposeViewController * vc = [[MFMailComposeViewController alloc] init];
		[vc setToRecipients:[NSArray arrayWithObject:[theClient email]]];
		[vc setMailComposeDelegate:self];
		[self.navigationController presentViewController:vc animated:YES completion:nil];
	}
	else
	{
		[[[AlertView alloc] initWithTitle:@"" message:@"You must configure an email account in the device settings to be able to send emails." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
	}
}

-(void)phone:(UIButton*)sender
{
	[[[AlertView alloc] initWithTitle:[theClient phone] message:@"Call this number?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:[NSArray arrayWithObject:@"Yes"]] show];
}

-(void)mobile:(UIButton*)sender
{
	[[[AlertView alloc] initWithTitle:[theClient mobile] message:@"Call this number?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:[NSArray arrayWithObject:@"Yes"]] show];
}

#pragma mark - ALERTVIEW DELEGATE

-(void)alertView:(AlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == 1)
	{
		if ([alertView.messageText componentsSeparatedByString:@"URL"].count > 1)
		{
			NSString * urlString = alertView.titleText;
			
			if ([urlString hasPrefix:@"http://"] || [urlString hasPrefix:@"https://"])
			{
				[[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
			}
			else
			{
				[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@", urlString]]];
			}
		}
		else
		{
			[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@", alertView.titleText]]];
		}
	}
}

#pragma mark - MAIL COMPOSER DELEGATE

-(void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
	[controller dismissViewControllerAnimated:YES completion:nil];
	
	if(result == MFMailComposeResultFailed && error != nil)
	{
		[[[UIAlertView alloc] initWithTitle:@"Failed to send email" message:error.localizedDescription delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
	}
}

#pragma mark - SCROLLVIEW DELEGATE

-(void)scrollViewDidScroll:(UIScrollView*)scrollView
{
	if (mainScrollView && [mainScrollView respondsToSelector:@selector(didScroll)])
		[mainScrollView didScroll];
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