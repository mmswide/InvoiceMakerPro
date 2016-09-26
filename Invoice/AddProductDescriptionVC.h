//
//  AddProductDescriptionVC.h
//  Invoice
//
//  Created by XGRoup5 on 8/19/13.
//  Copyright (c) 2013 XGRoup. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CustomVC.h"

@class ProductOBJ;

@interface AddProductDescriptionVC : CustomVC

{
	ProductOBJ * theProduct;
}

-(id)initWithProduct:(ProductOBJ*)sender;

@end