//
//  AddItemVC.m
//  Invoice
//
//  Created by Paul on 06/05/14.
//  Copyright (c) 2014 XGRoup. All rights reserved.
//

#import "AddItemVC.h"
#import "Defines.h"
#import "CreateOrEditProductVC.h"
#import "BaseTableCell.h"
#import "CellWithPush.h"
#import "CellWithText.h"
#import "DescriptionCell.h"
#import "DescriptionCell.h"
#import "CellWithEditField.h"
#import "ProductsVC.h"

@interface AddItemVC () <UITextFieldDelegate, UITextViewDelegate, UITableViewDataSource, UITableViewDelegate, ProductOrServiceSelectorDelegate, ProductCreatorDelegate>

@end

@implementation AddItemVC

-(id)initWithInvoice:(InvoiceOBJ*)sender index:(NSInteger)i {
	self = [super init];
	
	if (self) {
		theInvoice = sender;
		index = i;
        isNewInvoice = YES;
		
		if (index < [theInvoice.products count]) {
			NSDictionary * dict = [theInvoice.products objectAtIndex:i];
			
			if (![[dict allKeys] containsObject:@"code"]) {
				theService = [[ServiceOBJ alloc] initWithContentsDictionary:dict];
				[theService setTax1Percentage:[theInvoice tax1Percentage]];
				[theService setTax2Percentage:[theInvoice tax2Percentage]];
			} else {
				theProduct = [[ProductOBJ alloc] initWithContentsDictionary:dict];
				[theProduct setTax1Percentage:[theInvoice tax1Percentage]];
				[theProduct setTax2Percentage:[theInvoice tax2Percentage]];
			}
		}
	}
	
	return self;
}

-(id)initWithQuote:(QuoteOBJ*)sender index:(NSInteger)i {
	self = [super init];
	
	if (self) {
		theQuote = sender;
		index = i;
        isNewInvoice = YES;
		
		if (index < [theQuote.products count]) {
			NSDictionary * dict = [theQuote.products objectAtIndex:i];
			
			if (![[dict allKeys] containsObject:@"code"]) {
				theService = [[ServiceOBJ alloc] initWithContentsDictionary:dict];
				[theService setTax1Percentage:[theQuote tax1Percentage]];
				[theService setTax2Percentage:[theQuote tax2Percentage]];
			} else {
				theProduct = [[ProductOBJ alloc] initWithContentsDictionary:dict];
				[theProduct setTax1Percentage:[theQuote tax1Percentage]];
				[theProduct setTax2Percentage:[theQuote tax2Percentage]];
			}
		}
	}
	
	return self;
}

-(id)initWithEstimate:(EstimateOBJ*)sender index:(NSInteger)i {
	self = [super init];
	
	if (self) {
		theEstimate = sender;
		index = i;
        isNewInvoice = YES;
		
		if (index < [theEstimate.products count]) {
			NSDictionary * dict = [theEstimate.products objectAtIndex:i];
			
			if (![[dict allKeys] containsObject:@"code"]) {
				theService = [[ServiceOBJ alloc] initWithContentsDictionary:dict];
				[theService setTax1Percentage:[theEstimate tax1Percentage]];
				[theService setTax2Percentage:[theEstimate tax2Percentage]];
			} else {
				theProduct = [[ProductOBJ alloc] initWithContentsDictionary:dict];
				[theProduct setTax1Percentage:[theEstimate tax1Percentage]];
				[theProduct setTax2Percentage:[theEstimate tax2Percentage]];
			}
		}
	}
	
	return self;
}

