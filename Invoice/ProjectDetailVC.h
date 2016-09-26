//
//  ProjectDetailVC.h
//  Invoice
//
//  Created by Paul on 17/06/14.
//  Copyright (c) 2014 XGRoup. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Defines.h"
#import "CustomVC.h"

@interface ProjectDetailVC : CustomVC
{
	ProjectOBJ * theProject;
	NSInteger project_index;
	
	UITextField * nameTextField;
	UITextField * companyTextField;
}

-(id)initWithProject:(ProjectOBJ*)project andIndex:(NSInteger)index;

-(void)back:(UIButton*)sender;
-(void)edit:(UIButton*)sender;
-(void)openContactDetails:(UIButton*)sender;
-(void)openInvoices:(UIButton*)sender;
-(void)openQuotes:(UIButton*)sender;
-(void)openEstimates:(UIButton*)sender;
-(void)openPurchaseOrders:(UIButton*)sender;

@end
