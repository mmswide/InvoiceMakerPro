//
//  TaxEditorVC.m
//  Invoice
//
//  Created by XGRoup5 on 8/16/13.
//  Copyright (c) 2013 XGRoup. All rights reserved.
//

#import "TaxEditorVC.h"
#import "CellWithPicker.h"
#import "CellWithText.h"

#import "Defines.h"

typedef enum {
  kPickerCaseTerms = 0,
  kPickerCaseTaxType,
  kPickerCaseDateFormat
} kPickerCase;

@interface TaxEditorVC () <UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate, UIPickerViewDataSource,
UIPickerViewDelegate>

@end

@implementation TaxEditorVC

-(id)init
{
	self = [super init];
	
	if (self) {
		taxAbreviation1 = @"taxAbreviation1";
		taxRate1 = @"taxRate1";
    taxAbreviation2 = @"taxAbreviation2";
    taxRate2 = @"taxRate2";
    taxTypeArray = [[NSMutableArray alloc] initWithObjects:@"No Tax", @"Single Tax", @"Compound Tax", nil];
	}
	
	return self;
}

#pragma mark - VIEW DID LOAD

-(void)viewDidLoad {
	[super viewDidLoad];
	
  settingsDictionary = [[NSMutableDictionary alloc] initWithDictionary:[CustomDefaults customObjectForKey:kSettingsKeyForNSUserDefaults]];
  
	theSelfView = [[UIView alloc] initWithFrame:CGRectMake(0, statusBarHeight, dvc_width, dvc_height)];
	[theSelfView setBackgroundColor:[UIColor clearColor]];
	[self.view addSubview:theSelfView];
		
	[self.view setBackgroundColor:app_background_color];
	
	topBarView = [[TopBar alloc] initWithFrame:CGRectMake(0, 0, dvc_width, 42 + statusBarHeight) andTitle:@"Tax Details"];
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
  
  myTableView = [[TableWithShadow alloc] initWithFrame:CGRectMake(0, 42, dvc_width, dvc_height - 87) style:UITableViewStyleGrouped];
  [myTableView setDataSource:self];
  [myTableView setDelegate:self];
  [myTableView setBackgroundColor:[UIColor clearColor]];
  [myTableView setSeparatorColor:[UIColor clearColor]];
  
  [theSelfView addSubview:myTableView];
  
  UIView * bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, dvc_width, dvc_height - 87)];
  [bgView setBackgroundColor:[UIColor clearColor]];
  [myTableView setBackgroundView:bgView];
  
	
	theToolbar = [[ToolBarView alloc] initWithFrame:CGRectMake(0, dvc_height, dvc_width, 40)];
//	[theToolbar.prevButton addTarget:self action:@selector(prevTextField:) forControlEvents:UIControlEventTouchUpInside];
//	[theToolbar.nextButton addTarget:self action:@selector(nextTextField:) forControlEvents:UIControlEventTouchUpInside];
  [theToolbar.prevButton setAlpha:0.0];
  [theToolbar.nextButton setAlpha:0.0];
	[theToolbar.doneButton addTarget:self action:@selector(closeTextView:) forControlEvents:UIControlEventTouchUpInside];
	[theSelfView addSubview:theToolbar];
	
	[self.view addSubview:topBarView];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  dispatch_async(dispatch_get_main_queue(), ^{
    [myTableView reloadData];
  });
}

-(void)viewDidAppear:(BOOL)animated
{
  [super viewDidAppear:animated];
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardFrameChanged:) name:UIKeyboardDidChangeFrameNotification object:nil];
}

#pragma mark - FUNCTIONS

-(void)back:(UIButton*)sender {
	[self.navigationController popViewControllerAnimated:YES];
}

