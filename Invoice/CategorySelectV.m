//
//  CategorySelectV.m
//  Invoice
//
//  Created by XGRoup on 6/25/14.
//  Copyright (c) 2014 XGRoup. All rights reserved.
//

#import "CategorySelectV.h"

#import <QuartzCore/QuartzCore.h>
#import "Defines.h"

@implementation CategorySelectV

- (id)initWithFrame:(CGRect)frame andType:(kSelectType)type andDelegate:(id <CategorySelectDelegate>)sender
{
	self = [super initWithFrame:frame];
	
	if (self)
	{
		_delegate = sender;
		currentType = type;
		
		int width = (type == kInvoiceSelect || type == kReceiptSelect || type == kTimesheetSelect) ? 300 : 200;
		int numberOfElements = (type == kInvoiceSelect || type == kReceiptSelect || type == kTimesheetSelect) ? 3 : 2;
		
		CGFloat origin = (frame.size.width - width) / 2;
		
		for(int i=0;i<numberOfElements;i++)
		{
			UIView *buttonView = [[UIView alloc] initWithFrame:CGRectMake(origin, 0, width / numberOfElements, frame.size.height)];
			buttonView.backgroundColor = [UIColor clearColor];
			[self addSubview:buttonView];
			
			UIImageView *buttonImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100, frame.size.height)];
			buttonImage.tag = 100;
			buttonImage.backgroundColor = [UIColor clearColor];
			[buttonView addSubview:buttonImage];
			
			if(i == 0)
				buttonImage.image = [UIImage imageNamed:@"leftRoundButton.png"];
			else
			if(i == 1 && (currentType == kInvoiceSelect || currentType == kReceiptSelect || currentType == kTimesheetSelect))
				buttonImage.image = [UIImage imageNamed:@"middleRoundButton.png"];
			else
			if(i == 1 && currentType == kProductAndServiceSelect)
				buttonImage.image = [UIImage imageNamed:@"rightRoundButton.png"];
			else
				buttonImage.image = [UIImage imageNamed:@"rightRoundButton.png"];
						
			UIButton *categoryButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, buttonView.frame.size.width, buttonView.frame.size.height)];
			categoryButton.backgroundColor = [UIColor clearColor];
			categoryButton.tag = i + 1;
			[categoryButton addTarget:self action:@selector(categoryAction:) forControlEvents:UIControlEventTouchUpInside];
			[buttonView addSubview:categoryButton];
						
			UILabel *categoryLabel = [[UILabel alloc] initWithFrame:CGRectMake(origin, 0, width / numberOfElements, frame.size.height)];
			categoryLabel.backgroundColor = [UIColor clearColor];
			categoryLabel.font = HelveticaNeue(13);
			categoryLabel.tag = - (i + 1);
			categoryLabel.textAlignment = NSTextAlignmentCenter;
			categoryLabel.text = [self generateCategoryName:i];
			categoryLabel.textColor = [UIColor grayColor];
			[self addSubview:categoryLabel];
						
			if(i == 0)
			{
				categoryLabel.textColor = [UIColor whiteColor];
				buttonImage.image = [UIImage imageNamed:@"leftRoundButtonSelected.png"];
				
				lastSelected = buttonView;
				lastLabelSelected = categoryLabel;
				lastImageSelected = buttonImage;
				lastButtonSelect = 1;
				
				_currentCategorySelected = 1;				
			}
					
			origin += width / numberOfElements - 1;
		}

	}
	
	return self;
}

-(NSString*)generateCategoryName:(int)sender
{
	if(sender == 0)
	{
		if(currentType == kInvoiceSelect)
			return @"Overdue";
		
		if(currentType == kProjectSelect)
			return @"Open";
		
		if(currentType == kReceiptSelect || currentType == kTimesheetSelect)
			return @"Week";
		
		return @"Product";
	}
	
	if(sender == 1)
	{
		if(currentType == kInvoiceSelect)
			return @"Open";
		
		if(currentType == kProjectSelect)
			return @"Completed";
		
		if(currentType == kReceiptSelect || currentType == kTimesheetSelect)
			return @"Month";
		
		return @"Service";
	}
	
	if(currentType == kInvoiceSelect)
		return @"Paid";
	
	return @"All";
}

#pragma mark - ACTIONS

-(void)categoryAction:(UIButton*)button
{
	if(lastSelected != nil)
	{
		[UIView transitionWithView:lastImageSelected
					duration:0.2f
					 options:UIViewAnimationOptionTransitionCrossDissolve
				    animations:
		 ^{
			 [lastLabelSelected setTextColor:[UIColor grayColor]];
			 
			if(lastButtonSelect == 1)
				[lastImageSelected setImage:[UIImage imageNamed:@"leftRoundButton.png"]];
			else
			if(lastButtonSelect == 2 && (currentType == kInvoiceSelect || currentType == kReceiptSelect || currentType == kTimesheetSelect))
				[lastImageSelected setImage:[UIImage imageNamed:@"middleRoundButton.png"]];
			else
			if(lastButtonSelect == 2 && currentType == kProductAndServiceSelect)
				[lastImageSelected setImage:[UIImage imageNamed:@"rightRoundButton.png"]];
			else
				[lastImageSelected setImage:[UIImage imageNamed:@"rightRoundButton.png"]];
			 			 
		 } completion:^(BOOL finished) {
			 
		 }];
	}
	
	if ([_delegate respondsToSelector:@selector(categorySelectDelegate:selectedCategory:)])
	{
		[_delegate categorySelectDelegate:self selectedCategory:(int)button.tag];
	}
	
	[UIView transitionWithView:(UIImageView*)[button.superview viewWithTag:100]
				duration:0.2f
				 options:UIViewAnimationOptionTransitionCrossDissolve
			    animations:
	 ^{
		 [(UILabel*)[self viewWithTag:-button.tag] setTextColor:[UIColor whiteColor]];
		 
		if(button.tag == 1)
			[(UIImageView*)[button.superview viewWithTag:100] setImage:[UIImage imageNamed:@"leftRoundButtonSelected.png"]];
		else
		if(button.tag == 2 && (currentType == kInvoiceSelect || currentType == kReceiptSelect || currentType == kTimesheetSelect))
			[(UIImageView*)[button.superview viewWithTag:100] setImage:[UIImage imageNamed:@"roundMiddleButtonSelected.png"]];
		else
		if(button.tag == 2 && currentType == kProductAndServiceSelect)
			[(UIImageView*)[button.superview viewWithTag:100] setImage:[UIImage imageNamed:@"rightRoundButtonSelected.png"]];
		else
			[(UIImageView*)[button.superview viewWithTag:100] setImage:[UIImage imageNamed:@"rightRoundButtonSelected.png"]];
		 		 
	 } completion:^(BOOL finished) {
		 
	 }];
	
	lastSelected = button.superview;
	lastLabelSelected = (UILabel*)[self viewWithTag:-button.tag];
	lastImageSelected = (UIImageView*)[button.superview viewWithTag:100];
	lastButtonSelect = (int)button.tag;
}

@end
