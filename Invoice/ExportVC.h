//
//  ExportVC.h
//  Invoice
//
//  Created by Paul on 19/06/14.
//  Copyright (c) 2014 XGRoup. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ToolBarView.h"
#import "TableWithShadow.h"
#import "ScrollWithShadow.h"
#import "ExportOBJ.h"
#import "CustomVC.h"

typedef enum {
	
	kPickerCaseCategory = 0,
	kPickerCaseEndDate,
	kPickerCaseStartDate
	
} kPickerCase;

@interface ExportVC : CustomVC
{
	ExportOBJ *theExport;
	
	NSArray *categoriesArray;
	
	kPickerCase current_picker_type;
	
	UIButton * exportButton;
	
	int numberOfRows;
	int currentRow;
}

@end
