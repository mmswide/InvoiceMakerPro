//
//  TimesheetCell.h
//  Invoice
//
//  Created by XGRoup on 7/17/14.
//  Copyright (c) 2014 XGRoup. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TimeSheetOBJ.h"
#import "ReceiptCell.h"

@interface TimesheetCell : UITableViewCell
{
	UIView * bgView;
	UIImageView * background;
	UILabel * titleLabel;
	UILabel * nameLabel;
	UILabel * priceLabel;
	UILabel * dateLabel;
}

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString*)reuseIdentifier;
-(void)loadTimesheet:(TimeSheetOBJ*)sender withCellType:(kCellType)type;
-(void)resize;

@end
