//
//  PinView.m
//  Invoice
//
//  Created by XGRoup5 on 8/16/13.
//  Copyright (c) 2013 XGRoup. All rights reserved.
//

#import "PinView.h"

#import "Defines.h"

@interface PinView () <UITextFieldDelegate>

@end

@implementation PinView

@synthesize backButton;
@synthesize delegate;

-(id)initWithTitle:(NSString*)title backButtonType:(kBackButtonType)type
{
	CGRect frame = CGRectMake(0, statusBarHeight, dvc_width, dvc_height);
		
	self = [super initWithFrame:frame];
	
	if (self)
	{
		[self setBackgroundColor:[UIColor whiteColor]];
		
		switch (type)
		{
			case kBackButtonTypeNone:
			{
				break;
			}
				
			case kBackButtonTypeBack:
			{
				backButton = [[BackButtonNormal alloc] initWithFrame:CGRectMake(0, 2, 70, 40) andTitle:@"Back"];
				[self addSubview:backButton];
				
				break;
			}
				
			case kBackButtonTypeCancel:
			{
				backButton = [[BackButtonNormal alloc] initWithFrame:CGRectMake(0, 2, 70, 40) andTitle:@"Cancel"];
				[backButton setBackgroundImage:nil forState:UIControlStateNormal];
				[backButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
				[self addSubview:backButton];
				
				break;
			}
				
			default:
				break;
		}
		
		UILabel * titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 2, dvc_width - 160, 40)];
		[titleLabel setText:title];
		[titleLabel setTextAlignment:NSTextAlignmentCenter];
		[titleLabel setTextColor:[UIColor blackColor]];
		[titleLabel setFont:HelveticaNeueMedium(17)];
		[titleLabel setBackgroundColor:[UIColor clearColor]];
		[self addSubview:titleLabel];
		
		for (int i = 0; i < 4; i++)
		{
			UIView * theView = [self textFieldWithTag:i + 1 andFrame:CGRectMake(((dvc_width - 190) / 2) + (i * 50), 100, 40, 40)];
			[self addSubview:theView];
		}
	}
	
	return self;
}

-(UIView*)textFieldWithTag:(int)tag andFrame:(CGRect)frame
{
	UIView * theView = [[UIView alloc] initWithFrame:frame];
	[theView setBackgroundColor:[UIColor clearColor]];
	
	UIImageView * bgForText = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
	[bgForText setImage:[[UIImage imageNamed:@"tableSingleCellWhite.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10]];
	[theView addSubview:bgForText];
	
	UITextField * textField = [[UITextField alloc] initWithFrame:CGRectMake(5, 5, frame.size.width - 10, frame.size.height - 10)];
	[textField setTextAlignment:NSTextAlignmentCenter];
	[textField setTextColor:[UIColor blackColor]];
	[textField setFont:HelveticaNeue(13)];
	[textField setSecureTextEntry:YES];
	[textField setTag:tag];
	[textField setDelegate:self];
	[textField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
	[textField setKeyboardType:UIKeyboardTypeNumberPad];
	[theView addSubview:textField];
	
	if (tag == 1)
		[textField becomeFirstResponder];
	
	UIView * block = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
	[block setBackgroundColor:[UIColor clearColor]];
	[theView addSubview:block];
	
	return theView;
}

-(void)resignFirstResponder
{
	[(UITextField*)[self viewWithTag:1] resignFirstResponder];
	[(UITextField*)[self viewWithTag:2] resignFirstResponder];
	[(UITextField*)[self viewWithTag:3] resignFirstResponder];
	[(UITextField*)[self viewWithTag:4] resignFirstResponder];
}

-(void)becomeFirstResponder
{
	[(UITextField*)[self viewWithTag:1] becomeFirstResponder];
}

#pragma mark - TEXTFIELD DELEGATE

-(BOOL)textField:(UITextField*)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString*)string
{
	if (![string isEqual:@""])
	{
		[(UITextField*)[self viewWithTag:textField.tag + 1] becomeFirstResponder];
	}
	else
	{
		[(UITextField*)[self viewWithTag:textField.tag - 1] becomeFirstResponder];
	}
	
	[textField setText:string];
	
	if (((UITextField*)[self viewWithTag:4]).text && ![((UITextField*)[self viewWithTag:4]).text isEqual:@""])
	{
		UITextField * field1 = (UITextField*)[self viewWithTag:1];
		UITextField * field2 = (UITextField*)[self viewWithTag:2];
		UITextField * field3 = (UITextField*)[self viewWithTag:3];
		UITextField * field4 = (UITextField*)[self viewWithTag:4];
		
		NSString * pin = [NSString stringWithFormat:@"%@%@%@%@", field1.text, field2.text, field3.text, field4.text];
		
		if ([delegate respondsToSelector:@selector(pinView:FinishedEnteringPin:)])
		{
			[delegate pinView:self FinishedEnteringPin:pin];
		}
	}
	
	return NO;
}

@end