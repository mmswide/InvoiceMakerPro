//
//  TimesheetUserDefaults.m
//  Invoice
//
//  Created by XGRoup on 9/5/14.
//  Copyright (c) 2014 XGRoup. All rights reserved.
//

#import "TimesheetUserDefaults.h"

#import "Defines.h"

@implementation TimesheetUserDefaults

-(id)init
{
	self = [super init];
	
	if(self)
	{
		timesheetArray = [[NSMutableArray alloc] init];
		filePath = [[NSString alloc] initWithString:[NSHomeDirectory() stringByAppendingString:@"/Documents/timesheets.plist"]];
		
		NSFileManager *manager = [NSFileManager defaultManager];
		
		if([manager fileExistsAtPath:filePath])
		{
			timesheetArray = [[NSMutableArray alloc] initWithContentsOfFile:filePath];
		}
	}
	
	return self;
}

+(id)defaultUserDefaults
{
	static TimesheetUserDefaults * manager;
	
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		
		manager = [[self alloc] init];
		
	});
	
	return manager;
}

-(void)createFile
{
	[timesheetArray removeAllObjects];
    
    if([[NSUserDefaults standardUserDefaults] objectForKey:kTimeSheetKeyForNSUserDefaults])
    {
        [timesheetArray addObjectsFromArray:[[NSUserDefaults standardUserDefaults] objectForKey:kTimeSheetKeyForNSUserDefaults]];
    }
    	
	NSFileManager *manager = [NSFileManager defaultManager];
	
	if(![manager fileExistsAtPath:filePath])
	{
		[manager createFileAtPath:filePath contents:[[NSData alloc] init] attributes:nil];
		
		[timesheetArray writeToFile:filePath atomically:YES];
	}	
}

-(void)saveTimesheets:(NSArray*)sender
{
	[timesheetArray removeAllObjects];
	[timesheetArray addObjectsFromArray:sender];
	
	[timesheetArray writeToFile:filePath atomically:YES];
}

-(NSArray*)loadTimesheets
{
	return timesheetArray;
}

@end