-(id)initWithPO:(PurchaseOrderOBJ*)sender index:(NSInteger)i {
	self = [super init];
	
	if (self) {
		thePurchareOrder = sender;
		index = i;
        isNewInvoice = YES;
		
		if (index < [thePurchareOrder.products count]) {
			NSDictionary * dict = [thePurchareOrder.products objectAtIndex:i];
			
			if (![[dict allKeys] containsObject:@"code"]) {
				theService = [[ServiceOBJ alloc] initWithContentsDictionary:dict];
				[theService setTax1Percentage:[thePurchareOrder tax1Percentage]];
				[theService setTax2Percentage:[thePurchareOrder tax2Percentage]];
			} else {
				theProduct = [[ProductOBJ alloc] initWithContentsDictionary:dict];
				[theProduct setTax1Percentage:[thePurchareOrder tax1Percentage]];
				[theProduct setTax2Percentage:[thePurchareOrder tax2Percentage]];
			}
		}
	}
	
	return self;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    theSelfView = [[UIView alloc] initWithFrame:CGRectMake(0, statusBarHeight, dvc_width, dvc_height)];
    [theSelfView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:theSelfView];
    
    [self.view setBackgroundColor:app_background_color];
    
    topBarView = [[TopBar alloc] initWithFrame:CGRectMake(0, 0, dvc_width, 42 + statusBarHeight) andTitle:@"Add Item"];
    [topBarView setBackgroundColor:app_bar_update_color];
    
    BackButton * backButton = [[BackButton alloc] initWithFrame:CGRectMake(0, 42 + statusBarHeight - 40, 70, 40) andTitle:@"Back"];
    [backButton addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    [topBarView addSubview:backButton];
    
    UIButton * addProduct = [[UIButton alloc] initWithFrame:CGRectMake(dvc_width - 60, 42 + statusBarHeight - 40, 60, 40)];
    [addProduct setTitle:@"Done" forState:UIControlStateNormal];
    [addProduct setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [addProduct setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [addProduct.titleLabel setFont:HelveticaNeueLight(17)];
    [addProduct addTarget:self action:@selector(addItem:) forControlEvents:UIControlEventTouchUpInside];
    [topBarView addSubview:addProduct];
    
    myTableView = [[TableWithShadow alloc] initWithFrame:CGRectMake(0, 42, dvc_width, dvc_height - 42) style:UITableViewStyleGrouped];
    [myTableView setDataSource:self];
    [myTableView setDelegate:self];
    myTableView.scrollEnabled = YES;
    [myTableView setBackgroundColor:[UIColor clearColor]];
    [myTableView setSeparatorColor:[UIColor clearColor]];
    [myTableView layoutIfNeeded];
    
    [theSelfView addSubview:myTableView];
    
    theToolbar = [[ToolBarView alloc] initWithFrame:CGRectMake(0, dvc_height, dvc_width, 40)];
    [theToolbar.prevButton setAlpha:0.0];
    [theToolbar.nextButton setAlpha:0.0];
    [theToolbar.doneButton addTarget:self action:@selector(closePicker:) forControlEvents:UIControlEventTouchUpInside];
    [theSelfView addSubview:theToolbar];
    
    UIView * bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, dvc_width, dvc_height - 42)];
    [bgView setBackgroundColor:[UIColor clearColor]];
    [myTableView setBackgroundView:bgView];
    
    [self.view addSubview:topBarView];
    
    [self initManualProduct];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [myTableView reloadData];
    
    [myTableView layoutIfNeeded];
    [theSelfView bringSubviewToFront:theToolbar];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardFrameChanged:) name:UIKeyboardDidChangeFrameNotification object:nil];
}

- (BaseOBJ *)baseObject {
    if(theInvoice) {
        return theInvoice;
    }
    if(theQuote) {
        return theQuote;
    }
    if(theEstimate) {
        return theEstimate;
    }
    return thePurchareOrder;
}

- (NSString *)objLanguageKey {
    if(theInvoice) {
        return @"invoice";
    }
    if(theQuote) {
        return @"quote";
    }
    if(theEstimate) {
        return @"estimate";
    }
    return @"purchase";
}

#pragma mark - FUNCTIONS

-(void)back:(UIButton*)sender {
    [currentTextfield resignFirstResponder];
    [currentTextView resignFirstResponder];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)selectItem:(UIButton*)sender
{
	ProductsVC * vc = [[ProductsVC alloc] init];
  vc.delegate = self;
	[self.navigationController pushViewController:vc animated:YES];
}

-(void)addItem:(UIButton*)sender {
	if (theProduct) {
		if (theProduct.quantity == 0.0f) {
			[[[AlertView alloc] initWithTitle:@"Error" message:@"Please enter the quantity." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] showInWindow];
			return;
		}
		
		if (_delegate && [_delegate respondsToSelector:@selector(viewController:addedProduct:atIndex:)]) {
			[_delegate viewController:self addedProduct:theProduct atIndex:index];
		}
	} else if (theService) {
		if (theService.quantity == 0.0f) {
			[[[AlertView alloc] initWithTitle:@"Error" message:@"Please enter the quantity." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] showInWindow];
			return;
		}
		
		if (_delegate && [_delegate respondsToSelector:@selector(viewController:addedService:atIndex:)]) {
			[_delegate viewController:self addedService:theService atIndex:index];
		}
	} else {
		[[[AlertView alloc] initWithTitle:@"Error" message:@"Please select the product or service." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] showInWindow];
		return;
	}
    if(isManualProduct) {
        [self saveNewProduct:theProduct];
    } else {
        [self updateProductAndService];
    }
	
	[self back:nil];
}

-(void)closePicker:(UIButton*)sender {
  isNewEditingField = NO;
	[currentTextfield resignFirstResponder];
  [currentTextView resignFirstResponder];
    
  [UIView animateWithDuration:0.25 animations:^{
    [theToolbar setFrame:CGRectMake(0, dvc_height, dvc_width, 40)];
    [myTableView setFrame:CGRectMake(myTableView.frame.origin.x, myTableView.frame.origin.y, dvc_width, dvc_height - 42)];
  } completion:^(BOOL finished) {
    if(!myTableView.isEditing) {
        [myTableView reloadData];
    }
  }];
}

