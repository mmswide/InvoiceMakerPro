//
//  ScrollWithShadow.h
//  Invoice
//
//  Created by XGRoup5 on 8/15/13.
//  Copyright (c) 2013 XGRoup. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ScrollWithShadow : UIScrollView

{
	UIImageView * upperShadow;
	UIImageView * lowerShadow;
}

-(id)initWithFrame:(CGRect)frame;
-(void)didScroll;

@end
