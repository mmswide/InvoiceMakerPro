//
//  ExportOBJ.m
//  Invoice
//
//  Created by Paul on 19/06/14.
//  Copyright (c) 2014 XGRoup. All rights reserved.
//

#import "ExportOBJ.h"

@implementation ExportOBJ

-(id)init
{
	self = [super init];
	
	if(self)
	{
		[self setCategory:@""];
		[self setStartDate:@"01/01/70"];
		[self setEndDate:@"01/01/70"];
	}
	
	return self;
}

@end
