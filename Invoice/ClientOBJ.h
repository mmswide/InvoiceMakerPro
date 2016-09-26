//
//  ClientOBJ.h
//  Invoice
//
//  Created by XGRoup5 on 8/13/13.
//  Copyright (c) 2013 XGRoup. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TermsManager.h"

typedef enum {
	
	kTitleMr = 0,
	kTitleMrs,
	kTitleMiss,
	kTitleMs,
	kTitleDr
	
} kTitle;

@class AddressOBJ;

@interface ClientOBJ : NSObject

{
	NSMutableDictionary * contents;
}

@property (nonatomic, copy) NSString *billingKey;
@property (nonatomic, copy) NSString *shippingKey;

-(id)init;
-(id)initWithClient:(ClientOBJ*)sender;
-(id)initWithContentsDictionary:(NSDictionary*)sender;
-(id)initForTemplate;

#pragma mark - GETTERS

+(NSString*)titleStringForType:(kTitle)title;
+(kTitle)titleTypeForString:(NSString*)title;
-(NSDictionary*)contentsDictionary;
-(NSDictionary*)partiallyContentsDictionary;

-(NSString*)ID;
-(NSString*)firstName;
-(NSString*)lastName;
-(NSString*)title;
-(NSString*)company;
-(NSString*)website;
-(NSString*)phone;
-(NSString*)mobile;
-(NSString*)fax;
-(NSString*)email;
-(AddressOBJ*)billingAddress;
-(AddressOBJ*)shippingAddress;
-(kTerms)terms;
-(NSString*)note;

#pragma mark - SETTERS

-(void)setID:(NSString*)sender;
-(void)setFirstName:(NSString*)sender;
-(void)setLastName:(NSString*)sender;
-(void)setTitle:(kTitle)sender;
-(void)setCompany:(NSString*)sender;
-(void)setWebsite:(NSString*)sender;
-(void)setPhone:(NSString*)sender;
-(void)setMobile:(NSString*)sender;
-(void)setFax:(NSString*)sender;
-(void)setEmail:(NSString*)sender;
-(void)setBillingAddress:(NSDictionary*)sender;
-(void)setShippingAddress:(NSDictionary*)sender;
-(void)setTerms:(kTerms)sender;
-(void)setNote:(NSString*)sender;

-(BOOL)isEqual:(ClientOBJ*)object;

@end
