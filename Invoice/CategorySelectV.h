//
//  CategorySelectV.h
//  Invoice
//
//  Created by XGRoup on 6/25/14.
//  Copyright (c) 2014 XGRoup. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CategorySelectV;

typedef enum {
	
	kInvoiceSelect = 0,
	kProductAndServiceSelect,
	kProjectSelect,
	kReceiptSelect,
	kTimesheetSelect
	
} kSelectType;

@protocol CategorySelectDelegate <NSObject>

-(void)categorySelectDelegate:(CategorySelectV*)view selectedCategory:(int)category;

@end


@interface CategorySelectV : UIView
{
	UIView *lastSelected;
	UILabel *lastLabelSelected;
	UIImageView *lastImageSelected;
	
	int lastButtonSelect;
		
	kSelectType currentType;
}

@property int currentCategorySelected;
@property (weak) id <CategorySelectDelegate> delegate;

- (id)initWithFrame:(CGRect)frame andType:(kSelectType)type andDelegate:(id <CategorySelectDelegate>)sender;

@end
