//
//  ServiceDetailsVC.h
//  Invoice
//
//  Created by XGRoup5 on 8/19/13.
//  Copyright (c) 2013 XGRoup. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CustomVC.h"

@class ServiceOBJ;

@interface ServiceDetailsVC : CustomVC

{
	ServiceOBJ * theService;
	int index_of_service;
	
	UILabel * nameLabel;
	UILabel * priceLabel;
	UILabel * noteLabel;
	UILabel * billingMethodLabel;
	UILabel * taxableLabel;
}

-(id)initWithService:(ServiceOBJ*)sender atIndex:(int)index;

@end