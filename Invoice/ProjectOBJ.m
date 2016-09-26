//
//  ProjectOBJ.m
//  Invoice
//
//  Created by Paul on 17/06/14.
//  Copyright (c) 2014 XGRoup. All rights reserved.
//

#import "ProjectOBJ.h"

#import "Defines.h"

@implementation ProjectOBJ

-(id)init
{
	self = [super init];
	
	if (self)
	{
		contents = [[NSMutableDictionary alloc] init];
		[contents setObject:NSStringFromClass([self class]) forKey:@"class"];
	
		[self setID:[data_manager createProjectID]];
		[self setProjectName:@""];
		[self setProjectNumber:@""];
		[self setClient:[[[ClientOBJ alloc] init] contentsDictionary]];
		[self setLocation:@""];
		[self setPaid:@""];
		[self setCompleted:@""];
	}
	
	return self;
}

-(id)initWithProject:(ProjectOBJ *)sender
{
	self = [super init];
	
	if (self)
	{
		contents = [[NSMutableDictionary alloc] init];
		[contents setObject:NSStringFromClass([self class]) forKey:@"class"];
		
		if (sender && [sender isKindOfClass:[ProjectOBJ class]])
		{
			[self setID:[sender ID]];
			[self setProjectName:[sender projectName]];
			[self setProjectNumber:[sender projectNumber]];
			[self setLocation:[sender location]];
			[self setClient:[[sender client] contentsDictionary]];
			[self setPaid:[sender paid]];
			[self setCompleted:[sender completed]];
		}
		else
		{
			[self setID:[data_manager createProjectID]];
			[self setProjectName:@""];
			[self setProjectNumber:@""];
			[self setLocation:@""];
			[self setClient:[[[ClientOBJ alloc] init] contentsDictionary]];
			[self setPaid:@""];
			[self setCompleted:@""];
		}
	}
	
	return self;
}

-(id)initWithContentsDictionary:(NSDictionary*)sender
{
	self = [super init];
	
	if (self)
	{
		contents = [[NSMutableDictionary alloc] init];
		[contents setObject:NSStringFromClass([self class]) forKey:@"class"];
		[contents addEntriesFromDictionary:sender];
	}
	
	return self;
}

#pragma mark - GETTERS

-(NSDictionary*)contentsDictionary
{
	return contents;
}

-(NSDictionary*)partiallyContentsDictionary
{
	NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] initWithDictionary:contents];
	[tempDict removeObjectForKey:@"id"];
	
	return tempDict;
}

-(NSString*)ID
{
	if([[contents allKeys] containsObject:@"id"] && [[contents objectForKey:@"id"] isKindOfClass:[NSString class]])
	{
		return [contents objectForKey:@"id"];
	}
	else
	{
		[data_manager logGetterErrorFromClass:[self class] forProperty:@"id" containedValue:[contents objectForKey:@"id"] withDefautReturnValue:@"empty string"];
		return @"";
	}
}

-(NSString*)projectName
{
	if ([[contents allKeys] containsObject:@"projectName"] && [[contents objectForKey:@"projectName"] isKindOfClass:[NSString class]])
	{
		return [contents objectForKey:@"projectName"];
	}
	else
	{
		[data_manager logGetterErrorFromClass:[self class] forProperty:@"projectName" containedValue:[contents objectForKey:@"projectName"] withDefautReturnValue:@"empty string"];
		return kInvTitle;
	}
}

-(NSString*)projectNumber
{
	if ([[contents allKeys] containsObject:@"projectNumber"] && [[contents objectForKey:@"projectNumber"] isKindOfClass:[NSString class]])
	{
		return [contents objectForKey:@"projectNumber"];
	}
	else
	{
		[data_manager logGetterErrorFromClass:[self class] forProperty:@"projectNumber" containedValue:[contents objectForKey:@"projectNumber"] withDefautReturnValue:@"empty string"];
		return kInvTitle;
	}
}

-(ClientOBJ*)client
{
	if ([[contents allKeys] containsObject:@"client"] && [[contents objectForKey:@"client"] isKindOfClass:[NSDictionary class]])
	{
		return [[ClientOBJ alloc] initWithContentsDictionary:[contents objectForKey:@"client"]];
	}
	else
	{
		[data_manager logGetterErrorFromClass:[self class] forProperty:@"client" containedValue:[contents objectForKey:@"client"] withDefautReturnValue:@"empty client"];
		return [[ClientOBJ alloc] init];
	}
}

-(NSString*)location
{
	if ([[contents allKeys] containsObject:@"location"] && [[contents objectForKey:@"location"] isKindOfClass:[NSString class]])
	{
		return [contents objectForKey:@"location"];
	}
	else
	{
		[data_manager logGetterErrorFromClass:[self class] forProperty:@"location" containedValue:[contents objectForKey:@"location"] withDefautReturnValue:@"empty string"];
		return kInvTitle;
	}
}

