//
//  EstimatesVC.h
//  Quote
//
//  Created by XGRoup5 on 9/17/13.
//  Copyright (c) 2013 XGRoup. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomVC.h"
#import "MenuV.h"

@class TableWithShadow;

@interface EstimatesVC_Q : CustomVC

{
	TableWithShadow * quotesTableView;
	NSMutableArray * array_with_quotes;
	
	NSInteger index_of_quote;
	
	NSInteger lastOriginX;
	
	MenuV *menuView;
	UIButton *cancel;
}

-(id)init;
-(id)initWithQuotes:(NSArray*)sender;
-(void)createQuote:(UIButton*)sender;

@end
