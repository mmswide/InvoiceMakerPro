//
//  TopBar.h
//  Invoice
//
//  Created by XGRoup5 on 9/5/13.
//  Copyright (c) 2013 XGRoup. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TopBar : UIView

{
	UILabel * titleLabel;
}

-(id)initWithFrame:(CGRect)frame andTitle:(NSString*)title;
-(void)setText:(NSString*)text;
-(void)setTextColor:(UIColor*)color;

@end