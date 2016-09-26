//
//  BaseTableCell.h
//  Invoice
//
//  Created by Dmytro Nosulich on 3/16/15.
//  Copyright (c) 2015 XGRoup. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"

#define EDGE_OFFSET 20.f

@interface BaseTableCell : UITableViewCell {
  BOOL isEditingMode;
  BOOL isTitleBigger;
  
  CGFloat valueOffset;
}

@property (nonatomic) BOOL canEditvalueField;
@property (nonatomic) BOOL isTitleEditable;
@property (nonatomic, assign) CGFloat cellWidth;

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier width:(CGFloat)width;
- (void)setCellType:(kCellType)type;
- (void)animateSelection;
- (void)setIsTitleEditable:(BOOL)isTitleEditable delegate:(id<UITextFieldDelegate>)delegate tag:(NSInteger)tag;
- (void)setAutolayoutForValueField;
- (void)setTitleEditableLayout;
- (void)makeTitleBigger:(BOOL)isbigger;
- (void)makeValueBigger:(BOOL)isbigger;
- (void)setAutoCapitalizationType:(UITextAutocapitalizationType)type;

- (void)setValueDelegate:(id<UITextFieldDelegate>)delegate tag:(NSInteger)tag keyboardType:(UIKeyboardType)keyboardType;
- (void)setTitlePlaceholder:(NSString *)placeholder;
- (void)setValuePlaceholder:(NSString *)placeholder;

- (void)setIsEditingMode:(BOOL)editing;

@end
