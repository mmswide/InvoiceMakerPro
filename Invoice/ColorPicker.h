//
//  ColorPicker.h
//  Work.
//
//  Created by XGRoup5 on 19/11/13.
//  Copyright (c) 2013 XGRoup. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SignatureView;

@interface ColorPicker : UIView

{
	UIBezierPath * border;
	CGFloat UNIT;
	
	CGFloat RED;
	CGFloat GREEN;
	CGFloat BLUE;
	CGFloat ALPHA;
}

-(id)initWithFrame:(CGRect)frame andColor:(UIColor*)color;

@property (strong) UIColor * bgColor;
@property (weak) SignatureView * parent;

@end