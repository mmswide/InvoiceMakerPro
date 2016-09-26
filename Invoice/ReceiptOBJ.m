//
//  ReceiptOBJ.m
//  Invoice
//
//  Created by XGRoup on 7/15/14.
//  Copyright (c) 2014 XGRoup. All rights reserved.
//

#import "ReceiptOBJ.h"

#import "Defines.h"
#import "JSON.h"

@implementation ReceiptOBJ

@synthesize title;
@synthesize tax1Percentage,tax2Percentage,imageString;

-(id)init
{
	self = [super init];
	
	if (self)
	{
		NSDictionary * settingsDictionary = [[NSDictionary alloc] initWithDictionary:[CustomDefaults customObjectForKey:kSettingsKeyForNSUserDefaults]];
		
		[self setID:[data_manager createReceiptID]];
		title = [[NSString alloc] initWithString:[CustomDefaults customObjectForKey:kReceiptTitleKeyForNSUserDefaults]];
		[self setNumber:@"RT00001"];
		[self setCategory:@""];
		[self setProject:[[ProjectOBJ alloc] init]];
		[self setClient:[[ClientOBJ alloc] init]];
		[self setDate:[[NSDate alloc] initWithTimeIntervalSinceNow:0]];
		[self setTotal:0];
		[self setSign:[data_manager currency]];
		[self setReceiptDescription:@""];

		imageString = [[NSMutableString alloc] initWithString:@""];
		
		_tax1Name = [[NSString alloc] initWithString:[settingsDictionary objectForKey:@"taxAbreviation1"]];
		tax1Percentage = [[settingsDictionary objectForKey:@"taxRate1"] floatValue];

		_tax2Name = [[NSString alloc] initWithString:[settingsDictionary objectForKey:@"taxAbreviation2"]];
		tax2Percentage = [[settingsDictionary objectForKey:@"taxRate2"] floatValue];
				
		if([_tax1Name isEqual:@""])
		{
			_tax1Name = [[NSString alloc] initWithFormat:@"Tax"];
		}
		
		_kindOfTax = kTypeNone;

		if(tax1Percentage != 0)
		{
			_kindOfTax = kTypeFirst;
		}
		
		if(tax2Percentage != 0)
		{
			_kindOfTax = kTypeBoth;
		}
	}
	
	return self;
}

-(id)initWithReceipt:(ReceiptOBJ *)sender
{
	if (sender && [sender isKindOfClass:[ReceiptOBJ class]])
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
			_kindOfTax = kTypeNone;
			
			_ID = [[NSMutableString alloc] initWithString:[sender objectForKey:@"id"]];
			title = [[NSMutableString alloc] initWithString:[sender objectForKey:@"title"]];
			_number = [[NSMutableString alloc] initWithString:[sender objectForKey:@"number"]];
			_category = [[NSMutableString alloc] initWithString:[sender objectForKey:@"category"]];
			
			_project = [[ProjectOBJ alloc] initWithContentsDictionary:[sender objectForKey:@"project"]];
			_client = [[ClientOBJ alloc] initWithContentsDictionary:[sender objectForKey:@"client"]];
			_date = [sender objectForKey:@"date"];
			_total = [[sender objectForKey:@"total"] floatValue];
			_sign = [[NSMutableString alloc] initWithString:[sender objectForKey:@"sign"]];
			_receiptDescription = [[NSMutableString alloc] initWithString:[sender objectForKey:@"description"]];
			imageString = [[NSMutableString alloc] initWithString:@""];
						
			if([[sender allKeys] containsObject:@"photo"] && [[sender objectForKey:@"photo"] isKindOfClass:[NSString class]])
			{
				[imageString setString:[sender objectForKey:@"photo"]];
				
				if([self getImage] == nil)
				{
					NSData *imageData = [[NSData alloc] initWithContentsOfFile:imageString];
					
					if(imageData.length == 0)
					{
						[imageString setString:@""];
					}
				}
			}
			else
			if([[sender allKeys] containsObject:@"photo"] && [[sender objectForKey:@"photo"] isKindOfClass:[NSData class]])
			{
				[self setImage:[sender objectForKey:@"photo"]];
			}
			
			_tax1Name = [[NSMutableString alloc] initWithString:[sender objectForKey:@"tax1"]];
			_tax2Name = [[NSMutableString alloc] initWithString:[sender objectForKey:@"tax2"]];
			
			tax1Percentage = [[sender objectForKey:@"tax1Percentage"] floatValue];
			tax2Percentage = [[sender objectForKey:@"tax2Percentage"] floatValue];
			
			if([sender.allKeys containsObject:@"image_data"])
			{
				NSData *imageData = [[NSData alloc] initWithData:[sender objectForKey:@"image_data"]];
				[self setImage:imageData];
			}
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
	[rep setObject:_category forKey:@"category"];
	[rep setObject:[_project contentsDictionary] forKey:@"project"];
	[rep setObject:[_client contentsDictionary] forKey:@"client"];
	[rep setObject:_date forKey:@"date"];
	[rep setObject:[NSString stringWithFormat:@"%f",_total] forKey:@"total"];
	[rep setObject:_sign forKey:@"sign"];
	[rep setObject:_receiptDescription forKey:@"description"];
	[rep setObject:imageString forKey:@"photo"];
	[rep setObject:_tax1Name forKey:@"tax1"];
	[rep setObject:_tax2Name forKey:@"tax2"];
	
	[rep setObject:[NSString stringWithFormat:@"%f",tax1Percentage] forKey:@"tax1Percentage"];
	[rep setObject:[NSString stringWithFormat:@"%f",tax2Percentage] forKey:@"tax2Percentage"];
		
	return rep;
}

