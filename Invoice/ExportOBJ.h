//
//  ExportOBJ.h
//  Invoice
//
//  Created by Paul on 19/06/14.
//  Copyright (c) 2014 XGRoup. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ExportOBJ : NSObject
{
}

-(id)init;

@property (strong) NSString *category;
@property (strong) NSString *startDate;
@property (strong) NSString *endDate;
@property (strong) NSString *filePath;

@end
