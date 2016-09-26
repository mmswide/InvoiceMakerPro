//
//  TableWithShadow.h
//  Invoice
//
//  Created by XGRoup5 on 8/14/13.
//  Copyright (c) 2013 XGRoup. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TableWithShadow : UITableView

{
	UIImageView * upperShadow;
	UIImageView * lowerShadow;
}

@property int upperShadowAlpha;

-(id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style;
-(void)didScroll;

@end
