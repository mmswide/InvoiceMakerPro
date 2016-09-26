//
//  CompanyOBJ.h
//  Invoice
//
//  Created by XGRoup5 on 8/15/13.
//  Copyright (c) 2013 XGRoup. All rights reserved.
//

#import "BaseOBJ.h"

@class AddressOBJ;

@interface CompanyOBJ : BaseOBJ

-(id)init;
-(id)initWithCompany:(CompanyOBJ*)sender;
-(id)initWithContentsDictionary:(NSDictionary*)sender;

#pragma mark - GETTERS

+ (CompanyOBJ *)savedCompany;

-(NSDictionary*)contentsDictionary;

-(NSString*)name;
-(AddressOBJ*)address;
-(NSString*)phone;
-(NSString*)mobile;
-(NSString*)fax;
-(NSString*)email;
-(NSString*)website;
-(UIImage*)logo;

#pragma mark - SETTERS

-(void)setName:(NSString*)sender;
-(void)setAddress:(NSDictionary*)sender;
-(void)setPhone:(NSString*)sender;
-(void)setMobile:(NSString*)sender;
-(void)setFax:(NSString*)sender;
-(void)setEmail:(NSString*)sender;
-(void)setWebsite:(NSString*)sender;
-(void)setLogo:(UIImage*)sender;

@end
