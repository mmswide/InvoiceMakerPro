//
//  CreateOrEditProductVC.m
//  Invoice
//
//  Created by XGRoup5 on 8/19/13.
//  Copyright (c) 2013 XGRoup. All rights reserved.
//

#import "CreateOrEditProductVC.h"

#import "Defines.h"
#import "AddProductDescriptionVC.h"
#import "ProductsVC.h"

#define ACCESSORY_SIZE 30.f
#define DESCRIPTION_VIEW_HEIGHT 210

@interface CreateOrEditProductVC () <UITextFieldDelegate, UITextViewDelegate, ProductOrServiceSelectorDelegate>

@end

@implementation CreateOrEditProductVC

@synthesize delegate;

-(id)initWithProduct:(ProductOBJ*)sender index:(NSInteger)i delegate:(id<ProductCreatorDelegate>)del {
	self = [super init];
	
	if (self) {
		delegate = del;
		index = i;
		
		titleString = @"New Product";
		
		if (sender) {
			titleString = @"Edit Product";
			
			theProduct = [[ProductOBJ alloc] initWithProduct:sender];
		} else {
			index = -1;
			theProduct = [[ProductOBJ alloc] init];
		}
	}
	
	return self;
}

#pragma mark - VIEW DID LOAD

-(void)viewDidLoad {
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
		[fieldTitle setFont:HelveticaNeue(15)];
		[fieldTitle setBackgroundColor:[UIColor clearColor]];
		[mainScrollView addSubview:fieldTitle];
    
		nameTextField = [[UITextField alloc] initWithFrame:CGRectMake(90, 10, (dvc_width - 20) - 100, 42)];
		[nameTextField setText:[theProduct name]];
		[nameTextField setTextAlignment:NSTextAlignmentRight];
		[nameTextField setTextColor:[UIColor clearColor]];
		[nameTextField setFont:HelveticaNeue(15)];
		[nameTextField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
		[nameTextField setBackgroundColor:[UIColor clearColor]];
		[nameTextField setReturnKeyType:UIReturnKeyNext];
		[nameTextField setAutocapitalizationType:UITextAutocapitalizationTypeWords];
		[nameTextField setAutocorrectionType:UITextAutocorrectionTypeDefault];
		[nameTextField setDelegate:self];
		[mainScrollView addSubview:nameTextField];
		
		nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(90, 5, (dvc_width - 20) - 100, 52)];
		[nameLabel setText:[theProduct name]];
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
		[rateTextField setText:[data_manager currencyAdjustedValue:[theProduct price]]];
		[rateTextField setTextAlignment:NSTextAlignmentRight];
		[rateTextField setTextColor:[UIColor darkGrayColor]];
		[rateTextField setFont:HelveticaNeue(15)];
		[rateTextField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
		[rateTextField setBackgroundColor:[UIColor clearColor]];
		[rateTextField setReturnKeyType:UIReturnKeyNext];
		[rateTextField setKeyboardType:UIKeyboardTypeDecimalPad];
		[rateTextField setDelegate:self];
		[mainScrollView addSubview:rateTextField];
	}
	
	//UNIT
	{
		UIImageView * fieldBG = [[UIImageView alloc] initWithFrame:CGRectMake(10, 114, dvc_width - 20, 42)];
		[fieldBG setImage:[[UIImage imageNamed:@"tableMiddleCellWhite.png"] stretchableImageWithLeftCapWidth:20 topCapHeight:15]];
		[mainScrollView addSubview:fieldBG];
		
		UILabel * fieldTitle = [[UILabel alloc] initWithFrame:CGRectMake(20, 114, (dvc_width - 40) / 2, 42)];
		[fieldTitle setText:@"Unit"];
		[fieldTitle setTextAlignment:NSTextAlignmentLeft];
		[fieldTitle setTextColor:[UIColor grayColor]];
		[fieldTitle setFont:HelveticaNeue(16)];
		[fieldTitle setBackgroundColor:[UIColor clearColor]];
		[mainScrollView addSubview:fieldTitle];
		
		unitTextField = [[UITextField alloc] initWithFrame:CGRectMake(dvc_width / 2, 114, (dvc_width - 40) / 2, 42)];
		[unitTextField setText:[theProduct unit]];
		[unitTextField setTextAlignment:NSTextAlignmentRight];
		[unitTextField setTextColor:[UIColor darkGrayColor]];
		[unitTextField setFont:HelveticaNeue(15)];
		[unitTextField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
		[unitTextField setBackgroundColor:[UIColor clearColor]];
		[unitTextField setReturnKeyType:UIReturnKeyNext];
		[unitTextField setKeyboardType:UIKeyboardTypeDefault];
		[unitTextField setDelegate:self];
		[mainScrollView addSubview:unitTextField];
	}
	
	//CODE
	{
		UIImageView * fieldBG = [[UIImageView alloc] initWithFrame:CGRectMake(10, 156, dvc_width - 20, 42)];
		[fieldBG setImage:[[UIImage imageNamed:@"tableMiddleCellWhite.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10]];
		[mainScrollView addSubview:fieldBG];
		
		UILabel * fieldTitle = [[UILabel alloc] initWithFrame:CGRectMake(20, 156, (dvc_width - 40) / 2, 42)];
		[fieldTitle setText:@"Code"];
		[fieldTitle setTextAlignment:NSTextAlignmentLeft];
		[fieldTitle setTextColor:[UIColor grayColor]];
		[fieldTitle setFont:HelveticaNeue(16)];
		[fieldTitle setBackgroundColor:[UIColor clearColor]];
		[mainScrollView addSubview:fieldTitle];
		
		codeTextField = [[UITextField alloc] initWithFrame:CGRectMake(dvc_width / 2, 156, (dvc_width - 40) / 2, 42)];
		[codeTextField setText:[theProduct code]];
		[codeTextField setTextAlignment:NSTextAlignmentRight];
		[codeTextField setTextColor:[UIColor darkGrayColor]];
		[codeTextField setFont:HelveticaNeue(15)];
		[codeTextField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
		[codeTextField setBackgroundColor:[UIColor clearColor]];
		[codeTextField setReturnKeyType:UIReturnKeyDone];
		[codeTextField setKeyboardType:UIKeyboardTypeDefault];
		[codeTextField setDelegate:self];
		[mainScrollView addSubview:codeTextField];
	}
	
	//TAXABLE
	{
		UIImageView * fieldBG = [[UIImageView alloc] initWithFrame:CGRectMake(10, 198, dvc_width - 20, 42)];
		[fieldBG setImage:[[UIImage imageNamed:@"tableBottomCellWhite.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10]];
		[mainScrollView addSubview:fieldBG];
		
		UILabel * fieldTitle = [[UILabel alloc] initWithFrame:CGRectMake(20, 198, (dvc_width - 40) / 2, 42)];
		[fieldTitle setText:@"Taxable"];
		[fieldTitle setTextAlignment:NSTextAlignmentLeft];
		[fieldTitle setTextColor:[UIColor grayColor]];
		[fieldTitle setFont:HelveticaNeue(16)];
		[fieldTitle setBackgroundColor:[UIColor clearColor]];
		[mainScrollView addSubview:fieldTitle];
		
		taxableSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
		[taxableSwitch setOn:[theProduct taxable]];
		[taxableSwitch setFrame:CGRectMake(dvc_width - 20 - taxableSwitch.frame.size.width, 198 + (42 - taxableSwitch.frame.size.height) / 2, taxableSwitch.frame.size.width, taxableSwitch.frame.size.height)];
		[taxableSwitch addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
		[mainScrollView addSubview:taxableSwitch];
	}
	
	//DESCRIPTION
	{
		UIImageView * fieldBG = [[UIImageView alloc] initWithFrame:CGRectMake(10, 260, dvc_width - 20, 35 + DESCRIPTION_VIEW_HEIGHT)];
		[fieldBG setImage:[[UIImage imageNamed:@"tableSingleCellWhite.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10]];
		[mainScrollView addSubview:fieldBG];
		
		UILabel * fieldTitle = [[UILabel alloc] initWithFrame:CGRectMake(20, 270, (dvc_width - 40) / 2, 20)];
		[fieldTitle setText:@"Description"];
		[fieldTitle setTextAlignment:NSTextAlignmentLeft];
		[fieldTitle setTextColor:[UIColor grayColor]];
		[fieldTitle setFont:HelveticaNeue(16)];
		[fieldTitle setBackgroundColor:[UIColor clearColor]];
		[mainScrollView addSubview:fieldTitle];
		
		descriptionTextView = [[UITextView alloc] initWithFrame:CGRectMake(20, 295, dvc_width - 40, DESCRIPTION_VIEW_HEIGHT)];
		[descriptionTextView setText:[theProduct note]];
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
		
		descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 277, dvc_width - 40, 52)];
		[descriptionLabel setText:[theProduct note]];
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
    
    [descriptionTextView setText:[theProduct note]];
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
	[codeTextField resignFirstResponder];
	[descriptionTextView resignFirstResponder];
	
	if ([[theProduct name] isEqual:@""])
	{
		[[[AlertView alloc] initWithTitle:@"The product must have a name." message:@"" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] showInWindow];
		return;
	}
	
//	if ([theProduct price] == 0)
//	{
//		[[[AlertView alloc] initWithTitle:@"The product's price cannot be 0." message:@"" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] showInWindow];
//		return;
//	}
//	
//	if ([[theProduct code] isEqual:@""])
//	{
//		[[[AlertView alloc] initWithTitle:@"The product must have a code." message:@"" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] showInWindow];
//		return;
//	}
	
	if (index < 0)
	{
		if (delegate && [delegate respondsToSelector:@selector(creatorViewController:createdObject:)])
		{
			[delegate creatorViewController:self createdObject:theProduct];
		}
	}
	else
	{
		if (delegate && [delegate respondsToSelector:@selector(editorViewController:editedObject:atIndex:)])
		{
			[delegate editorViewController:self editedObject:theProduct atIndex:index];
		}
	}
	
	[self dismissViewControllerAnimated:YES completion:nil];
}

-(void)switchChanged:(UISwitch*)sender
{
	[theProduct setTaxable:sender.on];
}

-(void)addDescription:(UIButton*)sender
{
	AddProductDescriptionVC * vc = [[AddProductDescriptionVC alloc] initWithProduct:theProduct];
	[self.navigationController pushViewController:vc animated:YES];
}

-(void)prev:(UIButton*)sender
{
	if ([rateTextField isFirstResponder])
	{
		[nameTextField becomeFirstResponder];
	}
	else if ([unitTextField isFirstResponder])
	{
		[rateTextField becomeFirstResponder];
	}
	else if ([codeTextField isFirstResponder])
	{
		[unitTextField becomeFirstResponder];
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
	else if ([unitTextField isFirstResponder])
	{
		[codeTextField becomeFirstResponder];
	}
}

-(void)closePicker:(UIButton*)sender
{
	[nameTextField resignFirstResponder];
	[rateTextField resignFirstResponder];
	[unitTextField resignFirstResponder];
	[codeTextField resignFirstResponder];
}

- (void)refresh {
    [nameTextField setText:[theProduct name]];
    [nameLabel setText:[theProduct name]];
    if(!nameTextField.isFirstResponder) {
        [nameLabel setTextColor:[UIColor darkGrayColor]];
    }
    [rateTextField setText:[data_manager currencyAdjustedValue:[theProduct price]]];
    [unitTextField setText:[theProduct unit]];
    [codeTextField setText:[theProduct code]];
    taxableSwitch.on = [theProduct taxable];
    [descriptionTextView setText:[theProduct note]];
    [descriptionLabel setText:[theProduct note]];
    if(!descriptionTextView.isFirstResponder) {
        [descriptionLabel setTextColor:[UIColor darkGrayColor]];
    }
}

- (void)openProductsPressed:(id)sender {
  ProductsVC *vc = [[ProductsVC alloc] init];
  vc.delegate = self;
  [self.navigationController pushViewController:vc animated:YES];
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
	else if ([textField isEqual:unitTextField])
	{
		[codeTextField becomeFirstResponder];
	}
	
	[textField resignFirstResponder];
	return YES;
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
    else if ([textField isEqual:codeTextField])
    {
        [theToolbar.nextButton setAlpha:0.5];
        [theToolbar.nextButton setUserInteractionEnabled:NO];
    }
    else if ([textField isEqual:unitTextField])
    {
        [textField setText:[theProduct rawUnit]];
    }
    
    return YES;
}

-(BOOL)textFieldShouldEndEditing:(UITextField*)textField
{
	if ([textField isEqual:nameTextField])
	{
		[theProduct setName:textField.text];
	}
	else if ([textField isEqual:rateTextField])
	{
		[theProduct setPrice:[textField.text floatValue]];
		[textField setText:[data_manager currencyAdjustedValue:[textField.text floatValue]]];
	}
	else if ([textField isEqual:codeTextField])
	{
		[theProduct setCode:textField.text];
	}
	else if ([textField isEqual:unitTextField])
	{
		[theProduct setUnit:textField.text];
		[textField setText:[theProduct unit]];
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

-(void)textFieldDidBeginEditing:(UITextField*)textField {
    CGFloat height = (theSelfView.frame.size.height - 42) - 40 - keyboard_height;
    
    [self edjustContentWithheight:height];
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
        [theProduct setNote:textView.text];
        
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

#pragma mark - PRODUCT OR SERVICE SELECTOR DELEGATE

-(void)viewController:(ProductsVC*)vc selectedProduct:(ProductOBJ*)sender
{
    theProduct = [[ProductOBJ alloc] initWithProduct:sender];

    [self refresh];
}

- (void)viewController:(ProductsVC *)vc selectedService:(ServiceOBJ *)sender {
    
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
    }];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end