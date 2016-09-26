//
//  InvoiceUserDefaults.m
//  Invoice
//
//  Created by XGRoup on 9/5/14.
//  Copyright (c) 2014 XGRoup. All rights reserved.
//

#import "InvoiceUserDefaults.h"

#import "Defines.h"

#define INVOICE_PREFIX @"invoice_prefix"
#define FILE_PATH [NSHomeDirectory() stringByAppendingString:@"/Documents/invoices.plist"]

@implementation InvoiceUserDefaults

-(id)init {
	self = [super init];
	
	if(self) {
	}
	
	return self;
}

+(id)defaultUserDefaults {
	static InvoiceUserDefaults * manager;
	
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		manager = [[self alloc] init];
	});
	
	return manager;
}

-(void)createFile {
	NSMutableArray* invoicesArray = [NSMutableArray new];
    
  if([[NSUserDefaults standardUserDefaults] objectForKey:kInvoicesKeyForNSUserDefaults]) {
    [invoicesArray addObjectsFromArray:[[NSUserDefaults standardUserDefaults] objectForKey:kInvoicesKeyForNSUserDefaults]];
  }
	
	NSFileManager *manager = [NSFileManager defaultManager];
	
	if(![manager fileExistsAtPath:FILE_PATH]) {
		[manager createFileAtPath:FILE_PATH contents:[[NSData alloc] init] attributes:nil];
		
		[invoicesArray writeToFile:FILE_PATH atomically:YES];
	}
}

-(void)saveInvoices:(NSArray*)sender
{
	[sender writeToFile:FILE_PATH atomically:YES];
}

-(NSArray*)loadInvoices
{
  NSFileManager *manager = [NSFileManager defaultManager];
  if([manager fileExistsAtPath:FILE_PATH]) {
    return [[NSMutableArray alloc] initWithContentsOfFile:FILE_PATH];
  }
  return [NSArray new];
}

- (NSString *)invoicePref {
    return [[NSUserDefaults standardUserDefaults] stringForKey:INVOICE_PREFIX]?:@"IN";
}

- (void)setInvoicePref:(NSString *)pref {
    if([pref length] > 0) {
        [[NSUserDefaults standardUserDefaults] setObject:pref forKey:INVOICE_PREFIX];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

@end
