//
//  CellWithSlider.h
//  Work.
//
//  Created by XGRoup on 6/23/14.
//  Copyright (c) 2014 XGRoup. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseTableCell.h"
#import "CellWithPush.h"

@interface CellWithSwitch : BaseTableCell
{
	UILabel * titleLabel;
	UIView * bgView;
	UIImageView * bg;
	UIImageView * bgSelected;
	UILabel * titleLabelSelected;
	
	UISwitch *valueSwith;
}

-(void)loadTitle:(NSString*)title andValue:(NSString*)value cellType:(kCellType)type;

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString*)reuseIdentifier;

- (void)setSwitchTarget:(id)target andSelector:(SEL)selector;

-(void)animateSelection;

@end
