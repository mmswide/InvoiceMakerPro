//
//  CompanyOBJ.m
//  Invoice
//
//  Created by XGRoup5 on 8/15/13.
//  Copyright (c) 2013 XGRoup. All rights reserved.
//

#import "CompanyOBJ.h"

#import "Defines.h"

@implementation CompanyOBJ

-(id)init
{
	self = [super init];
	
	if (self)
	{
		contents = [[NSMutableDictionary alloc] init];
		[contents setObject:NSStringFromClass([self class]) forKey:@"class"];
		
		[self setName:@""];
		[self setAddress:[[[AddressOBJ alloc] init] contentsDictionary]];
		[self setPhone:@""];
		[self setMobile:@""];
		[self setFax:@""];
		[self setEmail:@""];
		[self setWebsite:@""];
		[self setLogo:[UIImage imageNamed:@""]];
    [self setProfileSettings:[self savedProfileSettingsWithCustomFields:YES]];
	}
	
	return self;
}

-(id)initWithCompany:(CompanyOBJ*)sender {
	self = [super init];
	
	if (self) {
		contents = [[NSMutableDictionary alloc] init];
		[contents setObject:NSStringFromClass([self class]) forKey:@"class"];
		
		if (sender && [sender isKindOfClass:[CompanyOBJ class]]) {
			[self setName:[sender name]];
			[self setAddress:[[sender address] contentsDictionary]];
			[self setPhone:[sender phone]];
			[self setMobile:[sender mobile]];
			[self setFax:[sender fax]];
			[self setEmail:[sender email]];
			[self setWebsite:[sender website]];
			[self setLogo:[sender logo]];
      [self setProfileSettings:[sender profileSettings]];
		} else {
			[self setName:@""];
			[self setAddress:[[[AddressOBJ alloc] init] contentsDictionary]];
			[self setPhone:@""];
			[self setMobile:@""];
			[self setFax:@""];
			[self setEmail:@""];
			[self setWebsite:@""];
			[self setLogo:[UIImage imageNamed:@""]];
      [self setProfileSettings:[self savedProfileSettingsWithCustomFields:YES]];
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
		
		if (!sender || sender.count == 0)
		{
			[self setName:@""];
			[self setAddress:[[[AddressOBJ alloc] init] contentsDictionary]];
			[self setPhone:@""];
			[self setMobile:@""];
			[self setFax:@""];
			[self setEmail:@""];
			[self setWebsite:@""];
			[self setLogo:[UIImage imageNamed:@""]];
		}
    [self setProfileSettings:[self savedProfileSettingsWithCustomFields:YES]];
	}
	
	return self;
}

- (NSArray *)localProfileSettings {
  return [data_manager companyProfileSettings];
}

- (void)saveProfileSettings {
  [data_manager setCompanyProfileSettings:[self profileSettings]];
}

- (NSArray *)newProfileSettings {
  NSMutableArray *settings = [NSMutableArray new];
  [settings addObject:@{VISIBILITY: [NSNumber numberWithBool:YES],
                        TYPE: [NSNumber numberWithInteger:ProfileLogo]}];
  [settings addObject:@{VISIBILITY: [NSNumber numberWithBool:YES],
                        TYPE: [NSNumber numberWithInteger:ProfileName]}];
  [settings addObject:@{VISIBILITY: [NSNumber numberWithBool:YES],
                        TYPE: [NSNumber numberWithInteger:ProfileWebsite]}];
  [settings addObject:@{VISIBILITY: [NSNumber numberWithBool:YES],
                        TYPE: [NSNumber numberWithInteger:ProfileEmail]}];
  [settings addObject:@{VISIBILITY: [NSNumber numberWithBool:YES],
                        TYPE: [NSNumber numberWithInteger:ProfileAddress]}];
  [settings addObject:@{VISIBILITY: [NSNumber numberWithBool:YES],
                        TYPE: [NSNumber numberWithInteger:ProfilePhone]}];
  [settings addObject:@{VISIBILITY: [NSNumber numberWithBool:YES],
                        TYPE: [NSNumber numberWithInteger:ProfileMobile]}];
  [settings addObject:@{VISIBILITY: [NSNumber numberWithBool:YES],
                        TYPE: [NSNumber numberWithInteger:ProfileFax]}];
  
  return settings;
}

#pragma mark - GETTERS

+ (CompanyOBJ *)savedCompany {
  if ([CustomDefaults customObjectForKey:kCompanyKeyForNSUserDefaults] && [[CustomDefaults customObjectForKey:kCompanyKeyForNSUserDefaults] isKindOfClass:[NSDictionary class]]) {
    return [[CompanyOBJ alloc] initWithContentsDictionary:[CustomDefaults customObjectForKey:kCompanyKeyForNSUserDefaults]];
  } else {
    CompanyOBJ *myCompany = [[CompanyOBJ alloc] init];
          
    [CustomDefaults setCustomObjects:[myCompany contentsDictionary] forKey:kCompanyKeyForNSUserDefaults];
    return myCompany;
  }
}

-(NSDictionary*)contentsDictionary
{
	return contents;
}

-(NSString*)name
{
	if ([[contents allKeys] containsObject:@"name"] && [[contents objectForKey:@"name"] isKindOfClass:[NSString class]])
	{
		return [contents objectForKey:@"name"];
	}
	else
	{
		[data_manager logGetterErrorFromClass:[self class] forProperty:@"name" containedValue:[contents objectForKey:@"name"] withDefautReturnValue:@"empty string"];
		return @"";
	}
}

-(AddressOBJ*)address
{
	if ([[contents allKeys] containsObject:@"address"] && [[contents objectForKey:@"address"] isKindOfClass:[NSString class]])
	{
		return [[AddressOBJ alloc] initWithContentsDictionary:[contents objectForKey:@"address"]];
	}
	else
	{
		[data_manager logGetterErrorFromClass:[self class] forProperty:@"address" containedValue:[contents objectForKey:@"address"] withDefautReturnValue:@"empty string"];
		return [[AddressOBJ alloc] init];
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

-(UIImage*)logo
{
	if ([[contents allKeys] containsObject:@"logo"] && [[contents objectForKey:@"logo"] isKindOfClass:[NSData class]])
	{
		return [UIImage imageWithData:[contents objectForKey:@"logo"]];
	}
	else
	{
		[data_manager logGetterErrorFromClass:[self class] forProperty:@"logo" containedValue:[contents objectForKey:@"logo"] withDefautReturnValue:@"nil image"];
		return [UIImage imageNamed:@""];
	}
}

#pragma mark - SETTERS

-(void)setName:(NSString*)sender
{
	if (sender && [sender isKindOfClass:[NSString class]])
	{
		[contents setObject:sender forKey:@"name"];
	}
	else
	{
		[data_manager logSetterErrorFromClass:[self class] forProperty:@"name" sentValue:sender withDefaultSetValue:@"empty string"];
		[contents setObject:@"" forKey:@"name"];
	}
}

-(void)setAddress:(NSDictionary*)sender
{
	if (sender && [sender isKindOfClass:[NSDictionary class]])
	{
		[contents setObject:sender forKey:@"address"];
	}
	else
	{
		[data_manager logSetterErrorFromClass:[self class] forProperty:@"address" sentValue:sender withDefaultSetValue:@"empty address"];
		[contents setObject:[[[AddressOBJ alloc] init] contentsDictionary] forKey:@"address"];
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

-(void)setLogo:(UIImage*)sender
{
	if (sender && [sender isKindOfClass:[UIImage class]])
	{
		[contents setObject:UIImagePNGRepresentation(sender) forKey:@"logo"];
	}
	else
	{
		[data_manager logSetterErrorFromClass:[self class] forProperty:@"logo" sentValue:sender withDefaultSetValue:@"nothing"];
		[contents removeObjectForKey:@"logo"];
	}
}

@end