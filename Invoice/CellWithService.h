//
//  CellWithService.h
//  Invoice
//
//  Created by XGRoup5 on 8/19/13.
//  Copyright (c) 2013 XGRoup. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
	
	kServiceCellTypeTop = 0,
	kServiceCellTypeMiddle,
	kServiceCellTypeBottom,
	kServiceCellTypeSingle
	
} kServiceCellType;

@class ServiceOBJ;

@interface CellWithService : UITableViewCell

{
	UIImageView * background;
	UILabel * titleLabel;
	UILabel * priceLabel;
}

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString*)reuseIdentifier;
-(void)loadService:(ServiceOBJ*)service withType:(kServiceCellType)type;
-(void)resize;

@end