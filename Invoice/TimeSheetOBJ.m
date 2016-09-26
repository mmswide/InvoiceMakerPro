//
//  TimeSheet.m
//  Invoice
//
//  Created by XGRoup on 7/17/14.
//  Copyright (c) 2014 XGRoup. All rights reserved.
//

#import "TimeSheetOBJ.h"

#import "Defines.h"

#import "ServiceTimeOBJ.h"

@implementation TimeSheetOBJ

@synthesize title;
@synthesize note;
@synthesize bigNote;

@synthesize otherComments;
@synthesize otherCommentsTitle;

@synthesize rightSignature;
@synthesize rightSignatureFrame;
@synthesize rightSignatureTitle;

@synthesize leftSignature;
@synthesize leftSignatureFrame;
@synthesize leftSignatureTitle;

-(id)init
{
	self = [super init];
	
	if (self)
	{
		[self setID:[data_manager createTimeSheetID]];
		title = [[NSMutableString alloc] initWithString:[CustomDefaults customObjectForKey:kTimesheetTitleKeyForNSUserDefaults]];
		[self setNumber:@"TS00001"];
		[self setClient:[[ClientOBJ alloc] init]];
		[self setDate:[[NSDate alloc] initWithTimeIntervalSinceNow:0]];
		[self setProject:[[ProjectOBJ alloc] init]];
		[self setServices:[[NSMutableArray alloc] init]];
				
		[self setDiscount:0.0];
		[self setSubtotal:0.0];
		
		[self setOtherCommentsTitle:TIMESHEET_OTHER_COMMENTS_TITLE];
		[self setOtherCommentsText:TIMESHEET_OTHER_COMMENTS_TEXT];
						
		rightSignature = [UIImage imageWithContentsOfFile:[NSHomeDirectory() stringByAppendingFormat:@"/Documents/%@",TIMESHEET_RIGHT_SIGNATURE_PATH]];
		[self setRightSignatureFrame:TIMESHEET_RIGHT_FRAME];
		[self setRightSignatureTitle:TIMESHEET_RIGHT_SIGNATURE_TITLE];
		[self setRightSignatureDate:[NSDate date]];
		
		leftSignature = [UIImage imageWithContentsOfFile:[NSHomeDirectory() stringByAppendingFormat:@"/Documents/%@",TIMESHEET_LEFT_SIGNATURE_PATH]];
		[self setLeftSignatureFrame:TIMESHEET_LEFT_FRAME];
		[self setLeftSignatureTitle:TIMESHEET_LEFT_SIGNATURE_TITLE];
		[self setLeftSignatureDate:[NSDate date]];
	
		NSDictionary *settingsDict = [[NSDictionary alloc] initWithDictionary:[CustomDefaults customObjectForKey:kSettingsKeyForNSUserDefaults]];
                
		if([TIMESHEET_FIRST_PAGE_NOTE isEqual:@""])
		{
			[self setNote:[settingsDict objectForKey:@"defaultNote"]];
		}
		else
		{
			[self setNote:TIMESHEET_FIRST_PAGE_NOTE];
		}
				
		[self setBigNote:TIMESHEET_SECOND_PAGE_NOTE];
	}
	
	return self;
}

