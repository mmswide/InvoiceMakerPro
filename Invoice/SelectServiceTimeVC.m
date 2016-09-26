//
//  CreateAndEditTimeVC.m
//  Work.
//
//  Created by XGRoup on 6/23/14.
//  Copyright (c) 2014 XGRoup. All rights reserved.
//

#import "SelectServiceTimeVC.h"

#import "Defines.h"
#import "CreateObjectiveVC.h"
#import "EditObjectiveVC.h"
#import "ProductsVC.h"

@interface SelectServiceTimeVC ()

<
UITextViewDelegate,
UITextFieldDelegate,
UIPickerViewDataSource,
UIPickerViewDelegate,
UIScrollViewDelegate,
ProductOrServiceSelectorDelegate
>

@end

@implementation SelectServiceTimeVC

@synthesize editorDelegate;

-(id)initWithEditorDelegate:(id<TimeEditorDelegate>)sender serviceTime:(ServiceTimeOBJ *)serviceTime andTitle:(NSString *)ttl
{
	self = [super init];
	
	if(self)
	{
		editorDelegate = sender;
				
		title = [[NSMutableString alloc] initWithString:ttl];
		theTime = [[ServiceTimeOBJ alloc] initWithTimeSheet:serviceTime];
	}
	
	return self;
}

#pragma mark
#pragma mark VIEW DID LOAD

-(void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	pickerAppeared = 0;
}

