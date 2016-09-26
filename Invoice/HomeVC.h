//
//  HomeVC.h
//  Invoice
//
//  Created by XGRoup5 on 8/13/13.
//  Copyright (c) 2013 XGRoup. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CustomVC.h"
#import "MenuV.h"

@interface HomeVC : CustomVC

{
	MenuV *menuView;
	
	UIButton * cancel;
	
	int lastOriginX;
}

-(id)init;

-(void)openInvoices:(UIButton*)sender;
-(void)openQuotes:(UIButton*)sender;
-(void)openEstimates:(UIButton*)sender;
-(void)openPurchaseOrders:(UIButton*)sender;

@end
