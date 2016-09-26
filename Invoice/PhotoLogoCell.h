//
//  PhotoLogoCell.h
//  Invoice
//
//  Created by Dmytro Nosulich on 5/8/15.
//  Copyright (c) 2015 XGRoup. All rights reserved.
//

#import "BaseTableCell.h"

@interface PhotoLogoCell : BaseTableCell

{
  UIImageView * arrow;
  UIImageView * logo;
  UITextField * titleTextField;
  UIView * bgView;
  UIImageView * bg;
  UIImageView * bgSelected;
  UILabel * titleLabelSelected;
  UIButton *accessoryButton;
  
  BOOL isArrowType;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString*)reuseIdentifier;
- (void)loadTitle:(NSString*)title andValue:(UIImage*)value cellType:(kCellType)type andSize:(int)size;
- (void)addAccessoryTarget:(id)target action:(SEL)action;
- (void)animateSelection;

@end
