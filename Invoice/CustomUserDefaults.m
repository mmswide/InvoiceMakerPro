//
//  CustomUserDefaults.m
//  Invoice
//
//  Created by XGRoup on 9/8/14.
//  Copyright (c) 2014 XGRoup. All rights reserved.
//

#import "CustomUserDefaults.h"

#import "Defines.h"

@implementation CustomUserDefaults

-(id)init
{
	self = [super init];
	
	if(self)
	{
		filePath = [[NSString alloc] initWithString:[NSHomeDirectory() stringByAppendingString:@"/Documents/settings.plist"]];
		settingsDict = [[NSMutableDictionary alloc] init];
		
		NSFileManager *fileManager = [NSFileManager defaultManager];
		
		if([fileManager fileExistsAtPath:filePath])
		{
			settingsDict = [[NSMutableDictionary alloc] initWithContentsOfFile:filePath];            
		}
	}
	
	return self;
}

+(id)defaultUserDefaults
{
	static CustomUserDefaults * manager;
	
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		
		manager = [[self alloc] init];
		
	});
	
	return manager;
}

-(void)createFile
{
	NSFileManager *manager = [NSFileManager defaultManager];
	
	if(![manager fileExistsAtPath:filePath])
	{
		[manager createFileAtPath:filePath contents:[[NSData alloc] init] attributes:nil];
		
		NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
		[dict writeToFile:filePath atomically:YES];
	}
  else
  {
      settingsDict = [[NSMutableDictionary alloc] initWithContentsOfFile:filePath];
  }
}

-(void)setContent:(NSDictionary*)dict
{
	[settingsDict removeAllObjects];
	[settingsDict addEntriesFromDictionary:dict];
	
	[settingsDict writeToFile:filePath atomically:YES];
}

-(void)setCustomString:(NSString*)value forKey:(NSString*)key
{
	[settingsDict setObject:value forKey:key];
	[settingsDict writeToFile:filePath atomically:YES];
}

-(void)setCustomInteger:(NSInteger)value forKey:(NSString *)key
{
	[settingsDict setObject:[NSString stringWithFormat:@"%ld",(long)value] forKey:key];
	[settingsDict writeToFile:filePath atomically:YES];
}

-(void)setCustomBool:(BOOL)value forKey:(NSString*)key
{
	[settingsDict setObject:[NSString stringWithFormat:@"%d",value] forKey:key];
	[settingsDict writeToFile:filePath atomically:YES];
}

-(void)setCustomObjects:(id)value forKey:(NSString*)key
{
	[settingsDict setObject:value forKey:key];
	[settingsDict writeToFile:filePath atomically:YES];
}

-(void)removeCustomObjectForKey:(NSString*)key
{
	if([settingsDict.allKeys containsObject:key])
	{
		[settingsDict removeObjectForKey:key];
		[settingsDict writeToFile:filePath atomically:YES];
	}
}

-(NSString*)customStringForKey:(NSString*)sender
{
	if([settingsDict.allKeys containsObject:sender])
	{
		return [settingsDict objectForKey:sender];
	}
	
	return @"";
}

-(NSInteger)customIntegerForKey:(NSString*)key
{
	if([settingsDict.allKeys containsObject:key])
	{
		return [[settingsDict objectForKey:key] integerValue];
	}
	
	return 0;
}

-(BOOL)customBoolForKey:(NSString*)key
{
	if([settingsDict.allKeys containsObject:key])
	{
		return [[settingsDict objectForKey:key] boolValue];
	}
	
	return 0;
}

-(id)customObjectForKey:(NSString*)key
{
	if([settingsDict.allKeys containsObject:key])
	{
        if([[settingsDict objectForKey:key] isKindOfClass:[NSDictionary class]])
        {
            return [[NSDictionary alloc] initWithDictionary:[settingsDict objectForKey:key]];
        }
        
        if([[settingsDict objectForKey:key] isKindOfClass:[NSArray class]])
        {
            return [[NSArray alloc] initWithArray:[settingsDict objectForKey:key]];
        }
        
        if([[settingsDict objectForKey:key] isKindOfClass:[NSString class]])
        {
            return [[NSString alloc] initWithString:[settingsDict objectForKey:key]];
        }
        
		return [settingsDict objectForKey:key];
	}
	
	return nil;
}

-(BOOL)containValueForKey:(NSString*)key {
  return [settingsDict.allKeys containsObject:key];
}

@end
