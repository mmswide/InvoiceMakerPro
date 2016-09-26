//
//  PDFCreator2.h
//  Invoice
//
//  Created by XGRoup on 7/16/14.
//  Copyright (c) 2014 XGRoup. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ReceiptOBJ;
@class AddressOBJ;
@class TimeSheetOBJ;

@interface PDFCreator2 : NSObject

+(NSData*)PDFDataFromUIView:(UIView*)aView;

+(NSString*)PDFPathFromUIView:(UIView*)aView;

#pragma mark - RECEIPT 

+(UIView*)PDFViewForReceipts:(NSArray*)receiptsArray;

+(UIView*)detailsForReceipts;

+(void)addReceiptDetails:(ReceiptOBJ*)receipt forView:(UIView*)view;

#pragma mark - TIMESHEET

+(UIView*)PDFViewFromTimesheet:(TimeSheetOBJ*)timesheet;
+(UIView*)detailsForTimesheet:(TimeSheetOBJ*)timesheet;
+(void)statisticsPartForTimesheet:(TimeSheetOBJ*)timesheet inView:(UIView*)view;

#pragma mark - COMMON

+(UIView*)currentPageFrom:(UIView*)sender;
+(UIView*)companyDetailsView;
+(UIView*)viewFromAddress:(AddressOBJ*)address withTitle:(NSString*)title companyName:(NSString*)companyName customerName:(NSString*)customerName;
+(UIView*)headerViewWithY:(CGFloat)Y hasDiscount:(BOOL)has_discount;
+(void)addObject:(NSDictionary*)object toView:(UIView*)view;
+(UILabel*)leftStatusLabelWithText:(NSString*)text size:(CGFloat)size andY:(CGFloat)Y isBold:(BOOL)bold andMaxWidth:(CGFloat)maxWidth;
+(UILabel*)rightStatusLabelWithText:(NSString*)text X:(CGFloat)X andY:(CGFloat)Y isBold:(BOOL)bold;

@end
