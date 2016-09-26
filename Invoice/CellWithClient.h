//
//  CellWithClient.h
//  Invoice
//
//  Created by XGRoup5 on 8/19/13.
//  Copyright (c) 2013 XGRoup. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
	
	kClientCellTypeTop = 0,
	kClientCellTypeMiddle,
	kClientCellTypeBottom,
	kClientCellTypeSingle
	
} kClientCellType;

@class ClientOBJ;
@class ProjectOBJ;

@interface CellWithClient : UITableViewCell

{
	UIImageView * background;
	UILabel * companyNameLabel;
	UILabel * clientNameLabel;
	UILabel * priceLabel;
	UILabel * dueLabel;
}

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString*)reuseIdentifier;
-(void)loadClient:(ClientOBJ*)client withType:(kClientCellType)type;
-(void)loadProject:(ProjectOBJ*)project withType:(kClientCellType)type;
-(void)resize;

@end
