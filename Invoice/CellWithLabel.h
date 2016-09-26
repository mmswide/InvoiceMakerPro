//
//  CellWithLabel.h
//  Invoice
//
//  Created by XGRoup on 7/14/14.
//  Copyright (c) 2014 XGRoup. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseTableCell.h"
#import "CellWithPush.h"

@interface CellWithLabel : BaseTableCell
{
	UILabel * titleLabel;
	UILabel * valueLabel;
	UIView * bgView;
	UIImageView * bg;
	UIImageView * bgSelected;
	UILabel * titleLabelSelected;
}

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString*)reuseIdentifier;
-(void)loadTitle:(NSString*)title andValue:(NSString*)value tag:(int)tag cellType:(kCellType)type;
-(void)animateSelection;
-(void)resize;
-(void)changeFontTo:(UIFont*)font;

@end
