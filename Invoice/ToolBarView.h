//
//  ToolBarView.h
//  Invoice
//
//  Created by XGRoup5 on 8/16/13.
//  Copyright (c) 2013 XGRoup. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BackButtonNormal.h"

@interface ToolBarView : UIView

@property (retain) BackButtonNormal * prevButton;
@property (retain) BackButtonNormal * nextButton;
@property (retain) UIButton * doneButton;

-(id)initWithFrame:(CGRect)frame;
-(void)keyboardWillHide:(NSNotification*)sender;

@end
