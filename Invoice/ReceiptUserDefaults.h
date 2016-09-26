//
//  ReceiptUserDefaults.h
//  Invoice
//
//  Created by XGRoup on 9/5/14.
//  Copyright (c) 2014 XGRoup. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ReceiptUserDefaults : NSObject
{
	NSMutableArray *receiptsArray;
	NSString *filePath;
}

+(id)defaultUserDefaults;

-(void)createFile;

-(void)saveReceipts:(NSArray*)sender;

-(NSArray*)loadReceipts;

@end
