//
//  CustomUserDefaults.h
//  Invoice
//
//  Created by XGRoup on 9/8/14.
//  Copyright (c) 2014 XGRoup. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseUserDefaults.h"

@interface CustomUserDefaults : BaseUserDefaults
{
	NSString *filePath;
	
	NSMutableDictionary *settingsDict;
}

+(id)defaultUserDefaults;

-(void)createFile;

-(void)setCustomString:(NSString*)value forKey:(NSString*)key;

-(void)setCustomInteger:(NSInteger)value forKey:(NSString *)key;

-(void)setCustomBool:(BOOL)value forKey:(NSString*)key;

-(void)setCustomObjects:(id)value forKey:(NSString*)key;

-(void)removeCustomObjectForKey:(NSString*)key;

-(void)setContent:(NSDictionary*)dict;

-(NSString*)customStringForKey:(NSString*)sender;

-(NSInteger)customIntegerForKey:(NSString*)key;

-(BOOL)customBoolForKey:(NSString*)key;

-(id)customObjectForKey:(NSString*)key;

-(BOOL)containValueForKey:(NSString*)key;

@end
