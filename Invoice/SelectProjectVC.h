//
//  SelectProjectVC.h
//  Invoice
//
//  Created by Paul on 18/06/14.
//  Copyright (c) 2014 XGRoup. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TableWithShadow.h"

#import "CustomVC.h"
#import "CategorySelectV.h"

@class InvoiceOBJ;
@class EstimateOBJ;
@class QuoteOBJ;
@class PurchaseOrderOBJ;
@class ReceiptOBJ;
@class TimeSheetOBJ;

@interface SelectProjectVC : CustomVC
{
	TableWithShadow *projectsTableView;
	
	InvoiceOBJ * theInvoice;
	EstimateOBJ * theEstimate;
	QuoteOBJ * theQuote;
	PurchaseOrderOBJ * thePurchareOrder;
	ReceiptOBJ *theReceipt;
	TimeSheetOBJ *theTimesheet;
	
	NSMutableArray *array_with_projects;
	NSMutableArray *array_with_completed_projects;
	NSMutableArray *array_with_open_projects;
	
	CategorySelectV *categoryBar;
	
	int categorySelected;
}

-(id)initWithInvoice:(InvoiceOBJ*)sender;
-(id)initWithEstimate:(EstimateOBJ*)sender;
-(id)initWithQuote:(QuoteOBJ*)sender;
-(id)initWithPO:(PurchaseOrderOBJ*)sender;
-(id)initWithReceipt:(ReceiptOBJ*)sender;
-(id)initWithTimesheet:(TimeSheetOBJ*)theTimeSheet;

@end