-(NSDictionary*)dictionaryRepresentationForCloud
{
	NSMutableDictionary * rep = [[NSMutableDictionary alloc] init];
	
	[rep setObject:NSStringFromClass([self class]) forKey:@"class"];
	[rep setObject:_ID forKey:@"id"];
	[rep setObject:title forKey:@"title"];
	[rep setObject:_number forKey:@"number"];
	[rep setObject:_category forKey:@"category"];
	[rep setObject:[_project contentsDictionary] forKey:@"project"];
	[rep setObject:[_client contentsDictionary] forKey:@"client"];
	[rep setObject:_date forKey:@"date"];
	[rep setObject:[NSString stringWithFormat:@"%f",_total] forKey:@"total"];
	[rep setObject:_sign forKey:@"sign"];
	[rep setObject:_receiptDescription forKey:@"description"];
	[rep setObject:imageString forKey:@"photo"];
	[rep setObject:_tax1Name forKey:@"tax1"];
	[rep setObject:_tax2Name forKey:@"tax2"];
	
	[rep setObject:[NSString stringWithFormat:@"%f",tax1Percentage] forKey:@"tax1Percentage"];
	[rep setObject:[NSString stringWithFormat:@"%f",tax2Percentage] forKey:@"tax2Percentage"];
	
	if(![imageString isEqual:@""])
	{
		NSData *imageData = [[NSData alloc] initWithContentsOfFile:imageString];
		
		if(imageData)
		{
			[rep setObject:imageData forKey:@"image_data"];
		}
		
	}
	
	return rep;
}

-(CGFloat)tax1Percentage
{
	if(_kindOfTax == kTypeFirst || _kindOfTax == kTypeBoth)
	{
		CGFloat temp = (tax1Percentage * _total) / 100;
		
		return temp;
	}
	
	return tax1Percentage;
}

-(CGFloat)tax2Percentage
{
	if(_kindOfTax == kTypeSecond || _kindOfTax == kTypeBoth)
	{
		CGFloat temp = (tax2Percentage * _total) / 100;
		
		return temp;
	}
	
	return tax2Percentage;
}

-(void)setTax1Percentage:(CGFloat)sender
{
	tax1Percentage = sender;
	
	if(_kindOfTax == kTypeBoth)
	{
		_kindOfTax = kTypeSecond;
	}
	else
	if (_kindOfTax == kTypeFirst)
	{
		_kindOfTax = kTypeNone;
	}
}

-(void)setTax2Percentage:(CGFloat)sender
{
	tax2Percentage = sender;
	
	if(_kindOfTax == kTypeBoth)
	{
		_kindOfTax = kTypeFirst;
	}
	else
	if(_kindOfTax == kTypeSecond)
	{
		_kindOfTax = kTypeNone;
	}
}

