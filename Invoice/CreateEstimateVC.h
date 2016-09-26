//
//  CreateEstimateVC.h
//  Invoice
//
//  Created by XGRoup5 on 8/27/13.
//  Copyright (c) 2013 XGRoup. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CustomVC.h"

@class ScrollWithShadow;
@class ToolBarView;
@class ClientOBJ;
@class CreateEstimateVC;
@class EstimateOBJ;
@class BaseTableCell;

@protocol EstimateCreatorDelegate <NSObject>

-(void)creatorViewController:(CreateEstimateVC*)viewController createdEstimate:(EstimateOBJ*)estimate;

@end

@interface CreateEstimateVC : CustomVC

{
	EstimateOBJ * theEstimate;
	UIButton * percentage;
	UIButton * value;
	BOOL has_alertview;
  
  EstimateOBJ *openedEstimate;
}

@property (weak) id<EstimateCreatorDelegate> delegate;

-(id)initForCreationWithDelegate:(id<EstimateCreatorDelegate>)del;
-(id)initWithEstimate:(EstimateOBJ*)sender delegate:(id<EstimateCreatorDelegate>)del;
-(void)cancel:(UIButton*)sender;
-(void)done:(UIButton*)sender;

-(void)showPercentageAndValue;
-(void)hidePercentageAndValue;
-(void)percentage:(UIButton*)sender;
-(void)value:(UIButton*)sender;

-(UITableViewCell*)cellInSection:(int)section atRow:(int)row;
-(UITableViewCell*)titleCellAtRow:(int)row;
-(BaseTableCell*)clientCellAtRow:(int)row;
-(UITableViewCell*)productCellAtRow:(int)row;
-(BaseTableCell*)valuesCellAtRow:(int)row;
-(UITableViewCell*)otherCellAtRow:(int)row;

-(void)selectedCellInSection:(int)section atRow:(int)row;
-(void)selectedTitleCellAtRow:(int)row;
-(void)selectedClientCellAtRow:(int)row;
-(void)selectedProductCellAtRow:(int)row;
-(void)selectedValuesCellAtRow:(int)row;
-(void)selectedOtherCellAtRow:(int)row;

-(void)closePicker:(UIButton*)sender;

@end