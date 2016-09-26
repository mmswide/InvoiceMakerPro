//
//  CellWithPush.h
//  Invoice
//
//  Created by XGRoup5 on 8/15/13.
//  Copyright (c) 2013 XGRoup. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseTableCell.h"

@interface CellWithPush : BaseTableCell

{
	UIImageView * arrow;
	UITextField * titleTextField;
	UITextField * valueTextField;
	UIView * bgView;
	UIImageView * bg;
	UIImageView * bgSelected;
	UILabel * titleLabelSelected;
  UIButton *accessoryButton;
  
  CGFloat cellWidth;
  
  BOOL isArrowType;
}

- (void)setValueTextfieldDelegate:(id<UITextFieldDelegate>)valueTextfieldDelegate tag:(NSInteger)tag;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString*)reuseIdentifier;
- (void)loadTitle:(NSString*)title andValue:(NSString*)value cellType:(kCellType)type andSize:(int)size;
- (void)addAccessoryTarget:(id)target action:(SEL)action;
- (void)removeAccessoryTarget;
- (void)animateSelection;
- (void)resize;
- (void)colorOn;
- (void)colorOff;
- (void)removeValueField;
- (void)setValueEditable:(BOOL)editable;

@end
