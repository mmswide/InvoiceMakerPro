//
//  CellWithProduct.h
//  Invoice
//
//  Created by XGRoup5 on 8/19/13.
//  Copyright (c) 2013 XGRoup. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {

	kProductCellTypeTop = 0,
	kProductCellTypeMiddle,
	kProductCellTypeBottom,
	kProductCellTypeSingle
	
} kProductCellType;

@class ProductOBJ;

@interface CellWithProduct : UITableViewCell

{
	UIImageView * background;
	UILabel * titleLabel;
	UILabel * priceLabel;
}

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString*)reuseIdentifier;
-(void)loadProduct:(ProductOBJ*)product withType:(kProductCellType)type;
-(void)resize;

@end