-(id)initWithTimeSheet:(TimeSheetOBJ *)sender
{
	if (sender && [sender isKindOfClass:[TimeSheetOBJ class]])
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
	if (sender && [sender isKindOfClass:[NSDictionary class]])
	{
		self = [super init];
				
		if (self)
		{
			_ID = [[NSString alloc] initWithString:[sender objectForKey:@"id"]];
			title = [[NSString alloc] initWithString:[sender objectForKey:@"title"]];
			
			_number = [[NSString alloc] initWithString:[sender objectForKey:@"number"]];
			_client = [[ClientOBJ alloc] initWithContentsDictionary:[sender objectForKey:@"client"]];
			_date = [sender objectForKey:@"date"];
			_project = [[ProjectOBJ alloc] initWithContentsDictionary:[sender objectForKey:@"project"]];
						
			_services = [[NSMutableArray alloc] initWithArray:[sender objectForKey:@"services"]];
			
			_subtotal = [[sender objectForKey:@"subtotal"] floatValue];
			_discount = [[sender objectForKey:@"discount"] floatValue];
			
			note = [[NSString alloc] initWithString:[sender objectForKey:@"note"]];
			
			bigNote = [[NSString alloc] initWithString:[sender objectForKey:@"big_note"]];
						
			otherComments = [[NSString alloc] initWithString:[sender objectForKey:@"other_comments"]];
			otherCommentsTitle = [[NSString alloc]initWithString:[sender objectForKey:@"other_comments_title"]];
			
			
			rightSignature = [UIImage imageWithContentsOfFile:[NSHomeDirectory() stringByAppendingFormat:@"/Documents/%@",TIMESHEET_RIGHT_SIGNATURE_PATH]];
			rightSignatureFrame = CGRectFromString([sender objectForKey:@"right_signature_frame"]);
			rightSignatureTitle = [[NSString alloc] initWithString:[sender objectForKey:@"right_signature_title"]];
			_rightSignatureDate = [sender objectForKey:@"right_date"];
						
			leftSignature = [UIImage imageWithContentsOfFile:[NSHomeDirectory() stringByAppendingFormat:@"/Documents/%@",TIMESHEET_LEFT_SIGNATURE_PATH]];
			leftSignatureFrame = CGRectFromString([sender objectForKey:@"left_signature_frame"]);
			leftSignatureTitle = [[NSString alloc] initWithString:[sender objectForKey:@"left_signature_title"]];
			_leftSignatureDate = [sender objectForKey:@"left_date"];
		}
	}
	else
	{
		self = [self init];
	}
	
	return self;
}

-(NSDictionary*)dictionaryRepresentation
{
	NSMutableDictionary * rep = [[NSMutableDictionary alloc] init];
	
	[rep setObject:NSStringFromClass([self class]) forKey:@"class"];
	[rep setObject:_ID forKey:@"id"];
	[rep setObject:title forKey:@"title"];
	[rep setObject:_number forKey:@"number"];
	[rep setObject:[_client contentsDictionary] forKey:@"client"];
	[rep setObject:[_project contentsDictionary] forKey:@"project"];
	[rep setObject:_date forKey:@"date"];
	[rep setObject:_services forKey:@"services"];
	[rep setObject:otherComments forKey:@"other_comments"];
	[rep setObject:otherCommentsTitle forKey:@"other_comments_title"];
	[rep setObject:[NSString stringWithFormat:@"%f",_subtotal] forKey:@"subtotal"];
	
	[rep setObject:note forKey:@"note"];
	[rep setObject:bigNote forKey:@"big_note"];
	[rep setObject:[NSString stringWithFormat:@"%f",_discount] forKey:@"discount"];
	
	[rep setObject:NSStringFromCGRect(rightSignatureFrame) forKey:@"right_signature_frame"];
	[rep setObject:rightSignatureTitle forKey:@"right_signature_title"];
	[rep setObject:_rightSignatureDate forKey:@"right_date"];
	
	[rep setObject:NSStringFromCGRect(leftSignatureFrame) forKey:@"left_signature_frame"];
	[rep setObject:leftSignatureTitle forKey:@"left_signature_title"];
	[rep setObject:_leftSignatureDate forKey:@"left_date"];
	
	return rep;
}