- (SectionTag)sectionTag:(NSInteger)sectionIndex {
    return sectionIndex + SectionAddItemDetails;
}

- (NSInteger)sectionIndex:(SectionTag)sectionTag {
    return MAX(sectionTag - SectionAddItemDetails, 0);
}

- (BOOL)isTitleTextfieldWithTag:(NSInteger)tag {
    return (tag - TextfieldOffsetTag) >= 0;
}

- (AddItemDetailType)titleIndex:(NSInteger)tag {
    return tag - TextfieldOffsetTag;
}

- (AddItemDetailType)addItemDetailTypeAtIndex:(NSInteger)rowIndex {
    NSArray *detailsRows = [self addItemDetailsRowsWhenEditing:addItemDetailsIsEditing];
    if(rowIndex < [detailsRows count]) {
        NSDictionary *detailSettings = [detailsRows objectAtIndex:rowIndex];
        return [detailSettings[TYPE] integerValue];
    }
    return -1;
}

- (NSInteger)indexOfAddItemType:(AddItemDetailType)type {
    NSArray *detailsRows = [self addItemDetailsRowsWhenEditing:addItemDetailsIsEditing];
    NSInteger typeIndex = 0;
    for(NSDictionary *details in detailsRows) {
        if([details[TYPE] integerValue] == type) {
            break;
        }
        typeIndex++;
    }
    return typeIndex;
}

- (void)initManualProduct {
    if(!theProduct && !theService) {
        theProduct = [[ProductOBJ alloc] init];
        theProduct.quantity = 1;
        isManualProduct = YES;
    }
}

#pragma mark - Editing section methods

- (void)setAddItemDetailsVisibility:(BOOL)visibility atIndex:(NSInteger)pIndex {
    NSMutableDictionary *detailsSettings = [NSMutableDictionary dictionaryWithDictionary:[[[self baseObject] addItemDetailsSettings] objectAtIndex:pIndex]];
    [detailsSettings setObject:[NSNumber numberWithBool:visibility] forKey:VISIBILITY];
    [[self baseObject] setAddItemDetailsSettings:detailsSettings atIndex:pIndex];
    [self saveAddItemDetailsSettings];
}

- (kCellType)addItemDetailsCellTypeForRowType:(AddItemDetailType)row {
    NSArray *detailsRows = [self addItemDetailsRowsWhenEditing:addItemDetailsIsEditing];
    NSInteger lIndex = 0;
    for(;lIndex < [detailsRows count]; lIndex++) {
        NSDictionary *detailSettings = detailsRows[lIndex];
        if([detailSettings[TYPE] integerValue] == row) {
            break;
        }
    }
    
    kCellType cellType = [self cellTypeForRow:lIndex fromCount:[detailsRows count]];
    
    return cellType;
}

- (kCellType)addItemDetailsCellTypeForRow:(NSInteger)row {
    NSArray *detailsRows = [self addItemDetailsRowsWhenEditing:addItemDetailsIsEditing];
    return [self cellTypeForRow:row fromCount:[detailsRows count]];
}

- (NSInteger)numberOfRowsInAddItemDetailsSection {
    return [[self addItemDetailsRowsWhenEditing:addItemDetailsIsEditing] count];
}

- (void)saveAddItemDetailsSettings {
    if(isNewInvoice) {
        [[self baseObject] saveAddItemDetailsSettings];
    }
}

- (NSArray *)addItemDetailsRowsWhenEditing:(BOOL)editing {
    NSArray *figureRows = nil;
    if(addItemDetailsIsEditing) {
        figureRows = [[self baseObject] addItemDetailsSettings];
    } else {
        figureRows = [[self baseObject] visibleRowsInAddItemDetailsSection];
    }
    return figureRows;
}

- (NSDictionary *)addItemSettingsForType:(AddItemDetailType)type defaultTitle:(NSString *)title {
  NSArray *detailRows = [self addItemDetailsRowsWhenEditing:addItemDetailsIsEditing];
  NSMutableDictionary *detailSettings = nil;
  for(NSInteger i = 0;i < [detailRows count]; i++) {
    detailSettings = detailRows[i];
    if([detailSettings[TYPE] integerValue] == type) {
      break;
    }
  }
  
  if(detailSettings[TITLE] == nil) {
    [[self baseObject] setTitle:title forAddItemType:type];
    detailSettings = [NSMutableDictionary dictionaryWithDictionary:detailSettings];
    [detailSettings setObject:title forKey:TITLE];
  }
  
  return detailSettings;
}

