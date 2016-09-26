//
//  LanguageVC.h
//  Invoice
//
//  Created by XGRoup on 8/6/14.
//  Copyright (c) 2014 XGRoup. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CustomVC.h"

@class ToolBarView;
@class TableWithShadow;
@class ScrollWithShadow;

@interface LanguageVC : CustomVC
{
	TableWithShadow * mainTableView;
	
	int currentRow;
	
	NSMutableArray *invoiceKeys;
	NSMutableArray *quoteKeys;
	NSMutableArray *estimateKeys;
	NSMutableArray *purchaseKeys;
	NSMutableArray *receiptsKeys;
	NSMutableArray *timesheetKeys;
	
	NSMutableDictionary *invoiceDict;
	NSMutableDictionary *quoteDict;
	NSMutableDictionary *estimateDict;
	NSMutableDictionary *purchaseDict;
	NSMutableDictionary *receiptDict;
	NSMutableDictionary *timesheetDict;
    
    UITextField *currentTextField;
}

@end
