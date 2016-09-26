//
//  ProductBaseOBJ.m
//  Invoice
//
//  Created by Dmytro Nosulich on 6/9/15.
//  Copyright (c) 2015 XGRoup. All rights reserved.
//

#import "ProductBaseOBJ.h"

@implementation ProductBaseOBJ

#pragma mark - GETTERS

-(NSDictionary*)contentsDictionary {
  NSAssert(NO, @"This method should be averridden by subclasses");
  return nil;
}

-(NSString*)ID {
  NSAssert(NO, @"This method should be averridden by subclasses");
  return nil;
}

-(NSString*)name {
  NSAssert(NO, @"This method should be averridden by subclasses");
  return nil;
}

-(CGFloat)price {
  NSAssert(NO, @"This method should be averridden by subclasses");
  return 0;
}

-(BOOL)taxable {
  NSAssert(NO, @"This method should be averridden by subclasses");
  return NO;
}

-(NSString*)note {
  NSAssert(NO, @"This method should be averridden by subclasses");
  return nil;
}

-(CGFloat)quantity {
  NSAssert(NO, @"This method should be averridden by subclasses");
  return 0;
}

-(CGFloat)discount {
  NSAssert(NO, @"This method should be averridden by subclasses");
  return 0;
}

-(CGFloat)total {
  NSAssert(NO, @"This method should be averridden by subclasses");
  return 0;
}

-(NSString*)unit {
  NSAssert(NO, @"This method should be averridden by subclasses");
  return nil;
}

-(NSString*)rawUnit {
  NSAssert(NO, @"This method should be averridden by subclasses");
  return nil;
}

-(CGFloat)tax1Percentage {
  NSAssert(NO, @"This method should be averridden by subclasses");
  return 0;
}

-(CGFloat)tax2Percentage {
  NSAssert(NO, @"This method should be averridden by subclasses");
  return 0;
}

-(CGFloat)tax1Value {
  NSAssert(NO, @"This method should be averridden by subclasses");
  return 0;
}

-(CGFloat)tax2Value {
  NSAssert(NO, @"This method should be averridden by subclasses");
  return 0;
}

-(NSString *)valueForCustomType:(AddItemDetailType)type {
  NSAssert(NO, @"This method should be averridden by subclasses");
  return nil;
}

#pragma mark - SETTERS

-(void)setID:(NSString*)sender {
  NSAssert(NO, @"This method should be averridden by subclasses");
}

-(void)setName:(NSString*)sender {
  NSAssert(NO, @"This method should be averridden by subclasses");
}

-(void)setPrice:(CGFloat)sender {
  NSAssert(NO, @"This method should be averridden by subclasses");
}

-(void)setTaxable:(BOOL)sender {
  NSAssert(NO, @"This method should be averridden by subclasses");
}

-(void)setNote:(NSString*)sender {
  NSAssert(NO, @"This method should be averridden by subclasses");
}

-(void)setQuantity:(CGFloat)sender {
  NSAssert(NO, @"This method should be averridden by subclasses");
}

-(void)setDiscount:(CGFloat)sender {
  NSAssert(NO, @"This method should be averridden by subclasses");
}

-(void)setUnit:(NSString*)sender {
  NSAssert(NO, @"This method should be averridden by subclasses");
}

-(void)setTax1Percentage:(CGFloat)sender {
  NSAssert(NO, @"This method should be averridden by subclasses");
}

-(void)setTax2Percentage:(CGFloat)sender {
  NSAssert(NO, @"This method should be averridden by subclasses");
}

- (void)setValue:(NSString *)value forCustomType:(AddItemDetailType)type {
  NSAssert(NO, @"This method should be averridden by subclasses");
}

@end
