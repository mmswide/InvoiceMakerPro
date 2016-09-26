//
//  AddressVC.h
//  Invoice
//
//  Created by XGRoup5 on 8/15/13.
//  Copyright (c) 2013 XGRoup. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CustomVC.h"

typedef NS_ENUM(NSInteger, kTextFieldType) {
	
	kTextFieldTypeAddressLine1 = 0,
	kTextFieldTypeAddressLine2,
	kTextFieldTypeAddressLine3,
	kTextFieldTypeCity,
	kTextFieldTypeState,
	kTextFieldTypeZIP,
	kTextFieldTypeCountry

};

@class ScrollWithShadow;
@class ToolBarView;
@class AddressOBJ;

@interface AddressVC : CustomVC {
	AddressOBJ * address;
  UITextField *currentTextField;
}

-(id)init;
-(void)back:(UIButton*)sender;
-(void)done:(UIButton*)sender;
-(UIView*)textFieldViewWithType:(kTextFieldType)type frame:(CGRect)frame andVaue:(NSString*)value;

@end