-(NSString*)paid
{
	if ([[contents allKeys] containsObject:@"paid"] && [[contents objectForKey:@"paid"] isKindOfClass:[NSString class]])
	{
		return [contents objectForKey:@"paid"];
	}
	else
	{
		[data_manager logGetterErrorFromClass:[self class] forProperty:@"paid" containedValue:[contents objectForKey:@"paid"] withDefautReturnValue:@"empty string"];
		return kInvTitle;
	}
}

-(NSString*)completed
{
	if ([[contents allKeys] containsObject:@"completed"] && [[contents objectForKey:@"completed"] isKindOfClass:[NSString class]])
	{
		return [contents objectForKey:@"completed"];
	}
	else
	{
		[data_manager logGetterErrorFromClass:[self class] forProperty:@"completed" containedValue:[contents objectForKey:@"completed"] withDefautReturnValue:@"empty string"];
		return kInvTitle;
	}
}

#pragma mark - SETTERS

-(void)setID:(NSString *)sender
{
	if(sender && [sender isKindOfClass:[NSString class]])
	{
		[contents setObject:sender forKey:@"id"];
	}
	else
	{
		[data_manager logSetterErrorFromClass:[self class] forProperty:@"id" sentValue:sender withDefaultSetValue:@"empty string"];
		[contents setObject:@"" forKey:@"id"];
	}
}

-(void)setProjectName:(NSString*)sender
{
	if (sender && [sender isKindOfClass:[NSString class]])
	{
		[contents setObject:sender forKey:@"projectName"];
	}
	else
	{
		[data_manager logSetterErrorFromClass:[self class] forProperty:@"projectName" sentValue:sender withDefaultSetValue:@"empty string"];
		[contents setObject:@"" forKey:@"projectName"];
	}
}

-(void)setProjectNumber:(NSString*)sender
{
	if(sender && [sender isKindOfClass:[NSString class]])
	{
		[contents setObject:sender forKey:@"projectNumber"];
	}
	else
	{
		[data_manager logSetterErrorFromClass:[self class] forProperty:@"projectNumber" sentValue:sender withDefaultSetValue:@"empty string"];
		[contents setObject:@"" forKey:@"projectNumber"];
	}
}

-(void)setClient:(NSDictionary*)sender
{
	if (sender && [sender isKindOfClass:[NSDictionary class]])
	{
		[contents setObject:sender forKey:@"client"];
	}
	else
	{
		[data_manager logSetterErrorFromClass:[self class] forProperty:@"client" sentValue:sender withDefaultSetValue:@"empty dictionary"];
		[contents setObject:[[[ClientOBJ alloc] init] contentsDictionary] forKey:@"client"];
	}
}

-(void)setLocation:(NSString*)sender
{
	if(sender && [sender isKindOfClass:[NSString class]])
	{
		[contents setObject:sender forKey:@"location"];
	}
	else
	{
		[data_manager logSetterErrorFromClass:[self class] forProperty:@"location" sentValue:sender withDefaultSetValue:@"empty string"];
		[contents setObject:@"" forKey:@"location"];
	}
}

-(void)setPaid:(NSString*)sender
{
	if(sender && [sender isKindOfClass:[NSString class]])
	{
		[contents setObject:sender forKey:@"paid"];
	}
	else
	{
		[data_manager logSetterErrorFromClass:[self class] forProperty:@"paid" sentValue:sender withDefaultSetValue:@"empty string"];
		[contents setObject:@"" forKey:@"paid"];
	}
}

-(void)setCompleted:(NSString*)sender
{
	if(sender && [sender isKindOfClass:[NSString class]])
	{
		[contents setObject:sender forKey:@"completed"];
	}
	else
	{
		[data_manager logSetterErrorFromClass:[self class] forProperty:@"completed" sentValue:sender withDefaultSetValue:@"empty string"];
		[contents setObject:@"" forKey:@"completed"];
	}
}

-(BOOL)isEqual:(ProjectOBJ*)object
{
	ClientOBJ *selfClient = [self client];
	ClientOBJ *senderClient = [object client];
		
	if([selfClient isEqual:senderClient] == NO)
		return NO;
		
	if(![[self projectName] isEqual:[object projectName]])
		return NO;

	if(![[self projectNumber] isEqual:[object projectNumber]])
		return NO;

	if([[self paid] intValue] != [[object paid] intValue])
		return NO;

	if([[self completed] intValue] != [[object completed] intValue])
		return NO;
	
	return YES;
}

@end
