//
//  AddClientAddressVC.h
//  Invoice
//
//  Created by XGRoup5 on 8/21/13.
//  Copyright (c) 2013 XGRoup. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomVC.h"

typedef enum {

	kAddresTypeBilling = 0,
	kAddresTypeShipping
	
} kAddresType;

typedef enum {
	
	kTextFieldTypeSwitch = -1,
	kTextFieldTypeAddressLine1,
	kTextFieldTypeAddressLine2,
	kTextFieldTypeAddressLine3,
	kTextFieldTypeCity,
	kTextFieldTypeState,
	kTextFieldTypeZIP,
	kTextFieldTypeCountry
	
} kTextFieldType;

@class ScrollWithShadow;
@class ToolBarView;
@class ClientOBJ;
@class AddressOBJ;

@protocol AddClientAddressVCDelegate;

@interface AddClientAddressVC : CustomVC

{
	AddressOBJ * address;
	kAddresType theType;
	ClientOBJ * theClient;
	BOOL same_as_billing_address;
}

@property (nonatomic, weak) id <AddClientAddressVCDelegate>delegate;
@property (nonatomic, copy) NSString *billingKey;
@property (nonatomic, copy) NSString *shippingKey;

-(id)initWithAddresType:(kAddresType)type client:(ClientOBJ*)client;
-(void)back:(UIButton*)sender;
-(void)done:(UIButton*)sender;
-(UIView*)textFieldViewWithType:(kTextFieldType)type frame:(CGRect)frame andVaue:(NSString*)value;
-(void)switchChanged:(UISwitch*)sender;

@end

@protocol AddClientAddressVCDelegate <NSObject>

@optional
- (void)didEditedClientAddress:(ClientOBJ*)client;

@end
