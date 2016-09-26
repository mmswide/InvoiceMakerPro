//
//  TaxEditorVC.h
//  Invoice
//
//  Created by XGRoup5 on 8/16/13.
//  Copyright (c) 2013 XGRoup. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CustomVC.h"

@class ToolBarView;

@interface TaxEditorVC : CustomVC

{
	NSString * taxAbreviation1;
	NSString * taxRate1;
  NSString * taxAbreviation2;
  NSString * taxRate2;
  NSMutableDictionary * settingsDictionary;
  NSMutableArray * taxTypeArray;
}

-(void)back:(UIButton*)sender;
-(void)done:(UIButton*)sender;
-(void)closeTextView:(UIButton*)sender;

@end