//
//  PhotoCell.h
//  Meeting.
//
//  Created by XGRoup5 on 30/10/13.
//  Copyright (c) 2013 XGRoup. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseTableCell.h"
#import "CellWithPush.h"

@interface PhotoCell : BaseTableCell

{
	UIImageView * theImageView;
	UIImageView * bg;
}

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString*)reuseIdentifier;
-(void)loadImage:(UIImage*)sender withType:(kCellType)type;
+(CGFloat)heightForImage:(UIImage*)sender;

@end