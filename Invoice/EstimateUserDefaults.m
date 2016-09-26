//
//  EstimateUserDefaults.m
//  Invoice
//
//  Created by XGRoup on 9/5/14.
//  Copyright (c) 2014 XGRoup. All rights reserved.
//

#import "EstimateUserDefaults.h"

#import "Defines.h"

#define ESTIMATE_PREFIX @"estimate_prefix"
#define FILE_PATH [NSHomeDirectory() stringByAppendingString:@"/Documents/estimates.plist"]

@implementation EstimateUserDefaults

-(id)init
{
	self = [super init];
	
	if(self) {
	}
	
	return self;
}

+(id)defaultUserDefaults
{
	static EstimateUserDefaults * manager;
	
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		manager = [[self alloc] init];
	});
	
	return manager;
}

-(void)createFile
{
	NSMutableArray* estimatesArray = [NSMutableArray new];
    
  if([[NSUserDefaults standardUserDefaults] objectForKey:kEstimatesKeyForNSUserDefaults]) {
    [estimatesArray addObjectsFromArray:[[NSUserDefaults standardUserDefaults] objectForKey:kEstimatesKeyForNSUserDefaults]];
  }
	
	NSFileManager *manager = [NSFileManager defaultManager];
	
	if(![manager fileExistsAtPath:FILE_PATH]) {
		[manager createFileAtPath:FILE_PATH contents:[[NSData alloc] init] attributes:nil];
		[estimatesArray writeToFile:FILE_PATH atomically:YES];
	}	
}

-(void)saveEstimates:(NSArray*)sender
{
	[sender writeToFile:FILE_PATH atomically:YES];
}

-(NSArray*)loadEstimates {
  NSFileManager *manager = [NSFileManager defaultManager];
		
  if([manager fileExistsAtPath:FILE_PATH]) {
    return [[NSMutableArray alloc] initWithContentsOfFile:FILE_PATH];
  }
  return [NSArray new];
}

- (NSString *)estimatePref {
    return [[NSUserDefaults standardUserDefaults] stringForKey:ESTIMATE_PREFIX]?:@"ES";
}

- (void)setEstimatePref:(NSString *)pref {
    if([pref length] > 0) {
        [[NSUserDefaults standardUserDefaults] setObject:pref forKey:ESTIMATE_PREFIX];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

@end
