//
//  CreateEstimateVC.h
//  Quote
//
//  Created by XGRoup5 on 9/17/13.
//  Copyright (c) 2013 XGRoup. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CustomVC.h"

@class ScrollWithShadow;
@class ToolBarView;
@class ClientOBJ;
@class CreateEstimateVC_Q;
@class QuoteOBJ;
@class BaseTableCell;

@protocol QuoteCreatorDelegate <NSObject>

-(void)creatorViewController:(CreateEstimateVC_Q*)viewController createdQuote:(QuoteOBJ*)quote;

@end

@interface CreateEstimateVC_Q : CustomVC

{
	QuoteOBJ * theQuote;
	UIButton * percentage;
	UIButton * value;
	BOOL has_alertview;
  
  QuoteOBJ *openedQuote;
}

@property (weak) id<QuoteCreatorDelegate> delegate;

-(id)initForCreationWithDelegate:(id<QuoteCreatorDelegate>)del;
-(id)initWithQuote:(QuoteOBJ*)sender delegate:(id<QuoteCreatorDelegate>)del;
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