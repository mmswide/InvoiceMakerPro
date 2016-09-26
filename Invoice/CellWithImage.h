//
//  CellWithImage.h
//  Invoice
//
//  Created by XGRoup on 8/6/14.
//  Copyright (c) 2014 XGRoup. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseTableCell.h"
#import "CellWithPush.h"

@interface CellWithImage : BaseTableCell
{
	UILabel * titleLabel;
	
	UIImageView *cellImage;
	
	UIView * bgView;
	UIImageView * bg;
	UIImageView * bgSelected;
	UILabel * titleLabelSelected;
}

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString*)reuseIdentifier;
-(void)loadTitle:(NSString*)title andValue:(NSData*)imageData tag:(int)tag cellType:(kCellType)type;
-(void)animateSelection;
-(void)resize;

@end
