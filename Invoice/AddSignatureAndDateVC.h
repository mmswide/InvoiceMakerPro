//
//  AddSignatureAndDateVC.h
//  Work.
//
//  Created by Paul on 16/04/14.
//  Copyright (c) 2014 XGRoup. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AlwaysShowViewController.h"

typedef enum {

	kSignatureTypeLeft = 0,
	kSignatureTypeRight

} kSignatureType;

@class AddSignatureAndDateVC;
@class SignatureView;
@class ToolBarView;
@class InvoiceOBJ;
@class QuoteOBJ;
@class EstimateOBJ;
@class PurchaseOrderOBJ;
@class TimeSheetOBJ;

@protocol SignatureAndDateCreatorDelegate <NSObject>

-(void)creatorViewController:(AddSignatureAndDateVC*)viewController createdSignature:(UIImage*)signature withFrame:(CGRect)frame title:(NSString*)title andDate:(NSDate*)date;

@end

@interface AddSignatureAndDateVC : AlwaysShowViewController

{
	SignatureView * signatureView;
	UIButton * dateSelectorButton;
	UIDatePicker * datePicker;
	NSDate * theDate;
	UIView * signatureTitleView;
  UITextView *titleTextView;
}

-(id)initWithDelegate:(id<SignatureAndDateCreatorDelegate>)sender andInvoice:(InvoiceOBJ*)invoice type:(kSignatureType)type;
-(id)initWithDelegate:(id<SignatureAndDateCreatorDelegate>)sender andQuote:(QuoteOBJ*)quote type:(kSignatureType)type;
-(id)initWithDelegate:(id<SignatureAndDateCreatorDelegate>)sender andEstimate:(EstimateOBJ*)estimate type:(kSignatureType)type;
-(id)initWithDelegate:(id<SignatureAndDateCreatorDelegate>)sender andPurchaseOrder:(PurchaseOrderOBJ*)purchaseOrder type:(kSignatureType)type;
-(id)initWithDelegate:(id<SignatureAndDateCreatorDelegate>)sender andTimesheet:(TimeSheetOBJ*)timesheet type:(kSignatureType)type;

-(void)cancel:(UIButton*)sender;
-(void)done:(UIButton*)sender;

@property (weak) id<SignatureAndDateCreatorDelegate> delegate;
@property kSignatureType signatureType;

@end
