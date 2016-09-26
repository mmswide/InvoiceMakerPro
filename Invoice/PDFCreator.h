//
//  PDFCreator.h
//  Invoice
//
//  Created by XGRoup5 on 8/27/13.
//  Copyright (c) 2013 XGRoup. All rights reserved.
//

#import <Foundation/Foundation.h>

#define CURRENT_PAGE_TAG 42

@class InvoiceOBJ;
@class EstimateOBJ;
@class QuoteOBJ;
@class PurchaseOrderOBJ;
@class AddressOBJ;
@class BaseOBJ;

@interface PDFCreator : NSObject

+(NSData*)PDFDataFromUIView:(UIView*)aView;
+(UIView*)PDFViewFromBaseObject:(BaseOBJ*)baseOBJ;

#pragma mark - INVOICE

+(UIView*)PDFViewFromInvoice:(InvoiceOBJ*)invoice;
+(UIView*)detailsForInvoice:(InvoiceOBJ*)invoice;
+(void)statisticsPartForInvoice:(InvoiceOBJ*)invoice inView:(UIView*)view;

#pragma mark - QUOTE

+(UIView*)PDFViewFromQuote:(QuoteOBJ*)quote;
+(UIView*)detailsForQuote:(QuoteOBJ*)quote;
+(void)statisticsPartForQuote:(QuoteOBJ*)quote inView:(UIView*)view;

#pragma mark - ESTIMATE

+(UIView*)PDFViewFromEstimate:(EstimateOBJ*)estimate;
+(UIView*)detailsForEstimate:(EstimateOBJ*)estimate;
+(void)statisticsPartForEstimate:(EstimateOBJ*)estimate inView:(UIView*)view;

#pragma mark - PURCHASE ORDER

+(UIView*)PDFViewFromPurchaseOrder:(PurchaseOrderOBJ*)purchaseOrder;
+(UIView*)detailsForPO:(PurchaseOrderOBJ*)purchaseOrder;
+(void)statisticsPartForPO:(PurchaseOrderOBJ*)purchaseOrder inView:(UIView*)view;

#pragma mark - COMMON

+(UIView*)currentPageFrom:(UIView*)sender;
+(UIView*)companyDetailsViewForObject:(BaseOBJ *)object;
+(UIView*)viewFromAddress:(AddressOBJ*)address withTitle:(NSString*)title companyName:(NSString*)companyName customerName:(NSString*)customerName;
+(UIView*)headerViewWithY:(CGFloat)Y hasDiscount:(BOOL)has_discount andType:(int)type andObject:(BaseOBJ*)object;
+(void)addObject:(NSDictionary*)object toView:(UIView*)view andObject:(BaseOBJ*)baseObject;;
+(UILabel*)leftStatusLabelWithText:(NSString*)text size:(CGFloat)size andY:(CGFloat)Y isBold:(BOOL)bold andMaxWidth:(CGFloat)maxWidth;
+(UILabel*)rightStatusLabelWithText:(NSString*)text X:(CGFloat)X andY:(CGFloat)Y isBold:(BOOL)bold;

@end