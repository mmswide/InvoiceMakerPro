//
//  ServiceTimeOBJ.m
//  Invoice
//
//  Created by XGRoup on 7/17/14.
//  Copyright (c) 2014 XGRoup. All rights reserved.
//

#import "ServiceTimeOBJ.h"

#import "Defines.h"
#import "ServiceOBJ.h"

@implementation ServiceTimeOBJ

@synthesize subtotal;

-(id)init
{
	self = [super init];
	
	if(self)
	{
		if([[CustomDefaults customObjectForKey:kDefaultServiceTime] allKeys].count != 0)
		{
			[self setDictionary:[CustomDefaults customObjectForKey:kDefaultServiceTime]];
			
			[self setOvertime:0.0];
			[self setProduct:[[ProductOBJ alloc] init]];
			[self setDiscountPercentage:0.0];
			[self setDate:[NSDate date]];
		}
		else
		{
			[self setProduct:[[ProductOBJ alloc] init]];
			[self setStartTime:[CustomDefaults customObjectForKey:kTimesheetStartTimeKey]];
			[self setFinishTime:[CustomDefaults customObjectForKey:kTimesheetFinishTimeKey]];
			[self setBreakTime:[[CustomDefaults customObjectForKey:kTimesheetBreakTimeKey] floatValue]];
			[self setOvertime:0.0];
			[self setDate:[NSDate date]];
			[self setIsPercentage:NO];
			
			[self setSubtotal:0.0];
			[self setDiscountPercentage:0.0];
			
			[CustomDefaults setCustomObjects:[self dictionaryRepresentation] forKey:kDefaultServiceTime];
		}
	}
	
	return self;
}

-(id)initWithTimeSheet:(ServiceTimeOBJ*)sender
{
	self = [super init];
	
	if (sender && [sender isKindOfClass:[ServiceTimeOBJ class]])
	{
		self = [self initWithDictionaryRepresentation:[sender dictionaryRepresentation]];
	}
	else
	{
		self = [self init];
	}
	
	return self;
}

-(id)initWithDictionaryRepresentation:(NSDictionary*)sender
{
	self = [super init];
	
	if(self)
	{		
		[self setProduct:[[ProductOBJ alloc] initWithContentsDictionary:[sender objectForKey:@"service"]]];
		[self setStartTime:[sender objectForKey:@"start_time"]];
		[self setFinishTime:[sender objectForKey:@"finish_time"]];
		[self setBreakTime:[[sender objectForKey:@"break_time"] floatValue]];
		[self setOvertime:[[sender objectForKey:@"overtime"] floatValue]];
		[self setSubtotal:[[sender objectForKey:@"subtotal"] floatValue]];
		[self setDiscountPercentage:[[sender objectForKey:@"discount_percentage"] floatValue]];
		[self setDate:[sender objectForKey:@"date"]];
		
		if([sender.allKeys containsObject:@"is_percentage"])
		{
			[self setIsPercentage:[[sender objectForKey:@"is_percentage"] boolValue]];
		}
	}
	
	return self;
}

-(void)setDictionary:(NSDictionary*)sender
{
	[self setProduct:[[ProductOBJ alloc] initWithContentsDictionary:[sender objectForKey:@"service"]]];
	[self setStartTime:[sender objectForKey:@"start_time"]];
	[self setFinishTime:[sender objectForKey:@"finish_time"]];
	[self setBreakTime:[[sender objectForKey:@"break_time"] floatValue]];
	[self setOvertime:[[sender objectForKey:@"overtime"] floatValue]];
	[self setSubtotal:[[sender objectForKey:@"subtotal"] floatValue]];
	[self setDiscountPercentage:[[sender objectForKey:@"discount_percentage"] floatValue]];
	[self setDate:[sender objectForKey:@"date"]];
	
	if([sender.allKeys containsObject:@"is_percentage"])
	{
		[self setIsPercentage:[[sender objectForKey:@"is_percentage"] boolValue]];
	}
}

-(NSDictionary*)dictionaryRepresentation
{
	NSMutableDictionary *rep = [[NSMutableDictionary alloc] init];
	
	[rep setObject:[_product contentsDictionary] forKey:@"service"];
	[rep setObject:_startTime forKey:@"start_time"];
	[rep setObject:_finishTime forKey:@"finish_time"];
	[rep setObject:[NSString stringWithFormat:@"%f",_breakTime] forKey:@"break_time"];
	[rep setObject:[NSString stringWithFormat:@"%f",_overtime] forKey:@"overtime"];
	[rep setObject:[NSString stringWithFormat:@"%f",subtotal] forKey:@"subtotal"];
	[rep setObject:[NSString stringWithFormat:@"%f",_discountPercentage] forKey:@"discount_percentage"];
	[rep setObject:_date forKey:@"date"];
	[rep setObject:[NSString stringWithFormat:@"%d",_isPercentage] forKey:@"is_percentage"];
	
	return rep;
}

