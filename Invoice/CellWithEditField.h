//
//  CellWithEditField.h
//  Invoice
//
//  Created by Dmytro Nosulich on 3/13/15.
//  Copyright (c) 2015 XGRoup. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseTableCell.h"
#import "CellWithPush.h"

@interface CellWithEditField : BaseTableCell {
    UITextField * titleTextField;
    UITextField * valueTextField;
    UIView * bgView;
    UIImageView * bg;
    UIImageView * bgSelected;
    UIButton *accessoryButton;
  
    CGFloat cellWidth;
}

@property (nonatomic, strong) UITextField *titleTextField;

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString*)reuseIdentifier;
-(void)loadTitle:(NSString*)value tag:(int)tag textFieldDelegate:(id<UITextFieldDelegate>)delegate cellType:(kCellType)type andKeyboardType:(UIKeyboardType)keyboardType;
-(void)setReturnkeyType:(UIReturnKeyType)type;
-(void)setAutoCorrectionType:(UITextAutocorrectionType)type;
-(void)setAutoCapitalizationType:(UITextAutocapitalizationType)type;
-(void)animateSelection;
-(void)setTextFieldEditable:(BOOL)sender;
-(void)changeFontTo:(UIFont*)sender;
-(void)resize:(CGFloat)height;

- (void)setCellType:(kCellType)type;

- (void)addAccessoryTarget:(id)target action:(SEL)action;

- (void)setAutolayoutForValueField;

- (void)setValueField:(NSString *)value tag:(NSInteger)tag;

@end
