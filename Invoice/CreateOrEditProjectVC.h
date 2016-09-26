//
//  CreateOrEditProjectVC.h
//  Invoice
//
//  Created by Paul on 17/06/14.
//  Copyright (c) 2014 XGRoup. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CustomVC.h"
#import "Defines.h"

typedef enum {
	
	kActiveFieldProjectName = 0,
	kActiveFieldProjectNumber,
	kActiveFieldLocation
} kActiveField;

@class CreateOrEditProjectVC;

@protocol ProjectCreatorDelegate <NSObject>

-(void)creatorViewController:(CreateOrEditProjectVC*)viewController createdProject:(ProjectOBJ*)project;

@end

@interface CreateOrEditProjectVC : CustomVC {
	ProjectOBJ *theProject;
	
	kActiveField active_field;
	BOOL another_textfield_takes_over;
	
	BOOL firstTime;
	
	int editState;
}

@property (weak) id<ProjectCreatorDelegate> delegate;

-(id)initWithProject:(ProjectOBJ*)sender delegate:(id<ProjectCreatorDelegate>)del;
-(void)cancel:(UIButton*)sender;
-(void)done:(UIButton*)sender;

@end
