//
//  BaseTableCell.m
//  Invoice
//
//  Created by Dmytro Nosulich on 3/16/15.
//  Copyright (c) 2015 XGRoup. All rights reserved.
//

#import "BaseTableCell.h"

@implementation BaseTableCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier width:(CGFloat)width {
  return [self initWithStyle:style reuseIdentifier:reuseIdentifier];
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setCellType:(kCellType)type {
}

-(void)animateSelection {
}

- (void)setIsTitleEditable:(BOOL)isTitleEditable delegate:(id<UITextFieldDelegate>)delegate tag:(NSInteger)tag {
}

- (void)setAutolayoutForValueField {
}

- (void)setTitleEditableLayout {
}

- (void)makeTitleBigger:(BOOL)isbigger {
}

- (void)makeValueBigger:(BOOL)isbigger {
}

- (void)setValueDelegate:(id<UITextFieldDelegate>)delegate tag:(NSInteger)tag keyboardType:(UIKeyboardType)keyboardType{
}

-(void)setAutoCapitalizationType:(UITextAutocapitalizationType)type {
}

- (void)setValuePlaceholder:(NSString *)placeholder {
}

- (void)setTitlePlaceholder:(NSString *)placeholder {
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    isEditingMode = editing;
}

- (void)setEditing:(BOOL)editing {
    [super setEditing:editing];
    
    isEditingMode = editing;
}

- (void)setIsEditingMode:(BOOL)editing {
  isEditingMode = editing;
}

@end
