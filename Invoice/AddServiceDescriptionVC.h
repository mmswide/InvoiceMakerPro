//
//  AddServiceDescriptionVC.h
//  Invoice
//
//  Created by XGRoup5 on 8/19/13.
//  Copyright (c) 2013 XGRoup. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CustomVC.h"

@class ServiceOBJ;

@interface AddServiceDescriptionVC : CustomVC

{
	ServiceOBJ * theService;
}

-(id)initWithService:(ServiceOBJ*)sender;

@end