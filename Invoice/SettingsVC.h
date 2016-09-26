//
//  SettingsVC.h
//  Invoice
//
//  Created by XGRoup5 on 8/13/13.
//  Copyright (c) 2013 XGRoup. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CustomVC.h"

typedef enum {
  
  kPickerCaseTerms = 0,
  kPickerCaseTaxType,
  kPickerCaseDateFormat
  
} kPickerCase;


@class TableWithShadow;

@interface SettingsVC : CustomVC

{
	TableWithShadow * mainTableView;
	
//	NSMutableArray * fiscalYearArray;
	NSMutableArray * taxTypeArray;
	
	kPickerCase current_picker_type;
	
	UIPopoverController * popOver;
	
	BOOL firstTime;
}

-(id)init;

-(UITableViewCell*)cellInSection:(int)section atRow:(int)row;
-(UITableViewCell*)companyCellAtRow:(int)row;
-(UITableViewCell*)taxCellAtRow:(int)row;
-(UITableViewCell*)documentCellAtRow:(int)row;
-(UITableViewCell*)securityCellAtRow:(int)row;
-(UITableViewCell*)businessCellAtRow:(int)row;
-(UITableViewCell*)supportCellAtRow:(int)row;

-(void)selectedCellInSection:(int)section atRow:(int)row;
-(void)selectedCompanyCellAtRow:(int)row;
-(void)selectedTaxCellAtRow:(int)row;
-(void)selectedDocumentCellAtRow:(int)row;
-(void)selectedSecurityCellAtRow:(int)row;
-(void)selectedBusinessCellAtRow:(int)row;
-(void)selectedSupportCellAtRow:(int)row;

-(void)openPickerForCase:(kPickerCase)type;
-(void)closePicker:(UIButton*)sender;

-(void)checkTaxConfiguration;

@end