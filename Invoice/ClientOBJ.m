//
//  ClientOBJ.m
//  Invoice
//
//  Created by XGRoup5 on 8/13/13.
//  Copyright (c) 2013 XGRoup. All rights reserved.
//

#import "ClientOBJ.h"

#import "Defines.h"

@implementation ClientOBJ

-(id)init
{
	self = [super init];
	
	if (self)
	{
		contents = [[NSMutableDictionary alloc] init];
		[contents setObject:NSStringFromClass([self class]) forKey:@"class"];
		
		[self setID:[data_manager createContactID]];
		[self setFirstName:@""];
		[self setLastName:@""];
		[self setTitle:kTitleMr];
		[self setCompany:@""];
		[self setWebsite:@""];
		[self setPhone:@""];
		[self setMobile:@""];
		[self setFax:@""];
		[self setEmail:@""];
		
		NSDictionary * settingsDictionary = [[NSDictionary alloc] initWithDictionary: [CustomDefaults customObjectForKey:kSettingsKeyForNSUserDefaults]];
		
		[self setBillingAddress:[[[AddressOBJ alloc] init] contentsDictionary]];
		[self setShippingAddress:[[[AddressOBJ alloc] init] contentsDictionary]];
		[self setTerms:[[settingsDictionary objectForKey:@"terms"] intValue]];
		[self setNote:@""];
	}
	
	return self;
}

