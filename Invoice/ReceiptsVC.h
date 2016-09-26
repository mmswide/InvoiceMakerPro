//
//  ReceiptsVC.h
//  Invoice
//
//  Created by XGRoup on 7/15/14.
//  Copyright (c) 2014 XGRoup. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CustomVC.h"
#import "ReceiptCell.h"
#import "MenuV.h"

typedef enum {
	
	kSectionWeek = 0,
	kSectionMonth,
	kSectionYear
	
} kReceiptSection;

@class CategorySelectV;

@interface ReceiptsVC : CustomVC
{
	UITableView * receiptTableView;
	NSMutableArray * array_with_receipts;
	
	NSMutableArray *weekReceipts;
	NSMutableArray *monthReceipts;
	NSMutableArray *yearReceipts;
	
	int index_of_receipt;
	
	kReceiptSection selected_section;
	
	CategorySelectV *categoryBar;
	
	MenuV *menuView;
	UIButton *cancel;
	
	int lastOriginX;
}

-(id)init;
-(id)initWithReceipt:(NSArray*)sender;

-(void)back:(UIButton*)sender;
-(void)createReceipt:(UIButton*)sender;

@end
