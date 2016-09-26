//
//  EstimateOBJ.h
//  Invoice
//
//  Created by XGRoup5 on 8/22/13.
//  Copyright (c) 2013 XGRoup. All rights reserved.
//

#import "BaseOBJ.h"

#import "TermsManager.h"

@class ClientOBJ;
@class AddressOBJ;
@class ProjectOBJ;

@interface EstimateOBJ : BaseOBJ

-(id)init;
-(id)initWithEstimate:(EstimateOBJ*)sender;
-(id)initWithContentsDictionary:(NSDictionary*)sender;
-(id)initForTemplate;

#pragma mark - GETTERS

-(NSString*)ID;
-(NSString*)title;
-(NSString*)name;
-(ProjectOBJ*)project;
-(kTerms)terms;
-(CGFloat)subtotal;
-(CGFloat)discount;
-(CGFloat)discountPercentage;
-(CGFloat)tax1Value;
-(CGFloat)tax1Percentage;
-(CGFloat)tax2Value;
-(CGFloat)tax2Percentage;
-(CGFloat)shippingValue;
-(CGFloat)total;
-(AddressOBJ*)billingAddress;
-(AddressOBJ*)shippingAddress;
-(NSString*)note;
-(NSString*)bigNote;
-(NSString*)creationDate;
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
-(void)setTerms:(kTerms)sender;
-(void)setDiscount:(CGFloat)sender;
-(void)setTax1Percentage:(CGFloat)sender;
-(void)setTax1Name:(NSString*)sender;
-(void)setTax2Percentage:(CGFloat)sender;
-(void)setTax2Name:(NSString*)sender;
-(void)setShippingValue:(CGFloat)sender;
-(void)setBillingAddress:(NSDictionary*)sender;
-(void)setShippingAddress:(NSDictionary*)sender;

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