//
//  PhotoCell.m
//  Meeting.
//
//  Created by XGRoup5 on 30/10/13.
//  Copyright (c) 2013 XGRoup. All rights reserved.
//

#import "PhotoCell.h"

#import "Defines.h"

@implementation PhotoCell

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString*)reuseIdentifier
{
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	
	if (self)
	{
		bg = [[UIImageView alloc] init];
		[self addSubview:bg];
		
		theImageView = [[UIImageView alloc] init];
		[theImageView setContentMode:UIViewContentModeScaleAspectFit];
		[self addSubview:theImageView];
		
		UIView * empty = [[UIView alloc] initWithFrame:CGRectMake(0, 0, dvc_width, 44)];
		[empty setBackgroundColor:[UIColor clearColor]];
		[self setBackgroundView:empty];
	}
	
	return self;
}

-(void)loadImage:(UIImage*)sender withType:(kCellType)type
{
	CGSize img_size = [data_manager sizeOfAspectScaledSize:sender.size inSize:CGSizeMake(dvc_width - 40, 9999)];
	
	if (!sender)
		img_size = CGSizeMake(dvc_width - 40, dvc_width - 40);
	
	[theImageView setFrame:CGRectMake(20, 10, dvc_width - 40, img_size.height)];
	[theImageView setImage:sender];
	
	[bg setFrame:CGRectMake(10, 0, dvc_width - 20, img_size.height + 20)];
	
	switch (type)
	{
		case kCellTypeTop:
		{
			[bg setImage:[[UIImage imageNamed:@"tableTopCellWhite.png"] stretchableImageWithLeftCapWidth:20 topCapHeight:15]];
			
			if (sys_version >= 7)
			{
				[bg setFrame:CGRectMake(10, 0, dvc_width - 20, img_size.height + 20)];
			}
			else
			{
				[bg setFrame:CGRectMake(10, 0, dvc_width - 20, img_size.height + 21)];
			}
			
			break;
		}
			
		case kCellTypeMiddle:
		{
			[bg setImage:[[UIImage imageNamed:@"tableMiddleCellWhite.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10]];
			
			break;
		}
			
		case kCellTypeBottom:
		{
			[bg setImage:[[UIImage imageNamed:@"tableBottomCellWhite.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10]];
			
			break;
		}
			
		case kCellTypeSingle:
		{
			[bg setImage:[[UIImage imageNamed:@"tableSingleCellWhite.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10]];
			
			break;
		}
			
		default:
			break;
	}
}

+(CGFloat)heightForImage:(UIImage*)sender
{
	if (!sender)
		return dvc_width - 20;
	
	CGSize img_size = [data_manager sizeOfAspectScaledSize:sender.size inSize:CGSizeMake(dvc_width - 40, 9999)];
	
	return img_size.height + 20;
}

-(void)prepareForReuse
{
	[super prepareForReuse];
	
	[theImageView setImage:nil];
}

-(void)setSelected:(BOOL)selected animated:(BOOL)animated
{
	[super setSelected:selected animated:animated];
}

@end