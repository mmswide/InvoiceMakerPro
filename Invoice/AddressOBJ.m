//
//  AddressOBJ.m
//  Invoice
//
//  Created by XGRoup5 on 8/28/13.
//  Copyright (c) 2013 XGRoup. All rights reserved.
//

#import "AddressOBJ.h"

#import "Defines.h"

@implementation AddressOBJ

-(id)init
{
	self = [super init];
	
	if (self)
	{
		contents = [[NSMutableDictionary alloc] init];
		[contents setObject:NSStringFromClass([self class]) forKey:@"class"];
		
		[self setAddressLine1:@""];
		[self setAddressLine2:@""];
		[self setAddressLine3:@""];
		[self setCity:@""];
		[self setState:@""];
		[self setZIP:@""];
		[self setCountry:@""];
	}
	
	return self;
}

-(id)initWithAddress:(AddressOBJ*)sender
{
	self = [super init];
	
	if (self)
	{
		contents = [[NSMutableDictionary alloc] init];
		[contents setObject:NSStringFromClass([self class]) forKey:@"class"];
		
		if (sender && [sender isKindOfClass:[AddressOBJ class]])
		{
			[self setAddressLine1:[sender addressLine1]];
			[self setAddressLine2:[sender addressLine2]];
			[self setAddressLine3:[sender addressLine3]];
			[self setCity:[sender city]];
			[self setState:[sender state]];
			[self setZIP:[sender ZIP]];
			[self setCountry:[sender country]];
      [self setSameAsBilling:[sender sameAsBilling]];
		}
		else
		{
			[self setAddressLine1:@""];
			[self setAddressLine2:@""];
			[self setAddressLine3:@""];
			[self setCity:@""];
			[self setState:@""];
			[self setZIP:@""];
			[self setCountry:@""];
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
		
		[self setAddressLine1:@"Address"];
		[self setAddressLine2:@"Part"];
		[self setAddressLine3:@"One"];
		[self setCity:@"City"];
		[self setState:@"State"];
		[self setZIP:@"ZIP"];
		[self setCountry:@"Country"];
	}
	
	return self;
}

- (BOOL)hasSameAddresAs:(AddressOBJ *)otherAddress {
  NSMutableDictionary *this = [contents copy];
  [this setObject:@"" forKey:@"billingTitle"];
  [this setObject:@"" forKey:@"shippingTitle"];
  NSMutableDictionary *that = [[otherAddress contentsDictionary] copy];
  [that setObject:@"" forKey:@"billingTitle"];
  [that setObject:@"" forKey:@"shippingTitle"];
  
  return [this isEqualToDictionary:that];
}

#pragma mark - GETTERS

-(NSDictionary*)contentsDictionary
{
	return contents;
}

-(NSString*)fullStringRepresentation
{
	NSString * firstLine = @"";
	
	if (![[self addressLine1] isEqual:@""] && ![[self addressLine2] isEqual:@""] && ![[self addressLine3] isEqual:@""])
	{
		firstLine = [NSString stringWithFormat:@"%@, %@, %@", [self addressLine1], [self addressLine2], [self addressLine3]];
	}
	else if ([[self addressLine1] isEqual:@""] && ![[self addressLine2] isEqual:@""] && ![[self addressLine3] isEqual:@""])
	{
		firstLine = [NSString stringWithFormat:@"%@, %@", [self addressLine2], [self addressLine3]];
	}
	else if (![[self addressLine1] isEqual:@""] && [[self addressLine2] isEqual:@""] && ![[self addressLine3] isEqual:@""])
	{
		firstLine = [NSString stringWithFormat:@"%@, %@", [self addressLine1], [self addressLine3]];
	}
	else if (![[self addressLine1] isEqual:@""] && ![[self addressLine2] isEqual:@""] && [[self addressLine3] isEqual:@""])
	{
		firstLine = [NSString stringWithFormat:@"%@, %@", [self addressLine1], [self addressLine2]];
	}
	else if ([[self addressLine1] isEqual:@""] && [[self addressLine2] isEqual:@""] && ![[self addressLine3] isEqual:@""])
	{
		firstLine = [NSString stringWithFormat:@"%@", [self addressLine3]];
	}
	else if ([[self addressLine1] isEqual:@""] && ![[self addressLine2] isEqual:@""] && [[self addressLine3] isEqual:@""])
	{
		firstLine = [NSString stringWithFormat:@"%@", [self addressLine2]];
	}
	else if (![[self addressLine1] isEqual:@""] && [[self addressLine2] isEqual:@""] && [[self addressLine3] isEqual:@""])
	{
		firstLine = [NSString stringWithFormat:@"%@", [self addressLine1]];
	}
	
	NSString * secondLine = @"";
	
	if (![[self city] isEqual:@""] && ![[self state] isEqual:@""] && ![[self ZIP] isEqual:@""])
	{
		secondLine = [NSString stringWithFormat:@"%@, %@, %@", [self city], [self state], [self ZIP]];
	}
	else if ([[self city] isEqual:@""] && ![[self state] isEqual:@""] && ![[self ZIP] isEqual:@""])
	{
		secondLine = [NSString stringWithFormat:@"%@, %@", [self state], [self ZIP]];
	}
	else if (![[self city] isEqual:@""] && [[self state] isEqual:@""] && ![[self ZIP] isEqual:@""])
	{
		secondLine = [NSString stringWithFormat:@"%@, %@", [self city], [self ZIP]];
	}
	else if (![[self city] isEqual:@""] && ![[self state] isEqual:@""] && [[self ZIP] isEqual:@""])
	{
		secondLine = [NSString stringWithFormat:@"%@, %@", [self city], [self state]];
	}
	else if ([[self city] isEqual:@""] && [[self state] isEqual:@""] && ![[self ZIP] isEqual:@""])
	{
		secondLine = [NSString stringWithFormat:@"%@", [self ZIP]];
	}
	else if ([[self city] isEqual:@""] && ![[self state] isEqual:@""] && [[self ZIP] isEqual:@""])
	{
		secondLine = [NSString stringWithFormat:@"%@", [self state]];
	}
	else if (![[self city] isEqual:@""] && [[self state] isEqual:@""] && [[self ZIP] isEqual:@""])
	{
		secondLine = [NSString stringWithFormat:@"%@", [self city]];
	}
	
	NSString * thirdLine = @"";
	
	if (![[self country] isEqual:@""])
	{
		thirdLine = [NSString stringWithFormat:@"%@", [self country]];
	}
	
	NSString * representation = @"";
	
	if (![firstLine isEqual:@""] && ![secondLine isEqual:@""] && ![thirdLine isEqual:@""])
	{
		representation = [NSString stringWithFormat:@"%@\n%@\n%@", firstLine, secondLine, thirdLine];
	}
	else if ([firstLine isEqual:@""] && ![secondLine isEqual:@""] && ![thirdLine isEqual:@""])
	{
		representation = [NSString stringWithFormat:@"%@\n%@", secondLine, thirdLine];
	}
	else if (![firstLine isEqual:@""] && [secondLine isEqual:@""] && ![thirdLine isEqual:@""])
	{
		representation = [NSString stringWithFormat:@"%@\n%@", firstLine, thirdLine];
	}
	else if (![firstLine isEqual:@""] && ![secondLine isEqual:@""] && [thirdLine isEqual:@""])
	{
		representation = [NSString stringWithFormat:@"%@\n%@", firstLine, secondLine];
	}
	else if ([firstLine isEqual:@""] && [secondLine isEqual:@""] && ![thirdLine isEqual:@""])
	{
		representation = [NSString stringWithFormat:@"%@", thirdLine];
	}
	else if ([firstLine isEqual:@""] && ![secondLine isEqual:@""] && [thirdLine isEqual:@""])
	{
		representation = [NSString stringWithFormat:@"%@", secondLine];
	}
	else if (![firstLine isEqual:@""] && [secondLine isEqual:@""] && [thirdLine isEqual:@""])
	{
		representation = [NSString stringWithFormat:@"%@", firstLine];
	}
	
	return representation;
}

-(NSString*)representationLine1
{
	NSString * firstLine = @"";
	
	if (![[self addressLine1] isEqual:@""] && ![[self addressLine2] isEqual:@""] && ![[self addressLine3] isEqual:@""])
	{
		firstLine = [NSString stringWithFormat:@"%@, %@, %@", [self addressLine1], [self addressLine2], [self addressLine3]];
	}
	else if ([[self addressLine1] isEqual:@""] && ![[self addressLine2] isEqual:@""] && ![[self addressLine3] isEqual:@""])
	{
		firstLine = [NSString stringWithFormat:@"%@, %@", [self addressLine2], [self addressLine3]];
	}
	else if (![[self addressLine1] isEqual:@""] && [[self addressLine2] isEqual:@""] && ![[self addressLine3] isEqual:@""])
	{
		firstLine = [NSString stringWithFormat:@"%@, %@", [self addressLine1], [self addressLine3]];
	}
	else if (![[self addressLine1] isEqual:@""] && ![[self addressLine2] isEqual:@""] && [[self addressLine3] isEqual:@""])
	{
		firstLine = [NSString stringWithFormat:@"%@, %@", [self addressLine1], [self addressLine2]];
	}
	else if ([[self addressLine1] isEqual:@""] && [[self addressLine2] isEqual:@""] && ![[self addressLine3] isEqual:@""])
	{
		firstLine = [NSString stringWithFormat:@"%@", [self addressLine3]];
	}
	else if ([[self addressLine1] isEqual:@""] && ![[self addressLine2] isEqual:@""] && [[self addressLine3] isEqual:@""])
	{
		firstLine = [NSString stringWithFormat:@"%@", [self addressLine2]];
	}
	else if (![[self addressLine1] isEqual:@""] && [[self addressLine2] isEqual:@""] && [[self addressLine3] isEqual:@""])
	{
		firstLine = [NSString stringWithFormat:@"%@", [self addressLine1]];
	}
	
	return firstLine;
}

-(NSString*)representationLine2
{
	NSString * secondLine = @"";
	
	if (![[self city] isEqual:@""] && ![[self state] isEqual:@""] && ![[self ZIP] isEqual:@""])
	{
		secondLine = [NSString stringWithFormat:@"%@, %@, %@", [self city], [self state], [self ZIP]];
	}
	else if ([[self city] isEqual:@""] && ![[self state] isEqual:@""] && ![[self ZIP] isEqual:@""])
	{
		secondLine = [NSString stringWithFormat:@"%@, %@", [self state], [self ZIP]];
	}
	else if (![[self city] isEqual:@""] && [[self state] isEqual:@""] && ![[self ZIP] isEqual:@""])
	{
		secondLine = [NSString stringWithFormat:@"%@, %@", [self city], [self ZIP]];
	}
	else if (![[self city] isEqual:@""] && ![[self state] isEqual:@""] && [[self ZIP] isEqual:@""])
	{
		secondLine = [NSString stringWithFormat:@"%@, %@", [self city], [self state]];
	}
	else if ([[self city] isEqual:@""] && [[self state] isEqual:@""] && ![[self ZIP] isEqual:@""])
	{
		secondLine = [NSString stringWithFormat:@"%@", [self ZIP]];
	}
	else if ([[self city] isEqual:@""] && ![[self state] isEqual:@""] && [[self ZIP] isEqual:@""])
	{
		secondLine = [NSString stringWithFormat:@"%@", [self state]];
	}
	else if (![[self city] isEqual:@""] && [[self state] isEqual:@""] && [[self ZIP] isEqual:@""])
	{
		secondLine = [NSString stringWithFormat:@"%@", [self city]];
	}
	
	return secondLine;
}

-(NSString*)representationLine3
{
	return [self country];
}

-(NSString*)billingTitle
{
	if ([[contents allKeys] containsObject:@"billingTitle"] && [[contents objectForKey:@"billingTitle"] isKindOfClass:[NSString class]]) {
		return [contents objectForKey:@"billingTitle"];
	} else {
		[data_manager logGetterErrorFromClass:[self class] forProperty:@"billingTitle" containedValue:[contents objectForKey:@"billingTitle"] withDefautReturnValue:@"empty string"];
		return [CustomDefaults customObjectForKey:kBillingAddressTitleKeyForNSUserDefaults];
	}
}

-(NSString*)shippingTitle
{
	if ([[contents allKeys] containsObject:@"shippingTitle"] && [[contents objectForKey:@"shippingTitle"] isKindOfClass:[NSString class]])
	{
		return [contents objectForKey:@"shippingTitle"];
	}
	else
	{
		[data_manager logGetterErrorFromClass:[self class] forProperty:@"shippingTitle" containedValue:[contents objectForKey:@"shippingTitle"] withDefautReturnValue:@"empty string"];
		return [CustomDefaults customObjectForKey:kShippingAddressTitleKeyForNSUserDefaults];
	}
}

-(NSString*)addressLine1
{
	if ([[contents allKeys] containsObject:@"addressLine1"] && [[contents objectForKey:@"addressLine1"] isKindOfClass:[NSString class]])
	{
		return [contents objectForKey:@"addressLine1"];
	}
	else
	{
		[data_manager logGetterErrorFromClass:[self class] forProperty:@"addressLine1" containedValue:[contents objectForKey:@"addressLine1"] withDefautReturnValue:@"empty string"];
		return @"";
	}
}

-(NSString*)addressLine2
{
	if ([[contents allKeys] containsObject:@"addressLine2"] && [[contents objectForKey:@"addressLine2"] isKindOfClass:[NSString class]])
	{
		return [contents objectForKey:@"addressLine2"];
	}
	else
	{
		[data_manager logGetterErrorFromClass:[self class] forProperty:@"addressLine2" containedValue:[contents objectForKey:@"addressLine2"] withDefautReturnValue:@"empty string"];
		return @"";
	}
}

-(NSString*)addressLine3
{
	if ([[contents allKeys] containsObject:@"addressLine3"] && [[contents objectForKey:@"addressLine3"] isKindOfClass:[NSString class]])
	{
		return [contents objectForKey:@"addressLine3"];
	}
	else
	{
		[data_manager logGetterErrorFromClass:[self class] forProperty:@"addressLine3" containedValue:[contents objectForKey:@"addressLine3"] withDefautReturnValue:@"empty string"];
		return @"";
	}
}

-(NSString*)city
{
	if ([[contents allKeys] containsObject:@"city"] && [[contents objectForKey:@"city"] isKindOfClass:[NSString class]])
	{
		return [contents objectForKey:@"city"];
	}
	else
	{
		[data_manager logGetterErrorFromClass:[self class] forProperty:@"city" containedValue:[contents objectForKey:@"city"] withDefautReturnValue:@"empty string"];
		return @"";
	}
}

-(NSString*)state
{
	if ([[contents allKeys] containsObject:@"state"] && [[contents objectForKey:@"state"] isKindOfClass:[NSString class]])
	{
		return [contents objectForKey:@"state"];
	}
	else
	{
		[data_manager logGetterErrorFromClass:[self class] forProperty:@"state" containedValue:[contents objectForKey:@"state"] withDefautReturnValue:@"empty string"];
		return @"";
	}
}

-(NSString*)ZIP
{
	if ([[contents allKeys] containsObject:@"ZIP"] && [[contents objectForKey:@"ZIP"] isKindOfClass:[NSString class]])
	{
		return [contents objectForKey:@"ZIP"];
	}
	else
	{
		[data_manager logGetterErrorFromClass:[self class] forProperty:@"ZIP" containedValue:[contents objectForKey:@"ZIP"] withDefautReturnValue:@"empty string"];
		return @"";
	}
}

-(NSString*)country
{
	if ([[contents allKeys] containsObject:@"country"] && [[contents objectForKey:@"country"] isKindOfClass:[NSString class]])
	{
		return [contents objectForKey:@"country"];
	}
	else
	{
		[data_manager logGetterErrorFromClass:[self class] forProperty:@"country" containedValue:[contents objectForKey:@"country"] withDefautReturnValue:@"empty string"];
		return @"";
	}
}

-(BOOL)sameAsBilling {
  if([contents objectForKey:@"sameAsBilling"]) {
    return [[contents objectForKey:@"sameAsBilling"] boolValue];
  } else {
    return NO;
  }
}

#pragma mark - SETTERS

-(void)setBillingTitle:(NSString*)sender {
	if (sender && [sender isKindOfClass:[NSString class]]) {
		[contents setObject:sender forKey:@"billingTitle"];
	} else {
		[data_manager logSetterErrorFromClass:[self class] forProperty:@"billingTitle" sentValue:sender withDefaultSetValue:@"empty string"];
		[contents setObject:[CustomDefaults customObjectForKey:kBillingAddressTitleKeyForNSUserDefaults] forKey:@"billingTitle"];
	}
}

-(void)setShippingTitle:(NSString*)sender {
	if (sender && [sender isKindOfClass:[NSString class]]) {
		[contents setObject:sender forKey:@"shippingTitle"];
	}
	else
	{
		[data_manager logSetterErrorFromClass:[self class] forProperty:@"shippingTitle" sentValue:sender withDefaultSetValue:@"empty string"];
		[contents setObject:[CustomDefaults customObjectForKey:kShippingAddressTitleKeyForNSUserDefaults] forKey:@"shippingTitle"];
	}
}

-(void)setAddressLine1:(NSString*)sender
{
	if (sender && [sender isKindOfClass:[NSString class]])
	{
		[contents setObject:sender forKey:@"addressLine1"];
	}
	else
	{
		[data_manager logSetterErrorFromClass:[self class] forProperty:@"addressLine1" sentValue:sender withDefaultSetValue:@"empty string"];
		[contents setObject:@"" forKey:@"addressLine1"];
	}
}

-(void)setAddressLine2:(NSString*)sender
{
	if (sender && [sender isKindOfClass:[NSString class]])
	{
		[contents setObject:sender forKey:@"addressLine2"];
	}
	else
	{
		[data_manager logSetterErrorFromClass:[self class] forProperty:@"addressLine2" sentValue:sender withDefaultSetValue:@"empty string"];
		[contents setObject:@"" forKey:@"addressLine2"];
	}
}

-(void)setAddressLine3:(NSString*)sender
{
	if (sender && [sender isKindOfClass:[NSString class]])
	{
		[contents setObject:sender forKey:@"addressLine3"];
	}
	else
	{
		[data_manager logSetterErrorFromClass:[self class] forProperty:@"addressLine3" sentValue:sender withDefaultSetValue:@"empty string"];
		[contents setObject:@"" forKey:@"addressLine3"];
	}
}

-(void)setCity:(NSString*)sender
{
	if (sender && [sender isKindOfClass:[NSString class]])
	{
		[contents setObject:sender forKey:@"city"];
	}
	else
	{
		[data_manager logSetterErrorFromClass:[self class] forProperty:@"city" sentValue:sender withDefaultSetValue:@"empty string"];
		[contents setObject:@"" forKey:@"city"];
	}
}

-(void)setState:(NSString*)sender
{
	if (sender && [sender isKindOfClass:[NSString class]])
	{
		[contents setObject:sender forKey:@"state"];
	}
	else
	{
		[data_manager logSetterErrorFromClass:[self class] forProperty:@"state" sentValue:sender withDefaultSetValue:@"empty string"];
		[contents setObject:@"" forKey:@"state"];
	}
}

-(void)setZIP:(NSString*)sender
{
	if (sender && [sender isKindOfClass:[NSString class]])
	{
		[contents setObject:sender forKey:@"ZIP"];
	}
	else
	{
		[data_manager logSetterErrorFromClass:[self class] forProperty:@"ZIP" sentValue:sender withDefaultSetValue:@"empty string"];
		[contents setObject:@"" forKey:@"ZIP"];
	}
}

-(void)setCountry:(NSString*)sender
{
	if (sender && [sender isKindOfClass:[NSString class]])
	{
		[contents setObject:sender forKey:@"country"];
	}
	else
	{
		[data_manager logSetterErrorFromClass:[self class] forProperty:@"country" sentValue:sender withDefaultSetValue:@"empty string"];
		[contents setObject:@"" forKey:@"country"];
	}
}

-(void)setSameAsBilling:(BOOL)sender {
  [contents setObject:[NSNumber numberWithBool:sender] forKey:@"sameAsBilling"];
}

#pragma mark - DESCRIPTION

-(NSString*)description
{
	return contents.description;
}

@end