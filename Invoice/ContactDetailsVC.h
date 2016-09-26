//
//  ContactDetailsVC.h
//  Invoice
//
//  Created by XGRoup5 on 8/22/13.
//  Copyright (c) 2013 XGRoup. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomVC.h"

@class ClientOBJ;
@class ScrollWithShadow;

@interface ContactDetailsVC : CustomVC
{
	ClientOBJ * theClient;
}

-(id)initWithClient:(ClientOBJ*)sender;
-(void)back:(UIButton*)sender;
-(void)website:(UIButton*)sender;
-(void)email:(UIButton*)sender;
-(void)phone:(UIButton*)sender;
-(void)mobile:(UIButton*)sender;

@end