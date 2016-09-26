//
//  AlertView.h
//  Invoice
//
//  Created by XGRoup5 on 8/14/13.
//  Copyright (c) 2013 XGRoup. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AlertView;

@protocol AlertViewDelegate<NSObject>

@optional

-(void)alertView:(AlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;

@end

@interface AlertView : UIView

{
	UIView * blackView;
	
	UILabel * titleLabel;
	UILabel * textLabel;
}

@property (weak) id<AlertViewDelegate> delegate;
@property (weak) NSString * titleText;
@property (weak) NSString * messageText;
@property (strong) UIView * content;

-(id)initWithTitle:(NSString*)title message:(NSString*)message delegate:(id)del cancelButtonTitle:(NSString*)cancelButtonTitle otherButtonTitles:(NSArray*)otherButtonTitles;
-(id)initWithButtons:(id)del cancelButtonTitle:(NSString*)cancelButtonTitle otherButtonTitles:(NSArray*)otherButtonTitles;

-(void)show;
-(void)showInWindow;
-(void)willMoveToSuperview:(UIView*)newSuperview;
-(void)close;
-(void)buttonAction:(UIButton*)sender;

@end