#pragma mark - PRODUCT OR SERVICE SELECTOR DELEGATE

-(void)viewController:(ProductsVC*)vc selectedProduct:(ProductOBJ*)sender {
	theService = nil;
	theProduct = sender;
  theProduct.quantity = 1;
  theProduct.discount = 0;
  
  isManualProduct = NO;

  [myTableView reloadData];
}

-(void)viewController:(ProductsVC*)vc selectedService:(ServiceOBJ*)sender {
	theProduct = nil;
	theService = sender;
  theService.quantity = 1;
  theService.discount = 0;
    
    isManualProduct = NO;
	
    [myTableView reloadData];
}

#pragma mark - UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView*)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0: {
            return [self numberOfRowsInAddItemDetailsSection];
            
            break;
        }
        default:
            break;
    }
    
    return 0;
}

-(UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath {
    UITableViewCell * theCell = [self cellInSection:(int)indexPath.section atRow:(int)indexPath.row];
    
    return theCell;
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
    
    if(section == 0) {
        NSInteger buttonWidth = 50;
        UIButton *editButton = [[UIButton alloc] initWithFrame:CGRectMake(view.frame.size.width - buttonWidth, 0, buttonWidth, view.frame.size.height)];
        editButton.tag = SectionAddItemDetails;
        [editButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [editButton.titleLabel setFont:HelveticaNeueLight(15)];
        [editButton setTitle:(tableView.isEditing && currentEditingSection == [self sectionTag:section])?@"Done":@"Edit" forState:UIControlStateNormal];
        [editButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateHighlighted];
        [editButton addTarget:self action:@selector(editSectionPressed:) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:editButton];
    }
    switch (section) {
        case 0: {
            [title setText:@"Details"];
            break;
        }
        default:
            break;
    }
    
    return view;
}

#pragma mark - UITableViewDelegate

-(CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath {
    if([self addItemDetailTypeAtIndex:indexPath.row] == RowDescription) {
        return DESCRIPTION_VIEW_HEIGHT;
    }
    return 42.0f;
}

-(CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section {
    return 30.0f;
}

-(void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath {
    if(!tableView.isEditing) {
        BaseTableCell *theCell = (BaseTableCell *)[tableView cellForRowAtIndexPath:indexPath];
        [theCell animateSelection];
        
        if([self addItemDetailTypeAtIndex:indexPath.row] == RowAddItem) {
            [self selectedCellInSection:(int)indexPath.section atRow:(int)indexPath.row];
        } else {
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
        }
    } else {
        if(indexPath.section == 0) {
            if([self addItemDetailTypeAtIndex:indexPath.row] != RowTotal) {
                [self setAddItemDetailsVisibility:YES atIndex:indexPath.row];
            }
        }
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(tableView.isEditing) {
        if(indexPath.section == 0) {
            if([self addItemDetailTypeAtIndex:indexPath.row] != RowTotal) {
                [self setAddItemDetailsVisibility:NO atIndex:indexPath.row];
            }
        }
    }
}

-(BOOL)tableView:(UITableView*)tableView canEditRowAtIndexPath:(NSIndexPath*)indexPath {
    NSInteger rowsCount = [self numberOfRowsInAddItemDetailsSection];
    
    if(currentEditingSection >= 0) {
        if ([self sectionTag:indexPath.section] == currentEditingSection && indexPath.row < rowsCount - 1) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger rowsCount = [self numberOfRowsInAddItemDetailsSection];
    if([self sectionTag:indexPath.section] == currentEditingSection && indexPath.row < rowsCount - 1) {
        return YES;
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    if([self sectionTag:sourceIndexPath.section] == currentEditingSection &&
       [self sectionTag:destinationIndexPath.section] == currentEditingSection) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if(currentEditingSection == SectionAddItemDetails) {
                [[self baseObject] moveAddItemDetailFromIndex:sourceIndexPath.row toIndex:destinationIndexPath.row];
                [self saveAddItemDetailsSettings];
            }
            [self updateCellsTypeInSection:[self sectionIndex:currentEditingSection]];
        });
    }
}

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath
       toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath {
    if (proposedDestinationIndexPath.row >= [self numberOfRowsInAddItemDetailsSection] - 1) {
       NSUInteger newIndex = [self numberOfRowsInAddItemDetailsSection] - 2;
       return [NSIndexPath indexPathForRow:newIndex inSection:0];
    }
    return proposedDestinationIndexPath;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
  if([cell respondsToSelector:@selector(setCellWidth:)])
    [(BaseTableCell *)cell setCellWidth:tableView.frame.size.width];
}

#pragma mark - TEXTFIELD DELEGATE

-(BOOL)textFieldShouldBeginEditing:(UITextField*)textField {
  [theToolbar setAlpha:1.0];
  
  isNewEditingField = NO;
  if(currentTextView || currentTextfield) {
    isNewEditingField = YES;
  }
  
  [UIView animateWithDuration:0.25 animations:^{
    [theToolbar setFrame:CGRectMake(0, dvc_height - keyboard_height - 40, dvc_width, 40)];
    [myTableView setFrame:CGRectMake(myTableView.frame.origin.x,
                                     myTableView.frame.origin.y,
                                     dvc_width,
                                     dvc_height - 82 - keyboard_height)];
  }];
  
  return YES;
}

-(BOOL)textFieldShouldEndEditing:(UITextField*)textField {
  if(!isNewEditingField) {
    [UIView animateWithDuration:0.25 animations:^{
      [theToolbar setFrame:CGRectMake(0, dvc_height, dvc_width, 40)];
    }];
  }
	
	return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField*)textField {
  isNewEditingField = NO;
	[textField resignFirstResponder];
	return YES;
}

-(void)textFieldDidBeginEditing:(UITextField*)textField {    
    currentTextfield = textField;
    currentTextView = nil;
    
    if(![self isTitleTextfieldWithTag:textField.tag]) {
        NSString * surplus = @"";
        
        if(textField.tag == RowRate) {
            [textField setText:[data_manager currencyStrippedString:textField.text]];
            if ([textField.text floatValue] == 0.0f) {
                [textField setText:@""];
            }
        } if (textField.tag == RowQuantity) {
          [textField setText:@""];
        } else if (textField.tag == RowDiscount) {
            surplus = [NSString stringWithFormat:@" %c", '%'];
            
            [textField setText:[textField.text stringByReplacingOccurrencesOfString:surplus withString:@""]];
            
            if ([textField.text floatValue] == 0.0f) {
                [textField setText:@""];
            }
        }
    }
}

-(void)textFieldDidEndEditing:(UITextField*)textField {
    NSString *editedValue = textField.text.length > 0?textField.text:textField.placeholder;
    NSInteger titleIndex = textField.tag;
    if([self isTitleTextfieldWithTag:textField.tag]) {
        titleIndex = [self titleIndex:textField.tag];
        [[self baseObject] setAddItemDetailTitle:editedValue forType:titleIndex];
    } else {
        if(textField.tag == RowAddItem) {
          if([textField.text length] > 0) {
            if (theProduct) {
                [theProduct setName:textField.text];
            } else if (theService) {
                [theService setName:textField.text];
            }
          }
        } if(textField.tag == RowRate) {
            if (theProduct) {
                [theProduct setPrice:[textField.text floatValue]];
            } else if (theService) {
                [theService setPrice:[textField.text floatValue]];
            }
        } else if (textField.tag == RowCode) {
            if(theProduct) {
                [theProduct setCode:textField.text];
            }
        } else if (textField.tag == RowQuantity) {
            if (theProduct) {
                [theProduct setQuantity:[data_manager trimmedQuantity:[textField.text floatValue]]];
            } else if (theService) {
                [theService setQuantity:[data_manager trimmedQuantity:[textField.text floatValue]]];
            }
        } else if (textField.tag == RowDiscount) {
            if (theProduct) {
                [theProduct setDiscount:[textField.text floatValue]];
            } else if (theService) {
                [theService setDiscount:[textField.text floatValue]];
            }
        } else if (textField.tag >= RowCustom1 && textField.tag <= RowCustom2) {
          if (theProduct) {
            [theProduct setValue:textField.text forCustomType:textField.tag];
          } else if (theService) {
            [theService setValue:textField.text forCustomType:textField.tag];
          }
        }
    }
    if(!isNewEditingField) {
        currentTextfield = nil;
        if(!myTableView.editing) {
            [myTableView reloadData];
        }
    }
}

#pragma mark - UITextViewDelegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    isNewEditingField = NO;
    if(currentTextView || currentTextfield) {
        isNewEditingField = YES;
    }
    
    currentTextfield = nil;
    currentTextView = textView;
    [theToolbar setAlpha:1.0];
    
    [UIView animateWithDuration:0.25 animations:^{
        [theToolbar setFrame:CGRectMake(0, dvc_height - keyboard_height - 40, dvc_width, 40)];
        [myTableView setFrame:CGRectMake(myTableView.frame.origin.x,
                                         myTableView.frame.origin.y,
                                         dvc_width,
                                         dvc_height - 82 - keyboard_height)];
    } completion:^(BOOL finished) {
        NSIndexPath *descriptionIP = [NSIndexPath indexPathForRow:[self indexOfAddItemType:RowDescription] inSection:0];
        [myTableView scrollToRowAtIndexPath:descriptionIP atScrollPosition:UITableViewScrollPositionNone animated:YES];
    }];
    
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
    if(textView.tag == RowDescription) {
        if (theProduct) {
            [theProduct setNote:textView.text];
        } else if (theService) {
            [theService setNote:textView.text];
        }
    }
    
    if(!isNewEditingField) {
        [UIView animateWithDuration:0.25 animations:^{
            [myTableView setFrame:CGRectMake(myTableView.frame.origin.x, myTableView.frame.origin.y, myTableView.frame.size.width, (theSelfView.frame.size.height - 42))];
            [theToolbar setFrame:CGRectMake(0, dvc_height, dvc_width, 40)];
        }];
        
        currentTextView = nil;
    }
    
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if([text isEqualToString:@"\n"]) {
        isNewEditingField = NO;
        [self closePicker:nil];
        return NO;
    }
    
    NSString * result = [textView.text stringByReplacingCharactersInRange:range withString:text];
    
    if (result.length > 450)
        return NO;
    
    return YES;
}

#pragma mark - CELL GENERATION

-(UITableViewCell*)cellInSection:(int)section atRow:(int)row {
    switch (section) {
        case 0: {
            NSDictionary *detailsSettings = [[self addItemDetailsRowsWhenEditing:detailsSectionIsEditing] objectAtIndex:row];
            NSInteger cellType = [detailsSettings[TYPE] integerValue];
            BaseTableCell *cell = [self detailedeCellAtRow:(int)cellType];
            [cell setAutolayoutForValueField];
            
            return cell;
            break;
        }
            default:
            break;
    }
    return nil;
}

-(BaseTableCell*)detailedeCellAtRow:(int)row {
    BaseTableCell * theCell;

    switch (row) {
        case RowAddItem: {
          theCell = [myTableView dequeueReusableCellWithIdentifier:@"tableCellPush"];
          
          if (!theCell) {
              theCell = [[CellWithPush alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"tableCellPush"];
          }
          
          NSString *value = @"";
          if(theProduct) {
              value = theProduct.name;
          } else if (theService) {
              value = theService.name;
          }
          
          [(CellWithPush*)theCell loadTitle:[[self baseObject] addItemDetailTitleForType:row]
                                   andValue:value
                                   cellType:[self addItemDetailsCellTypeForRowType:RowAddItem]
                                    andSize:20.0];
          [(CellWithPush*)theCell setValueTextfieldDelegate:self tag:row];
          [theCell setUserInteractionEnabled:YES];
          [theCell setCanEditvalueField:YES];
          [theCell setIsTitleEditable:YES delegate:self tag:TextfieldOffsetTag + row];
          [theCell setValuePlaceholder:@"Enter item name"];
          [theCell makeValueBigger:YES];
            
            break;
        }
            
        case RowDescription: {
            theCell = [myTableView dequeueReusableCellWithIdentifier:@"descriptionCell"];
            
            if (!theCell) {
                theCell = [[DescriptionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"descriptionCell"];
            }
            
            NSString *note = @"";
            if([theProduct.note length] > 0) {
                note = theProduct.note;
            } else if ([theService.note length] > 0) {
                note = theService.note;
            }
            
            [(DescriptionCell*)theCell loadTitle:[[self baseObject] addItemDetailTitleForType:row]
                                        andValue:note
                                             tag:row
                               textFieldDelegate:self
                                        cellType:[self addItemDetailsCellTypeForRowType:RowDescription]
                                 andKeyboardType:UIKeyboardTypeDefault];
            
            [theCell setUserInteractionEnabled:YES];
            [theCell setIsTitleEditable:YES delegate:self tag:TextfieldOffsetTag + row];
            
            break;
        }
            
        case RowRate: {
            theCell = [myTableView dequeueReusableCellWithIdentifier:@"tableCellText"];
            
            if (!theCell) {
                theCell = [[CellWithText alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"tableCellText"];
            }
            
            CGFloat price = 0.f;
            if(theProduct) {
                price = theProduct.price;
            } else if (theService) {
                price = theService.price;
            }
            
            [(CellWithText*)theCell loadTitle:[[self baseObject] addItemDetailTitleForType:row]
                                     andValue:[data_manager currencyAdjustedValue:price]
                                          tag:row
                            textFieldDelegate:self
                                     cellType:[self addItemDetailsCellTypeForRowType:RowRate]
                              andKeyboardType:UIKeyboardTypeDecimalPad];
            [theCell setUserInteractionEnabled:YES];
            [theCell setCanEditvalueField:YES];
            [theCell setIsTitleEditable:YES delegate:self tag:TextfieldOffsetTag + row];
            
            break;
        }
        
        case RowCode: {
            theCell = [myTableView dequeueReusableCellWithIdentifier:@"tableCellText"];
            
            if (!theCell) {
                theCell = [[CellWithText alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"tableCellText"];
            }
            
            NSString *code = @"";
            BOOL enableCode = theProduct != nil || theService == nil;
            if(theProduct) {
                code = theProduct.code;
                enableCode = YES;
            }
            
            [(CellWithText*)theCell loadTitle:[[self baseObject] addItemDetailTitleForType:row]
                                     andValue:code
                                          tag:row
                            textFieldDelegate:self
                                     cellType:[self addItemDetailsCellTypeForRowType:RowCode]
                              andKeyboardType:UIKeyboardTypeDefault];
            [theCell setUserInteractionEnabled:YES];
            [(CellWithText*)theCell setAutoCapitalizationType:UITextAutocapitalizationTypeSentences];
            [theCell setCanEditvalueField:enableCode];
            [theCell setIsTitleEditable:YES delegate:self tag:TextfieldOffsetTag + row];
            
            break;
        }
            
        case RowQuantity: {
            theCell = [myTableView dequeueReusableCellWithIdentifier:@"tableCellText"];
            
            if (!theCell) {
                theCell = [[CellWithText alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"tableCellText"];
            }
            
            NSString * value;
            NSString *valueText = @"";
            NSString * unit;
            if (theProduct) {
                valueText = [NSString stringWithFormat:@"%g %@", [theProduct quantity], [theProduct rawUnit]];
                value = [NSString stringWithFormat:@"%g", [theProduct quantity]];
                unit = [theProduct rawUnit];
            } else if (theService) {
                valueText = [NSString stringWithFormat:@"%g %@", [theService quantity], [theService rawUnit]];
                value = [NSString stringWithFormat:@"%g", [theService quantity]];
                unit = [theService rawUnit];
            }
            NSArray * components = [value componentsSeparatedByString:@"."];
            
            if (components.count > 1) {
                NSString * afterPoint = [components objectAtIndex:1];
                
                switch ([data_manager decimalPlacement]){
                    case kPlacementForDecimalOneDigit: {
                        valueText = [NSString stringWithFormat:@"%.1f %@", [value floatValue], unit];
                        break;
                    }
                    case kPlacementForDecimalTwoDigits: {
                        if (afterPoint.length > 2) {
                            valueText = [NSString stringWithFormat:@"%.2f %@", [value floatValue], unit];
                        }
                        break;
                    }
                    case kPlacementForDecimalThreeDigits: {
                        if (afterPoint.length > 3) {
                            valueText = [NSString stringWithFormat:@"%.3f %@", [value floatValue], unit];
                        }
                        break;
                    }
                    case kPlacementForDecimalNone: {
                        valueText = [NSString stringWithFormat:@"%i %@", [value intValue], unit];
                        break;
                    }
                    default:
                        break;
                }
            }
            
            [(CellWithText*)theCell loadTitle:[[self baseObject] addItemDetailTitleForType:row]
                                     andValue:valueText
                                          tag:row
                            textFieldDelegate:self
                                     cellType:[self addItemDetailsCellTypeForRowType:RowQuantity]
                              andKeyboardType:UIKeyboardTypeDecimalPad];
            [theCell setUserInteractionEnabled:YES];
            [theCell setCanEditvalueField:YES];
            [theCell setIsTitleEditable:YES delegate:self tag:TextfieldOffsetTag + row];
            
            break;
        }
        case RowDiscount: {
            theCell = [myTableView dequeueReusableCellWithIdentifier:@"tableCellText"];
            
            if (!theCell) {
                theCell = [[CellWithText alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"tableCellText"];
            }
            
            NSString *discount = @"";
            if (theProduct) {
                discount = [NSString stringWithFormat:@"%.2f %c", [theProduct discount], '%'];
            }
            else if (theService) {
                discount = [NSString stringWithFormat:@"%.2f %c", [theService discount], '%'];
            }
            
            [(CellWithText*)theCell loadTitle:[[self baseObject] addItemDetailTitleForType:row]
                                     andValue:discount
                                          tag:row
                            textFieldDelegate:self
                                     cellType:[self addItemDetailsCellTypeForRowType:RowDiscount]
                              andKeyboardType:UIKeyboardTypeDecimalPad];
            [theCell setUserInteractionEnabled:YES];
            [theCell setCanEditvalueField:YES];
            [theCell setIsTitleEditable:YES delegate:self tag:TextfieldOffsetTag + row];
            
            break;
        }
        
        case RowTotal: {
            theCell = [myTableView dequeueReusableCellWithIdentifier:@"tableCellText"];
            
            if (!theCell) {
                theCell = [[CellWithText alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"tableCellText"];
            }
            
            NSString *value = @"";
            if (theProduct) {
                value = [NSString stringWithFormat:@"%@", [data_manager currencyAdjustedValue:[theProduct total]]];
            } else if (theService) {
                value = [NSString stringWithFormat:@"%@", [data_manager currencyAdjustedValue:[theService total]]];
            }
            
            [(CellWithText*)theCell loadTitle:[[self baseObject] addItemDetailTitleForType:row]
                                     andValue:value
                                          tag:row
                            textFieldDelegate:self
                                     cellType:[self addItemDetailsCellTypeForRowType:RowTotal]
                              andKeyboardType:UIKeyboardTypeDecimalPad];
            [theCell setUserInteractionEnabled:YES];
            [theCell setCanEditvalueField:NO];
            [theCell setIsTitleEditable:YES delegate:self tag:TextfieldOffsetTag + row];
            
            break;
        }
        
      case RowCustom1:
      case RowCustom2: {
        theCell = [myTableView dequeueReusableCellWithIdentifier:@"tableCellEditField"];
        
        if (!theCell) {
          theCell = [[CellWithEditField alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"tableCellEditField"];
        }
        
        [(CellWithEditField*)theCell loadTitle:[[self baseObject] addItemDetailTitleForType:row]
                                           tag:row + CustomTextfieldTitleOffset
                             textFieldDelegate:self
                                      cellType:[self addItemDetailsCellTypeForRowType:row]
                               andKeyboardType:UIKeyboardTypeDefault];
        
        NSString *value = @"";
        if(theProduct) {
          value = [theProduct valueForCustomType:row];
        } else if (theService) {
          value = [theService valueForCustomType:row];
        }
        [(CellWithEditField*)theCell setValueField:value tag:row];
        [theCell setAutolayoutForValueField];
        
      }
        break;
        
        default:
            break;
    }
    
    [theCell setSelectionStyle:UITableViewCellSelectionStyleBlue];
    return theCell;
}

#pragma mark - CELL SELECTION

-(void)selectedCellInSection:(int)section atRow:(int)row {
    switch (section) {
        case 0: {
            [self selectItem:nil];
            break;
        }
            default:
            break;
    }
}

#pragma mark - PRODUCT CREATOR DELEGATE

-(void)creatorViewController:(CreateOrEditProductVC*)viewController createdObject:(ProductOBJ*)product {
    theService = nil;
    theProduct = product;
    
    [self saveNewProduct:product];
}

- (void)saveNewProduct:(ProductOBJ *)product {
    if(product) {
        [sync_manager updateCloud:[product contentsDictionary] andPurposeForDelete:1];
        
        NSMutableArray *array_with_products = [NSMutableArray arrayWithArray:[data_manager loadProductsArrayFromUserDefaultsAtKey:kProductsKeyForNSUserDefaults]];
        [array_with_products addObject:product];
        
        [data_manager saveProductsArrayToUserDefaults:array_with_products forKey:kProductsKeyForNSUserDefaults];
    }
}

#pragma mark - VIEW CONTROLLER FUNCTIONS

- (void)updateProductAndService {
    NSMutableArray *array_with_products = [NSMutableArray new];
    NSMutableArray *array_with_services = [NSMutableArray new];
    
    NSArray * arrayOfAll = [data_manager loadProductsArrayFromUserDefaultsAtKey:kProductsKeyForNSUserDefaults];
    
    for (NSObject * temp in arrayOfAll) {
        if ([temp isKindOfClass:[ProductOBJ class]]) {
            [array_with_products addObject:temp];
        } else if ([temp isKindOfClass:[ServiceOBJ class]]) {
            [array_with_services addObject:temp];
        }
    }
    [self sortProductArray:array_with_products];
    [self sortProductArray:array_with_services];
    
    //prod
    if(theProduct) {
        [sync_manager updateCloud:[theProduct contentsDictionary] andPurposeForDelete:0];
        [array_with_products replaceObjectAtIndex:theProduct.indexInCollection withObject:theProduct];
    }
    
    //serv
    if(theService) {
        [sync_manager updateCloud:[theService contentsDictionary] andPurposeForDelete:0];
        [array_with_services replaceObjectAtIndex:theService.indexInCollection withObject:theService];
    }
    
    NSMutableArray * array = [[NSMutableArray alloc] init];
    [array addObjectsFromArray:array_with_products];
    [array addObjectsFromArray:array_with_services];
    
    [data_manager saveProductsArrayToUserDefaults:array forKey:kProductsKeyForNSUserDefaults];
}

-(void)sortProductArray:(NSMutableArray *)array {
    NSComparisonResult (^myComparator)(id, id) = ^NSComparisonResult(ProductOBJ * obj1, ProductOBJ * obj2) {
        return [[[obj1 name] uppercaseString] compare:[[obj2 name] uppercaseString]];
    };
    [array sortUsingComparator:myComparator];
}

-(void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

#pragma mark - NSNotificationCenter

-(void)keyboardFrameChanged:(NSNotification*)notification {
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

@end