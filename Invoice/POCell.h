//
//  POCell.h
//  Invoice
//
//  Created by XGRoup5 on 8/27/13.
//  Copyright (c) 2013 XGRoup. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
	
	kPOCellTypeTop = 0,
	kPOCellTypeMiddle,
	kPOCellTypeBottom,
	kPOCellTypeSingle
	
} kPOCellType;

@class PurchaseOrderOBJ;

@interface POCell : UITableViewCell

{
	UIView * bgView;
	UIImageView * background;
	UILabel * titleLabel;
    UILabel * clientNameLabel;
	UILabel * nameLabel;
	UILabel * priceLabel;
	UILabel * dueLabel;
	UILabel * statusLabel;
}

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString*)reuseIdentifier;
-(void)loadPO:(PurchaseOrderOBJ*)sender withCellType:(kPOCellType)type;
-(void)resize;

@end
