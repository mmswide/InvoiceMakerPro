//
//  CellWithLabel.m
//  Invoice
//
//  Created by XGRoup on 7/14/14.
//  Copyright (c) 2014 XGRoup. All rights reserved.
//

#import "CellWithLabel.h"

#import "Defines.h"

@implementation CellWithLabel

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString*)reuseIdentifier
{
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	
	if (self)
	{
		[self.layer setMasksToBounds:YES];
		
		[self setBackgroundColor:[UIColor clearColor]];
		
		[self setSelectionStyle:UITableViewCellSelectionStyleNone];
		
		bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, dvc_width, dvc_height)];
		[bgView setBackgroundColor:[UIColor clearColor]];
		[self setBackgroundView:bgView];
		
		bg = [[UIImageView alloc] initWithFrame:CGRectMake(10, 0, dvc_width - 20, 42)];
		[bg setTag:1];
		[self addSubview:bg];
		
		bgSelected = [[UIImageView alloc] initWithFrame:CGRectMake(10, 0, dvc_width - 20, 42)];
		[bgSelected setTag:2];
		[bgSelected setAlpha:0.0];
		[self addSubview:bgSelected];
		
		titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, (dvc_width - 40) * 0.6, 42)];
		[titleLabel setTextAlignment:NSTextAlignmentLeft];
		[titleLabel setTextColor:[UIColor grayColor]];
		[titleLabel setFont:HelveticaNeue(16)];
		[titleLabel setBackgroundColor:[UIColor clearColor]];
		[titleLabel setTag:10];
		[titleLabel setNumberOfLines:2];
		[self addSubview:titleLabel];
		
		titleLabelSelected = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, (dvc_width - 40) * 0.6, 42)];
		[titleLabelSelected setTextAlignment:NSTextAlignmentLeft];
		[titleLabelSelected setTextColor:app_tab_selected_color];
		[titleLabelSelected setFont:HelveticaNeue(16)];
		[titleLabelSelected setBackgroundColor:[UIColor clearColor]];
		[titleLabelSelected setTag:20];
		[titleLabelSelected setAlpha:0.0];
		[titleLabelSelected setNumberOfLines:2];
		[self addSubview:titleLabelSelected];
		
		valueLabel = [[UILabel alloc] initWithFrame:CGRectMake(25 + (dvc_width - 40) * 0.6, 0, (dvc_width - 40) * 0.33, 42)];
		[valueLabel setTextAlignment:NSTextAlignmentRight];
		[valueLabel setTextColor:[UIColor darkGrayColor]];
		[valueLabel setFont:HelveticaNeue(16)];
		[valueLabel setBackgroundColor:[UIColor clearColor]];
		[valueLabel setTextAlignment:NSTextAlignmentRight];
		[self addSubview:valueLabel];
	}
	
	return self;
}

-(void)prepareForReuse
{
	[super prepareForReuse];
	
	[bg setImage:nil];
	[titleLabel setText:@""];
	[titleLabelSelected setText:@""];
	[valueLabel setText:@""];
}

-(void)setSelected:(BOOL)selected animated:(BOOL)animated
{
	[super setSelected:selected animated:animated];
}

-(void)animateSelection
{
	[UIView animateWithDuration:0.15 animations:^{
		
		[bg setAlpha:0.0];
		[bgSelected setAlpha:1.0];
		[titleLabel setAlpha:0.0];
		[titleLabelSelected setAlpha:1.0];
		
	} completion:^(BOOL finished) {
		
		[UIView animateWithDuration:0.15 animations:^{
			
			[bg setAlpha:1.0];
			[bgSelected setAlpha:0.0];
			[titleLabel setAlpha:1.0];
			[titleLabelSelected setAlpha:0.0];
			
		}];
		
	}];
}

