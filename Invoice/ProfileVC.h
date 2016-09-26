//
//  ProfileVC.h
//  Invoice
//
//  Created by XGRoup5 on 8/15/13.
//  Copyright (c) 2013 XGRoup. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CustomVC.h"

@class ToolBarView;
@class ScrollWithShadow;
@class CompanyOBJ;

@interface ProfileVC : CustomVC

{
	CompanyOBJ * myCompany;
	UIPopoverController * popOver;
	CGFloat height;
}

@property(nonatomic, weak) BaseOBJ *baseObject;
@property(nonatomic, assign) BOOL isNewDocument;

-(id)init;
-(void)remakeForFirstUse;

@end