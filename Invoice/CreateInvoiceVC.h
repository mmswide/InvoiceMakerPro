//
//  CreateInvoiceVC.h
//  Invoice
//
//  Created by XGRoup5 on 8/15/13.
//  Copyright (c) 2013 XGRoup. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CustomVC.h"

typedef enum {
	
	kPickerCaseTerms = 0,
	kPickerCaseDate,
	kPickerCaseDueDate
	
} kPickerCase;

@class ToolBarView;
@class ClientOBJ;
@class CreateInvoiceVC;
@class InvoiceOBJ;
@class BaseTableCell;

@protocol InvoiceCreatorDelegate <NSObject>

-(void)creatorViewController:(CreateInvoiceVC*)viewController createdInvoice:(InvoiceOBJ*)invoice;

@end

@interface CreateInvoiceVC : CustomVC {
	InvoiceOBJ * theInvoice;
	kPickerCase current_picker_type;
	UIButton * percentage;
	UIButton * value;
	BOOL has_alertview;
  
  InvoiceOBJ *openedInvoice;
}

@property (weak) id<InvoiceCreatorDelegate> delegate;

-(id)initForCreationWithDelegate:(id<InvoiceCreatorDelegate>)del;
-(id)initWithInvoice:(InvoiceOBJ*)sender delegate:(id<InvoiceCreatorDelegate>)del;
-(void)cancel:(UIButton*)sender;
-(void)done:(UIButton*)sender;
-(void)showPercentageAndValue;
-(void)hidePercentageAndValue;
-(void)percentage:(UIButton*)sender;
-(void)value:(UIButton*)sender;

-(UITableViewCell*)cellInSection:(int)section atRow:(int)row;
-(UITableViewCell*)titleCellAtRow:(int)row;
-(UITableViewCell*)productCellAtRow:(int)row;
-(BaseTableCell*)valuesCellAtRow:(int)row;
-(UITableViewCell*)otherCellAtRow:(int)row;

-(void)selectedCellInSection:(int)section atRow:(int)row;
-(void)selectedTitleCellAtRow:(int)row;
-(void)selectedProductCellAtRow:(int)row;
-(void)selectedValuesCellAtRow:(int)row;
-(void)selectedOtherCellAtRow:(int)row;

-(void)openPickerForCase:(kPickerCase)pickerCase;
-(void)closePicker:(UIButton*)sender;

@end
