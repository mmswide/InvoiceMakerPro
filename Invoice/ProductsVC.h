//
//  ProductsVC.h
//  Invoice
//
//  Created by XGRoup5 on 8/13/13.
//  Copyright (c) 2013 XGRoup. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CellWithProduct.h"
#import "CellWithService.h"
#import "CategorySelectV.h"
#import "CustomVC.h"

@class TableWithShadow;
@class ScrollWithShadow;
@protocol ProductOrServiceSelectorDelegate;

@interface ProductsVC : CustomVC

{
	TableWithShadow * productsAndServicesTableView;
	NSMutableArray * array_with_products;
	NSMutableArray * array_with_services;
	
	CategorySelectV *categoryBar;
	
	int categorySelected;
}

@property (nonatomic, weak) id<ProductOrServiceSelectorDelegate> delegate;

@end

@protocol ProductOrServiceSelectorDelegate <NSObject>

-(void)viewController:(ProductsVC*)vc selectedProduct:(ProductOBJ*)sender;
-(void)viewController:(ProductsVC*)vc selectedService:(ServiceOBJ*)sender;

@end
