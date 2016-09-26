//
//  BarButton.h
//  Invoice
//
//  Created by XGRoup5 on 8/14/13.
//  Copyright (c) 2013 XGRoup. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BarButton : UIButton

{
	UILabel * labelWithTitle;
	UIImageView * buttonImage;
}

-(id)initWithFrame:(CGRect)frame title:(NSString*)title andTag:(int)tag;
-(void)setSelected:(BOOL)selected;

@end