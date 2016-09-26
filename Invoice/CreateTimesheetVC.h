//
//  CreateTimesheetVC.h
//  Invoice
//
//  Created by XGRoup on 7/17/14.
//  Copyright (c) 2014 XGRoup. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CustomVC.h"

@class CreateTimesheetVC;
@class ScrollWithShadow;
@class ToolBarView;
@class ClientOBJ;
@class TimeSheetOBJ;

@protocol TimesheetCreatorDelegate <NSObject>

-(void)creatorViewController:(CreateTimesheetVC*)viewController createdTimesheet:(TimeSheetOBJ*)timesheet;

@end

@interface CreateTimesheetVC : CustomVC
{
	TimeSheetOBJ * theTimeSheet;
	BOOL has_alertview;
	
	int currentRow;
	
	UIButton *percentage;
	UIButton *value;
	
	int service_time_index;
}

@property (weak) id<TimesheetCreatorDelegate> delegate;

-(id)initForCreationWithDelegate:(id<TimesheetCreatorDelegate>)del;
-(id)initWithTimesheet:(TimeSheetOBJ*)sender delegate:(id <TimesheetCreatorDelegate>)del;

-(void)cancel:(UIButton*)sender;
-(void)done:(UIButton*)sender;

-(UITableViewCell*)cellInSection:(int)section atRow:(int)row;
-(void)selectedCellInSection:(int)section atRow:(int)row;


@end
