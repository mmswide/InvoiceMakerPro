//
//  ESTCell.h
//  Invoice
//
//  Created by XGRoup5 on 8/27/13.
//  Copyright (c) 2013 XGRoup. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
	
	kEstimateCellTypeTop = 0,
	kEstimateCellTypeMiddle,
	kEstimateCellTypeBottom,
	kEstimateCellTypeSingle
	
} kEstimateCellType;

@class EstimateOBJ;

@interface ESTCell : UITableViewCell

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
-(void)loadEstimate:(EstimateOBJ*)sender withCellType:(kEstimateCellType)type;
-(void)resize;

@end