-(void)viewDidLoad
{
	[super viewDidLoad];
	
	pickerAppeared = 0;
			
	theSelfView = [[UIView alloc] initWithFrame:CGRectMake(0, statusBarHeight, dvc_width, (dvc_height + 20))];
	[theSelfView setBackgroundColor:[UIColor clearColor]];
	[self.view addSubview:theSelfView];
	
	[self.view setBackgroundColor:app_background_color];
	
	topBarView = [[TopBar alloc] initWithFrame:CGRectMake(0, 0, dvc_width, 42 + statusBarHeight) andTitle:title];
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
	
	mainScrollView = [[ScrollWithShadow alloc] initWithFrame:CGRectMake(0, 42, dvc_width, dvc_height - 42)];
	[mainScrollView setDelegate:self];
	[mainScrollView setBackgroundColor:[UIColor clearColor]];
	[mainScrollView setContentSize:CGSizeMake(dvc_width, 10 *  45)];
	[theSelfView addSubview:mainScrollView];
	
	CGFloat y = 0;
	
	// Service
	{
		UIImageView * bg = [[UIImageView alloc] initWithFrame:CGRectMake(10, y, dvc_width - 20, 42)];
		[bg setImage:[[UIImage imageNamed:@"tableTopCellWhite.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10]];
		[mainScrollView addSubview:bg];
		
		UILabel * titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, y, (dvc_width - 40) * 0.6, 42)];
		[titleLabel setText:@"Service"];
		[titleLabel setTextAlignment:NSTextAlignmentLeft];
		[titleLabel setTextColor:[UIColor grayColor]];
		[titleLabel setFont:HelveticaNeue(16)];
		[titleLabel setBackgroundColor:[UIColor clearColor]];
		[mainScrollView addSubview:titleLabel];
				
		UITextField * valueTextField = [[UITextField alloc] initWithFrame:CGRectMake((dvc_width - 40) * 0.3, y + 1, dvc_width * 0.68 - 28.0, 42)];
		[valueTextField setText:[[theTime product] name]];
		[valueTextField setTextAlignment:NSTextAlignmentRight];
		[valueTextField setTextColor:[UIColor darkGrayColor]];
		[valueTextField setFont:HelveticaNeue(16)];
		[valueTextField setBackgroundColor:[UIColor clearColor]];
		[valueTextField setReturnKeyType:UIReturnKeyDone];
		[valueTextField setAutocapitalizationType:UITextAutocapitalizationTypeSentences];
		[valueTextField setAutocorrectionType:UITextAutocorrectionTypeYes];
		valueTextField.layer.sublayerTransform = CATransform3DMakeTranslation(-1, 0, 0);
		[valueTextField setDelegate:self];
		[valueTextField setTag:111];
		[mainScrollView addSubview:valueTextField];
		
		UIImageView *plusImage = [[UIImageView alloc] initWithFrame:CGRectMake(valueTextField.frame.origin.x + valueTextField.frame.size.width + 4, y + 11, 20, 20)];
		plusImage.image = [UIImage imageNamed:@"plus.png"];
		[mainScrollView addSubview:plusImage];
		
		UIButton *addButton = [[UIButton alloc] initWithFrame:CGRectMake(valueTextField.frame.origin.x + valueTextField.frame.size.width + 4, 0, 30, 42)];
		[addButton setBackgroundColor:[UIColor clearColor]];
		[addButton addTarget:self action:@selector(openProductServiceSelect:) forControlEvents:UIControlEventTouchUpInside];
		[mainScrollView addSubview:addButton];
	}
	
	//DATE
	{
		y += 42;
		
		UIImageView * bg = [[UIImageView alloc] initWithFrame:CGRectMake(10, y, dvc_width - 20, 42)];
		[bg setImage:[[UIImage imageNamed:@"tableMiddleCellWhite.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10]];
		[mainScrollView addSubview:bg];
		
		UILabel * titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, y, (dvc_width - 40) * 0.6, 42)];
		[titleLabel setText:@"Date"];
		[titleLabel setTextAlignment:NSTextAlignmentLeft];
		[titleLabel setTextColor:[UIColor grayColor]];
		[titleLabel setFont:HelveticaNeue(16)];
		[titleLabel setBackgroundColor:[UIColor clearColor]];
		[mainScrollView addSubview:titleLabel];
		
		[date_formatter setDateFormat:[DELEGATE userSelectedDateFormat]];
		
		UITextField * valueTextField = [[UITextField alloc] initWithFrame:CGRectMake(25 + (dvc_width - 40) * 0.3, y + 1, (dvc_width - 40) * 0.68, 42)];
		[valueTextField setText:[date_formatter stringFromDate:[theTime date]]];
		[valueTextField setTextAlignment:NSTextAlignmentRight];
		[valueTextField setTextColor:[UIColor darkGrayColor]];
		[valueTextField setFont:HelveticaNeue(16)];
		valueTextField.layer.sublayerTransform = CATransform3DMakeTranslation(-1, 0, 0);
		[valueTextField setBackgroundColor:[UIColor clearColor]];
		[valueTextField setReturnKeyType:UIReturnKeyDone];
		[valueTextField setAutocapitalizationType:UITextAutocapitalizationTypeSentences];
		[valueTextField setAutocorrectionType:UITextAutocorrectionTypeYes];
		[valueTextField setDelegate:self];
		[valueTextField setTag:1000];
		[mainScrollView addSubview:valueTextField];
	}
	
	//START
	{
		y += 42;
		
		UIImageView * bg = [[UIImageView alloc] initWithFrame:CGRectMake(10, y, dvc_width - 20, 42)];
		[bg setImage:[[UIImage imageNamed:@"tableMiddleCellWhite.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10]];
		[mainScrollView addSubview:bg];
		
		UILabel * titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, y, (dvc_width - 40) * 0.6, 42)];
		[titleLabel setText:@"Start Time"];
		[titleLabel setTextAlignment:NSTextAlignmentLeft];
		[titleLabel setTextColor:[UIColor grayColor]];
		[titleLabel setFont:HelveticaNeue(16)];
		[titleLabel setBackgroundColor:[UIColor clearColor]];
		[mainScrollView addSubview:titleLabel];
		
		[date_formatter setDateFormat:@"hh:mm a"];
		
		UITextField * valueTextField = [[UITextField alloc] initWithFrame:CGRectMake(25 + (dvc_width - 40) * 0.3, y + 1, (dvc_width - 40) * 0.68, 42)];
		[valueTextField setText:[date_formatter stringFromDate:[theTime startTime]]];
		[valueTextField setTextAlignment:NSTextAlignmentRight];
		[valueTextField setTextColor:[UIColor darkGrayColor]];
		[valueTextField setFont:HelveticaNeue(16)];
		valueTextField.layer.sublayerTransform = CATransform3DMakeTranslation(-1, 0, 0);
		[valueTextField setBackgroundColor:[UIColor clearColor]];
		[valueTextField setReturnKeyType:UIReturnKeyDone];
		[valueTextField setAutocapitalizationType:UITextAutocapitalizationTypeSentences];
		[valueTextField setAutocorrectionType:UITextAutocorrectionTypeYes];
		[valueTextField setDelegate:self];
		[valueTextField setTag:222];
		[mainScrollView addSubview:valueTextField];
	}
	
	//Finish Time
	{
		y += 42;
		
		UIImageView * bg = [[UIImageView alloc] initWithFrame:CGRectMake(10, y, dvc_width - 20, 42)];
		[bg setImage:[[UIImage imageNamed:@"tableMiddleCellWhite.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10]];
		[mainScrollView addSubview:bg];
		
		UILabel * titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, y, (dvc_width - 40) * 0.6, 42)];
		[titleLabel setText:@"Finish Time"];
		[titleLabel setTextAlignment:NSTextAlignmentLeft];
		[titleLabel setTextColor:[UIColor grayColor]];
		[titleLabel setFont:HelveticaNeue(16)];
		[titleLabel setBackgroundColor:[UIColor clearColor]];
		[mainScrollView addSubview:titleLabel];
		
		[date_formatter setDateFormat:@"hh:mm a"];
		
		UITextField * valueTextField = [[UITextField alloc] initWithFrame:CGRectMake(25 + (dvc_width - 40) * 0.3, y + 1, (dvc_width - 40) * 0.68, 42)];
		[valueTextField setText:[date_formatter stringFromDate:[theTime finishTime]]];
		[valueTextField setTextAlignment:NSTextAlignmentRight];
		[valueTextField setTextColor:[UIColor darkGrayColor]];
		[valueTextField setFont:HelveticaNeue(16)];
		[valueTextField setBackgroundColor:[UIColor clearColor]];
		valueTextField.layer.sublayerTransform = CATransform3DMakeTranslation(-1, 0, 0);
		[valueTextField setReturnKeyType:UIReturnKeyDone];
		[valueTextField setAutocapitalizationType:UITextAutocapitalizationTypeSentences];
		[valueTextField setAutocorrectionType:UITextAutocorrectionTypeYes];
		[valueTextField setDelegate:self];
		[valueTextField setTag:333];
		[mainScrollView addSubview:valueTextField];
	}
		
	//Breaktime
	{
		y += 42;
		
		UIImageView * bg = [[UIImageView alloc] initWithFrame:CGRectMake(10, y, dvc_width - 20, 42)];
		[bg setImage:[[UIImage imageNamed:@"tableMiddleCellWhite.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10]];
		[mainScrollView addSubview:bg];
		
		UILabel * titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, y, (dvc_width - 40) * 0.6, 42)];
		[titleLabel setText:@"Break Time"];
		[titleLabel setTextAlignment:NSTextAlignmentLeft];
		[titleLabel setTextColor:[UIColor grayColor]];
		[titleLabel setFont:HelveticaNeue(16)];
		[titleLabel setBackgroundColor:[UIColor clearColor]];
		[mainScrollView addSubview:titleLabel];
		
		UITextField * valueTextField = [[UITextField alloc] initWithFrame:CGRectMake(25 + (dvc_width - 40) * 0.3, y + 1, (dvc_width - 40) * 0.68, 42)];
		[valueTextField setText:[theTime breakString]];
		[valueTextField setTextAlignment:NSTextAlignmentRight];
		[valueTextField setTextColor:[UIColor darkGrayColor]];
		[valueTextField setFont:HelveticaNeue(16)];
		[valueTextField setBackgroundColor:[UIColor clearColor]];
		valueTextField.layer.sublayerTransform = CATransform3DMakeTranslation(-1, 0, 0);
		[valueTextField setReturnKeyType:UIReturnKeyDone];
		[valueTextField setAutocapitalizationType:UITextAutocapitalizationTypeSentences];
		[valueTextField setAutocorrectionType:UITextAutocorrectionTypeYes];
		[valueTextField setDelegate:self];
		[valueTextField setTag:444];
		[mainScrollView addSubview:valueTextField];
	}
	
	//Overtime
	{
		y += 42;
		
		UIImageView * bg = [[UIImageView alloc] initWithFrame:CGRectMake(10, y, dvc_width - 20, 42)];
		[bg setImage:[[UIImage imageNamed:@"tableMiddleCellWhite.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10]];
		[mainScrollView addSubview:bg];
		
		UILabel * titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, y, (dvc_width - 40) * 0.6, 42)];
		[titleLabel setText:@"Overtime"];
		[titleLabel setTextAlignment:NSTextAlignmentLeft];
		[titleLabel setTextColor:[UIColor grayColor]];
		[titleLabel setFont:HelveticaNeue(16)];
		[titleLabel setBackgroundColor:[UIColor clearColor]];
		[mainScrollView addSubview:titleLabel];
		
		UITextField * valueTextField = [[UITextField alloc] initWithFrame:CGRectMake(25 + (dvc_width - 40) * 0.3, y + 1, (dvc_width - 40) * 0.68, 42)];
		[valueTextField setText:[theTime overtimeString]];
		[valueTextField setTextAlignment:NSTextAlignmentRight];
		[valueTextField setTextColor:[UIColor darkGrayColor]];
		[valueTextField setFont:HelveticaNeue(16)];
		[valueTextField setBackgroundColor:[UIColor clearColor]];
		valueTextField.layer.sublayerTransform = CATransform3DMakeTranslation(-1, 0, 0);
		[valueTextField setReturnKeyType:UIReturnKeyDone];
		[valueTextField setAutocapitalizationType:UITextAutocapitalizationTypeSentences];
		[valueTextField setAutocorrectionType:UITextAutocorrectionTypeYes];
		[valueTextField setDelegate:self];
		[valueTextField setTag:555];
		[mainScrollView addSubview:valueTextField];
	}
	
	//Duration
	{
		y += 42;
		
		UIImageView * bg = [[UIImageView alloc] initWithFrame:CGRectMake(10, y, dvc_width - 20, 42)];
		[bg setImage:[[UIImage imageNamed:@"tableMiddleCellWhite.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10]];
		[mainScrollView addSubview:bg];
		
		UILabel * titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, y, (dvc_width - 40) * 0.6, 42)];
		[titleLabel setText:@"Duration"];
		[titleLabel setTextAlignment:NSTextAlignmentLeft];
		[titleLabel setTextColor:[UIColor grayColor]];
		[titleLabel setFont:HelveticaNeue(16)];
		[titleLabel setBackgroundColor:[UIColor clearColor]];
		[mainScrollView addSubview:titleLabel];
		
		UITextField * valueTextField = [[UITextField alloc] initWithFrame:CGRectMake(25 + (dvc_width - 40) * 0.3, y + 1, (dvc_width - 40) * 0.68, 42)];
		[valueTextField setText:[theTime duration]];
		[valueTextField setTextAlignment:NSTextAlignmentRight];
		[valueTextField setTextColor:[UIColor darkGrayColor]];
		[valueTextField setFont:HelveticaNeue(16)];
		[valueTextField setBackgroundColor:[UIColor clearColor]];
		valueTextField.layer.sublayerTransform = CATransform3DMakeTranslation(-1, 0, 0);
		[valueTextField setReturnKeyType:UIReturnKeyDone];
		[valueTextField setAutocapitalizationType:UITextAutocapitalizationTypeSentences];
		[valueTextField setAutocorrectionType:UITextAutocorrectionTypeYes];
		[valueTextField setDelegate:self];
		[valueTextField setTag:666];
		[mainScrollView addSubview:valueTextField];
	}
	
	// Subtotal
	{
		y += 42;
		
		UIImageView * bg = [[UIImageView alloc] initWithFrame:CGRectMake(10, y, dvc_width - 20, 42)];
		[bg setImage:[[UIImage imageNamed:@"tableMiddleCellWhite.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10]];
		[mainScrollView addSubview:bg];
		
		UILabel * titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, y, (dvc_width - 40) * 0.6, 42)];
		[titleLabel setText:@"Subtotal"];
		[titleLabel setTextAlignment:NSTextAlignmentLeft];
		[titleLabel setTextColor:[UIColor grayColor]];
		[titleLabel setFont:HelveticaNeue(16)];
		[titleLabel setBackgroundColor:[UIColor clearColor]];
		[mainScrollView addSubview:titleLabel];
		
		NSString *valueString = [data_manager currencyAdjustedValue:[theTime subtotal]];
		
		UITextField * valueTextField = [[UITextField alloc] initWithFrame:CGRectMake(25 + (dvc_width - 40) * 0.3, y + 1, (dvc_width - 40) * 0.68, 42)];
		[valueTextField setText:valueString];
		[valueTextField setTextAlignment:NSTextAlignmentRight];
		[valueTextField setTextColor:[UIColor darkGrayColor]];
		[valueTextField setFont:HelveticaNeue(16)];
		[valueTextField setBackgroundColor:[UIColor clearColor]];
		[valueTextField setReturnKeyType:UIReturnKeyDone];
		[valueTextField setAutocapitalizationType:UITextAutocapitalizationTypeSentences];
		[valueTextField setAutocorrectionType:UITextAutocorrectionTypeYes];
		valueTextField.layer.sublayerTransform = CATransform3DMakeTranslation(-1, 0, 0);
		[valueTextField setDelegate:self];
		[valueTextField setTag:777];
		[mainScrollView addSubview:valueTextField];
	}
	
	// Discount
	{
		y += 42;
		
		NSString *titleString = [NSString stringWithFormat:@"Discount (%@%c)",[data_manager valueAdjusted:[theTime discountShowPercentage]],'%'];
		NSString *valueString = [NSString stringWithFormat:@"%@",[data_manager currencyAdjustedValue:[theTime discountPercentage]]];
				
		UIImageView * bg = [[UIImageView alloc] initWithFrame:CGRectMake(10, y, dvc_width - 20, 42)];
		[bg setImage:[[UIImage imageNamed:@"tableMiddleCellWhite.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10]];
		[mainScrollView addSubview:bg];
		
		UILabel * titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, y, (dvc_width - 40) * 0.6, 42)];
		[titleLabel setText:titleString];
		[titleLabel setTextAlignment:NSTextAlignmentLeft];
		[titleLabel setTextColor:[UIColor grayColor]];
		[titleLabel setTag:-888];
		[titleLabel setFont:HelveticaNeue(16)];
		[titleLabel setBackgroundColor:[UIColor clearColor]];
		[mainScrollView addSubview:titleLabel];
		
		UITextField * valueTextField = [[UITextField alloc] initWithFrame:CGRectMake(25 + (dvc_width - 40) * 0.3, y + 1, (dvc_width - 40) * 0.68, 42)];
		[valueTextField setText:valueString];
		[valueTextField setTextAlignment:NSTextAlignmentRight];
		[valueTextField setTextColor:[UIColor darkGrayColor]];
		[valueTextField setFont:HelveticaNeue(16)];
		[valueTextField setBackgroundColor:[UIColor clearColor]];
		[valueTextField setReturnKeyType:UIReturnKeyDone];
		valueTextField.keyboardType = UIKeyboardTypeDecimalPad;
		[valueTextField setDelegate:self];
		valueTextField.layer.sublayerTransform = CATransform3DMakeTranslation(-1, 0, 0);
		[valueTextField setTag:888];
		[mainScrollView addSubview:valueTextField];
	}
	
	// Total
	{
		y += 42;
				
		UIImageView * bg = [[UIImageView alloc] initWithFrame:CGRectMake(10, y, dvc_width - 20, 42)];
		[bg setImage:[[UIImage imageNamed:@"tableBottomCellWhite.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10]];
		[mainScrollView addSubview:bg];
		
		UILabel * titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, y, (dvc_width - 40) * 0.6, 42)];
		[titleLabel setText:@"Total"];
		[titleLabel setTextAlignment:NSTextAlignmentLeft];
		[titleLabel setTextColor:[UIColor grayColor]];
		[titleLabel setFont:HelveticaNeue(16)];
		[titleLabel setBackgroundColor:[UIColor clearColor]];
		[mainScrollView addSubview:titleLabel];
		
		UITextField * valueTextField = [[UITextField alloc] initWithFrame:CGRectMake(25 + (dvc_width - 40) * 0.3, y + 1, (dvc_width - 40) * 0.68, 42)];
		[valueTextField setText:[data_manager currencyAdjustedValue:[theTime getTotal]]];
		[valueTextField setTextAlignment:NSTextAlignmentRight];
		[valueTextField setTextColor:[UIColor darkGrayColor]];
		[valueTextField setFont:HelveticaNeue(16)];
		[valueTextField setBackgroundColor:[UIColor clearColor]];
		[valueTextField setReturnKeyType:UIReturnKeyDone];
		valueTextField.keyboardType = UIKeyboardTypeDecimalPad;
		[valueTextField setDelegate:self];
		valueTextField.layer.sublayerTransform = CATransform3DMakeTranslation(-1, 0, 0);
		[valueTextField setTag:999];
		[mainScrollView addSubview:valueTextField];
	}
	
	theToolbar = [[ToolBarView alloc] initWithFrame:CGRectMake(0, (dvc_height + 20), dvc_width, 40)];
	[theToolbar.prevButton setAlpha:0.0];
	[theToolbar.nextButton setAlpha:0.0];
	[theToolbar.doneButton addTarget:self action:@selector(closePicker:) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:theToolbar];
	
	percentage = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
	[percentage setTitle:[NSString stringWithFormat:@"%c", '%'] forState:UIControlStateNormal];
	[percentage setTitleColor:app_tab_selected_color forState:UIControlStateSelected];
	[percentage setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	[percentage.titleLabel setFont:HelveticaNeueLight(17)];
	[percentage addTarget:self action:@selector(percentage:) forControlEvents:UIControlEventTouchUpInside];
	[theToolbar addSubview:percentage];
	
	value = [[UIButton alloc] initWithFrame:CGRectMake(40, 0, 40, 40)];
	[value setTitle:[NSString stringWithFormat:@"%@", [data_manager currency]] forState:UIControlStateNormal];
	[value setTitleColor:app_tab_selected_color forState:UIControlStateSelected];
	[value setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	[value.titleLabel setFont:HelveticaNeueLight(17)];
	[value setSelected:YES];
	[value addTarget:self action:@selector(value:) forControlEvents:UIControlEventTouchUpInside];
	[theToolbar addSubview:value];
	
	[self.view addSubview:topBarView];
}

#pragma mark
#pragma mark PICKERS

-(void)openPicker
{
	percentage.alpha = 0.0;
	value.alpha = 0.0;
	
	[(UITextField*)[theSelfView viewWithTag:111] resignFirstResponder];
	[(UITextField*)[theSelfView viewWithTag:222] resignFirstResponder];
	[(UITextField*)[theSelfView viewWithTag:333] resignFirstResponder];
	[(UITextField*)[theSelfView viewWithTag:444] resignFirstResponder];
	[(UITextField*)[theSelfView viewWithTag:555] resignFirstResponder];
	[(UITextField*)[theSelfView viewWithTag:666] resignFirstResponder];
	[(UITextField*)[theSelfView viewWithTag:777] resignFirstResponder];
	[(UITextField*)[theSelfView viewWithTag:888] resignFirstResponder];
	[(UITextField*)[theSelfView viewWithTag:999] resignFirstResponder];
	[(UITextField*)[theSelfView viewWithTag:1000] resignFirstResponder];
	
	UIButton * closeAll = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, dvc_width, dvc_height)];
	[closeAll setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.2]];
	[closeAll addTarget:self action:@selector(closePicker:) forControlEvents:UIControlEventTouchUpInside];
	[closeAll setTag:123123];
	[self.view addSubview:closeAll];
	[self.view bringSubviewToFront:theToolbar];
	
	[[self.navigationController.view viewWithTag:101010] removeFromSuperview];
	
	UIView * viewWithPicker = [[UIView alloc] initWithFrame:CGRectMake(0, (dvc_height + 20) + 60, dvc_width, keyboard_height)];
	[viewWithPicker setBackgroundColor:[UIColor clearColor]];
	[viewWithPicker setTag:101010];
	[viewWithPicker.layer setMasksToBounds:YES];
	[self.navigationController.view addSubview:viewWithPicker];
	
	UIView * picker;
	
	switch (picker_type)
	{
		case kPickerTypeStart:
		{
			picker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 0, dvc_width, keyboard_height)];
			[picker setCenter:CGPointMake(dvc_width / 2, keyboard_height / 2)];
			[(UIDatePicker*)picker setDatePickerMode:UIDatePickerModeTime];
			[(UIDatePicker*)picker setMinuteInterval:5];
			picker.backgroundColor = [UIColor whiteColor];
			[picker setTag:989898];
			[viewWithPicker addSubview:picker];
			
			[(UIDatePicker*)picker setDate:[theTime startTime]];
			
			break;
		}
			
		case kPickerTypeFinish:
		{
			picker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 0, dvc_width, keyboard_height)];
			[picker setCenter:CGPointMake(dvc_width / 2, keyboard_height / 2)];
			[(UIDatePicker*)picker setDatePickerMode:UIDatePickerModeTime];
			[(UIDatePicker*)picker setMinuteInterval:5];
			picker.backgroundColor = [UIColor whiteColor];
			[picker setTag:989898];
			[viewWithPicker addSubview:picker];
			
			[(UIDatePicker*)picker setDate:[theTime finishTime]];
			
			break;
		}
			
		case kPickerTypeBreak:
		{
			picker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 0, dvc_width, keyboard_height)];
			[picker setCenter:CGPointMake(dvc_width / 2, keyboard_height / 2)];
			[(UIPickerView*)picker setDataSource:self];
			[(UIPickerView*)picker setDelegate:self];
			[picker setTag:989898];
			[viewWithPicker addSubview:picker];
			
			[(UIPickerView*)picker selectRow:[theTime breakHours] inComponent:0 animated:YES];
			[(UIPickerView*)picker selectRow:[theTime breakMinutes] / 5 inComponent:1 animated:YES];
			
			break;
		}
			
		case kPickerTypeOvertime:
		{
			picker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 0, dvc_width, keyboard_height)];
			[picker setCenter:CGPointMake(dvc_width / 2, keyboard_height / 2)];
			[(UIPickerView*)picker setDataSource:self];
			[(UIPickerView*)picker setDelegate:self];
			[picker setTag:989898];
			[viewWithPicker addSubview:picker];
			
			[(UIPickerView*)picker selectRow:[theTime overtimeHours] inComponent:0 animated:YES];
			[(UIPickerView*)picker selectRow:[theTime overtimeMinuts] / 5 inComponent:1 animated:YES];
			
			break;
		}
			
		case kPickerTypeDate:
		{
			picker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 0, dvc_width, keyboard_height)];
			[picker setCenter:CGPointMake(dvc_width / 2, keyboard_height / 2)];
			[(UIDatePicker*)picker setDatePickerMode:UIDatePickerModeDate];
			[(UIPickerView*)picker setDelegate:self];
			[picker setTag:989898];
			[viewWithPicker addSubview:picker];
			
			[(UIDatePicker*)picker setDate:[theTime date]];
		}
						
		default:
			break;
	}
	
	[picker setBackgroundColor:[UIColor whiteColor]];
	
	if (iPad)
	{
		[picker setTransform:CGAffineTransformMakeScale(1.0, (float)(keyboard_height) / 216.0f)];
	}
	
	[UIView animateWithDuration:0.25 animations:^{
		
		[viewWithPicker setFrame:CGRectMake(0, (dvc_height + 20) - keyboard_height + 20, dvc_width, keyboard_height)];
		[theToolbar setFrame:CGRectMake(0, (dvc_height + 40) - keyboard_height - 40, dvc_width, 40)];
		
	}];
}

