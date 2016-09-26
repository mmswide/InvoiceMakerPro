//
//  InvoicesVC.h
//  Invoice
//
//  Created by XGRoup5 on 8/13/13.
//  Copyright (c) 2013 XGRoup. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CategorySelectV.h"
#import "CustomVC.h"

typedef enum {

	kSectionNone = -1,
	kSectionOpen = 0,
	kSectionPaid,
	kSectionOverdue
	
} kSection;

@class TableWithShadow;

@interface InvoicesVC : CustomVC

{
	UITableView * invoicesTableView;
	NSMutableArray * array_with_invoices;

	NSMutableArray *openInvoicesArray;
	NSMutableArray *paidInvoicesArray;
	NSMutableArray *overdueInvoicesArray;
			
	int index_of_invoice;
	
	kSection selected_section;
	
	CategorySelectV *categoryBar;
}

-(id)init;
-(id)initWithInvoices:(NSArray*)sender;
-(void)back:(UIButton*)sender;
-(void)createInvoice:(UIButton*)sender;

@end