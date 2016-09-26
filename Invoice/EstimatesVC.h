//
//  EstimatesVC.h
//  Invoice
//
//  Created by XGRoup5 on 8/13/13.
//  Copyright (c) 2013 XGRoup. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CustomVC.h"
#import "MenuV.h"

@class TableWithShadow;

@interface EstimatesVC : CustomVC

{
	TableWithShadow * estimatesTableView;
	NSMutableArray * array_with_estimates;
	
	int index_of_estimate;
	
	int lastOriginX;
	
	MenuV *menuView;
	UIButton *cancel;
}

-(id)init;
-(id)initWithEstimates:(NSArray*)sender;
-(void)back:(UIButton*)sender;
-(void)createEstimate:(UIButton*)sender;

@end
