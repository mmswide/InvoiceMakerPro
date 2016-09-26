//
//  PurchaseOrdersVC.h
//  Invoice
//
//  Created by XGRoup5 on 8/13/13.
//  Copyright (c) 2013 XGRoup. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CustomVC.h"
#import "MenuV.h"

@class TableWithShadow;

@interface PurchaseOrdersVC : CustomVC

{
	TableWithShadow * posTableView;
	NSMutableArray * array_with_pos;
	
	int index_of_po;
	
	int lastOriginX;
	
	MenuV *menuView;
	UIButton *cancel;
}

-(id)init;
-(id)initWithPOS:(NSArray*)sender;
-(void)back:(UIButton*)sender;
-(void)createPO:(UIButton*)sender;

@end