-(void)setTitle:(NSString *)sender
{
	[CustomDefaults setCustomObjects:sender forKey:kTimesheetTitleKeyForNSUserDefaults];
	
	title = [[NSString alloc] initWithString:sender];
	
	NSMutableDictionary *languageDict = [[NSMutableDictionary alloc] initWithDictionary:[CustomDefaults customObjectForKey:kLanguageKeyForNSUserDefaults]];
	
	NSMutableDictionary *timesheetDict = [[NSMutableDictionary alloc] initWithDictionary:[languageDict objectForKey:@"timesheet"]];
	[timesheetDict setObject:sender forKey:@"Timesheet"];
	
	[languageDict setObject:timesheetDict forKey:@"timesheet"];
	
	[CustomDefaults setCustomObjects:languageDict forKey:kLanguageKeyForNSUserDefaults];
}

-(void)setNote:(NSString *)sender
{
	if(![sender isEqual:@""])
	{
		[CustomDefaults setCustomString:sender forKey:TIMESHEET_FIRST_PAGE_NOTE_KEY];
		
		note = [[NSString alloc] initWithString:sender];
	}
	else
	{
		note = [[NSString alloc] initWithString:[CustomDefaults customStringForKey:TIMESHEET_FIRST_PAGE_NOTE_KEY]];
	}
}

-(void)setBigNote:(NSString *)sender
{
	if(![sender isEqual:@""])
	{
		[CustomDefaults setCustomString:sender forKey:TIMESHEET_SECOND_PAGE_NOTE_KEY];
		
		bigNote = [[NSString alloc] initWithString:sender];
	}
	else
	{
		bigNote = [[NSString alloc] initWithString:[CustomDefaults customStringForKey:TIMESHEET_SECOND_PAGE_NOTE_KEY]];
	}
}

-(void)setOtherCommentsTitle:(NSString *)sender;
{
	otherCommentsTitle = [[NSString alloc] initWithString:sender];
	
	[CustomDefaults setCustomString:sender forKey:TIMESHEET_OTHER_COMMENTS_TITLE_KEY];
}

-(void)setOtherCommentsText:(NSString *)sender
{
	otherComments = [[NSString alloc] initWithString:sender];
	
	[CustomDefaults setCustomString:sender forKey:TIMESHEET_OTHER_COMMENTS_TEXT_KEY];
}

#pragma mark
#pragma mark RIGHT SIGNATURE TITLE

-(void)setRightSignatureTitle:(NSString *)sender
{
	[CustomDefaults setCustomString:sender forKey:TIMESHEET_RIGHT_SIGNATURE_TITLE_KEY];
	
	rightSignatureTitle = [[NSString alloc] initWithString:sender];
}

-(void)setRightSignatureFrame:(CGRect)sender
{
	[CustomDefaults setCustomObjects:[NSKeyedArchiver archivedDataWithRootObject:[NSValue valueWithCGRect:sender]] forKey:TIMESHEET_RIGHT_FRAME_KEY];
	
	rightSignatureFrame = sender;
}

-(void)setRightSignature:(UIImage *)sender
{
	[self removeRightSignatureImage];
	
	if (!sender)
	{
		return;
	}
	
	NSMutableString * filePath = [[NSMutableString alloc] initWithFormat:@"%@/Documents/", NSHomeDirectory()];
	
	NSData * imageData = UIImagePNGRepresentation(sender);
	
	NSString * MD5 = [[NSString stringWithFormat:@"%@", imageData] MD5];
	
	[filePath appendFormat:@"%@", MD5];
		
	[CustomDefaults setCustomString:MD5 forKey:TIMESHEET_RIGHT_SIGNATURE_PATH_KEY];
	
	[[NSFileManager defaultManager] createFileAtPath:filePath contents:[NSData data] attributes:[[NSDictionary alloc] init]];
	
	[imageData writeToFile:filePath atomically:YES];
	
	rightSignature = sender;
}

