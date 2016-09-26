//
//  CellWithPicker.h
//  Invoice
//
//  Created by XGRoup5 on 8/15/13.
//  Copyright (c) 2013 XGRoup. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseTableCell.h"
#import "CellWithPush.h"

@interface CellWithPicker : BaseTableCell

{
	UITextField * titleTextField;
	UILabel * valueLabel;
	UIView * bgView;
	UIImageView * bg;
	UIImageView * bgSelected;
	UILabel * titleLabelSelected;
  
  CGFloat cellWidth;
}

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString*)reuseIdentifier;
-(void)loadTitle:(NSString*)title andValue:(NSString*)value cellType:(kCellType)type;
-(void)animateSelection;
-(void)resize;

@end
