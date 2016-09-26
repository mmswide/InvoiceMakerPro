//
//  QuoteUserDefaults.m
//  Invoice
//
//  Created by XGRoup on 9/5/14.
//  Copyright (c) 2014 XGRoup. All rights reserved.
//

#import "QuoteUserDefaults.h"

#import "Defines.h"

#define QUOTE_PREFIX @"quote_prefix"
#define FILE_PATH [NSHomeDirectory() stringByAppendingString:@"/Documents/quotes.plist"]

@implementation QuoteUserDefaults

-(id)init {
	self = [super init];
	
	if(self) {
	}
	
	return self;
}

+(id)defaultUserDefaults
{
	static QuoteUserDefaults * manager;
	
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		
		manager = [[self alloc] init];
		
	});
	
	return manager;
}

-(void)createFile
{
	NSMutableArray* quoteArray = [NSMutableArray new];
    
  if([[NSUserDefaults standardUserDefaults] objectForKey:kQuotesKeyForNSUserDefaults]) {
    [quoteArray addObjectsFromArray:[[NSUserDefaults standardUserDefaults] objectForKey:kQuotesKeyForNSUserDefaults]];
  }
	
	NSFileManager *manager = [NSFileManager defaultManager];
	
	if(![manager fileExistsAtPath:FILE_PATH])
	{
		[manager createFileAtPath:FILE_PATH contents:[[NSData alloc] init] attributes:nil];
		
		[quoteArray writeToFile:FILE_PATH atomically:YES];
	}
}

-(void)saveQuotes:(NSArray*)sender
{
	[sender writeToFile:FILE_PATH atomically:YES];
}

-(NSArray*)loadQuotes
{
  NSFileManager *manager = [NSFileManager defaultManager];
  if([manager fileExistsAtPath:FILE_PATH]) {
    return [[NSMutableArray alloc] initWithContentsOfFile:FILE_PATH];
  }
  return [NSArray new];
}

- (NSString *)quotePref {
    return [[NSUserDefaults standardUserDefaults] stringForKey:QUOTE_PREFIX]?:@"QU";
}

- (void)setQuotePref:(NSString *)pref {
    if([pref length] > 0) {
        [[NSUserDefaults standardUserDefaults] setObject:pref forKey:QUOTE_PREFIX];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

@end