-(CGFloat)subtotal
{
	subtotal = [[self product] price];
	
	NSString *unit = @"";
	
	if([[[self product] unit] componentsSeparatedByString:@"/"].count > 1)
	{
		unit = [[[[self product] unit] componentsSeparatedByString:@"/"] objectAtIndex:1];
	}
	
	CGFloat pricePerSecond = 0;
	
	if([unit isEqual:@"hr"] || [unit isEqual:@"hour"])
	{
		pricePerSecond = subtotal / 3600;
	}
	else
	if([unit isEqual:@"minute"] || [unit isEqual:@"min"])
	{
		pricePerSecond = subtotal / 60;
	}
	else
	if([unit isEqual:@"second"] || [unit isEqual:@"sec"])
	{
		pricePerSecond = subtotal;
	}
	
	if(pricePerSecond != 0)
		subtotal = [self totalTimeInSeconds] * pricePerSecond;
	
	return subtotal;
}

-(CGFloat)getTotal
{
	CGFloat total = [self subtotal] - [self discountPercentage];
	
	if(total < 0)
		return 0.0;
	
	return total;
}

-(CGFloat)discountShowPercentage
{
	float total = [self subtotal];
		
	if(total == 0)
		return 0;
	
	return ([self discountPercentage] * 100) / total;
}

-(NSString*)breakString
{
	NSInteger hours = _breakTime / 3600;
	
	NSInteger remainder = _breakTime - (hours * 3600);
	
	NSInteger minutes = remainder / 60;
	
	NSString * hoursString = [NSString stringWithFormat:@"0%ld", (long)hours];
	NSString * minutesString = [NSString stringWithFormat:@"0%ld", (long)minutes];
	
	if (hours > 9)
	{
		hoursString = [NSString stringWithFormat:@"%ld", (long)hours];
	}
	
	if (minutes > 9)
	{
		minutesString = [NSString stringWithFormat:@"%ld", (long)minutes];
	}
	
	return [NSString stringWithFormat:@"%@:%@", hoursString, minutesString];
}

-(NSInteger)breakHours
{
	NSInteger hours = _breakTime / 3600;
	
	return hours;
}

-(NSInteger)breakMinutes
{
	NSInteger hours = _breakTime / 3600;
	
	NSInteger remainder = _breakTime - (hours * 3600);
	
	NSInteger minutes = remainder / 60;
	
	return minutes;
}

-(NSString*)overtimeString
{
	NSInteger hours = _overtime / 3600;
	
	NSInteger remainder = _overtime - (hours * 3600);
	
	NSInteger minutes = remainder / 60;
	
	NSString * hoursString = [NSString stringWithFormat:@"0%ld", (long)hours];
	NSString * minutesString = [NSString stringWithFormat:@"0%ld", (long)minutes];
	
	if (hours > 9)
	{
		hoursString = [NSString stringWithFormat:@"%ld", (long)hours];
	}
	
	if (minutes > 9)
	{
		minutesString = [NSString stringWithFormat:@"%ld", (long)minutes];
	}
	
	return [NSString stringWithFormat:@"%@:%@", hoursString, minutesString];
	
}

-(NSInteger)overtimeHours
{
	NSInteger hours = _overtime / 3600;
	
	return hours;
	
}

-(NSInteger)overtimeMinuts
{
	NSInteger hours = _overtime / 3600;
	
	NSInteger remainder = _overtime - (hours * 3600);
	
	NSInteger minutes = remainder / 60;
	
	return minutes;
}

-(NSInteger)totalTimeInSeconds
{
	int interval = [_finishTime timeIntervalSinceDate:_startTime];
	interval -= _breakTime;
	interval += _overtime;
	
	return interval;
}

-(NSString*)duration
{
	NSInteger hours = [self totalTimeInSeconds] / 3600;
	
	NSInteger remainder = [self totalTimeInSeconds] - (hours * 3600);
	
	NSInteger minutes = remainder / 60;
	
	NSString * hoursString = [NSString stringWithFormat:@"0%ld", (long)hours];
	NSString * minutesString = [NSString stringWithFormat:@"0%ld", (long)minutes];
	
	if (hours > 9)
	{
		hoursString = [NSString stringWithFormat:@"%ld", (long)hours];
	}
	
	if (minutes > 9)
	{
		minutesString = [NSString stringWithFormat:@"%ld", (long)minutes];
	}
	
	return [NSString stringWithFormat:@"%@:%@", hoursString, minutesString];
}

-(NSString*)totalHours
{
	float totalTimeInterval = [self totalTimeInSeconds];
		
	NSInteger hours = totalTimeInterval / 3600;
	
	NSInteger remainder = totalTimeInterval - (hours * 3600);
	
	NSInteger minutes = remainder / 60;
	
	NSString * hoursString = [NSString stringWithFormat:@"0%ld", (long)hours];
	NSString * minutesString = [NSString stringWithFormat:@"0%ld", (long)minutes];
	
	if (hours > 9)
	{
		hoursString = [NSString stringWithFormat:@"%ld", (long)hours];
	}
	
	if (minutes > 9)
	{
		minutesString = [NSString stringWithFormat:@"%ld", (long)minutes];
	}
	
	return [NSString stringWithFormat:@"%@ h %@ min", hoursString, minutesString];
}

-(void)adjustDiscount
{
	CGFloat tempSubtotal = subtotal;
	
	if(tempSubtotal != 0)
	{
		_discountPercentage = (_discountPercentage * [self subtotal]) / tempSubtotal;
	}
}


@end
