//
//  CellWithCheck.h
//  Invoice
//
//  Created by Paul on 17/06/14.
//  Copyright (c) 2014 XGRoup. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
	
	kProjectCellTypeTop = 0,
	kProjectCellTypeMiddle,
	kProjectCellTypeBottom,
	kProjectCellTypeingle
	
} kProjectCellType;

@interface CellWithCheck : UITableViewCell
{
	UIImageView * arrow;
	UILabel * titleLabel;
	UIView * bgView;
	UIImageView * bg;
	UIImageView * bgSelected;
	UILabel * titleLabelSelected;
}

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString*)reuseIdentifier;
-(void)loadTitle:(NSString*)title andValue:(NSString*)value cellType:(kProjectCellType)type;
-(void)animateSelection;
-(void)resize;
-(void)colorOn;
-(void)colorOff;

@end
