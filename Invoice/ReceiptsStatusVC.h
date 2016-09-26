//
//  ReceiptsStatusVC.h
//  Invoice
//
//  Created by XGRoup on 7/22/14.
//  Copyright (c) 2014 XGRoup. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CustomVC.h"
#import "CategorySelectV.h"
#import "ReceiptsVC.h"

@class ClientOBJ;
@class ProjectOBJ;
@class TableWithShadow;

@interface ReceiptsStatusVC : CustomVC
{
	ClientOBJ * theClient;
	ProjectOBJ *theProject;

	NSArray *array_with_receipts;
	NSMutableArray *weekReceipts;
	NSMutableArray *monthReceipts;
	NSMutableArray *yearReceipts;
	
	TableWithShadow * receiptTableView;
	
	CategorySelectV *categoryBar;
	
	kReceiptSection selected_section;
}

-(id)initWithClient:(ClientOBJ*)sender;
-(id)initWithProject:(ProjectOBJ*)sender;

-(void)back:(UIButton*)sender;

@end