-(void)closePicker:(UIButton*)sender
{
	pickerAppeared = 0;
	
	UIView * daPicker = [self.navigationController.view viewWithTag:989898];
	
	if (!daPicker)
	{
		[(UITextField*)[self.view viewWithTag:888] resignFirstResponder];
		
		return;
	}
	
	switch (picker_type)
	{
		case kPickerTypeStart:
		{
			NSDate * temp = [theTime startTime];
			
			if ([daPicker isKindOfClass:[UIDatePicker class]])
				[theTime setStartTime:[(UIDatePicker*)daPicker date]];
			
			if ([theTime.startTime timeIntervalSinceDate:theTime.finishTime] > 0)
				[theTime setStartTime:temp];
			
			[date_formatter setDateFormat:@"hh:mm a"];
			[(UITextField*)[theSelfView viewWithTag:222] setText:[date_formatter stringFromDate:[theTime startTime]]];
			
			if([theTime totalTimeInSeconds] < 0)
			{
				[theTime setBreakTime:0.0];
				[(UITextField*)[self.view viewWithTag:444] setText:[theTime breakString]];
			}
			
			[data_manager saveServiceTimeToUserDefaults:theTime forKey:kDefaultServiceTime];
			
			break;
		}
			
		case kPickerTypeFinish:
		{
			NSDate * temp = [theTime finishTime];
			
			if ([daPicker isKindOfClass:[UIDatePicker class]])
				[theTime setFinishTime:[(UIDatePicker*)daPicker date]];
			
			if ([theTime.startTime timeIntervalSinceDate:theTime.finishTime] > 0)
				[theTime setFinishTime:temp];
			
			[date_formatter setDateFormat:@"hh:mm a"];
			[(UITextField*)[theSelfView viewWithTag:333] setText:[date_formatter stringFromDate:[theTime finishTime]]];
			
			if([theTime totalTimeInSeconds] < 0)
			{
				[theTime setBreakTime:0.0];
				[(UITextField*)[self.view viewWithTag:444] setText:[theTime breakString]];
			}
			
			[data_manager saveServiceTimeToUserDefaults:theTime forKey:kDefaultServiceTime];
			
			break;
		}
			
		case kPickerTypeBreak:
		{
			
			[(UITextField*)[theSelfView viewWithTag:444] setText:[theTime breakString]];
			
			[data_manager saveServiceTimeToUserDefaults:theTime forKey:kDefaultServiceTime];
			
			break;
		}
			
		case kPickerTypeOvertime:
		{
			[(UITextField*)[theSelfView viewWithTag:555] setText:[theTime overtimeString]];
						
			if([theTime totalTimeInSeconds] < 0)
			{
				[theTime setBreakTime:0.0];
				
				[(UITextField*)[self.view viewWithTag:444] setText:[theTime breakString]];
			}
			
			[data_manager saveServiceTimeToUserDefaults:theTime forKey:kDefaultServiceTime];
			
			break;
		}
			
		case kPickerTypeDate:
		{
			[theTime setDate:[(UIDatePicker*)daPicker date]];
			
			[date_formatter setDateFormat:[DELEGATE userSelectedDateFormat]];
			
			[(UITextField*)[theSelfView viewWithTag:1000] setText:[date_formatter stringFromDate:[theTime date]]];
			
			[data_manager saveServiceTimeToUserDefaults:theTime forKey:kDefaultServiceTime];
			
			break;
		}
			
		default:
			break;
	}
	
	[(UITextField*)[theSelfView viewWithTag:666] setText:[theTime duration]];
		
	if([theTime isPercentage] == YES)
	{
		[theTime adjustDiscount];
	}
	
	[(UITextField*)[self.view viewWithTag:777] setText:[data_manager currencyAdjustedValue:[theTime subtotal]]];
	[(UITextField*)[self.view viewWithTag:999] setText:[data_manager currencyAdjustedValue:[theTime getTotal]]];
	
	NSString *titleString = [NSString stringWithFormat:@"Discount (%@%c)",[data_manager valueAdjusted:[theTime discountShowPercentage]],'%'];
	NSString *valueString = [NSString stringWithFormat:@"%@",[data_manager currencyAdjustedValue:[theTime discountPercentage]]];
	
	[(UITextField*)[self.view viewWithTag:-888] setText:titleString];
	[(UITextField*)[self.view viewWithTag:888] setText:valueString];
	
	[UIView animateWithDuration:0.25 animations:^{
		
		[[self.navigationController.view viewWithTag:101010] setFrame:CGRectMake(0, (dvc_height + 20) + 60, dvc_width, keyboard_height)];
		[theToolbar setFrame:CGRectMake(0, (dvc_height + 40), dvc_width, 40)];
		
	} completion:^(BOOL finished) {
		
		[[self.navigationController.view viewWithTag:101010] removeFromSuperview];
		
		[[self.view viewWithTag:123123] removeFromSuperview];
		
	}];
}

