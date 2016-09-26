//
//  PurchaseUserDefaults.m
//  Invoice
//
//  Created by XGRoup on 9/5/14.
//  Copyright (c) 2014 XGRoup. All rights reserved.
//

#import "PurchaseUserDefaults.h"

#import "Defines.h"

#define PURCHASE_PREFIX @"purchase_prefix"
#define FILE_PATH [NSHomeDirectory() stringByAppendingString:@"/Documents/purchases.plist"]

@implementation PurchaseUserDefaults

-(id)init
{
	self = [super init];
	
	if(self) {
	}
	
	return self;
}

+(id)defaultUserDefaults
{
	static PurchaseUserDefaults * manager;
	
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		manager = [[self alloc] init];
	});
	
	return manager;
}

-(void)createFile
{
	NSMutableArray* purchaseArray = [NSMutableArray new];
    
  if([[NSUserDefaults standardUserDefaults] objectForKey:kPurchaseOrdersKeyForNSUserDefaults]) {
    [purchaseArray addObjectsFromArray:[[NSUserDefaults standardUserDefaults] objectForKey:kPurchaseOrdersKeyForNSUserDefaults]];
  }
    
    NSFileManager *manager = [NSFileManager defaultManager];
	
	if(![manager fileExistsAtPath:FILE_PATH])
	{
		[manager createFileAtPath:FILE_PATH contents:[[NSData alloc] init] attributes:nil];
		
		[purchaseArray writeToFile:FILE_PATH atomically:YES];
	}	
}

-(void)savePurchases:(NSArray*)sender
{
	[sender writeToFile:FILE_PATH atomically:YES];
}

-(NSArray*)loadPurchases {
  NSFileManager *manager = [NSFileManager defaultManager];
		
  if([manager fileExistsAtPath:FILE_PATH]) {
    return [[NSMutableArray alloc] initWithContentsOfFile:FILE_PATH];
  }
  return [NSArray new];
}

- (NSString *)purchasePref {
    return [[NSUserDefaults standardUserDefaults] stringForKey:PURCHASE_PREFIX]?:@"PO";
}

- (void)setPurchasePref:(NSString *)pref {
    if([pref length] > 0) {
        [[NSUserDefaults standardUserDefaults] setObject:pref forKey:PURCHASE_PREFIX];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

@end