-(void)done:(UIButton*)sender {
  [CustomDefaults setCustomObjects:settingsDictionary forKey:kSettingsKeyForNSUserDefaults];
  
  [DELEGATE checkTaxConfiguration];
  
  if(![DELEGATE tax_misconfigured]) {
    
    NSString * abr1 = settingsDictionary[taxAbreviation1];
    NSString * rate1 = settingsDictionary[taxRate1];
    NSString * abr2 = settingsDictionary[taxAbreviation2];
    NSString * rate2 = settingsDictionary[taxRate2];
    
    if ((![abr1 isEqual:@""] && [rate1 floatValue] != 0.0f) || (![abr2 isEqual:@""] && [rate2 floatValue] != 0.f)) {
      [data_manager makeProductsAndServicesTaxable];
    }

    [self dismissViewControllerAnimated:YES completion:nil];
  } else {
    [DELEGATE goToTab:nil];
  }
}

#pragma mark - TABLE VIEW DATASOURCE

-(NSInteger)numberOfSectionsInTableView:(UITableView*)tableView {
  return 1;
}

-(NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section {
  switch (section){
    case 0: {
      if ([[settingsDictionary objectForKey:@"taxType"] isEqual:@"No Tax"]) {
        return 1;
      } else if ([[settingsDictionary objectForKey:@"taxType"] isEqual:@"Single Tax"]) {
        return 4;
      } else if ([[settingsDictionary objectForKey:@"taxType"] isEqual:@"Compound Tax"]) {
        return 6;
      }
    }
      
    default:
      break;
  }
  
  return 0;
}

-(UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath {
  return [self cellInSection:(int)indexPath.section atRow:(int)indexPath.row];
}

-(UIView*)tableView:(UITableView*)tableView viewForHeaderInSection:(NSInteger)section {
  UIView * view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, dvc_width, 30)];
  [view setBackgroundColor:[UIColor clearColor]];
  
  UILabel * title = [[UILabel alloc] initWithFrame:CGRectMake(22, 0, dvc_width - 44, 30)];
  [title setTextAlignment:NSTextAlignmentLeft];
  [title setTextColor:app_title_color];
  [title setFont:HelveticaNeueMedium(15)];
  [title setBackgroundColor:[UIColor clearColor]];
  [view addSubview:title];
  
  switch (section) {
    case 0: {
      [title setText:@"Tax"];
      break;
    }
      
    default:
      break;
  }
  
  return view;
}

#pragma mark - TABLE VIEW DELEGATE

