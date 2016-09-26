//
//  PinView.h
//  Invoice
//
//  Created by XGRoup5 on 8/16/13.
//  Copyright (c) 2013 XGRoup. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {

	kBackButtonTypeNone = 0,
	kBackButtonTypeBack,
	kBackButtonTypeCancel

} kBackButtonType;

@class PinView;

@protocol PinViewDelegate <NSObject>

-(void)pinView:(PinView*)view FinishedEnteringPin:(NSString*)pin;

@end

@class BackButtonNormal;

@interface PinView : UIView

@property (retain) BackButtonNormal * backButton;
@property (weak) id<PinViewDelegate> delegate;

-(id)initWithTitle:(NSString*)title backButtonType:(kBackButtonType)type;
-(void)resignFirstResponder;
-(void)becomeFirstResponder;

@end
