//
//  ClientDetailsVC.h
//  Invoice
//
//  Created by XGRoup5 on 8/19/13.
//  Copyright (c) 2013 XGRoup. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomVC.h"

@class ClientOBJ;
@class ScrollWithShadow;

@interface ClientDetailsVC : CustomVC

{
	ClientOBJ * theClient;
	int client_index;
	
	UITextField * nameTextField;
	UITextField * companyTextField;
}

-(id)initWithClient:(ClientOBJ*)sender atIndex:(int)index;
-(void)back:(UIButton*)sender;
-(void)edit:(UIButton*)sender;
-(void)openContactDetails:(UIButton*)sender;
-(void)openInvoices:(UIButton*)sender;
-(void)openQuotes:(UIButton*)sender;
-(void)openEstimates:(UIButton*)sender;
-(void)openPurchaseOrders:(UIButton*)sender;

@end