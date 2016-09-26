//
//  CreateOrEditServiceVC.h
//  Invoice
//
//  Created by XGRoup5 on 8/19/13.
//  Copyright (c) 2013 XGRoup. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomVC.h"

@class ServiceOBJ;
@class CreateOrEditServiceVC;
@class ToolBarView;

@protocol ServiceCreatorDelegate <NSObject>

-(void)creatorViewController:(CreateOrEditServiceVC*)viewController createdService:(ServiceOBJ*)service;
-(void)editorViewController:(CreateOrEditServiceVC*)viewController editedService:(ServiceOBJ*)service atIndex:(NSInteger)index;

@end

@interface CreateOrEditServiceVC : CustomVC

{
	NSString * titleString;
	ServiceOBJ * theService;
	
	UITextField * nameTextField;
	UITextField * rateTextField;
	UITextField * unitTextField;
	UITextView * descriptionTextView;
	BOOL another_textfield_takes_over;
	
	UILabel * nameLabel;
	UILabel * descriptionLabel;
	
	NSInteger index;
}

@property (weak) id<ServiceCreatorDelegate> delegate;

-(id)initWithService:(ServiceOBJ*)sender index:(NSInteger)i delegate:(id<ServiceCreatorDelegate>)del;
-(void)cancel:(UIButton*)sender;
-(void)done:(UIButton*)sender;
-(void)switchChanged:(UISwitch*)sender;
-(void)addDescription:(UIButton*)sender;
-(void)prev:(UIButton*)sender;
-(void)next:(UIButton*)sender;
-(void)closePicker:(UIButton*)sender;

@end