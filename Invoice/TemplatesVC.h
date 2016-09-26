//
//  TemplatesVC.h
//  Invoice
//
//  Created by XGRoup5 on 9/5/13.
//  Copyright (c) 2013 XGRoup. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CustomVC.h"

@interface TemplatesVC : CustomVC

{
	int current_template;
}

-(id)init;
-(void)back:(UIButton*)sender;
-(void)done:(UIButton*)sender;

@end