-(id)initWithClient:(ClientOBJ*)sender
{
	self = [super init];
	
	if (self)
	{
		contents = [[NSMutableDictionary alloc] init];
		[contents setObject:NSStringFromClass([self class]) forKey:@"class"];
		
		if (sender && [sender isKindOfClass:[ClientOBJ class]])
		{
			[self setID:[sender ID]];
			[self setFirstName:[sender firstName]];
			[self setLastName:[sender lastName]];
			[self setTitle:[ClientOBJ titleTypeForString:[sender title]]];
			[self setCompany:[sender company]];
			[self setWebsite:[sender website]];
			[self setPhone:[sender phone]];
			[self setMobile:[sender mobile]];
			[self setFax:[sender fax]];
			[self setEmail:[sender email]];
			[self setBillingAddress:[[sender billingAddress] contentsDictionary]];
			[self setShippingAddress:[[sender shippingAddress] contentsDictionary]];
			[self setTerms:[sender terms]];
			[self setNote:[sender note]];
		}
		else
		{
			[self setID:[data_manager createContactID]];
			[self setFirstName:@""];
			[self setLastName:@""];
			[self setTitle:kTitleMr];
			[self setCompany:@""];
			[self setWebsite:@""];
			[self setPhone:@""];
			[self setMobile:@""];
			[self setFax:@""];
			[self setEmail:@""];
			
			NSDictionary * settingsDictionary = [[NSDictionary alloc] initWithDictionary: [CustomDefaults customObjectForKey:kSettingsKeyForNSUserDefaults]];
			
			[self setBillingAddress:[[[AddressOBJ alloc] init] contentsDictionary]];
			[self setShippingAddress:[[[AddressOBJ alloc] init] contentsDictionary]];
			[self setTerms:[[settingsDictionary objectForKey:@"terms"] intValue]];
			[self setNote:@""];
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

-(id)initForTemplate
{
	self = [super init];
	
	if (self)
	{
		contents = [[NSMutableDictionary alloc] init];
		[contents setObject:NSStringFromClass([self class]) forKey:@"class"];
		
		[self setFirstName:@"First Name"];
		[self setLastName:@"Last Name"];
		[self setTitle:kTitleMr];
		[self setCompany:@"Company"];
		[self setWebsite:@"www.website.com"];
		[self setPhone:@"1234567890"];
		[self setMobile:@"1234567890"];
		[self setFax:@"1234567890"];
		[self setEmail:@"email@address.com"];
		
		NSDictionary * settingsDictionary = [[NSDictionary alloc] initWithDictionary: [CustomDefaults customObjectForKey:kSettingsKeyForNSUserDefaults]];
		
		[self setBillingAddress:[[[AddressOBJ alloc] initForTemplate] contentsDictionary]];
		[self setShippingAddress:[[[AddressOBJ alloc] initForTemplate] contentsDictionary]];
		[self setTerms:[[settingsDictionary objectForKey:@"terms"] intValue]];
		[self setNote:@"Note"];
	}
	
	return self;
}

#pragma mark - GETTERS

+(NSString*)titleStringForType:(kTitle)title
{
	switch (title)
	{
		case kTitleMr:
		{
			return @"Mr.";
			break;
		}
			
		case kTitleMs:
		{
			return @"Ms.";
			break;
		}
			
		case kTitleMrs:
		{
			return @"Mrs.";
			break;
		}
			
		case kTitleMiss:
		{
			return @"Miss.";
			break;
		}
			
		case kTitleDr:
		{
			return @"Dr.";
			break;
		}
			
		default:
			break;
	}
	
	return @"";
}

+(kTitle)titleTypeForString:(NSString*)title
{
	if ([title isEqual:@"Mr."])
	{
		return kTitleMr;
	}
	else if ([title isEqual:@"Ms."])
	{
		return kTitleMs;
	}
	else if ([title isEqual:@"Mrs."])
	{
		return kTitleMrs;
	}
	else if ([title isEqual:@"Miss."])
	{
		return kTitleMiss;
	}
	else if ([title isEqual:@"Dr."])
	{
		return kTitleDr;
	}
	
	return 0;
}

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

-(NSString*)firstName
{
	if ([[contents allKeys] containsObject:@"firstName"] && [[contents objectForKey:@"firstName"] isKindOfClass:[NSString class]])
	{
		return [contents objectForKey:@"firstName"];
	}
	else
	{
		[data_manager logGetterErrorFromClass:[self class] forProperty:@"firstName" containedValue:[contents objectForKey:@"firstName"] withDefautReturnValue:@"empty string"];
		return @"";
	}
}

-(NSString*)lastName
{
	if ([[contents allKeys] containsObject:@"lastName"] && [[contents objectForKey:@"lastName"] isKindOfClass:[NSString class]])
	{
		return [contents objectForKey:@"lastName"];
	}
	else
	{
		[data_manager logGetterErrorFromClass:[self class] forProperty:@"lastName" containedValue:[contents objectForKey:@"lastName"] withDefautReturnValue:@"empty string"];
		return @"";
	}
}

-(NSString*)title
{
	if ([[contents allKeys] containsObject:@"title"] && [[contents objectForKey:@"title"] isKindOfClass:[NSString class]])
	{
		return [contents objectForKey:@"title"];
	}
	else
	{
		[data_manager logGetterErrorFromClass:[self class] forProperty:@"title" containedValue:[contents objectForKey:@"title"] withDefautReturnValue:@"empty string"];
		return @"";
	}
}

-(NSString*)company
{
	if ([[contents allKeys] containsObject:@"company"] && [[contents objectForKey:@"company"] isKindOfClass:[NSString class]])
	{
		return [contents objectForKey:@"company"];
	}
	else
	{
		[data_manager logGetterErrorFromClass:[self class] forProperty:@"company" containedValue:[contents objectForKey:@"company"] withDefautReturnValue:@"empty string"];
		return @"";
	}
}

-(NSString*)website
{
	if ([[contents allKeys] containsObject:@"website"] && [[contents objectForKey:@"website"] isKindOfClass:[NSString class]])
	{
		return [contents objectForKey:@"website"];
	}
	else
	{
		[data_manager logGetterErrorFromClass:[self class] forProperty:@"website" containedValue:[contents objectForKey:@"website"] withDefautReturnValue:@"empty string"];
		return @"";
	}
}

-(NSString*)phone
{
	if ([[contents allKeys] containsObject:@"phone"] && [[contents objectForKey:@"phone"] isKindOfClass:[NSString class]])
	{
		return [contents objectForKey:@"phone"];
	}
	else
	{
		[data_manager logGetterErrorFromClass:[self class] forProperty:@"phone" containedValue:[contents objectForKey:@"phone"] withDefautReturnValue:@"empty string"];
		return @"";
	}
}

-(NSString*)mobile
{
	if ([[contents allKeys] containsObject:@"mobile"] && [[contents objectForKey:@"mobile"] isKindOfClass:[NSString class]])
	{
		return [contents objectForKey:@"mobile"];
	}
	else
	{
		[data_manager logGetterErrorFromClass:[self class] forProperty:@"mobile" containedValue:[contents objectForKey:@"mobile"] withDefautReturnValue:@"empty string"];
		return @"";
	}
}

-(NSString*)fax
{
	if ([[contents allKeys] containsObject:@"fax"] && [[contents objectForKey:@"fax"] isKindOfClass:[NSString class]])
	{
		return [contents objectForKey:@"fax"];
	}
	else
	{
		[data_manager logGetterErrorFromClass:[self class] forProperty:@"fax" containedValue:[contents objectForKey:@"fax"] withDefautReturnValue:@"empty string"];
		return @"";
	}
}

-(NSString*)email
{
	if ([[contents allKeys] containsObject:@"email"] && [[contents objectForKey:@"email"] isKindOfClass:[NSString class]])
	{
		return [contents objectForKey:@"email"];
	}
	else
	{
		[data_manager logGetterErrorFromClass:[self class] forProperty:@"email" containedValue:[contents objectForKey:@"email"] withDefautReturnValue:@"empty string"];
		return @"";
	}
}

-(AddressOBJ*)billingAddress
{
	if ([[contents allKeys] containsObject:@"billingAddress"] && [[contents objectForKey:@"billingAddress"] isKindOfClass:[NSDictionary class]])
	{
		return [[AddressOBJ alloc] initWithContentsDictionary:[contents objectForKey:@"billingAddress"]];
	}
	else
	{
		[data_manager logGetterErrorFromClass:[self class] forProperty:@"billingAddress" containedValue:[contents objectForKey:@"billingAddress"] withDefautReturnValue:@"empty address"];
		return [[AddressOBJ alloc] init];
	}
}

-(AddressOBJ*)shippingAddress
{
	if ([[contents allKeys] containsObject:@"shippingAddress"] && [[contents objectForKey:@"shippingAddress"] isKindOfClass:[NSDictionary class]])
	{
		return [[AddressOBJ alloc] initWithContentsDictionary:[contents objectForKey:@"shippingAddress"]];
	}
	else
	{
		[data_manager logGetterErrorFromClass:[self class] forProperty:@"shippingAddress" containedValue:[contents objectForKey:@"shippingAddress"] withDefautReturnValue:@"empty address"];
		return [[AddressOBJ alloc] init];
	}
}

-(kTerms)terms
{
	if ([[contents allKeys] containsObject:@"terms"] && [[contents objectForKey:@"terms"] isKindOfClass:[NSNumber class]])
	{
		return [[contents objectForKey:@"terms"] intValue];
	}
	else
	{
		[data_manager logGetterErrorFromClass:[self class] forProperty:@"terms" containedValue:[contents objectForKey:@"terms"] withDefautReturnValue:@"7 days"];
		return kTerms7Days;
	}
}

-(NSString*)note
{
	if ([[contents allKeys] containsObject:@"note"] && [[contents objectForKey:@"note"] isKindOfClass:[NSString class]])
	{
		return [contents objectForKey:@"note"];
	}
	else
	{
		[data_manager logGetterErrorFromClass:[self class] forProperty:@"note" containedValue:[contents objectForKey:@"note"] withDefautReturnValue:@"empty string"];
		return @"";
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

-(void)setFirstName:(NSString*)sender
{
	if (sender && [sender isKindOfClass:[NSString class]])
	{
		[contents setObject:sender forKey:@"firstName"];
	}
	else
	{
		[data_manager logSetterErrorFromClass:[self class] forProperty:@"firstName" sentValue:sender withDefaultSetValue:@"empty string"];
		[contents setObject:@"" forKey:@"firstName"];
	}
}

-(void)setLastName:(NSString*)sender
{
	if (sender && [sender isKindOfClass:[NSString class]])
	{
		[contents setObject:sender forKey:@"lastName"];
	}
	else
	{
		[data_manager logSetterErrorFromClass:[self class] forProperty:@"lastName" sentValue:sender withDefaultSetValue:@"empty string"];
		[contents setObject:@"" forKey:@"lastName"];
	}
}

-(void)setTitle:(kTitle)sender
{
	[contents setObject:[ClientOBJ titleStringForType:sender] forKey:@"title"];
}

-(void)setCompany:(NSString*)sender
{
	if (sender && [sender isKindOfClass:[NSString class]])
	{
		[contents setObject:sender forKey:@"company"];
	}
	else
	{
		[data_manager logSetterErrorFromClass:[self class] forProperty:@"company" sentValue:sender withDefaultSetValue:@"empty string"];
		[contents setObject:@"" forKey:@"company"];
	}
}

-(void)setWebsite:(NSString*)sender
{
	if (sender && [sender isKindOfClass:[NSString class]])
	{
		[contents setObject:sender forKey:@"website"];
	}
	else
	{
		[data_manager logSetterErrorFromClass:[self class] forProperty:@"website" sentValue:sender withDefaultSetValue:@"empty string"];
		[contents setObject:@"" forKey:@"website"];
	}
}

-(void)setPhone:(NSString*)sender
{
	if (sender && [sender isKindOfClass:[NSString class]])
	{
		[contents setObject:sender forKey:@"phone"];
	}
	else
	{
		[data_manager logSetterErrorFromClass:[self class] forProperty:@"phone" sentValue:sender withDefaultSetValue:@"empty string"];
		[contents setObject:@"" forKey:@"phone"];
	}
}

-(void)setMobile:(NSString*)sender
{
	if (sender && [sender isKindOfClass:[NSString class]])
	{
		[contents setObject:sender forKey:@"mobile"];
	}
	else
	{
		[data_manager logSetterErrorFromClass:[self class] forProperty:@"mobile" sentValue:sender withDefaultSetValue:@"empty string"];
		[contents setObject:@"" forKey:@"mobile"];
	}
}

-(void)setFax:(NSString*)sender
{
	if (sender && [sender isKindOfClass:[NSString class]])
	{
		[contents setObject:sender forKey:@"fax"];
	}
	else
	{
		[data_manager logSetterErrorFromClass:[self class] forProperty:@"fax" sentValue:sender withDefaultSetValue:@"empty string"];
		[contents setObject:@"" forKey:@"fax"];
	}
}

-(void)setEmail:(NSString*)sender
{
	if (sender && [sender isKindOfClass:[NSString class]])
	{
		[contents setObject:sender forKey:@"email"];
	}
	else
	{
		[data_manager logSetterErrorFromClass:[self class] forProperty:@"email" sentValue:sender withDefaultSetValue:@"empty string"];
		[contents setObject:@"" forKey:@"email"];
	}
}

-(void)setBillingAddress:(NSDictionary*)sender
{
	if (sender && [sender isKindOfClass:[NSDictionary class]])
	{
		[contents setObject:sender forKey:@"billingAddress"];
	}
	else
	{
		[data_manager logSetterErrorFromClass:[self class] forProperty:@"billingAddress" sentValue:sender withDefaultSetValue:@"empty address"];
		[contents setObject:[[[AddressOBJ alloc] init] contentsDictionary] forKey:@"billingAddress"];
	}
}

-(void)setShippingAddress:(NSDictionary*)sender
{
	if (sender && [sender isKindOfClass:[NSDictionary class]])
	{
		[contents setObject:sender forKey:@"shippingAddress"];
	}
	else
	{
		[data_manager logSetterErrorFromClass:[self class] forProperty:@"shippingAddress" sentValue:sender withDefaultSetValue:@"empty address"];
		[contents setObject:[[[AddressOBJ alloc] init] contentsDictionary] forKey:@"shippingAddress"];
	}
}

-(void)setTerms:(kTerms)sender
{
	[contents setObject:[NSNumber numberWithInt:sender] forKey:@"terms"];
}

-(void)setNote:(NSString*)sender
{
	if (sender && [sender isKindOfClass:[NSString class]])
	{
		[contents setObject:sender forKey:@"note"];
	}
	else
	{
		[data_manager logSetterErrorFromClass:[self class] forProperty:@"note" sentValue:sender withDefaultSetValue:@"empty string"];
		[contents setObject:@"" forKey:@"note"];
	}
}

-(BOOL)isEqual:(ClientOBJ*)object
{
	if(![[self contentsDictionary] isEqual:[object contentsDictionary]])
		return NO;
	
	return YES;
}

#pragma mark - DESCRIPTION

-(NSString*)description
{
	return contents.description;
}

@end
