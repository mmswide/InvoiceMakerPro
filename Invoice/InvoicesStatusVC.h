//
//  InvoicesStatusVC.h
//  Invoice
//
//  Created by XGRoup5 on 8/22/13.
//  Copyright (c) 2013 XGRoup. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CustomVC.h"
#import "CategorySelectV.h"

@class ClientOBJ;
@class ProjectOBJ;
@class TableWithShadow;

@interface InvoicesStatusVC : CustomVC

{
	ClientOBJ * theClient;
	ProjectOBJ *theProject;
	
	NSArray * overdue_invoices_array;
	NSArray * current_invoices_array;
	NSArray * paid_invoices_array;
	
	TableWithShadow * mainTableView;
	
	CategorySelectV *categoryBar;
	
	int categorySelected;
}

-(id)initWithClient:(ClientOBJ*)sender;
-(id)initWithProject:(ProjectOBJ*)sender;

-(void)back:(UIButton*)sender;

@end