#pragma mark
#pragma mark PICKERVIEW DELEGATE

-(NSString*)pickerView:(UIPickerView*)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
	NSString * titleString = @"";
	
	switch (component)
	{
		case 0:
		{
			titleString = [NSString stringWithFormat:@"%ld hours", (long)row];
			
			break;
		}
			
		case 1:
		{
			titleString = [NSString stringWithFormat:@"%ld minutes", (long)row * 5];
			
			break;
		}
			
		default:
			break;
	}
	
	return titleString;
}

-(void)pickerView:(UIPickerView*)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
	NSTimeInterval temp = [theTime breakTime];
	
	switch (component)
	{
		case 0:
		{
			if(picker_type == kPickerTypeBreak)
				[theTime setBreakTime:(row * 3600) + ([theTime breakMinutes] * 60)];
			else
				[theTime setOvertime:(row * 3600) + ([theTime overtimeMinuts] * 60)];
			
			break;
		}
			
		case 1:
		{
			if(picker_type == kPickerTypeBreak)
				[theTime setBreakTime:((row * 5) * 60) + ([theTime breakHours] * 3600)];
			else
				[theTime setOvertime:((row * 5) * 60) + ([theTime overtimeHours] * 3600)];
			
			break;
		}
			
		default:
			break;
	}
		
	if(picker_type == kPickerTypeBreak)
	{
		if ([theTime totalTimeInSeconds] >= 0)
		{
			[(UITextField*)[theSelfView viewWithTag:444] setText:[theTime breakString]];
			[(UITextField*)[theSelfView viewWithTag:666] setText:[theTime duration]];
		}
		else
		{
			[theTime setBreakTime:temp];
			
			[pickerView selectRow:[theTime breakHours] inComponent:0 animated:YES];
			[pickerView selectRow:[theTime breakMinutes] / 5 inComponent:1 animated:YES];
		}
	}
	
	if([theTime isPercentage] == YES)
	{
		[theTime adjustDiscount];
	}
	
	[(UITextField*)[self.view viewWithTag:777] setText:[data_manager currencyAdjustedValue:[theTime subtotal]]];
	[(UITextField*)[self.view viewWithTag:999] setText:[data_manager currencyAdjustedValue:[theTime getTotal]]];
	
	NSString *titleString = [NSString stringWithFormat:@"Discount (%@%c)",[data_manager valueAdjusted:[theTime discountShowPercentage]],'%'];
	NSString *valueString = [NSString stringWithFormat:@"%@",[data_manager currencyAdjustedValue:[theTime discountPercentage]]];
	
	[(UITextField*)[self.view viewWithTag:-888] setText:titleString];
	[(UITextField*)[self.view viewWithTag:888] setText:valueString];
	
	[data_manager saveServiceTimeToUserDefaults:theTime forKey:kDefaultServiceTime];
}

