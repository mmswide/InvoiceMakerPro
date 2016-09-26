//
//  CellWithText.h
//  Invoice
//
//  Created by XGRoup5 on 8/15/13.
//  Copyright (c) 2013 XGRoup. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseTableCell.h"
#import "CellWithPush.h"

@interface CellWithText : BaseTableCell

{
	UITextField * titleTextField;
	UITextField * valueTextField;
	UIView * bgView;
	UIImageView * bg;
	UIImageView * bgSelected;
	UILabel * titleLabelSelected;
  UIButton *accessoryButton;
  
  CGFloat cellWidth;
}

@property (nonatomic, strong) UITextField *valueTextField;
@property (nonatomic, assign) BOOL activeValueOnSelection;


-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString*)reuseIdentifier;
-(void)loadTitle:(NSString*)title andValue:(NSString*)value tag:(int)tag textFieldDelegate:(id<UITextFieldDelegate>)delegate cellType:(kCellType)type andKeyboardType:(UIKeyboardType)keyboardType;
-(void)setReturnkeyType:(UIReturnKeyType)type;
-(void)setAutoCorrectionType:(UITextAutocorrectionType)type;
-(void)animateSelection;
-(void)setTextFieldEditable:(BOOL)sender;
-(void)changeFontTo:(UIFont*)sender;
-(void)resize:(CGFloat)height;

- (void)addAccessoryTarget:(id)target action:(SEL)action;

- (void)setAutolayoutForValueField;

@end