-(void)loadTitle:(NSString*)title andValue:(NSString*)value tag:(int)tag cellType:(kCellType)type
{
	[valueLabel setFont:HelveticaNeue(16)];
	
	[bg setFrame:CGRectMake(10, 0, dvc_width - 20, 42)];
	[bgSelected setFrame:CGRectMake(10, 0, dvc_width - 20, 42)];
	
	switch (type)
	{
		case kCellTypeTop:
		{
			[bg setImage:[[UIImage imageNamed:@"tableTopCellWhite.png"] stretchableImageWithLeftCapWidth:20 topCapHeight:15]];
			[bgSelected setImage:[[UIImage imageNamed:@"selectedTopCell.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10]];
			
			if (sys_version >= 7)
			{
				[bg setFrame:CGRectMake(10, 0, dvc_width - 20, 42)];
				[bgSelected setFrame:CGRectMake(10, 0, dvc_width - 20, 42)];
			}
			else
			{
				[bg setFrame:CGRectMake(10, 0, dvc_width - 20, 43)];
				[bgSelected setFrame:CGRectMake(10, 0, dvc_width - 20, 43)];
			}
			
			break;
		}
			
		case kCellTypeMiddle:
		{
			[bg setImage:[[UIImage imageNamed:@"tableMiddleCellWhite.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10]];
			[bgSelected setImage:[[UIImage imageNamed:@"selectedMiddleCell.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10]];
			
			break;
		}
			
		case kCellTypeBottom:
		{
			[bg setImage:[[UIImage imageNamed:@"tableBottomCellWhite.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10]];
			[bgSelected setImage:[[UIImage imageNamed:@"selectedBottomCell.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10]];
			
			break;
		}
			
		case kCellTypeSingle:
		{
			[bg setImage:[[UIImage imageNamed:@"tableSingleCellWhite.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10]];
			[bgSelected setImage:[[UIImage imageNamed:@"selectedSingleCell.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10]];
			
			break;
		}
			
		default:
			break;
	}
	
	[titleLabel setText:title];
	[titleLabelSelected setText:title];
	
	CGSize title_size = [data_manager sizeForString:title withFont:titleLabel.font constrainedToSize:CGSizeMake(MAXFLOAT, MAXFLOAT)];
	[valueLabel setFrame:CGRectMake(titleLabel.frame.origin.x + title_size.width + 10, valueLabel.frame.origin.y, dvc_width - (titleLabel.frame.origin.x + title_size.width + 35), 42)];
	[valueLabel setTag:tag];
	[valueLabel setText:value];
	[valueLabel setBackgroundColor:[UIColor clearColor]];
	
	if (valueLabel.text.length > 0)
	{
		CGSize valueSize = [data_manager sizeForString:valueLabel.text withFont:valueLabel.font constrainedToSize:CGSizeMake(MAXFLOAT, MAXFLOAT)];
		
		[valueLabel setFrame:CGRectMake(dvc_width - valueSize.width - 20, self.frame.size.height - 42, valueSize.width, 42)];
	}
	
	[titleLabel setFrame:CGRectMake(20, self.frame.size.height - 42, dvc_width - 20 - valueLabel.frame.size.width - 30, 42)];
	[titleLabelSelected setFrame:titleLabel.frame];
}

-(void)resize
{
	[bg setFrame:CGRectMake(10, self.frame.size.height - 42, dvc_width - 20, 42)];
	[bgSelected setFrame:CGRectMake(10, self.frame.size.height - 42, dvc_width - 20, 42)];
	[titleLabel setFrame:CGRectMake(20, self.frame.size.height - 42, (dvc_width - 40) * 0.6, 42)];
	[titleLabelSelected setFrame:CGRectMake(20, self.frame.size.height - 42, (dvc_width - 40) * 0.6, 42)];
	[valueLabel setFrame:CGRectMake(25 + (dvc_width - 40) * 0.6, self.frame.size.height - 42, (dvc_width - 40) * 0.33, 42)];
	
	CGSize valueSize = [data_manager sizeForString:valueLabel.text withFont:valueLabel.font constrainedToSize:CGSizeMake(MAXFLOAT, MAXFLOAT)];
	
	[valueLabel setFrame:CGRectMake(dvc_width - valueSize.width - 20, self.frame.size.height - 42, valueSize.width, 42)];
	[titleLabel setFrame:CGRectMake(20, self.frame.size.height - 42, dvc_width - 20 - valueLabel.frame.size.width - 30, 42)];
	[titleLabelSelected setFrame:titleLabel.frame];
}

-(void)changeFontTo:(UIFont*)font
{
	valueLabel.font = font;
}

@end
