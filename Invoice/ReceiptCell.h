//
//  ReceiptCell.h
//  Invoice
//
//  Created by XGRoup on 7/15/14.
//  Copyright (c) 2014 XGRoup. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ReceiptOBJ.h"
#import "Defines.h"

@interface ReceiptCell : UITableViewCell
{
	UIView * bgView;
	UIImageView * background;
	UILabel * titleLabel;
	UILabel * nameLabel;
	UILabel * priceLabel;
	UILabel * dateLabel;
}

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString*)reuseIdentifier;
-(void)loadReceipt:(ReceiptOBJ*)sender withCellType:(kCellType)type;
-(void)resize;

@end
