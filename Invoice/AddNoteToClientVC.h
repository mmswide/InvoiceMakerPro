//
//  AddNoteToClientVC.h
//  Invoice
//
//  Created by XGRoup5 on 8/21/13.
//  Copyright (c) 2013 XGRoup. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CustomVC.h"

@class ClientOBJ;

@interface AddNoteToClientVC : CustomVC

{
	ClientOBJ * theClient;
}

-(id)initWithClient:(ClientOBJ*)sender;
-(void)back:(UIButton*)sender;
-(void)done:(UIButton*)sender;
-(void)closeTextView:(UIButton*)sender;

@end