//
//  PasscodeLockVC.h
//  Invoice
//
//  Created by XGRoup5 on 8/16/13.
//  Copyright (c) 2013 XGRoup. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CustomVC.h"

typedef enum {
	
	kPinStateFirstEnter = 0,
	kPinStateConfirm,
	kPinStateSelectNewPin,
	kPinStateConfirmNewPin,
	kPinStateEnterForChange,
	kPinStateEnterForRemove
	
} kPinState;

@class PinView;

@interface PasscodeLockVC : CustomVC

{
	NSMutableDictionary * settingsDictionary;
	kPinState pin_state;
	NSString * tempPin;
	PinView * currentPinView;
}

-(id)init;
-(void)back:(UIButton*)sender;
-(void)changePinCode:(UIButton*)sender;
-(void)turnPinOff:(UIButton*)sender;

@end
