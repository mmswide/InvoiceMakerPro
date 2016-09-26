//
//  ProjectContactDetailVC.h
//  Invoice
//
//  Created by Paul on 17/06/14.
//  Copyright (c) 2014 XGRoup. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CustomVC.h"

@class ProjectOBJ;
@class ScrollWithShadow;

@interface ProjectContactDetailVC : CustomVC
{
	ProjectOBJ *theProject;
}

-(id)initWithProject:(ProjectOBJ*)project;

@end
