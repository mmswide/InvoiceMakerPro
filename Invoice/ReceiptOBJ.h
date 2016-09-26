//
//  ReceiptOBJ.h
//  Invoice
//
//  Created by XGRoup on 7/15/14.
//  Copyright (c) 2014 XGRoup. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ProjectOBJ;
@class ClientOBJ;

typedef enum{
	kTypeFirst = 0,
	kTypeSecond = 1,
	kTypeBoth = 2,
	kTypeNone
	
} kTaxType;

@interface ReceiptOBJ : NSObject

@property (strong) NSString *ID;
@property (nonatomic,strong) NSString *title;
@property (strong) NSString *number;
@property (strong) NSString *category;
@property (strong) ProjectOBJ *project;
@property (strong) ClientOBJ *client;
@property (strong) NSDate *date;
@property (strong) NSString *receiptDescription;
@property CGFloat total;
@property (strong) NSString *sign;
@property (nonatomic,strong) NSMutableString *imageString;

@property (strong) NSString *tax1Name;
@property (strong) NSString *tax2Name;

@property (nonatomic) CGFloat tax1Percentage;
@property (nonatomic) CGFloat tax2Percentage;

@property kTaxType kindOfTax;

-(id)init;
-(id)initWithReceipt:(ReceiptOBJ*)sender;
-(id)initWithDictionaryRepresentation:(NSDictionary*)sender;

-(NSDictionary*)dictionaryRepresentation;
-(NSDictionary*)dictionaryRepresentationForCloud;

-(CGFloat)tax1ShowValue;
-(CGFloat)tax2ShowValue;
-(CGFloat)getTotal;

-(void)setImage:(NSData *)sender;
-(UIImage*)getImage;
-(void)repairImagePath;

@end
