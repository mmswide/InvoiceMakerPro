//
//  ReceiptUserDefaults.m
//  Invoice
//
//  Created by XGRoup on 9/5/14.
//  Copyright (c) 2014 XGRoup. All rights reserved.
//

#import "ReceiptUserDefaults.h"

#import "Defines.h"

@implementation ReceiptUserDefaults

-(id)init
{
	self = [super init];
	
	if(self)
	{
		receiptsArray = [[NSMutableArray alloc] init];
		filePath = [[NSString alloc] initWithString:[NSHomeDirectory() stringByAppendingString:@"/Documents/receipts.plist"]];
		
		NSFileManager *manager = [NSFileManager defaultManager];
		
		if([manager fileExistsAtPath:filePath])
		{
			receiptsArray = [[NSMutableArray alloc] initWithContentsOfFile:filePath];
		}
	}
	
	return self;
}

+(id)defaultUserDefaults
{
	static ReceiptUserDefaults * manager;
	
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		
		manager = [[self alloc] init];
		
	});
	
	return manager;
}

-(void)createFile
{
	[receiptsArray removeAllObjects];
    
    if([[NSUserDefaults standardUserDefaults] objectForKey:kReceiptsKeyForNSUserDefaults])
    {
        [receiptsArray addObjectsFromArray:[[NSUserDefaults standardUserDefaults] objectForKey:kReceiptsKeyForNSUserDefaults]];
    }
		
	NSFileManager *manager = [NSFileManager defaultManager];
	
	if(![manager fileExistsAtPath:filePath])
	{
		[manager createFileAtPath:filePath contents:[[NSData alloc] init] attributes:nil];
		
		[receiptsArray writeToFile:filePath atomically:YES];
	}	
}

-(void)saveReceipts:(NSArray*)sender
{
	[receiptsArray removeAllObjects];
	[receiptsArray addObjectsFromArray:sender];
	
	[receiptsArray writeToFile:filePath atomically:YES];
}

-(NSArray*)loadReceipts
{
	return receiptsArray;
}

@end
