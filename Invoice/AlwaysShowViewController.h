//
//  AlwaysShowViewController.h
//  Invoice
//
//  Created by Dmytro Nosulich on 6/12/15.
//  Copyright (c) 2015 XGRoup. All rights reserved.
//

#import "CustomVC.h"

#define ALWAYS_SHOW_HEIGHT 40.f

typedef NS_ENUM(NSInteger, AlwaysShowType) {
  AlwaysShowTypeSignatyreLeft,
  AlwaysShowTypeSignatyreRight,
  AlwaysShowTypeNote,
  AlwaysShowTypeOtherComment
};

@class InvoiceOBJ;
@class QuoteOBJ;
@class EstimateOBJ;
@class PurchaseOrderOBJ;
@class TimeSheetOBJ;

@interface AlwaysShowViewController : CustomVC {
  
  UIView * oAlwaysView;
  
  InvoiceOBJ * theInvoice;
  QuoteOBJ * theQuote;
  EstimateOBJ * theEstimate;
  PurchaseOrderOBJ * thePurchaseOrder;
  TimeSheetOBJ *theTimesheet;
  
  AlwaysShowType alwaysShowType;
}

- (BOOL)addAlwaysShowSwitchAfterY:(CGFloat)y;

@end
