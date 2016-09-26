//
//  CreateReceiptVC2.h
//  Invoice
//
//  Created by XGRoup on 7/15/14.
//  Copyright (c) 2014 XGRoup. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CustomVC.h"

@class CreateReceiptVC;
@class ScrollWithShadow;
@class ToolBarView;
@class ReceiptOBJ;
@class ClientOBJ;
@class CreateInvoiceVC;

@protocol ReceiptCreatorDelegate <NSObject>

-(void)creatorViewController:(CreateReceiptVC*)viewController createdReceipt:(ReceiptOBJ*)receipt;

@end

@interface CreateReceiptVC : CustomVC
{
	ReceiptOBJ * theReceipt;
	BOOL has_alertview;
	
	int currentRow;
	int typeOfTax;
	
	UIButton *percentage;
	UIButton *value;
}

@property (weak) id<ReceiptCreatorDelegate> delegate;

-(id)initForCreationWithDelegate:(id<ReceiptCreatorDelegate>)del;
-(id)initWithReceipt:(ReceiptOBJ*)sender delegate:(id<ReceiptCreatorDelegate>)del;
-(void)cancel:(UIButton*)sender;
-(void)done:(UIButton*)sender;

-(UITableViewCell*)cellInSection:(int)section atRow:(int)row;

-(void)selectedCellInSection:(int)section atRow:(int)row;

-(void)openPicker;
-(void)closePicker:(UIButton*)sender;

@end
