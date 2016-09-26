//
//  ESTCell.h
//  Quote
//
//  Created by XGRoup5 on 9/17/13.
//  Copyright (c) 2013 XGRoup. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
	
	kEstimateCellTypeTop = 0,
	kEstimateCellTypeMiddle,
	kEstimateCellTypeBottom,
	kEstimateCellTypeSingle
	
} kEstimateCellType;

@class QuoteOBJ;

@interface ESTCell_Q : UITableViewCell

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
-(void)loadQuote:(QuoteOBJ*)sender withCellType:(kEstimateCellType)type;
-(void)resize;

@end
