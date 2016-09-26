//
//  CreateOrEditClientVC.h
//  Invoice
//
//  Created by XGRoup5 on 8/19/13.
//  Copyright (c) 2013 XGRoup. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CustomVC.h"

typedef enum {
	
	kPickerCaseClientTerms = 0,
	kPickerCaseClientTitle
	
} kPickerCaseClient;

typedef enum {
	
	kActiveFieldCompanyName = 0,
	kActiveFieldWebsite,
	kActiveFieldEmail,
	kActiveFieldPhone,
	kActiveFieldFax,
	kActiveFieldFirstName,
	kActiveFieldLastName,
	kActiveFieldTitle,
	kActiveFieldMobile,
	kActiveFieldTerms
	
} kActiveField;

@class ScrollWithShadow;
@class TableWithShadow;
@class ToolBarView;
@class ClientOBJ;
@class CreateOrEditClientVC;

@protocol ClientCreatorDelegate <NSObject>
@optional
-(void)creatorViewController:(CreateOrEditClientVC*)viewController createdClient:(ClientOBJ*)client;

@end

@interface CreateOrEditClientVC : CustomVC

{
	ClientOBJ * theClient;
	kPickerCaseClient current_picker_type;
	BOOL another_textfield_takes_over;
	kActiveField active_field;
	
	BOOL firstTime;
	
	int editState;
}

@property (weak) id<ClientCreatorDelegate> delegate;

-(id)initWithClient:(ClientOBJ*)sender delegate:(id<ClientCreatorDelegate>)del;
-(void)cancel:(UIButton*)sender;
-(void)done:(UIButton*)sender;

-(UITableViewCell*)cellInSection:(int)section atRow:(int)row;
-(UITableViewCell*)companyCellAtRow:(int)row;
-(UITableViewCell*)clientCellAtRow:(int)row;
-(UITableViewCell*)addressCellAtRow:(int)row;
-(UITableViewCell*)otherCellAtRow:(int)row;

-(void)selectedCellInSection:(int)section atRow:(int)row;
-(void)selectedCompanyCellAtRow:(int)row;
-(void)selectedClientCellAtRow:(int)row;
-(void)selectedAddressCellAtRow:(int)row;
-(void)selectedOtherCellAtRow:(int)row;

-(void)openPickerForCase:(kPickerCaseClient)pickerCase;
-(void)closePicker:(UIButton*)sender;

@end
