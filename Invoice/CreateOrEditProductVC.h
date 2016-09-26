//
//  CreateOrEditProductVC.h
//  Invoice
//
//  Created by XGRoup5 on 8/19/13.
//  Copyright (c) 2013 XGRoup. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CustomVC.h"

@class ProductOBJ;
@class CreateOrEditProductVC;
@class ToolBarView;

@protocol ProductCreatorDelegate <NSObject>

-(void)creatorViewController:(CreateOrEditProductVC*)viewController createdObject:(ProductOBJ*)product;
@optional
-(void)editorViewController:(CreateOrEditProductVC*)viewController editedObject:(ProductOBJ*)product atIndex:(NSInteger)index;

@end

@interface CreateOrEditProductVC : CustomVC

{
	NSString * titleString;
	ProductOBJ * theProduct;
	
	UITextField * nameTextField;
	UITextField * rateTextField;
	UITextField * unitTextField;
	UITextField * codeTextField;
	UITextView * descriptionTextView;
    UISwitch * taxableSwitch;
	BOOL another_textfield_takes_over;
	
	UILabel * nameLabel;
	UILabel * descriptionLabel;
	
	NSInteger index;
}

@property (weak) id<ProductCreatorDelegate> delegate;

-(id)initWithProduct:(ProductOBJ*)sender index:(NSInteger)i delegate:(id<ProductCreatorDelegate>)del;
-(void)cancel:(UIButton*)sender;
-(void)done:(UIButton*)sender;
-(void)switchChanged:(UISwitch*)sender;
-(void)addDescription:(UIButton*)sender;
-(void)prev:(UIButton*)sender;
-(void)next:(UIButton*)sender;
-(void)closePicker:(UIButton*)sender;

@end