//
//  TermsManager.m
//  Invoice
//
//  Created by XGRoup5 on 8/30/13.
//  Copyright (c) 2013 XGRoup. All rights reserved.
//

#import "TermsManager.h"

@implementation TermsManager

+(NSString*)termsString:(kTerms)terms
{
	switch (terms)
	{
		case kTerms7Days:
		{
			return @"7 days";
			break;
		}
			
		case kTerms14Days:
		{
			return @"14 days";
			break;
		}
			
		case kTerms21Days:
		{
			return @"21 days";
			break;
		}
			
		case kTerms30Days:
		{
			return @"30 days";
			break;
		}
			
		case kTerms45Days:
		{
			return @"45 days";
			break;
		}
			
		case kTerms60Days:
		{
			return @"60 days";
			break;
		}
			
		case kTerms180Days:
		{
			return @"180 days";
			break;
		}
			
		case kTermsDueOnReceipt:
		{
			return @"Due on receipt";
			break;
		}
			
		default:
			break;
	}
}

+(NSDate*)dueDateFromThisDate:(NSDate*)date withTerms:(kTerms)terms
{
	int seconds = 0;
	
	switch (terms)
	{
		case kTerms7Days:
		{
			seconds = 7 * 86400;
			break;
		}
			
		case kTerms14Days:
		{
			seconds = 14 * 86400;
			break;
		}
			
		case kTerms21Days:
		{
			seconds = 21 * 86400;
			break;
		}
			
		case kTerms30Days:
		{
			seconds = 30 * 86400;
			break;
		}
			
		case kTerms45Days:
		{
			seconds = 45 * 86400;
			break;
		}
			
		case kTerms60Days:
		{
			seconds = 60 * 86400;
			break;
		}
			
		case kTerms180Days:
		{
			seconds = 180 * 86400;
			break;
		}
			
		case kTermsDueOnReceipt:
		{
			break;
		}
			
		default:
			break;
	}
	
	if (seconds == 0)
	{
		return date;
	}
	else
	{
		return [NSDate dateWithTimeInterval:seconds sinceDate:date];
	}
}

@end