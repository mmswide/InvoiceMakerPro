//
//  OtherCommentsVC.h
//  Invoice
//
//  Created by Paul on 16/04/14.
//  Copyright (c) 2014 XGRoup. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AlwaysShowViewController.h"

@class InvoiceOBJ;
@class QuoteOBJ;
@class EstimateOBJ;
@class PurchaseOrderOBJ;
@class TimeSheetOBJ;

@interface OtherCommentsVC : AlwaysShowViewController

{
	UIView * oTitleView;
	UIView * oTextView;
	UIImageView * secondBgForText;
	UITextView * secondTextView;
}

-(id)initWithInvoice:(InvoiceOBJ*)sender;
-(id)initWithQuote:(QuoteOBJ*)sender;
-(id)initWithEstimate:(EstimateOBJ*)sender;
-(id)initWithPurchaseOrder:(PurchaseOrderOBJ*)sender;
-(id)initWithTimesheet:(TimeSheetOBJ*)sender;

@end
