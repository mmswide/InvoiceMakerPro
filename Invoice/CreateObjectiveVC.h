//
//  CreateObjectiveVC.h
//  Meeting.
//
//  Created by XGRoup5 on 31/10/13.
//  Copyright (c) 2013 XGRoup. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CustomVC.h"

@class CreateObjectiveVC;

@protocol ObjectiveCreatorDelegate <NSObject>

-(void)creatorViewController:(CreateObjectiveVC*)viewController createdObjective:(NSString*)objective;

@end

@interface CreateObjectiveVC : CustomVC

{
	NSMutableString * theObjective;
	NSMutableString * titleString;
}

@property (weak) id<ObjectiveCreatorDelegate> delegate;

-(id)initWithDelegate:(id<ObjectiveCreatorDelegate>)sender;
-(void)changeTitleTo:(NSString*)sender;
-(void)back:(UIButton*)sender;
-(void)done:(UIButton*)sender;
-(void)closeTextView:(UIButton*)sender;

@end