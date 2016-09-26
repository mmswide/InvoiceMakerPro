//
//  INVCell.h
//  Invoice
//
//  Created by XGRoup5 on 8/22/13.
//  Copyright (c) 2013 XGRoup. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {

	kInvoiceCellTypeTop = 0,
	kInvoiceCellTypeMiddle,
	kInvoiceCellTypeBottom,
	kInvoiceCellTypeSingle
	
} kInvoiceCellType;

@class InvoiceOBJ;

@interface INVCell : UITableViewCell

{
	UIView * bgView;
	UIImageView * background;
	UILabel * titleLabel;
	UILabel * nameLabel;
    UILabel * clientNameLabel;
	UILabel * priceLabel;
	UILabel * dueLabel;
	UILabel * statusLabel;
}

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString*)reuseIdentifier;
-(void)loadInvoice:(InvoiceOBJ*)sender withCellType:(kInvoiceCellType)type;
-(void)resize;

@end