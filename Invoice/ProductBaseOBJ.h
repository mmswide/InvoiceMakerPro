//
//  ProductBaseOBJ.h
//  Invoice
//
//  Created by Dmytro Nosulich on 6/9/15.
//  Copyright (c) 2015 XGRoup. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseOBJ.h"

@interface ProductBaseOBJ : NSObject

#pragma mark - GETTERS

-(NSDictionary*)contentsDictionary;

-(NSString*)ID;
-(NSString*)name;
-(CGFloat)price;
-(BOOL)taxable;
-(NSString*)note;
-(CGFloat)quantity;
-(CGFloat)discount;
-(CGFloat)total;
-(NSString*)unit;
-(NSString*)rawUnit;
-(CGFloat)tax1Percentage;
-(CGFloat)tax2Percentage;
-(CGFloat)tax1Value;
-(CGFloat)tax2Value;
-(NSString *)valueForCustomType:(AddItemDetailType)type;

#pragma mark - SETTERS

-(void)setID:(NSString*)sender;
-(void)setName:(NSString*)sender;
-(void)setPrice:(CGFloat)sender;
-(void)setTaxable:(BOOL)sender;
-(void)setNote:(NSString*)sender;
-(void)setQuantity:(CGFloat)sender;
-(void)setDiscount:(CGFloat)sender;
-(void)setUnit:(NSString*)sender;
-(void)setTax1Percentage:(CGFloat)sender;
-(void)setTax2Percentage:(CGFloat)sender;
- (void)setValue:(NSString *)value forCustomType:(AddItemDetailType)type;


@end
