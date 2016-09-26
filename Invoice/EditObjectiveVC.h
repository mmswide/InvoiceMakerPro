//
//  EditObjectiveVC.h
//  Meeting.
//
//  Created by XGRoup5 on 31/10/13.
//  Copyright (c) 2013 XGRoup. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CustomVC.h"

@class EditObjectiveVC;

@protocol ObjectiveEditorDelegate <NSObject>

-(void)editorViewController:(EditObjectiveVC*)viewController editedObjective:(NSString*)objective;

@end

@interface EditObjectiveVC : CustomVC

{
	NSMutableString * theObjective;
	NSMutableString * titleString;
}

@property (weak) id<ObjectiveEditorDelegate> delegate;

-(id)initWithDelegate:(id<ObjectiveEditorDelegate>)sender andObjective:(NSString*)obj;
-(void)changeTitleTo:(NSString*)sender;
-(void)back:(UIButton*)sender;
-(void)done:(UIButton*)sender;
-(void)closeTextView:(UIButton*)sender;

@end