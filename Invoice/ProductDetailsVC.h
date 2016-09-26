//
//  ProductDetailsVC.h
//  Invoice
//
//  Created by XGRoup5 on 8/19/13.
//  Copyright (c) 2013 XGRoup. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CustomVC.h"

@class ProductOBJ;

@interface ProductDetailsVC : CustomVC

{
	ProductOBJ * theProduct;
	int index_of_product;
	
	UILabel * nameLabel;
	UILabel * priceLabel;
	UILabel * noteLabel;
	UILabel * codeLabel;
	UILabel * taxableLabel;
}

-(id)initWithProduct:(ProductOBJ*)sender atIndex:(int)index;

@end