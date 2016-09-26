//
//  ClientsVC.h
//  Invoice
//
//  Created by XGRoup5 on 8/13/13.
//  Copyright (c) 2013 XGRoup. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CellWithClient.h"
#import "CustomVC.h"

@class TableWithShadow;
@class InvoiceOBJ;
@class EstimateOBJ;
@class QuoteOBJ;
@class PurchaseOrderOBJ;
@class ProjectOBJ;
@class ReceiptOBJ;
@class TimeSheetOBJ;

@interface ClientsVC : CustomVC

{
	TableWithShadow * clientsTableView;
	NSMutableArray * array_with_clients;
  
  InvoiceOBJ * theInvoice;
  EstimateOBJ * theEstimate;
  QuoteOBJ * theQuote;
  PurchaseOrderOBJ * thePurchareOrder;
  ProjectOBJ *theProject;
  ReceiptOBJ *theReceipt;
  TimeSheetOBJ *theTimesheet;
}

-(id)initWithInvoice:(InvoiceOBJ*)sender;
-(id)initWithEstimate:(EstimateOBJ*)sender;
-(id)initWithQuote:(QuoteOBJ*)sender;
-(id)initWithPO:(PurchaseOrderOBJ*)sender;
-(id)initWithProject:(ProjectOBJ*)sender;
-(id)initWithReceipt:(ReceiptOBJ*)sender;
-(id)initWithTimesheet:(TimeSheetOBJ*)sender;

-(id)init;
-(void)createClient:(UIButton*)sender;

@end
