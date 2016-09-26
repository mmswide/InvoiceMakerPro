//
//  AddNoteVC.h
//  Invoice
//
//  Created by XGRoup5 on 8/23/13.
//  Copyright (c) 2013 XGRoup. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AlwaysShowViewController.h"

@class InvoiceOBJ;
@class EstimateOBJ;
@class QuoteOBJ;
@class PurchaseOrderOBJ;
@class TimeSheetOBJ;

@interface AddNoteVC : AlwaysShowViewController

{
	UIView * firstPageView;
	UIView * secondPageView;
	UIImageView * secondBgForText;
	UITextView * secondTextView;
    
    UIView *realActiveView;
}

-(id)initWithInvoice:(InvoiceOBJ*)sender;
-(id)initWithEstimate:(EstimateOBJ*)sender;
-(id)initWithQuote:(QuoteOBJ*)sender;
-(id)initWithPO:(PurchaseOrderOBJ*)sender;
-(id)initWithTimesheet:(TimeSheetOBJ*)sender;

@end