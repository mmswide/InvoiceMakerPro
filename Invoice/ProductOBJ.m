//
//  ProductOBJ.m
//  Invoice
//
//  Created by XGRoup5 on 8/13/13.
//  Copyright (c) 2013 XGRoup. All rights reserved.
//

#import "ProductOBJ.h"

#import "Defines.h"

#define CUSTOM_FIELD(x) [NSString stringWithFormat:@"CUSTOM_FIELD_%@",x]

@implementation ProductOBJ
@synthesize indexInCollection = _indexInCollection;

-(id)init
{
	self = [super init];
	
	if (self)
	{
		contents = [[NSMutableDictionary alloc] init];
		[contents setObject:NSStringFromClass([self class]) forKey:@"class"];
		
		[self setID:[data_manager createProductID]];
		[self setName:@""];
		[self setPrice:0.0f];
		[self setCode:@""];
		[self setTaxable:[CustomDefaults customBoolForKey:kDefaultTaxable]];
		[self setNote:@""];
		[self setQuantity:0.0f];
		[self setDiscount:0.0f];
		[self setUnit:@"item"];
	}
	
	return self;
}

-(id)initWithProduct:(ProductOBJ*)sender
{
	self = [super init];
	
	if (self)
	{
		contents = [[NSMutableDictionary alloc] init];
		[contents setObject:NSStringFromClass([self class]) forKey:@"class"];
		
		if (sender && [sender isKindOfClass:[ProductOBJ class]])
		{
			[self setID:[sender ID]];
			[self setName:[sender name]];
			[self setPrice:[sender price]];
			[self setCode:[sender code]];
			[self setTaxable:[sender taxable]];
			[self setNote:[sender note]];
			[self setQuantity:[data_manager trimmedQuantity:[sender quantity]]];
			[self setDiscount:[sender discount]];
			[self setUnit:[sender rawUnit]];
		}
		else
		{
			[self setID:[data_manager createProductID]];
			[self setName:@""];
			[self setPrice:0.0f];
			[self setCode:@""];
			[self setTaxable:[CustomDefaults customBoolForKey:kDefaultTaxable]];
			[self setNote:@""];
			[self setQuantity:0.0f];
			[self setDiscount:0.0f];
			[self setUnit:@"item"];
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
		[contents addEntriesFromDictionary:sender];
		
		if(![sender.allKeys containsObject:@"class"] || [[sender objectForKey:@"class"] isEqual:@""])
			[contents setObject:NSStringFromClass([self class]) forKey:@"class"];
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
		
		[self setName:@"Product"];
		[self setPrice:100.0f];
		[self setCode:@"1234"];
		[self setTaxable:YES];
		[self setNote:@"Note"];
		[self setQuantity:arc4random() % 36 + 15];
		[self setDiscount:(float)(arc4random() % 100) / 100.0f];
		[self setUnit:@"item"];
	}
	
	return self;
}

#pragma mark - GETTERS

-(NSDictionary*)contentsDictionary
{
	return contents;
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

-(CGFloat)price
{
	if ([[contents allKeys] containsObject:@"price"] && [[contents objectForKey:@"price"] isKindOfClass:[NSNumber class]])
	{
		return [[contents objectForKey:@"price"] floatValue];
	}
	else
	{
		[data_manager logGetterErrorFromClass:[self class] forProperty:@"price" containedValue:[contents objectForKey:@"price"] withDefautReturnValue:@"0.0"];
		return 0.0f;
	}
}

-(NSString*)code
{
	if ([[contents allKeys] containsObject:@"code"] && [[contents objectForKey:@"code"] isKindOfClass:[NSString class]])
	{
		return [contents objectForKey:@"code"];
	}
	else
	{
		[data_manager logGetterErrorFromClass:[self class] forProperty:@"code" containedValue:[contents objectForKey:@"code"] withDefautReturnValue:@"empty string"];
		return @"";
	}
}

-(BOOL)taxable
{
	if ([[contents allKeys] containsObject:@"taxable"] && [[contents objectForKey:@"taxable"] isKindOfClass:[NSNumber class]])
	{
		return [[contents objectForKey:@"taxable"] boolValue];
	}
	else
	{
		[data_manager logGetterErrorFromClass:[self class] forProperty:@"taxable" containedValue:[contents objectForKey:@"taxable"] withDefautReturnValue:@"false"];
		return NO;
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

-(CGFloat)quantity
{
	if ([[contents allKeys] containsObject:@"quantity"] && [[contents objectForKey:@"quantity"] isKindOfClass:[NSNumber class]])
	{
		return [[contents objectForKey:@"quantity"] floatValue];
	}
	else
	{
		[data_manager logGetterErrorFromClass:[self class] forProperty:@"quantity" containedValue:[contents objectForKey:@"quantity"] withDefautReturnValue:@"0"];
		return 0.0f;
	}
}

-(CGFloat)discount
{
	if ([[contents allKeys] containsObject:@"discount"] && [[contents objectForKey:@"discount"] isKindOfClass:[NSNumber class]])
	{
		return [[contents objectForKey:@"discount"] floatValue];
	}
	else
	{
		[data_manager logGetterErrorFromClass:[self class] forProperty:@"discount" containedValue:[contents objectForKey:@"discount"] withDefautReturnValue:@"0"];
		return 0.0f;
	}
}

-(CGFloat)total
{
	CGFloat value = ([self quantity] * [self price]) - ([self quantity] * [self price] * ([self discount] / 100));
	return value;
}

-(NSString*)unit
{
	if ([[contents allKeys] containsObject:@"unit"] && [[contents objectForKey:@"unit"] isKindOfClass:[NSString class]])
	{
		return [NSString stringWithFormat:@"Rate/%@", [contents objectForKey:@"unit"]];
	}
	else
	{
		[data_manager logGetterErrorFromClass:[self class] forProperty:@"unit" containedValue:[contents objectForKey:@"unit"] withDefautReturnValue:@"empty string"];
		return @"";
	}
}

-(NSString*)rawUnit
{
	if ([[contents allKeys] containsObject:@"unit"] && [[contents objectForKey:@"unit"] isKindOfClass:[NSString class]])
	{
		return [contents objectForKey:@"unit"];
	}
	else
	{
		[data_manager logGetterErrorFromClass:[self class] forProperty:@"unit" containedValue:[contents objectForKey:@"unit"] withDefautReturnValue:@"empty string"];
		return @"";
	}
}

-(CGFloat)tax1Percentage
{
	if ([[contents allKeys] containsObject:@"tax1Percentage"] && [[contents objectForKey:@"tax1Percentage"] isKindOfClass:[NSNumber class]])
	{
		return [[contents objectForKey:@"tax1Percentage"] floatValue];
	}
	else
	{
		[data_manager logGetterErrorFromClass:[self class] forProperty:@"tax1Percentage" containedValue:[contents objectForKey:@"tax1Percentage"] withDefautReturnValue:@"0.0"];
		return 0.0f;
	}
}

-(CGFloat)tax2Percentage
{
	if ([[contents allKeys] containsObject:@"tax2Percentage"] && [[contents objectForKey:@"tax2Percentage"] isKindOfClass:[NSNumber class]])
	{
		return [[contents objectForKey:@"tax2Percentage"] floatValue];
	}
	else
	{
		[data_manager logGetterErrorFromClass:[self class] forProperty:@"tax2Percentage" containedValue:[contents objectForKey:@"tax2Percentage"] withDefautReturnValue:@"0.0"];
		return 0.0f;
	}
}

-(CGFloat)tax1Value
{
	CGFloat value = [self total] * ([self tax1Percentage] / 100);
	
	return value;
}

-(CGFloat)tax2Value
{
	CGFloat value = [self total] * ([self tax2Percentage] / 100);
	
	return value;
}

- (NSString *)valueForCustomType:(AddItemDetailType)type {
  if([contents objectForKey:CUSTOM_FIELD(@(type))]) {
    return [contents objectForKey:CUSTOM_FIELD(@(type))];
  }
  return @"";
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

-(void)setPrice:(CGFloat)sender
{
	[contents setObject:[NSNumber numberWithFloat:sender] forKey:@"price"];
}

-(void)setCode:(NSString*)sender
{
	if (sender && [sender isKindOfClass:[NSString class]])
	{
		[contents setObject:sender forKey:@"code"];
	}
	else
	{
		[data_manager logSetterErrorFromClass:[self class] forProperty:@"code" sentValue:sender withDefaultSetValue:@"empty string"];
		[contents setObject:@"" forKey:@"code"];
	}
}

-(void)setTaxable:(BOOL)sender
{
	[contents setObject:[NSNumber numberWithBool:sender] forKey:@"taxable"];
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

-(void)setQuantity:(CGFloat)sender
{
	[contents setObject:[NSNumber numberWithFloat:sender] forKey:@"quantity"];
}

-(void)setDiscount:(CGFloat)sender
{
	[contents setObject:[NSNumber numberWithFloat:sender] forKey:@"discount"];
}

-(void)setUnit:(NSString*)sender
{
	if (sender && [sender isKindOfClass:[NSString class]])
	{
		[contents setObject:sender forKey:@"unit"];
	}
	else
	{
		[data_manager logSetterErrorFromClass:[self class] forProperty:@"unit" sentValue:sender withDefaultSetValue:@"empty string"];
		[contents setObject:@"" forKey:@"unit"];
	}
}

-(void)setTax1Percentage:(CGFloat)sender
{
	[contents setObject:[NSNumber numberWithFloat:sender] forKey:@"tax1Percentage"];
}

-(void)setTax2Percentage:(CGFloat)sender
{
	[contents setObject:[NSNumber numberWithFloat:sender] forKey:@"tax2Percentage"];
}

- (void)setValue:(NSString *)value forCustomType:(AddItemDetailType)type {
  if(value) {
    [contents setObject:value forKey:CUSTOM_FIELD(@(type))];
  } else {
    [data_manager logSetterErrorFromClass:[self class] forProperty:CUSTOM_FIELD(@(type)) sentValue:value withDefaultSetValue:@"empty string"];
    [contents setObject:@"" forKey:CUSTOM_FIELD(@(type))];
  }
}

#pragma mark - DESCRIPTION

-(NSString*)description
{
	return contents.description;
}


@end