-(CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath {
  return 42.0f;
}

-(CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section {
  return 42.0f;
}

-(void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath {
  UITableViewCell * theCell = [tableView cellForRowAtIndexPath:indexPath];
  
  if ([theCell isKindOfClass:[CellWithPicker class]]) {
    [(CellWithPicker*)theCell animateSelection];
  } else if ([theCell isKindOfClass:[CellWithText class]]) {
    [(CellWithText*)theCell animateSelection];
  }
  
  [self selectedCellInSection:(int)indexPath.section atRow:(int)indexPath.row];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
  if([cell respondsToSelector:@selector(setCellWidth:)])
    [(BaseTableCell *)cell setCellWidth:tableView.frame.size.width];
}

#pragma mark - CELL GENERATION

-(UITableViewCell*)cellInSection:(int)section atRow:(int)row {
  switch (section) {
    case 0: {
      return [self taxCellAtRow:row];
      break;
    }
						
    default:
      break;
  }
  
  return nil;
}

-(UITableViewCell*)taxCellAtRow:(int)row {
  BaseTableCell * theCell;
  
  switch (row) {
    case TaxType: {
      theCell = [myTableView dequeueReusableCellWithIdentifier:@"tableCellPicker"];
      
      if (!theCell) {
        theCell = [[CellWithPicker alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"tableCellPicker"];
      }
      
      kCellType type = kCellTypeTop;
      
      if ([[settingsDictionary objectForKey:@"taxType"] isEqual:@"No Tax"]) {
        type = kCellTypeSingle;
      }
      
      [(CellWithPicker*)theCell loadTitle:@"Tax Type" andValue:[settingsDictionary objectForKey:@"taxType"] cellType:type];
      
      break;
    }
      
    case Tax1Rate: {
      theCell = [myTableView dequeueReusableCellWithIdentifier:@"tableCellText"];
      
      if (!theCell) {
        theCell = [[CellWithText alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"tableCellText"];
      }
      
      [(CellWithText*)theCell loadTitle:@"Rate:" andValue:[NSString stringWithFormat:@"%@ %c", [settingsDictionary objectForKey:@"taxRate1"], '%'] tag:row textFieldDelegate:self cellType:kCellTypeMiddle andKeyboardType:UIKeyboardTypeDecimalPad];
      [(CellWithText*)theCell setActiveValueOnSelection:YES];
      [theCell setUserInteractionEnabled:YES];
      
      break;
    }
      
    case Tax1Abreviation: {
      theCell = [myTableView dequeueReusableCellWithIdentifier:@"tableCellText"];
      
      if (!theCell) {
        theCell = [[CellWithText alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"tableCellText"];
      }
      
      [(CellWithText*)theCell loadTitle:@"Abreviation:" andValue:[settingsDictionary objectForKey:@"taxAbreviation1"] tag:row textFieldDelegate:self cellType:kCellTypeMiddle andKeyboardType:UIKeyboardTypeDefault];
      [(CellWithText*)theCell setActiveValueOnSelection:YES];
      [theCell setUserInteractionEnabled:YES];
      
      break;
    }
      
    case Tax2Rate: {
      if ([[settingsDictionary objectForKey:@"taxType"] isEqual:@"Single Tax"]) {
        theCell = [self taxRegNoCellFromTable:myTableView];
      } else {
        theCell = [myTableView dequeueReusableCellWithIdentifier:@"tableCellText"];
        
        if (!theCell) {
          theCell = [[CellWithText alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"tableCellText"];
        }
        
        [(CellWithText*)theCell loadTitle:@"Rate:" andValue:[NSString stringWithFormat:@"%@ %c", [settingsDictionary objectForKey:@"taxRate2"], '%'] tag:row textFieldDelegate:self cellType:kCellTypeMiddle andKeyboardType:UIKeyboardTypeDecimalPad];
        [(CellWithText*)theCell setActiveValueOnSelection:YES];
        [theCell setUserInteractionEnabled:YES];
      }
      
      break;
    }
      
    case Tax2Abreviation: {
      theCell = [myTableView dequeueReusableCellWithIdentifier:@"tableCellText"];
      
      if (!theCell) {
        theCell = [[CellWithText alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"tableCellText"];
      }
      
      [(CellWithText*)theCell loadTitle:@"Abreviation:" andValue:[settingsDictionary objectForKey:@"taxAbreviation2"] tag:row textFieldDelegate:self cellType:kCellTypeMiddle andKeyboardType:UIKeyboardTypeDefault];
      [(CellWithText*)theCell setActiveValueOnSelection:YES];
      [theCell setUserInteractionEnabled:YES];
      break;
    }
      
    case TaxRegNo: {
      theCell = [self taxRegNoCellFromTable:myTableView];
      break;
    }
      
    default:
      break;
  }
  
  [theCell setTitleEditableLayout];
  [theCell setAutolayoutForValueField];
  
  return theCell;
}

- (BaseTableCell *)taxRegNoCellFromTable:(UITableView *)tableView {
  BaseTableCell *theCell = [tableView dequeueReusableCellWithIdentifier:@"tableCellText"];
  
  if (!theCell) {
				theCell = [[CellWithText alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"tableCellText"];
  }
  
  [(CellWithText*)theCell loadTitle:@"Tax Reg No." andValue:[settingsDictionary objectForKey:@"taxRegNo"] tag:888 textFieldDelegate:self cellType:kCellTypeBottom andKeyboardType:UIKeyboardTypeDefault];
  [theCell setUserInteractionEnabled:YES];
  return theCell;
}

#pragma mark - CELL SELECTION

-(void)selectedCellInSection:(int)section atRow:(int)row {
  switch (section) {
    case 0: {
      [self selectedTaxCellAtRow:row];
      break;
    }
      
    default:
      break;
  }
}

-(void)selectedTaxCellAtRow:(int)row {
  switch (row) {
    case TaxType: {
      //tax type
      [self openPickerForCase:kPickerCaseTaxType];
      
      break;
    }
      
    case Tax1Rate: {
      //tax 1
      [(UITextField*)[self.view viewWithTag:row] becomeFirstResponder];
      
      break;
    }
      
    case Tax1Abreviation: {
      [(UITextField*)[self.view viewWithTag:row] becomeFirstResponder];
      break;
    }
      
    case Tax2Rate: {
      if ([[settingsDictionary objectForKey:@"taxType"] isEqual:@"Single Tax"]) {
        //tax reg no.
        [(UITextField*)[self.view viewWithTag:888] becomeFirstResponder];
      } else if ([[settingsDictionary objectForKey:@"taxType"] isEqual:@"Compound Tax"]) {
        //tax 2
        [(UITextField*)[self.view viewWithTag:row] becomeFirstResponder];
      }
      
      break;
    }
      
    case Tax2Abreviation: {
      [(UITextField*)[self.view viewWithTag:row] becomeFirstResponder];
      
      break;
    }
      
    case TaxRegNo: {
      //tax reg no.
      [(UITextField*)[self.view viewWithTag:888] becomeFirstResponder];
      
      break;
    }
      
    default:
      break;
  }
}

#pragma mark - OPEN PICKER

-(void)openPickerForCase:(kPickerCase)type {
  if ([self.navigationController.view viewWithTag:101010])
    return;
  
  [activeTextField resignFirstResponder];
  [[self.navigationController.view viewWithTag:101010] removeFromSuperview];
  [[self.view viewWithTag:999] removeFromSuperview];
  [(UITextField*)[self.view viewWithTag:888] resignFirstResponder];
  
  UIView * viewWithPicker = [[UIView alloc] initWithFrame:CGRectMake(0, dvc_height + 60, dvc_width, keyboard_height)];
  [viewWithPicker setBackgroundColor:[UIColor clearColor]];
  [viewWithPicker setTag:101010];
  [viewWithPicker.layer setMasksToBounds:YES];
  [self.navigationController.view addSubview:viewWithPicker];
  
  UIPickerView * picker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 0, dvc_width, keyboard_height)];
  picker.backgroundColor = [UIColor whiteColor];
  [picker setDelegate:self];
  [picker setDataSource:self];
  
  if (!iPad) {
    [picker setTransform:CGAffineTransformMakeScale(1.09, 1.09)];
  } else {
    [picker setTransform:CGAffineTransformMakeScale(1.0, (float)(keyboard_height) / 216.0f)];
  }
  
  [picker setCenter:CGPointMake(dvc_width / 2, keyboard_height / 2)];
  [viewWithPicker addSubview:picker];
  
  [picker selectRow:[taxTypeArray indexOfObject:[settingsDictionary objectForKey:@"taxType"]] inComponent:0 animated:YES];
  [picker reloadAllComponents];
  
  
  UIView * indicator = [[UIView alloc] initWithFrame:CGRectMake(0, 0, dvc_width, 30)];
  [indicator setBackgroundColor:app_tab_selected_color];
  [indicator setCenter:CGPointMake(dvc_width / 2, keyboard_height / 2)];
  [indicator setAlpha:0.2];
  [indicator setUserInteractionEnabled:NO];
  [viewWithPicker addSubview:indicator];
  
  ToolBarView * thePikerToolbar = [[ToolBarView alloc] initWithFrame:CGRectMake(0, dvc_height, dvc_width, 40)];
  [thePikerToolbar.prevButton setAlpha:0.0];
  [thePikerToolbar.nextButton setAlpha:0.0];
  [thePikerToolbar.doneButton addTarget:self action:@selector(closePicker:) forControlEvents:UIControlEventTouchUpInside];
  [thePikerToolbar setTag:999];
  [theSelfView addSubview:thePikerToolbar];
  
  [UIView animateWithDuration:0.25 animations:^{
    [viewWithPicker setFrame:CGRectMake(0, dvc_height - keyboard_height + 20, dvc_width, keyboard_height)];
    [thePikerToolbar setFrame:CGRectMake(0, dvc_height - keyboard_height - 40, dvc_width, 40)];
    [myTableView setFrame:CGRectMake(myTableView.frame.origin.x, myTableView.frame.origin.y, dvc_width, dvc_height - 82 - keyboard_height)];
  }];
}

-(void)closePicker:(UIButton*)sender {
  [DELEGATE checkTaxConfiguration];
  
  if(activeTextField) {
    [activeTextField resignFirstResponder];
    activeTextField = nil;
  }
  
  [(UITextField*)[self.view viewWithTag:888] resignFirstResponder];
		
  [UIView animateWithDuration:0.25 animations:^{
    [[self.navigationController.view viewWithTag:101010] setFrame:CGRectMake(0, dvc_height + 60, dvc_width, keyboard_height)];
    [[self.view viewWithTag:999] setFrame:CGRectMake(0, dvc_height, dvc_width, 40)];
    
    [myTableView setFrame:CGRectMake(myTableView.frame.origin.x, myTableView.frame.origin.y, dvc_width, dvc_height - 87)];
  } completion:^(BOOL finished) {
    [[self.navigationController.view viewWithTag:101010] removeFromSuperview];
    [[self.view viewWithTag:999] removeFromSuperview];
  }];
}

#pragma mark - PICKERVIEW DATASOURCE

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView*)pickerView {
  return 1;
}

-(NSInteger)pickerView:(UIPickerView*)pickerView numberOfRowsInComponent:(NSInteger)component {
  return taxTypeArray.count;
}

-(UIView*)pickerView:(UIPickerView*)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView*)view {
  UIView * theView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, dvc_width, 30)];
  [theView setBackgroundColor:[UIColor clearColor]];
  
  UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(30, 0, dvc_width - 60, 30)];
  [label setTextAlignment:NSTextAlignmentLeft];
  [label setTextColor:[UIColor darkGrayColor]];
  [label setFont:HelveticaNeue(15)];
  [label setBackgroundColor:[UIColor clearColor]];
  [theView addSubview:label];
  
  if (row == [pickerView selectedRowInComponent:component]) {
    [label setTextColor:[UIColor blackColor]];
  }
  
  [label setText:[taxTypeArray objectAtIndex:row]];
  
  return theView;
}

#pragma mark - PICKERVIEW DELEGATE

-(CGFloat)pickerView:(UIPickerView*)pickerView rowHeightForComponent:(NSInteger)component {
  return 30;
}

-(void)pickerView:(UIPickerView*)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
  [pickerView reloadAllComponents];
  
  [settingsDictionary setObject:[taxTypeArray objectAtIndex:row] forKey:@"taxType"];
  
  if ([[settingsDictionary objectForKey:@"taxType"] isEqual:@"No Tax"]) {
    [settingsDictionary setObject:@"" forKey:@"taxAbreviation1"];
    [settingsDictionary setObject:@"0.0" forKey:@"taxRate1"];
    
    [settingsDictionary setObject:@"" forKey:@"taxAbreviation2"];
    [settingsDictionary setObject:@"0.0" forKey:@"taxRate2"];
    
    [CustomDefaults setCustomBool:NO forKey:kDefaultTaxable];
  }
  else if ([[settingsDictionary objectForKey:@"taxType"] isEqual:@"Single Tax"]) {
    [settingsDictionary setObject:@"" forKey:@"taxAbreviation2"];
    [settingsDictionary setObject:@"0.0" forKey:@"taxRate2"];
  }
  
  [myTableView reloadData];
  
  [CustomDefaults setCustomObjects:settingsDictionary forKey:kSettingsKeyForNSUserDefaults];
}


#pragma mark - TEXTFIELD DELEGATE

-(void)closeTextView:(UIButton*)sender {
	[activeTextField resignFirstResponder];
	
	[UIView animateWithDuration:0.25 animations:^{
		[theToolbar setFrame:CGRectMake(0, dvc_height, dvc_width, 40)];
	}];
}

-(BOOL)textFieldShouldBeginEditing:(UITextField*)textField {
  activeTextField = textField;
  
//  if (textField.tag == Tax1Rate) {
//    [theToolbar.prevButton setAlpha:0.5];
//    [theToolbar.prevButton setUserInteractionEnabled:NO];
//    [theToolbar.nextButton setAlpha:1.0];
//    [theToolbar.nextButton setUserInteractionEnabled:YES];
//  }
//  else if(textField)
//  {
//    [theToolbar.prevButton setAlpha:1.0];
//    [theToolbar.prevButton setUserInteractionEnabled:YES];
//    [theToolbar.nextButton setAlpha:0.5];
//    [theToolbar.nextButton setUserInteractionEnabled:NO];
//  }
  
  [UIView animateWithDuration:0.25 animations:^{
    [theToolbar setFrame:CGRectMake(0, dvc_height - keyboard_height - 40, dvc_width, 40)];
    [myTableView setFrame:CGRectMake(myTableView.frame.origin.x, myTableView.frame.origin.y, dvc_width, dvc_height - 82 - keyboard_height)];
  }];
  return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
  if(textField.tag == Tax1Rate || textField.tag == Tax2Rate) {
    NSString *value = [textField.text stringByReplacingOccurrencesOfString:@"%" withString:@""];
    if ([value floatValue] == 0.0f) {
      [textField setText:@" %"];
    }
    
    UITextPosition *positionBeginning = [textField endOfDocument];
    
    UITextRange *textRange = [textField textRangeFromPosition:positionBeginning
                                                   toPosition:positionBeginning];
    
    // Calculate the new position, - for left and + for right
    UITextPosition *newPosition = [textField positionFromPosition:textRange.start offset:-2];
    
    // Construct a new range using the object that adopts the UITextInput, our textfield
    UITextRange *newMiddleRange = [textField textRangeFromPosition:newPosition
                                                        toPosition:newPosition];
    UITextRange *newRange = [textField textRangeFromPosition:newPosition toPosition:newMiddleRange.start];
    
    [textField setSelectedTextRange:newRange];
  }
}

-(BOOL)textFieldShouldEndEditing:(UITextField*)textField {
  //tax editing
  if(textField.tag == Tax1Rate || textField.tag == Tax2Rate) {
    NSString *value = [textField.text stringByReplacingOccurrencesOfString:@"%" withString:@""];
    if([value floatValue] == 0) {
      textField.text = @"0.0 %";
    } else if (![textField.text containsString:@"%"]) {
      value = [textField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
      textField.text = [NSString stringWithFormat:@"%@ %@", value, @"%"];
    } else {
      [textField setText:[NSString stringWithFormat:@"%.2f", [textField.text floatValue]]];
    }
  }
  
  if(textField.tag == Tax1Rate) {
    NSString *value = [textField.text stringByReplacingOccurrencesOfString:@"%" withString:@""];
    value = [value stringByReplacingOccurrencesOfString:@" " withString:@""];
    [settingsDictionary setObject:value forKey:@"taxRate1"];
  } else if (textField.tag == Tax1Abreviation) {
    [settingsDictionary setObject:textField.text forKey:@"taxAbreviation1"];
  } else if (textField.tag == Tax2Rate) {
    NSString *value = [textField.text stringByReplacingOccurrencesOfString:@"%" withString:@""];
    value = [value stringByReplacingOccurrencesOfString:@" " withString:@""];
    [settingsDictionary setObject:value forKey:@"taxRate2"];
  } else if(textField.tag == Tax2Abreviation) {
    [settingsDictionary setObject:textField.text forKey:@"taxAbreviation2"];
  }
  
  [CustomDefaults setCustomObjects:settingsDictionary forKey:kSettingsKeyForNSUserDefaults];
  
  if([activeTextField isEqual:textField]) {
    [UIView animateWithDuration:0.25 animations:^{
      [myTableView setFrame:CGRectMake(myTableView.frame.origin.x, myTableView.frame.origin.y, dvc_width, dvc_height - 87)];
      [theToolbar setFrame:CGRectMake(0, dvc_height, dvc_width, 40)];
    }];
  }
  
  return YES;
}

#pragma mark - NSNotification Center

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
        
    }];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end