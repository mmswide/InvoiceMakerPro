//
//  ServiceTimeOBJ.h
//  Invoice
//
//  Created by XGRoup on 7/17/14.
//  Copyright (c) 2014 XGRoup. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ProductOBJ;

@interface ServiceTimeOBJ : NSObject

@property (strong) ProductOBJ *product;
@property (strong) NSDate *startTime;
@property (strong) NSDate *finishTime;
@property NSTimeInterval breakTime;
@property NSTimeInterval overtime;
@property NSDate *date;
@property BOOL isPercentage;

@property (nonatomic) CGFloat subtotal;
@property CGFloat discountPercentage;

-(id)init;
-(id)initWithTimeSheet:(ServiceTimeOBJ*)sender;
-(id)initWithDictionaryRepresentation:(NSDictionary*)sender;

-(NSDictionary*)dictionaryRepresentation;

-(CGFloat)getTotal;

-(CGFloat)discountShowPercentage;

-(NSString*)breakString;

-(NSInteger)breakHours;

-(NSInteger)breakMinutes;

-(NSString*)overtimeString;

-(NSInteger)overtimeHours;

-(NSInteger)overtimeMinuts;

-(NSString*)duration;

-(NSInteger)totalTimeInSeconds;

-(NSString*)totalHours;

-(void)adjustDiscount;

@end
