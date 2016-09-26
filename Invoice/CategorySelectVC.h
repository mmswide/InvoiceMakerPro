//
//  CategorySelectVC.h
//  Invoice
//
//  Created by XGRoup on 7/15/14.
//  Copyright (c) 2014 XGRoup. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ScrollWithShadow;
@class TableWithShadow;
@class ToolBarView;
@class ReceiptOBJ;

@interface CategorySelectVC : UIViewController
{
	UIView *theSelfView;
	
	ScrollWithShadow *mainScrollView;
	TableWithShadow *myTableView;
	
	BOOL categoryAdded;
	
	ToolBarView *theToolbar;
	
	NSMutableArray *categoriesArray;
	
	ReceiptOBJ *theReceipt;
}

-(id)initWithReceipt:(ReceiptOBJ*)sender;

@end
