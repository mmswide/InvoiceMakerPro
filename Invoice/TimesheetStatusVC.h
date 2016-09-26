//
//  TimesheetStatusVC.h
//  Invoice
//
//  Created by XGRoup on 7/22/14.
//  Copyright (c) 2014 XGRoup. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CustomVC.h"
#import "TimesheetCell.h"
#import "ReceiptsVC.h"

@class CategorySelectV;

@interface TimesheetStatusVC : CustomVC
{
	UITableView * timesheetTableView;
	NSMutableArray * array_with_timesheets;
	
	NSMutableArray *weekTimesheets;
	NSMutableArray *monthTimesheets;
	NSMutableArray *yearTimesheets;
		
	kReceiptSection selected_section;
	
	CategorySelectV *categoryBar;
}

-(id)initWithClient:(ClientOBJ*)client;

-(id)initWithProject:(ProjectOBJ*)project;

@end
