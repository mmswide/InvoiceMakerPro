//
//  EditTitleVC.h
//  Invoice
//
//  Created by Paul on 24/03/14.
//  Copyright (c) 2014 XGRoup. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomVC.h"

@class InvoiceOBJ;
@class EstimateOBJ;
@class QuoteOBJ;
@class PurchaseOrderOBJ;
@class ReceiptOBJ;
@class TimeSheetOBJ;

@interface EditTitleVC : CustomVC

{
	InvoiceOBJ * theInvoice;
	EstimateOBJ * theEstimate;
	QuoteOBJ * theQuote;
	PurchaseOrderOBJ * thePurchareOrder;
	ReceiptOBJ *theReceipt;
	TimeSheetOBJ *theTimesheet;
}

-(id)initWithInvoice:(InvoiceOBJ*)sender;
-(id)initWithEstimate:(EstimateOBJ*)sender;
-(id)initWithQuote:(QuoteOBJ*)sender;
-(id)initWithPO:(PurchaseOrderOBJ*)sender;
-(id)initWithReceipt:(ReceiptOBJ*)sender;
-(id)initWithTimesheet:(TimeSheetOBJ*)sender;

@end
