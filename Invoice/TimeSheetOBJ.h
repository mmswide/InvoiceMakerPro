//
//  TimeSheet.h
//  Invoice
//
//  Created by XGRoup on 7/17/14.
//  Copyright (c) 2014 XGRoup. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ClientOBJ;
@class ProjectOBJ;
@class TimeSheetOBJ;
@class ServiceTimeOBJ;

@interface TimeSheetOBJ : NSObject

@property (strong) NSString *ID;
@property (nonatomic,strong) NSString *title;
@property (strong) NSString *number;
@property (strong) ClientOBJ *client;
@property (strong) NSDate *date;
@property (strong) ProjectOBJ *project;

@property CGFloat subtotal;
@property CGFloat discount;

@property (strong) NSMutableArray *services;

@property (nonatomic,strong) NSString *otherComments;
@property (nonatomic,strong) NSString *otherCommentsTitle;

@property (nonatomic,strong) NSString *rightSignatureTitle;
@property (nonatomic,strong) UIImage *rightSignature;
@property (nonatomic) CGRect rightSignatureFrame;
@property NSDate *rightSignatureDate;

@property (nonatomic,strong) NSString *leftSignatureTitle;
@property (nonatomic,strong) UIImage *leftSignature;
@property (nonatomic) CGRect leftSignatureFrame;
@property NSDate *leftSignatureDate;

@property (nonatomic,strong) NSString *note;
@property (nonatomic,strong) NSString *bigNote;

-(id)init;
-(id)initWithTimeSheet:(TimeSheetOBJ*)sender;
-(id)initWithDictionaryRepresentation:(NSDictionary*)sender;

-(void)setOtherCommentsTitle:(NSString *)sender;
-(void)setOtherCommentsText:(NSString *)sender;

#pragma mark
#pragma mark LEFT SIGNATURE TITLE

-(void)setLeftSignatureTitle:(NSString *)sender;
-(void)setLeftSignatureFrame:(CGRect)sender;
-(void)setLeftSignature:(UIImage *)leftSignature;

-(NSDictionary*)dictionaryRepresentation;

-(void)addServiceTime:(ServiceTimeOBJ*)service;

-(void)removeServiceTimeAtIndex:(int)index;

-(ServiceTimeOBJ*)serviceTimeAtIndex:(int)index;

-(void)replaceServiceTime:(ServiceTimeOBJ*)service atIndex:(int)index;

-(CGFloat)getDiscountShowValue;

-(CGFloat)getTotalValue;

-(NSString*)getTotalHours;

@end
