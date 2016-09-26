//
//  CreateAndEditTimeVC.h
//  Work.
//
//  Created by XGRoup on 6/23/14.
//  Copyright (c) 2014 XGRoup. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CustomVC.h"

typedef enum {
	
	kPickerTypeStart = 0,
	kPickerTypeBreak,
	kPickerTypeFinish,
	kPickerTypeOvertime,
	kPickerTypeDate
	
} kPickerType;

@class SelectServiceTimeVC;
@class ToolBarView;
@class ScrollWithShadow;
@class ServiceTimeOBJ;

@protocol TimeEditorDelegate <NSObject>

-(void)editorViewController:(SelectServiceTimeVC*)viewController editedTime:(ServiceTimeOBJ*)time;

@end

@interface SelectServiceTimeVC : CustomVC

{
	int pickerAppeared;
	
	ServiceTimeOBJ *theTime;
	NSMutableString * title;
	kPickerType picker_type;
	
	UIButton *percentage;
	UIButton *value;
}

@property (weak) id<TimeEditorDelegate> editorDelegate;

-(id)initWithEditorDelegate:(id<TimeEditorDelegate>)sender serviceTime:(ServiceTimeOBJ *)serviceTime andTitle:(NSString *)ttl;

-(void)cancel:(UIButton*)sender;
-(void)done:(UIButton*)sender;

-(void)openPicker;
-(void)closePicker:(UIButton*)sender;

@end
