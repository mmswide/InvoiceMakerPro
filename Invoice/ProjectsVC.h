//
//  ProjectsVC.h
//  Invoice
//
//  Created by Paul on 17/06/14.
//  Copyright (c) 2014 XGRoup. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TableWithShadow.h"
#import "CustomVC.h"
#import "CategorySelectV.h"

@interface ProjectsVC : CustomVC
{
	TableWithShadow *projectsTableView;
	
	NSMutableArray *array_with_projects;
	NSMutableArray *array_with_completed_projects;
	NSMutableArray *array_with_open_projects;
	
	CategorySelectV *categoryBar;
	
	int categorySelected;
}
@end
