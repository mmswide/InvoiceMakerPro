//
//  CreatePOVC.h
//  Invoice
//
//  Created by XGRoup5 on 8/27/13.
//  Copyright (c) 2013 XGRoup. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CustomVC.h"

@class ScrollWithShadow;
@class ClientOBJ;
@class CreatePOVC;
@class PurchaseOrderOBJ;
@class BaseTableCell;

@protocol PurchaseOrderCreatorDelegate <NSObject>

-(void)creatorViewController:(CreatePOVC*)viewController createdPO:(PurchaseOrderOBJ*)PO;

@end

@interface CreatePOVC : CustomVC

{
	PurchaseOrderOBJ * thePurchaseOrder;
	UIButton * percentage;
	UIButton * value;
	BOOL has_alertview;
  
  PurchaseOrderOBJ *openedPO;
}

@property (weak) id<PurchaseOrderCreatorDelegate> delegate;

-(id)initForCreationWithDelegate:(id<PurchaseOrderCreatorDelegate>)del;
-(id)initWithPO:(PurchaseOrderOBJ*)sender delegate:(id<PurchaseOrderCreatorDelegate>)del;
-(void)cancel:(UIButton*)sender;
-(void)done:(UIButton*)sender;

-(void)showPercentageAndValue;
-(void)hidePercentageAndValue;
-(void)percentage:(UIButton*)sender;
-(void)value:(UIButton*)sender;

-(BaseTableCell*)cellInSection:(int)section atRow:(int)row;
-(BaseTableCell*)clientCellAtRow:(int)row;
-(BaseTableCell*)productCellAtRow:(int)row;
-(BaseTableCell*)valuesCellAtRow:(int)row;
-(BaseTableCell*)otherCellAtRow:(int)row;

-(void)selectedCellInSection:(int)section atRow:(int)row;
-(void)selectedClientCellAtRow:(int)row;
-(void)selectedProductCellAtRow:(int)row;
-(void)selectedValuesCellAtRow:(int)row;
-(void)selectedOtherCellAtRow:(int)row;

-(void)closePicker:(UIButton*)sender;

@end