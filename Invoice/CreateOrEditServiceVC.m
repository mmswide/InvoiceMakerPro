//
//  CreateOrEditServiceVC.m
//  Invoice
//
//  Created by XGRoup5 on 8/19/13.
//  Copyright (c) 2013 XGRoup. All rights reserved.
//

#import "CreateOrEditServiceVC.h"

#import "Defines.h"
#import "AddServiceDescriptionVC.h"
#define DESCRIPTION_VIEW_HEIGHT 210

@interface CreateOrEditServiceVC () <UITextFieldDelegate, UITextViewDelegate, AlertViewDelegate>

@end

@implementation CreateOrEditServiceVC

@synthesize delegate;

-(id)initWithService:(ServiceOBJ*)sender index:(NSInteger)i delegate:(id<ServiceCreatorDelegate>)del
{
	self = [super init];
	
	if (self)
	{
		delegate = del;
		
		titleString = @"New Service";
		index = i;
		
		if (sender)
		{
			titleString = @"Edit Service";
			
			theService = [[ServiceOBJ alloc] initWithService:sender];
		}
		else
		{
			index = -1;
			theService = [[ServiceOBJ alloc] init];
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
	
	topBarView = [[TopBar alloc] initWithFrame:CGRectMake(0, 0, dvc_width, 42 + statusBarHeight) andTitle:titleString];
	[topBarView setBackgroundColor:app_bar_update_color];
	
	UIButton * cancel = [[UIButton alloc] initWithFrame:CGRectMake(0, 42 + statusBarHeight - 40, 80, 40)];
	[cancel setTitle:@"Cancel" forState:UIControlStateNormal];
	[cancel setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[cancel setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
	[cancel.titleLabel setFont:HelveticaNeueLight(17)];
	[cancel addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
	[topBarView addSubview:cancel];
	
	UIButton * done = [[UIButton alloc] initWithFrame:CGRectMake(dvc_width - 60, 42 + statusBarHeight - 40, 60, 40)];
	[done setTitle:@"Done" forState:UIControlStateNormal];
	[done setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[done setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
	[done.titleLabel setFont:HelveticaNeueLight(17)];
	[done addTarget:self action:@selector(done:) forControlEvents:UIControlEventTouchUpInside];
	[topBarView addSubview:done];
	
	mainScrollView = (ScrollWithShadow *)[[UIScrollView alloc] initWithFrame:CGRectMake(0, 42, dvc_width, theSelfView.frame.size.height - 42)];
	[mainScrollView setBackgroundColor:[UIColor clearColor]];
	[theSelfView addSubview:mainScrollView];
	
	//NAME
	{
		UIImageView * fieldBG = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, dvc_width - 20, 42)];
		[fieldBG setImage:[[UIImage imageNamed:@"tableSingleCellWhite.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10]];
		[mainScrollView addSubview:fieldBG];
		
		UILabel * fieldTitle = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, 60, 42)];
		[fieldTitle setText:@"Name"];
		[fieldTitle setTextAlignment:NSTextAlignmentLeft];
		[fieldTitle setTextColor:[UIColor grayColor]];
		[fieldTitle setFont:HelveticaNeue(16)];
		[fieldTitle setBackgroundColor:[UIColor clearColor]];
		[mainScrollView addSubview:fieldTitle];
		
		nameTextField = [[UITextField alloc] initWithFrame:CGRectMake(90, 10, (dvc_width - 20) - 100, 42)];
		[nameTextField setText:[theService name]];
		[nameTextField setTextAlignment:NSTextAlignmentRight];
		[nameTextField setTextColor:[UIColor clearColor]];
		[nameTextField setFont:HelveticaNeue(15)];
		[nameTextField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
		[nameTextField setBackgroundColor:[UIColor clearColor]];
		[nameTextField setDelegate:self];
		[nameTextField setAutocapitalizationType:UITextAutocapitalizationTypeWords];
		[nameTextField setAutocorrectionType:UITextAutocorrectionTypeDefault];
		[nameTextField setReturnKeyType:UIReturnKeyNext];
		[mainScrollView addSubview:nameTextField];
		
		nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(90, 5, (dvc_width - 20) - 100, 52)];
		[nameLabel setText:[theService name]];
		[nameLabel setTextAlignment:NSTextAlignmentRight];
		[nameLabel setTextColor:[UIColor darkGrayColor]];
		[nameLabel setFont:HelveticaNeue(15)];
		[nameLabel setBackgroundColor:[UIColor clearColor]];
		[nameLabel setNumberOfLines:2];
		[nameLabel setUserInteractionEnabled:NO];
		[mainScrollView addSubview:nameLabel];
	}
	
	//RATE
	{
		UIImageView * fieldBG = [[UIImageView alloc] initWithFrame:CGRectMake(10, 72, dvc_width - 20, 42)];
		[fieldBG setImage:[[UIImage imageNamed:@"tableTopCellWhite.png"] stretchableImageWithLeftCapWidth:20 topCapHeight:15]];
		[mainScrollView addSubview:fieldBG];
		
		UILabel * fieldTitle = [[UILabel alloc] initWithFrame:CGRectMake(20, 72, (dvc_width - 40) / 2, 42)];
		[fieldTitle setText:@"Rate"];
		[fieldTitle setTextAlignment:NSTextAlignmentLeft];
		[fieldTitle setTextColor:[UIColor grayColor]];
		[fieldTitle setFont:HelveticaNeue(16)];
		[fieldTitle setBackgroundColor:[UIColor clearColor]];
		[mainScrollView addSubview:fieldTitle];
		
		rateTextField = [[UITextField alloc] initWithFrame:CGRectMake(dvc_width / 2, 72, (dvc_width - 40) / 2, 42)];
		[rateTextField setText:[data_manager currencyAdjustedValue:[theService price]]];
		[rateTextField setTextAlignment:NSTextAlignmentRight];
		[rateTextField setTextColor:[UIColor darkGrayColor]];
		[rateTextField setFont:HelveticaNeue(15)];
		[rateTextField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
		[rateTextField setBackgroundColor:[UIColor clearColor]];
		[rateTextField setKeyboardType:UIKeyboardTypeDecimalPad];
		[rateTextField setDelegate:self];
		[mainScrollView addSubview:rateTextField];
	}
	
	//BILLING METHOD
	{
		UIImageView * fieldBG = [[UIImageView alloc] initWithFrame:CGRectMake(10, 114, dvc_width - 20, 42)];
		[fieldBG setImage:[[UIImage imageNamed:@"tableMiddleCellWhite.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10]];
		[mainScrollView addSubview:fieldBG];
		
		UILabel * fieldTitle = [[UILabel alloc] initWithFrame:CGRectMake(20, 114, (dvc_width - 40) / 2, 42)];
		[fieldTitle setText:@"Unit"];
		[fieldTitle setTextAlignment:NSTextAlignmentLeft];
		[fieldTitle setTextColor:[UIColor grayColor]];
		[fieldTitle setFont:HelveticaNeue(16)];
		[fieldTitle setBackgroundColor:[UIColor clearColor]];
		[mainScrollView addSubview:fieldTitle];
		
		unitTextField = [[UITextField alloc] initWithFrame:CGRectMake(dvc_width / 2, 114, (dvc_width - 40) / 2, 42)];
		[unitTextField setText:[theService unit]];
		[unitTextField setTextAlignment:NSTextAlignmentRight];
		[unitTextField setTextColor:[UIColor darkGrayColor]];
		[unitTextField setFont:HelveticaNeue(15)];
		[unitTextField setBackgroundColor:[UIColor clearColor]];
		[unitTextField setDelegate:self];
		[unitTextField setReturnKeyType:UIReturnKeyDone];
		[unitTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
		[unitTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
		[mainScrollView addSubview:unitTextField];
	}
	
	//TAXABLE
	{
		UIImageView * fieldBG = [[UIImageView alloc] initWithFrame:CGRectMake(10, 156, dvc_width - 20, 42)];
		[fieldBG setImage:[[UIImage imageNamed:@"tableBottomCellWhite.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10]];
		[mainScrollView addSubview:fieldBG];
		
		UILabel * fieldTitle = [[UILabel alloc] initWithFrame:CGRectMake(20, 156, (dvc_width - 40) / 2, 42)];
		[fieldTitle setText:@"Taxable"];
		[fieldTitle setTextAlignment:NSTextAlignmentLeft];
		[fieldTitle setTextColor:[UIColor grayColor]];
		[fieldTitle setFont:HelveticaNeue(16)];
		[fieldTitle setBackgroundColor:[UIColor clearColor]];
		[mainScrollView addSubview:fieldTitle];
		
		UISwitch * isTaxable = [[UISwitch alloc] initWithFrame:CGRectZero];
		[isTaxable setOn:[theService taxable]];
		[isTaxable setFrame:CGRectMake(dvc_width - 20 - isTaxable.frame.size.width, 156 + (42 - isTaxable.frame.size.height) / 2, isTaxable.frame.size.width, isTaxable.frame.size.height)];
		[isTaxable addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
		[mainScrollView addSubview:isTaxable];
	}
	
	//DESCRIPTION
	{
		UIImageView * fieldBG = [[UIImageView alloc] initWithFrame:CGRectMake(10, 218, dvc_width - 20, 35 + DESCRIPTION_VIEW_HEIGHT)];
		[fieldBG setImage:[[UIImage imageNamed:@"tableSingleCellWhite.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10]];
		[mainScrollView addSubview:fieldBG];
		
		UILabel * fieldTitle = [[UILabel alloc] initWithFrame:CGRectMake(20, 228, (dvc_width - 40) / 2, 20)];
		[fieldTitle setText:@"Description"];
		[fieldTitle setTextAlignment:NSTextAlignmentLeft];
		[fieldTitle setTextColor:[UIColor grayColor]];
		[fieldTitle setFont:HelveticaNeue(16)];
		[fieldTitle setBackgroundColor:[UIColor clearColor]];
		[mainScrollView addSubview:fieldTitle];
		
		descriptionTextView = [[UITextView alloc] initWithFrame:CGRectMake(20, 253, dvc_width - 40, DESCRIPTION_VIEW_HEIGHT)];
		[descriptionTextView setText:[theService note]];
		[descriptionTextView setTextAlignment:NSTextAlignmentLeft];
		[descriptionTextView setTextColor:[UIColor darkGrayColor]];
		[descriptionTextView setFont:HelveticaNeue(15)];
		[descriptionTextView setBackgroundColor:[UIColor clearColor]];
//		[descriptionTextView setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
		[descriptionTextView setBackgroundColor:[UIColor clearColor]];
		[descriptionTextView setReturnKeyType:UIReturnKeyDone];
		[descriptionTextView setKeyboardType:UIKeyboardTypeDefault];
		[descriptionTextView setDelegate:self];
		[mainScrollView addSubview:descriptionTextView];
		
		descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 235, dvc_width - 40, 52)];
		[descriptionLabel setText:[theService note]];
		[descriptionLabel setTextAlignment:NSTextAlignmentLeft];
		[descriptionLabel setTextColor:[UIColor darkGrayColor]];
		[descriptionLabel setFont:HelveticaNeue(15)];
		[descriptionLabel setBackgroundColor:[UIColor clearColor]];
		[descriptionLabel setNumberOfLines:2];
		[descriptionLabel setUserInteractionEnabled:NO];
//		[mainScrollView addSubview:descriptionLabel];
		
//		UIButton * addDescription = [[UIButton alloc] initWithFrame:CGRectMake(20, 218, dvc_width - 40, 64)];
//		[addDescription setBackgroundColor:[UIColor clearColor]];
//		[addDescription addTarget:self action:@selector(addDescription:) forControlEvents:UIControlEventTouchUpInside];
//		[mainScrollView addSubview:addDescription];
		
		[mainScrollView setContentSize:CGSizeMake(mainScrollView.frame.size.width, fieldBG.frame.size.height + fieldBG.frame.origin.y + 20)];
	}
	
	theToolbar = [[ToolBarView alloc] initWithFrame:CGRectMake(0, dvc_height, dvc_width, 40)];
	[theToolbar.prevButton addTarget:self action:@selector(prev:) forControlEvents:UIControlEventTouchUpInside];
	[theToolbar.nextButton addTarget:self action:@selector(next:) forControlEvents:UIControlEventTouchUpInside];
	[theToolbar.doneButton addTarget:self action:@selector(closePicker:) forControlEvents:UIControlEventTouchUpInside];
	[theSelfView addSubview:theToolbar];
	
	[self.view addSubview:topBarView];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [descriptionTextView setText:[theService note]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardFrameChanged:) name:UIKeyboardDidChangeFrameNotification object:nil];
}

#pragma mark - FUNCTIONS

-(void)cancel:(UIButton*)sender
{
	[self dismissViewControllerAnimated:YES completion:nil];
}

-(void)done:(UIButton*)sender
{
	[nameTextField resignFirstResponder];
	[rateTextField resignFirstResponder];
	[unitTextField resignFirstResponder];
	[descriptionTextView resignFirstResponder];
	
	if ([[theService name] isEqual:@""])
	{
		[[[AlertView alloc] initWithTitle:@"The service must have a name." message:@"" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] showInWindow];
		return;
	}
	
//	if ([theService price] == 0)
//	{
//		[[[AlertView alloc] initWithTitle:@"The service's price cannot be 0." message:@"" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] showInWindow];
//		return;
//	}
	
	if (index < 0)
	{
		if (delegate && [delegate respondsToSelector:@selector(creatorViewController:createdService:)])
		{
			[delegate creatorViewController:self createdService:theService];
		}
	}
	else
	{
		if (delegate && [delegate respondsToSelector:@selector(editorViewController:editedService:atIndex:)])
		{
			[delegate editorViewController:self editedService:theService atIndex:index];
		}
	}
	
	[self dismissViewControllerAnimated:YES completion:nil];
}

-(void)switchChanged:(UISwitch*)sender
{
	[theService setTaxable:sender.on];
}

-(void)addDescription:(UIButton*)sender
{
	AddServiceDescriptionVC * vc = [[AddServiceDescriptionVC alloc] initWithService:theService];
	[self.navigationController pushViewController:vc animated:YES];
}

-(void)prev:(UIButton*)sender
{
	if ([unitTextField isFirstResponder])
	{
		[rateTextField becomeFirstResponder];
	}
	else if ([rateTextField isFirstResponder])
	{
		[nameTextField becomeFirstResponder];
	}
}

-(void)next:(UIButton*)sender
{
	if ([nameTextField isFirstResponder])
	{
		[rateTextField becomeFirstResponder];
	}
	else if ([rateTextField isFirstResponder])
	{
		[unitTextField becomeFirstResponder];
	}
}

-(void)closePicker:(UIButton*)sender
{
	[nameTextField resignFirstResponder];
	[unitTextField resignFirstResponder];
	[rateTextField resignFirstResponder];
}

- (void)edjustContentWithheight:(CGFloat)height {
    another_textfield_takes_over = NO;
    
    [UIView animateWithDuration:0.25 animations:^{
        
        if(theToolbar.frame.origin.y >= dvc_height)
        {
            [theToolbar setFrame:CGRectMake(0, dvc_height - keyboard_height - 40, dvc_width, 40)];
        }
        
        [mainScrollView setFrame:CGRectMake(mainScrollView.frame.origin.x, mainScrollView.frame.origin.y, mainScrollView.frame.size.width, height)];
        
    }];
}

#pragma mark - TEXTFIELD DELEGATE

-(BOOL)textFieldShouldReturn:(UITextField*)textField
{
	if ([textField isEqual:nameTextField])
	{
		[rateTextField becomeFirstResponder];
	}
	else if ([textField isEqual:rateTextField])
	{
		[unitTextField becomeFirstResponder];
	}
	
	[textField resignFirstResponder];
	return YES;
}

-(BOOL)textFieldShouldEndEditing:(UITextField*)textField
{
	if ([textField isEqual:nameTextField])
	{
		[theService setName:textField.text];
	}
	if ([textField isEqual:unitTextField])
	{
		[theService setUnit:textField.text];
		[textField setText:[theService unit]];
	}
	else if ([textField isEqual:rateTextField])
	{
		[theService setPrice:[textField.text floatValue]];
		[textField setText:[data_manager currencyAdjustedValue:[textField.text floatValue]]];
	}
	
    if (!another_textfield_takes_over)
    {
        [UIView animateWithDuration:0.25 animations:^{
            
            [mainScrollView setFrame:CGRectMake(mainScrollView.frame.origin.x, mainScrollView.frame.origin.y, mainScrollView.frame.size.width, (theSelfView.frame.size.height - 42))];
            [theToolbar setFrame:CGRectMake(0, dvc_height, dvc_width, 40)];
            
        }];
    }
    
	return YES;
}

-(void)textFieldDidEndEditing:(UITextField*)textField
{
	if ([textField isEqual:nameTextField])
	{
		[nameLabel setText:nameTextField.text];
		[nameLabel setTextColor:[UIColor darkGrayColor]];
		[nameTextField setTextColor:[UIColor clearColor]];
	}
}

-(void)textFieldDidBeginEditing:(UITextField*)textField
{
    CGFloat height = (theSelfView.frame.size.height - 42) - 40 - keyboard_height;
    
    [self edjustContentWithheight:height];
}

-(BOOL)textFieldShouldBeginEditing:(UITextField*)textField
{
	another_textfield_takes_over = YES;
	
	[theToolbar setAlpha:1.0];
	
	[theToolbar.prevButton setAlpha:1.0];
	[theToolbar.prevButton setUserInteractionEnabled:YES];
	
	[theToolbar.nextButton setAlpha:1.0];
	[theToolbar.nextButton setUserInteractionEnabled:YES];
	
	if ([textField isEqual:nameTextField])
	{
		[nameLabel setTextColor:[UIColor clearColor]];
		[nameTextField setTextColor:[UIColor darkGrayColor]];
		
		[theToolbar.prevButton setAlpha:0.5];
		[theToolbar.prevButton setUserInteractionEnabled:NO];
	}
	else if ([textField isEqual:rateTextField])
	{
		[textField setText:[data_manager currencyStrippedString:textField.text]];
		
		if ([textField.text floatValue] == 0.0f)
		{
			[textField setText:@""];
		}
	}
	else if ([textField isEqual:unitTextField])
	{
		[theToolbar.nextButton setAlpha:0.5];
		[theToolbar.nextButton setUserInteractionEnabled:NO];
		
		[textField setText:[theService rawUnit]];
	}
	
	return YES;
}

-(BOOL)textField:(UITextField*)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString*)string
{
	if ([textField isEqual:nameTextField])
	{
		NSString * result = [textField.text stringByReplacingCharactersInRange:range withString:string];
		
		if (result.length > 50)
			return NO;
	}
	else if ([textField isEqual:unitTextField])
	{
		NSString * result = [textField.text stringByReplacingCharactersInRange:range withString:string];
		
		if (result.length > 4)
			return NO;
	}
	
	return YES;
}

#pragma mark - UITextViewDelegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    [theToolbar setAlpha:1.0];
    
    [theToolbar.prevButton setAlpha:1.0];
    [theToolbar.prevButton setUserInteractionEnabled:YES];
    
    [theToolbar.nextButton setAlpha:1.0];
    [theToolbar.nextButton setUserInteractionEnabled:YES];
    
    if ([textView isEqual:descriptionTextView]) {
        [descriptionLabel setTextColor:[UIColor clearColor]];
        //        [descriptionTextView setTextColor:[UIColor darkGrayColor]];
        
        [theToolbar setAlpha:0.0];
    }
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
    if ([textView isEqual:descriptionTextView]) {
        [theService setNote:textView.text];
        
        [UIView animateWithDuration:0.25 animations:^{
            
            [mainScrollView setFrame:CGRectMake(mainScrollView.frame.origin.x, mainScrollView.frame.origin.y, mainScrollView.frame.size.width, (theSelfView.frame.size.height - 42))];
            [theToolbar setFrame:CGRectMake(0, dvc_height, dvc_width, 40)];
            
        }];
    }
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    CGFloat height = (theSelfView.frame.size.height - 42) - 40 - keyboard_height + theToolbar.frame.size.height;
    [self edjustContentWithheight:height];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        CGFloat offsetY = MIN(MAX(mainScrollView.contentSize.height - mainScrollView.frame.size.height, 0),
                              descriptionLabel.frame.origin.y - 20);
        CGPoint contentOffset = CGPointMake(0, offsetY);
        [mainScrollView setContentOffset:contentOffset animated:YES];
    });
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    if ([textView isEqual:descriptionTextView]) {
        [descriptionLabel setText:descriptionTextView.text];
        [descriptionLabel setTextColor:[UIColor darkGrayColor]];
        //        [descriptionTextView setTextColor:[UIColor clearColor]];
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    if ([textView isEqual:descriptionTextView]) {
        NSString * result = [textView.text stringByReplacingCharactersInRange:range withString:text];
        
        if (result.length > 450)
            return NO;
    }
    return YES;
}

#pragma mark - NSNotificationCenter

-(void)keyboardFrameChanged:(NSNotification*)notification
{
    NSDictionary* info = [notification userInfo];
    
    CGPoint to = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].origin;
    
    if(to.y == dvc_height + 20)
    {
        return;
    }
    
    [UIView animateWithDuration:0.25 animations:^{
        
        theToolbar.frame = CGRectMake(theToolbar.frame.origin.x, to.y - theToolbar.frame.size.height - 20, theToolbar.frame.size.width, theToolbar.frame.size.height);
        
        if(theToolbar.alpha == 0.0f)
        {
            [mainScrollView setFrame:CGRectMake(mainScrollView.frame.origin.x, mainScrollView.frame.origin.y, dvc_width, dvc_height - (dvc_height - to.y) - 47 - 14)];
        }
        else
        {
            [mainScrollView setFrame:CGRectMake(mainScrollView.frame.origin.x, mainScrollView.frame.origin.y, dvc_width, dvc_height - (dvc_height - to.y) - 87 - 14)];
        }
        
    } completion:^(BOOL finished) {
        
        
    }];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end