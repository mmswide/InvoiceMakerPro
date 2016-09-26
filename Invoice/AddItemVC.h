//
//  AddItemVC.h
//  Invoice
//
//  Created by Paul on 06/05/14.
//  Copyright (c) 2014 XGRoup. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomVC.h"

@class InvoiceOBJ;
@class EstimateOBJ;
@class QuoteOBJ;
@class PurchaseOrderOBJ;
@class AddItemVC;
@class ProductOBJ;
@class ServiceOBJ;
@class ToolBarView;

@protocol AddItemDelegate <NSObject>

-(void)viewController:(AddItemVC*)vc addedProduct:(ProductOBJ*)sender atIndex:(NSInteger)index;
-(void)viewController:(AddItemVC*)vc addedService:(ServiceOBJ*)sender atIndex:(NSInteger)index;

@end

@interface AddItemVC : CustomVC

{
	InvoiceOBJ * theInvoice;
	EstimateOBJ * theEstimate;
	QuoteOBJ * theQuote;
	PurchaseOrderOBJ * thePurchareOrder;
	NSInteger index;
	ProductOBJ * theProduct;
	ServiceOBJ * theService;
	UILabel * itemNameLabel;
	UITextField * quantityTextField;
	UITextField * discountTextField;
	UILabel * totalLabel;
    
  UITextField *currentTextfield;
  UITextView *currentTextView;
  
  BOOL isManualProduct;
  BOOL isNewEditingField;
}

@property (weak) id<AddItemDelegate> delegate;

-(id)initWithInvoice:(InvoiceOBJ*)sender index:(NSInteger)i;
-(id)initWithEstimate:(EstimateOBJ*)sender index:(NSInteger)i;
-(id)initWithQuote:(QuoteOBJ*)sender index:(NSInteger)i;
-(id)initWithPO:(PurchaseOrderOBJ*)sender index:(NSInteger)i;

@end