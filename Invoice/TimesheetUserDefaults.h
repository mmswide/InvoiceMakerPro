//
//  TimesheetUserDefaults.h
//  Invoice
//
//  Created by XGRoup on 9/5/14.
//  Copyright (c) 2014 XGRoup. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TimesheetUserDefaults : NSObject
{
	NSMutableArray *timesheetArray;
	NSString *filePath;
}

+(id)defaultUserDefaults;

-(void)createFile;

-(void)saveTimesheets:(NSArray*)sender;

-(NSArray*)loadTimesheets;

@end
