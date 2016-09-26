//
//  TimesheetVC.h
//  Invoice
//
//  Created by XGRoup on 7/17/14.
//  Copyright (c) 2014 XGRoup. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CustomVC.h"
#import "TimesheetCell.h"
#import "ReceiptsVC.h"
#import "MenuV.h"

@class CategorySelectV;

@interface TimesheetVC : CustomVC
{
	UITableView * timesheetTableView;
	NSMutableArray * array_with_timesheets;
	
	NSMutableArray *weekTimesheets;
	NSMutableArray *monthTimesheets;
	NSMutableArray *yearTimesheets;
	
	int index_of_timesheet;
	
	kReceiptSection selected_section;
	
	CategorySelectV *categoryBar;
	
	int lastOriginX;
	
	MenuV *menuView;
	UIButton *cancel;
	
}

-(id)init;
-(id)initWithTimesheets:(NSArray*)sender;

-(void)back:(UIButton*)sender;
-(void)createTimesheet:(UIButton*)sender;

@end