#pragma mark
#pragma mark PICKERVIEW DATASOURCE

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView*)pickerView
{
	return 2;
}

-(NSInteger)pickerView:(UIPickerView*)pickerView numberOfRowsInComponent:(NSInteger)component
{
	NSInteger rows = 0;
	
	switch (component)
	{
		case 0:
		{
			rows = 9;
			break;
		}
			
		case 1:
		{
			rows = 12;
			break;
		}
			
		default:
			break;
	}
	
	return rows;
}

#pragma mark
#pragma mark TEXTVIEW DELEGATE

-(void)closeTextView:(UIButton*)sender
{
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
	if(pickerAppeared == 1)
		return NO;
	
	pickerAppeared = 1;
	
	switch (textField.tag)
	{
		case 111:
		{
			ProductsVC *vc = [[ProductsVC alloc] init];
      vc.delegate = self;
			[self.navigationController pushViewController:vc animated:YES];
			
			break;
		}
			
		case 222:
		{
			picker_type = kPickerTypeStart;
			[self openPicker];
			
			break;
		}
			
		case 333:
		{
			picker_type = kPickerTypeFinish;
			[self openPicker];
			
			break;
		}
			
		case 444:
		{
			picker_type = kPickerTypeBreak;
			[self openPicker];
			
			break;
		}
			
		case 555:
		{
			picker_type = kPickerTypeOvertime;
			[self openPicker];
			
			break;
		}

		case 888:
		{
			textField.text = @"";
			
			percentage.alpha = 1.0;
			value.alpha = 1.0;
			
			[UIView animateWithDuration:0.25 animations:^{
				
				[theToolbar setFrame:CGRectMake(0, dvc_height - keyboard_height - 20, dvc_width, 40)];
				
				if(dvc_width == 320)
				{
					[mainScrollView setFrame:CGRectMake(mainScrollView.frame.origin.x, mainScrollView.frame.origin.y, dvc_width, dvc_height - 80 - keyboard_height)];
					[mainScrollView setContentOffset:CGPointMake(0, dvc_height - 65 - keyboard_height)];
					
					if (mainScrollView && [mainScrollView respondsToSelector:@selector(didScroll)])
						[mainScrollView didScroll];
				}
				
			} completion:^(BOOL finished) {
				
				[mainScrollView setScrollEnabled:NO];
				
			}];
						
			return YES;
			
			break;
		}
			
		case 1000:
		{
			picker_type = kPickerTypeDate;
			[self openPicker];
			
			break;
		}
						
		default:
		{
			pickerAppeared = 0;
			
			break;
		}
	}
	
	return NO;
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{	
	if(textField.tag == 888)
	{
		[mainScrollView setScrollEnabled:YES];
		
		if(percentage.selected)
		{			
			[theTime setIsPercentage:YES];
			
			float total = [theTime subtotal];
			float percent = (total * [textField.text floatValue] / 100);
			
			[theTime setDiscountPercentage:percent];
		}
		else
		{
			[theTime setIsPercentage:NO];
			
			[theTime setDiscountPercentage:[textField.text floatValue]];
		}
		
		NSString *titleLabel = [NSString stringWithFormat:@"Discount (%@%c)",[data_manager valueAdjusted:[theTime discountShowPercentage]],'%'];
		NSString *valueString = [NSString stringWithFormat:@"%@",[data_manager currencyAdjustedValue:[theTime discountPercentage]]];
		
		[(UITextField*)[self.view viewWithTag:888] setText:valueString];
		[(UITextField*)[self.view viewWithTag:-888] setText:titleLabel];
		
		[(UITextField*)[self.view viewWithTag:999] setText:[data_manager currencyAdjustedValue:[theTime getTotal]]];
	}
	
	[UIView animateWithDuration:0.25 animations:^{
		
		[theToolbar setFrame:CGRectMake(0, dvc_height + 20, dvc_width, 40)];
		
		[mainScrollView setFrame:CGRectMake(mainScrollView.frame.origin.x, mainScrollView.frame.origin.y, dvc_width, dvc_height - 42)];
		if (mainScrollView && [mainScrollView respondsToSelector:@selector(didScroll)])
			[mainScrollView didScroll];
		
	} completion:^(BOOL finished) {
		
		percentage.alpha = 0.0;
		value.alpha = 0.0;
	}];
	
	[data_manager saveServiceTimeToUserDefaults:theTime forKey:kDefaultServiceTime];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[textField resignFirstResponder];
	return YES;
}

#pragma mark
#pragma mark SELECT PRODUCT / SERVICE DELEGATE

-(void)viewController:(ProductsVC *)vc selectedProduct:(ProductOBJ *)sender
{
	[sender setQuantity:1.0];
	
	[theTime setProduct:sender];
	[data_manager saveServiceTimeToUserDefaults:theTime forKey:kDefaultServiceTime];
			
	if([theTime isPercentage] == YES)
	{
		[theTime adjustDiscount];
	}
	
	NSString *valueString = [data_manager currencyAdjustedValue:[theTime subtotal]];
		
	[(UITextField*)[self.view viewWithTag:111] setText:[[theTime product] name]];
	[(UITextField*)[self.view viewWithTag:777] setText:valueString];
		
	NSString *discountTitleString = [NSString stringWithFormat:@"Discount (%@%c)",[data_manager valueAdjusted:[theTime discountShowPercentage]],'%'];
	NSString *discountValueString = [data_manager currencyAdjustedValue:[theTime discountPercentage]];
	
	[(UITextField*)[self.view viewWithTag:888] setText:discountValueString];
	[(UITextField*)[self.view viewWithTag:-888] setText:discountTitleString];
	
	[(UITextField*)[self.view viewWithTag:999] setText:[data_manager currencyAdjustedValue:[theTime getTotal]]];
}

-(void)viewController:(ProductsVC *)vc selectedService:(ServiceOBJ *)sender
{
	[sender setQuantity:1.0];
	
	[theTime setProduct:[[ProductOBJ alloc] initWithContentsDictionary:[sender contentsDictionary]]];
	[data_manager saveServiceTimeToUserDefaults:theTime forKey:kDefaultServiceTime];

	if([theTime isPercentage] == YES)
	{
		[theTime adjustDiscount];
	}
	
	NSString *valueString = [data_manager currencyAdjustedValue:[theTime subtotal]];
		
	[(UITextField*)[self.view viewWithTag:111] setText:[[theTime product] name]];
	[(UITextField*)[self.view viewWithTag:777] setText:valueString];
			
	NSString *discountTitleString = [NSString stringWithFormat:@"Discount (%@%c)",[data_manager valueAdjusted:[theTime discountShowPercentage]],'%'];
	NSString *discountValueString = [data_manager currencyAdjustedValue:[theTime discountPercentage]];
	
	[(UITextField*)[self.view viewWithTag:888] setText:discountValueString];
	[(UITextField*)[self.view viewWithTag:-888] setText:discountTitleString];
	
	[(UITextField*)[self.view viewWithTag:999] setText:[data_manager currencyAdjustedValue:[theTime getTotal]]];
}

#pragma mark - SCROLL VIEW DELEGATE

-(void)scrollViewDidScroll:(UIScrollView*)scrollView
{
	if (mainScrollView && [mainScrollView respondsToSelector:@selector(didScroll)])
		[mainScrollView didScroll];
}

#pragma mark
#pragma mark Actions

-(void)openProductServiceSelect:(UIButton*)button
{
	ProductsVC *vc = [[ProductsVC alloc] init];
  vc.delegate = self;
	[self.navigationController pushViewController:vc animated:YES];
}

-(void)percentage:(UIButton*)sender
{
	[percentage setSelected:YES];
	[value setSelected:NO];
}

-(void)value:(UIButton*)sender
{
	[percentage setSelected:NO];
	[value setSelected:YES];
}

-(void)cancel:(UIButton*)sender
{
	[self.navigationController popViewControllerAnimated:YES];
}

-(void)done:(UIButton*)sender
{
	[(UITextField*)[theSelfView viewWithTag:111] resignFirstResponder];
	[(UITextField*)[theSelfView viewWithTag:222] resignFirstResponder];
	[(UITextField*)[theSelfView viewWithTag:333] resignFirstResponder];
	[(UITextField*)[theSelfView viewWithTag:444] resignFirstResponder];
	[(UITextField*)[theSelfView viewWithTag:555] resignFirstResponder];
	[(UITextField*)[theSelfView viewWithTag:666] resignFirstResponder];
	[(UITextField*)[theSelfView viewWithTag:777] resignFirstResponder];
	[(UITextField*)[theSelfView viewWithTag:888] resignFirstResponder];
	[(UITextField*)[theSelfView viewWithTag:999] resignFirstResponder];
	[(UITextField*)[theSelfView viewWithTag:1000] resignFirstResponder];
		
	if([[[theTime product] name] isEqual:@""])
	{
		[[[AlertView alloc] initWithTitle:@"" message:@"Please select a product or service." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] showInWindow];
		
		return;
	}
		
	if (editorDelegate)
	{
		if ([editorDelegate respondsToSelector:@selector(editorViewController:editedTime:)])
		{
			[editorDelegate editorViewController:self editedTime:theTime];
		}
	}
	
	[self.navigationController popViewControllerAnimated:YES];
}

-(void)dealloc
{
	[mainScrollView setDelegate:nil];
}

@end
