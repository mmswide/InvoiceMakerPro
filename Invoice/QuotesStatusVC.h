//
//  QuotesStatusVC.h
//  Invoice
//
//  Created by XGRoup5 on 9/27/13.
//  Copyright (c) 2013 XGRoup. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CustomVC.h"

@class ClientOBJ;
@class ProjectOBJ;
@class TableWithShadow;

@interface QuotesStatusVC : CustomVC

{
	ClientOBJ * theClient;
	ProjectOBJ *theProject;
	
	NSArray * quotes_array;
	TableWithShadow * mainTableView;
}

-(id)initWithClient:(ClientOBJ*)sender;
-(id)initWithProject:(ProjectOBJ*)sender;

-(void)back:(UIButton*)sender;

@end