-(void)removeRightSignatureImage
{
	if(TIMESHEET_RIGHT_SIGNATURE_PATH && ![TIMESHEET_RIGHT_SIGNATURE_PATH isEqual:@""])
	{
		[[NSFileManager defaultManager] removeItemAtPath:[NSHomeDirectory() stringByAppendingFormat:@"/Documents/%@",TIMESHEET_RIGHT_SIGNATURE_PATH] error:nil];
	}
	
	[CustomDefaults setCustomString:@"" forKey:TIMESHEET_RIGHT_SIGNATURE_PATH_KEY];
	
	rightSignature = nil;
}

#pragma mark
#pragma mark LEFT SIGNATURE TITLE

-(void)setLeftSignatureTitle:(NSString *)sender
{
	[CustomDefaults setCustomString:sender forKey:TIMESHEET_LEFT_SIGNATURE_TITLE_KEY];
	
	leftSignatureTitle = [[NSString alloc] initWithString:sender];
}

-(void)setLeftSignatureFrame:(CGRect)sender
{
	[CustomDefaults setCustomObjects:[NSKeyedArchiver archivedDataWithRootObject:[NSValue valueWithCGRect:sender]] forKey:TIMESHEET_LEFT_FRAME_KEY];

	leftSignatureFrame = sender;
}

-(void)setLeftSignature:(UIImage *)sender
{
	[self removeLeftSignatureImage];
		
	if (!sender)
	{
		return;
	}
	
	NSMutableString * filePath = [[NSMutableString alloc] initWithFormat:@"%@/Documents/", NSHomeDirectory()];
	
	NSData * imageData = UIImagePNGRepresentation(sender);
	
	NSString * MD5 = [[NSString stringWithFormat:@"%@", imageData] MD5];
	
	[filePath appendFormat:@"%@", MD5];
		
	[CustomDefaults setCustomString:MD5 forKey:TIMESHEET_LEFT_SIGNATURE_PATH_KEY];
		
	[[NSFileManager defaultManager] createFileAtPath:filePath contents:[NSData data] attributes:[[NSDictionary alloc] init]];
	
	[imageData writeToFile:filePath atomically:YES];
	
	leftSignature = sender;
}

-(void)removeLeftSignatureImage
{
	if(TIMESHEET_LEFT_SIGNATURE_PATH && ![TIMESHEET_LEFT_SIGNATURE_PATH isEqual:@""])
	{
		[[NSFileManager defaultManager] removeItemAtPath:[NSHomeDirectory() stringByAppendingFormat:@"/Documents/%@",TIMESHEET_LEFT_SIGNATURE_PATH] error:nil];
	}
	
	[CustomDefaults setCustomString:@"" forKey:TIMESHEET_LEFT_SIGNATURE_PATH_KEY];

	leftSignature = nil;
}

-(void)addServiceTime:(ServiceTimeOBJ*)service
{
	[_services addObject:[service dictionaryRepresentation]];
}

-(void)removeServiceTimeAtIndex:(int)index
{
	[_services removeObjectAtIndex:index];
}

-(ServiceTimeOBJ*)serviceTimeAtIndex:(int)index
{
	return [[ServiceTimeOBJ alloc] initWithDictionaryRepresentation:[_services objectAtIndex:index]];
}

-(void)replaceServiceTime:(ServiceTimeOBJ*)service atIndex:(int)index
{
	[_services replaceObjectAtIndex:index withObject:[service dictionaryRepresentation]];
}

-(CGFloat)getDiscountShowValue
{
	if(_subtotal == 0)
		return 0.0f;
	
	return (_discount * 100) / _subtotal;
}

-(CGFloat)getTotalValue
{
	if(_subtotal == 0.0)
		return 0.0;
	
	float total = _subtotal - [self discount];
	
	if(total < 0)
		return 0;
	
	return total;
}

-(NSString*)getTotalHours
{
	float totalTimeInterval = 0.0;
	
	for(int i=0;i<[self services].count;i++)
	{
		ServiceTimeOBJ *time = [self serviceTimeAtIndex:i];
		
		totalTimeInterval += [time totalTimeInSeconds];
	}
	
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

@end