-(CGFloat)tax1ShowValue
{
	if(_kindOfTax == kTypeBoth || _kindOfTax == kTypeFirst)
	{
		return tax1Percentage;
	}
	
	if(_total == 0 || tax1Percentage == 0)
		return 0;
	
	CGFloat value = (tax1Percentage * 100) / _total;
	return value;
}

-(CGFloat)tax2ShowValue
{
	if(_kindOfTax == kTypeBoth || _kindOfTax == kTypeSecond)
	{
		return tax2Percentage;
	}
	
	if(_total == 0 || tax2Percentage == 0)
		return 0;
	
	CGFloat value = (tax2Percentage * 100) / _total;
	
	return value;
}

-(CGFloat)getTotal
{
	if(_total == 0)
		return 0;
	
	return _total + tax1Percentage + tax2Percentage;
}

-(void)setTitle:(NSString *)sender
{
	[CustomDefaults setCustomObjects:sender forKey:kReceiptTitleKeyForNSUserDefaults];
	
	title = [[NSString alloc] initWithString:sender];
	
	NSMutableDictionary *languageDict = [[NSMutableDictionary alloc] initWithDictionary:[CustomDefaults customObjectForKey:kLanguageKeyForNSUserDefaults]];
	
	NSMutableDictionary *receiptDict = [[NSMutableDictionary alloc] initWithDictionary:[languageDict objectForKey:@"receipt"]];
	[receiptDict setObject:sender forKey:@"Receipt"];
	
	[languageDict setObject:receiptDict forKey:@"receipt"];
	
	[CustomDefaults setCustomObjects:languageDict forKey:kLanguageKeyForNSUserDefaults];
}

#pragma mark - IMAGES

-(void)setImage:(NSData *)sender
{
	if(sender != nil)
	{
		if(![imageString isEqual:@""])
		{
			[self removeImageAtPath:imageString];
		}
		
		[imageString setString:[self writeImageToFile:sender]];
	}
	else
	{
		[self removeImageAtPath:imageString];
		[imageString setString:@""];
	}
}

-(NSString*)writeImageToFile:(NSData*)imageData
{
	NSMutableString * filePath = [[NSMutableString alloc] initWithFormat:@"%@/Documents/", NSHomeDirectory()];
	
	NSString * MD5 = [NSString stringWithFormat:@"%@_%@",[data_manager generateDeviceID],[[NSString stringWithFormat:@"%@", imageData] MD5]];
	
	[filePath appendFormat:@"%@", MD5];
			
	[[NSFileManager defaultManager] createFileAtPath:filePath contents:[NSData data] attributes:[[NSDictionary alloc] init]];
	
	[imageData writeToFile:filePath atomically:YES];
	
	return MD5;
}

-(UIImage*)getImage
{
	if(![imageString isEqual:@""])
	{
		if([[imageString componentsSeparatedByString:@"/Documents/"] count] > 1)
		{
			NSString *imageName = [[imageString componentsSeparatedByString:@"/Documents/"] objectAtIndex:1];
			[imageString setString:imageName];
		}
		
		NSString *imagePath = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/%@",imageString];
		NSData *imageData = [[NSData alloc] initWithContentsOfFile:imagePath];
		
		UIImage *tempImage = [[UIImage alloc] initWithData:imageData];
		
		return tempImage;
	}
	
	return nil;
}

-(void)removeImageAtPath:(NSString*)path
{
	NSString *imagePath = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/%@",path];
	
	if ((![imagePath isEqual:[NSHomeDirectory() stringByAppendingFormat:@"/Documents/"]]) && [[NSFileManager defaultManager] fileExistsAtPath:imagePath])
	{
		[[NSFileManager defaultManager] removeItemAtPath:imagePath error:nil];
	}
}

-(void)repairImagePath
{	
	if(![imageString isEqual:@""])
	{
		if([[imageString componentsSeparatedByString:@"/Documents/"] count] > 1)
		{
			NSString *imageName = [[imageString componentsSeparatedByString:@"/Documents/"] objectAtIndex:1];
			[imageString setString:imageName];
		}
	}
}

@end
