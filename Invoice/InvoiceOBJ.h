//
//  InvoiceOBJ.h
//  Invoice
//
//  Created by XGRoup5 on 8/13/13.
//  Copyright (c) 2013 XGRoup. All rights reserved.
//

#import "BaseOBJ.h"
#import "TermsManager.h"

typedef enum {
	
	kInvoiceStatusOverdue = 0,
	kInvoiceStatusCurrent,
	kInvoiceStatusPaid
	
} kInvoiceStatus;

@class ClientOBJ;
@class AddressOBJ;
@class EstimateOBJ;
@class QuoteOBJ;
@class PurchaseOrderOBJ;
@class ProjectOBJ;
@class TimeSheetOBJ;

@interface InvoiceOBJ : BaseOBJ

-(id)init;
-(id)initWithInvoice:(InvoiceOBJ*)sender;
-(id)initWithContentsDictionary:(NSDictionary*)sender;
-(id)initWithQuote:(QuoteOBJ*)sender;
-(id)initWithEstimate:(EstimateOBJ*)sender;
-(id)initWithPurchaseOrder:(PurchaseOrderOBJ*)sender;
-(id)initWithTimesheet:(TimeSheetOBJ*)sender;

-(id)initForTemplate;

#pragma mark - GETTERS

+(NSString*)statusTextFor:(kInvoiceStatus)status;

-(NSString*)ID;
-(NSString*)title;
-(NSString*)name;
-(kInvoiceStatus)status;
-(ProjectOBJ*)project;
-(NSString*)date;
-(NSString*)dueDate;
-(kTerms)terms;
-(CGFloat)balanceDue;
-(CGFloat)balanceDuePaid;
-(CGFloat)subtotal;
-(CGFloat)discount;
-(CGFloat)discountPercentage;
-(CGFloat)tax1Value;
-(CGFloat)tax1Percentage;
-(CGFloat)tax2Value;
-(CGFloat)tax2Percentage;
-(CGFloat)shippingValue;
-(CGFloat)total;
-(CGFloat)paid;
//-(AddressOBJ*)billingAddress;
//-(AddressOBJ*)shippingAddress;
-(NSString*)note;
-(NSString*)bigNote;
-(NSString*)otherCommentsTitle;
-(NSString*)otherCommentsText;
-(NSString*)rightSignatureTitle;
-(UIImage*)rightSignature;
-(NSString*)rightSignatureDate;
-(CGRect)rightSignatureFrame;
-(NSString*)leftSignatureTitle;
-(UIImage*)leftSignature;
-(NSString*)leftSignatureDate;
-(CGRect)leftSignatureFrame;

#pragma mark - SETTERS

-(void)setID:(NSString*)sender;
-(void)setTitle:(NSString*)sender;
-(void)setName:(NSString*)sender;
-(void)setProject:(NSDictionary*)sender;
-(void)setDate:(NSDate*)sender;
-(void)setDueDate:(NSDate*)sender;
-(void)clearDueDate;
-(void)setTerms:(kTerms)sender;
-(void)setDiscount:(CGFloat)sender;
-(void)setTax1Percentage:(CGFloat)sender;
-(void)setTax1Name:(NSString*)sender;
-(void)setTax2Percentage:(CGFloat)sender;
-(void)setTax2Name:(NSString*)sender;
-(void)setShippingValue:(CGFloat)sender;
-(void)setPaid:(CGFloat)sender;

//note
-(void)setNote:(NSString*)sender;
-(void)saveNote:(NSString*)sender;
-(void)setBigNote:(NSString*)sender;
-(void)saveBigNote:(NSString*)sender;

-(void)setNumber:(int)sender;
-(void)setStringNumber:(NSString*)sender;

//other comments
-(void)setOtherCommentsTitle:(NSString*)sender;
-(void)saveOtherCommentsTitle:(NSString*)sender;
-(void)setOtherCommentsText:(NSString*)sender;
-(void)saveOtherCommentsText:(NSString*)sender;

//signature
-(void)setRightSignatureTitle:(NSString*)sender;
-(void)saveRightSignatureTitle:(NSString*)sender;
-(void)setRightSignature:(UIImage*)sender;
-(void)saveRightSignature:(UIImage*)sender;
-(void)setRightSignatureDate:(NSDate*)sender;
-(void)setRightSignatureFrame:(CGRect)sender;
-(void)saveRightSignatureFrame:(CGRect)sender;

-(void)setLeftSignatureTitle:(NSString*)sender;
-(void)saveLeftSignatureTitle:(NSString*)sender;
-(void)setLeftSignature:(UIImage*)sender;
-(void)saveLeftSignature:(UIImage*)sender;
-(void)setLeftSignatureDate:(NSDate*)sender;
-(void)setLeftSignatureFrame:(CGRect)sender;
-(void)saveLeftSignatureFrame:(CGRect)sender;

-(void)repairSignatures;

@end