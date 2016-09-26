//
//  AddressOBJ.h
//  Invoice
//
//  Created by XGRoup5 on 8/28/13.
//  Copyright (c) 2013 XGRoup. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AddressOBJ : NSObject

{
	NSMutableDictionary * contents;
}

@property (nonatomic, copy) NSString *billingKey;
@property (nonatomic, copy) NSString *shippingKey;

-(id)init;
-(id)initWithAddress:(AddressOBJ*)sender;
-(id)initWithContentsDictionary:(NSDictionary*)sender;
-(id)initForTemplate;

#pragma mark - GETTERS

-(NSDictionary*)contentsDictionary;

-(NSString*)fullStringRepresentation;
-(NSString*)representationLine1;
-(NSString*)representationLine2;
-(NSString*)representationLine3;

-(NSString*)billingTitle;
-(NSString*)shippingTitle;
-(NSString*)addressLine1;
-(NSString*)addressLine2;
-(NSString*)addressLine3;
-(NSString*)city;
-(NSString*)state;
-(NSString*)ZIP;
-(NSString*)country;
-(BOOL)sameAsBilling;

#pragma mark - SETTERS

-(void)setBillingTitle:(NSString*)sender;
-(void)setShippingTitle:(NSString*)sender;
-(void)setAddressLine1:(NSString*)sender;
-(void)setAddressLine2:(NSString*)sender;
-(void)setAddressLine3:(NSString*)sender;
-(void)setCity:(NSString*)sender;
-(void)setState:(NSString*)sender;
-(void)setZIP:(NSString*)sender;
-(void)setCountry:(NSString*)sender;
-(void)setSameAsBilling:(BOOL)sender;

@end