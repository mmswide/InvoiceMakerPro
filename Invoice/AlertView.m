//
//  AlertView.m
//  Invoice
//
//  Created by XGRoup5 on 8/14/13.
//  Copyright (c) 2013 XGRoup. All rights reserved.
//

#import "AlertView.h"

#import "Defines.h"
#import "ButtonForAlert.h"

@interface AlertView () <UIAlertViewDelegate>

@end

@implementation AlertView

@synthesize delegate;
@synthesize titleText;
@synthesize messageText;

-(id)initWithTitle:(NSString*)title message:(NSString*)message delegate:(id)del cancelButtonTitle:(NSString*)cancelButtonTitle otherButtonTitles:(NSArray*)otherButtonTitles
{
	self = [super init];
	
	if (self)
	{
		delegate = del;
		
		[self setFrame:CGRectMake(0, 0, dvc_width, dvc_height + 20)];
		
		blackView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, dvc_width, dvc_height + 20)];
		[blackView setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.5]];
		[blackView setAlpha:0.0];
		[self addSubview:blackView];
		
		CGSize title_size = [data_manager sizeForString:title withFont:[UIFont fontWithName:@"Helvetica" size:18] constrainedToSize:CGSizeMake(256, MAXFLOAT)];
		CGSize message_size = [data_manager sizeForString:message withFont:[UIFont fontWithName:@"Helvetica-Light" size:16] constrainedToSize:CGSizeMake(256, MAXFLOAT)];
		
		_content = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 276, title_size.height + message_size.height + 30 + 54)];
		[_content setBackgroundColor:[UIColor clearColor]];
		[self addSubview:_content];
		
		UIImageView * bg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 276, _content.frame.size.height)];
		[bg setImage:[[UIImage imageNamed:@"alertViewBackground.png"] stretchableImageWithLeftCapWidth:15 topCapHeight:15]];
		[_content addSubview:bg];
		
		titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 256, title_size.height)];
		[titleLabel setText:title];
		[titleLabel setTextAlignment:NSTextAlignmentCenter];
		[titleLabel setTextColor:[UIColor darkGrayColor]];
		[titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:18]];
		[titleLabel setBackgroundColor:[UIColor clearColor]];
		[titleLabel setNumberOfLines:0];
		[_content addSubview:titleLabel];
		
		titleText = titleLabel.text;
		
		if ([title isEqual:@""])
		{
			textLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 256, message_size.height)];
		}
		else
		{
			textLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 20 + title_size.height, 256, message_size.height)];
		}
		
		[textLabel setText:message];
		[textLabel setTextAlignment:NSTextAlignmentCenter];
		[textLabel setTextColor:[UIColor darkGrayColor]];
		[textLabel setFont:[UIFont fontWithName:@"Helvetica-Light" size:16]];
		[textLabel setBackgroundColor:[UIColor clearColor]];
		[textLabel setNumberOfLines:0];
		[_content addSubview:textLabel];
		
		messageText = textLabel.text;
		
		CGFloat button_width;
		CGFloat cancel_y;
		
		if (otherButtonTitles.count % 2 == 0)
		{
			button_width = 127;
			cancel_y = 10 + textLabel.frame.origin.y + message_size.height + 47 * (otherButtonTitles.count / 2);
		}
		else
		{
			button_width = 260;
			cancel_y = 10 + textLabel.frame.origin.y + message_size.height + 47 * otherButtonTitles.count;
		}
		
		ButtonForAlert * cancel = [[ButtonForAlert alloc] initWithFrame:CGRectMake(8, cancel_y, 260, 42) title:cancelButtonTitle andTag:0];
		[cancel addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
		[_content addSubview:cancel];
		
		for (NSString * otherTitle in otherButtonTitles)
		{
			int index = (int)[otherButtonTitles indexOfObject:otherTitle];
			
			if (button_width == 260)
			{
				ButtonForAlert * button = [[ButtonForAlert alloc] initWithFrame:CGRectMake(8, 10 + textLabel.frame.origin.y + message_size.height + 47 * index, button_width, 42) title:otherTitle andTag:index + 1];
				[button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
				[_content addSubview:button];
			}
			else
			{
				ButtonForAlert * button = [[ButtonForAlert alloc] initWithFrame:CGRectMake(8 + (133 * (index % 2)), 10 + textLabel.frame.origin.y + message_size.height + 47 * (index / 2), button_width, 42) title:otherTitle andTag:index + 1];
				[button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
				[_content addSubview:button];
			}
		}
		
		[_content setFrame:CGRectMake(0, 0, 276, cancel.frame.origin.y + 48)];
		[_content setCenter:CGPointMake(dvc_width / 2, (dvc_height + 20) / 2)];
		[bg setFrame:CGRectMake(0, 0, 276, _content.frame.size.height)];
	}
	
	return self;
}

-(id)initWithButtons:(id)del cancelButtonTitle:(NSString*)cancelButtonTitle otherButtonTitles:(NSArray*)otherButtonTitles
{
	self = [super init];
	
	if (self)
	{
		delegate = del;
		
		[self setFrame:CGRectMake(0, 0, dvc_width, dvc_height + 20)];
		
		blackView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, dvc_width, dvc_height + 20)];
		[blackView setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.5]];
		[blackView setAlpha:0.0];
		[self addSubview:blackView];
				
		_content = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 276, 30 + 54)];
		[_content setBackgroundColor:[UIColor clearColor]];
		[self addSubview:_content];
		
		UIImageView * bg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 276, _content.frame.size.height)];
		[bg setImage:[[UIImage imageNamed:@"alertViewBackground.png"] stretchableImageWithLeftCapWidth:15 topCapHeight:15]];
		[_content addSubview:bg];
										
		CGFloat button_width;
		CGFloat cancel_y;
		
		if (otherButtonTitles.count % 2 == 0)
		{
			button_width = 127;
			cancel_y = 10 + 47 * (otherButtonTitles.count / 2);
		}
		else
		{
			button_width = 260;
			cancel_y = 10 + 47 * otherButtonTitles.count;
		}
		
		ButtonForAlert * cancel = [[ButtonForAlert alloc] initWithFrame:CGRectMake(8, cancel_y, 260, 42) title:cancelButtonTitle andTag:0];
		[cancel addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
		[_content addSubview:cancel];
		
		for (NSString * otherTitle in otherButtonTitles)
		{
			int index = (int)[otherButtonTitles indexOfObject:otherTitle];
			
			if (button_width == 260)
			{
				ButtonForAlert * button = [[ButtonForAlert alloc] initWithFrame:CGRectMake(8, 10 + 47 * index, button_width, 42) title:otherTitle andTag:index + 1];
				[button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
				[_content addSubview:button];
			}
			else
			{
				ButtonForAlert * button = [[ButtonForAlert alloc] initWithFrame:CGRectMake(8 + (133 * (index % 2)), 10 + 47 * (index / 2), button_width, 42) title:otherTitle andTag:index + 1];
				[button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
				[_content addSubview:button];
			}
		}
		
		[_content setFrame:CGRectMake(0, 0, 276, cancel.frame.origin.y + 48)];
		[_content setCenter:CGPointMake(dvc_width / 2, (dvc_height + 20) / 2)];
		[bg setFrame:CGRectMake(0, 0, 276, _content.frame.size.height)];
	}
	
	return self;
}

-(void)show
{
	[DELEGATE.window.rootViewController.view addSubview:self];
}

-(void)showInWindow
{
	[DELEGATE.window addSubview:self];
}

-(void)willMoveToSuperview:(UIView*)newSuperview
{
	if (newSuperview)
	{
		[_content setTransform:CGAffineTransformMakeScale(0.1, 0.1)];
		
		[UIView animateWithDuration:0.25 animations:^{
			
			[blackView setAlpha:1.0];
			[_content setTransform:CGAffineTransformIdentity];
			
		}];
	}
}

-(void)close
{
	[UIView animateWithDuration:0.25 animations:^{
		
		[blackView setAlpha:0.0];
		[_content setTransform:CGAffineTransformMakeScale(0.1, 0.1)];
		
	} completion:^(BOOL finished) {
		
		[self removeFromSuperview];
		
	}];
}

-(void)buttonAction:(UIButton*)sender
{
	if ([delegate respondsToSelector:@selector(alertView:clickedButtonAtIndex:)])
	{
		[delegate alertView:self clickedButtonAtIndex:sender.tag];
	}
	
	[self close];
}

@end