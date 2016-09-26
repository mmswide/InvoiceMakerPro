//
//  DescriptionCell.h
//  Invoice
//
//  Created by Dmytro Nosulich on 4/1/15.
//  Copyright (c) 2015 XGRoup. All rights reserved.
//

#import "BaseTableCell.h"
#import "CellWithPush.h"

#define DESCRIPTION_VIEW_HEIGHT 210

@class PlaceHolderTextView;
@interface DescriptionCell : BaseTableCell

{
    UITextField * titleTextField;
    PlaceHolderTextView * valueTextView;
    UIView * bgView;
    UIImageView * bg;
    UIImageView * bgSelected;
    UILabel * titleLabelSelected;
    UIButton *accessoryButton;
}

@property (nonatomic, strong) PlaceHolderTextView *valueTextView;

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString*)reuseIdentifier;
-(void)loadTitle:(NSString*)title andValue:(NSString*)value tag:(int)tag textFieldDelegate:(id<UITextViewDelegate>)delegate cellType:(kCellType)type andKeyboardType:(UIKeyboardType)keyboardType;
-(void)setReturnkeyType:(UIReturnKeyType)type;
-(void)setAutoCorrectionType:(UITextAutocorrectionType)type;
-(void)setAutoCapitalizationType:(UITextAutocapitalizationType)type;
-(void)animateSelection;
-(void)setTextFieldEditable:(BOOL)sender;
-(void)changeFontTo:(UIFont*)sender;
-(void)resize:(CGFloat)height;

- (void)setAutolayoutForValueField;

@end
