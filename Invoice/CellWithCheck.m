//
//  CellWithCheck.m
//  Invoice
//
//  Created by Paul on 17/06/14.
//  Copyright (c) 2014 XGRoup. All rights reserved.
//

#import "CellWithCheck.h"

#import "Defines.h"

@implementation CellWithCheck

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
		
		arrow = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 16, 16)];
		[arrow setImage:[UIImage imageNamed:@"checkArrow.png"]];
		[arrow setAlpha:0.0];
		[arrow setCenter:CGPointMake(dvc_width - 26, 21)];
		[self addSubview:arrow];
		
		titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, (dvc_width - 40) * 0.6, 42)];
		[titleLabel setTextAlignment:NSTextAlignmentLeft];
		[titleLabel setTextColor:[UIColor grayColor]];
		[titleLabel setFont:HelveticaNeue(16)];
		[titleLabel setBackgroundColor:[UIColor clearColor]];
		[titleLabel setTag:10];
		[self addSubview:titleLabel];
		
		titleLabelSelected = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, (dvc_width - 40) * 0.6, 42)];
		[titleLabelSelected setTextAlignment:NSTextAlignmentLeft];
		[titleLabelSelected setTextColor:app_tab_selected_color];
		[titleLabelSelected setFont:HelveticaNeue(16)];
		[titleLabelSelected setBackgroundColor:[UIColor clearColor]];
		[titleLabelSelected setTag:20];
		[titleLabelSelected setAlpha:0.0];
		[self addSubview:titleLabelSelected];
	}
	
	return self;
}

-(void)prepareForReuse
{
	[super prepareForReuse];
	
	[bg setImage:nil];
	[titleLabel setText:@""];
	[titleLabelSelected setText:@""];
	[arrow setAlpha:0.0];
}

-(void)setSelected:(BOOL)selected animated:(BOOL)animated
{
	[super setSelected:selected animated:animated];
}

-(void)loadTitle:(NSString*)title andValue:(NSString*)value cellType:(kProjectCellType)type
{
	[bg setFrame:CGRectMake(10, 0, dvc_width - 20, 42)];
	[bgSelected setFrame:CGRectMake(10, 0, dvc_width - 20, 42)];
	
	switch (type)
	{
		case kProjectCellTypeTop:
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
			
		case kProjectCellTypeMiddle:
		{
			[bg setImage:[[UIImage imageNamed:@"tableMiddleCellWhite.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10]];
			[bgSelected setImage:[[UIImage imageNamed:@"selectedMiddleCell.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10]];
			
			break;
		}
			
		case kProjectCellTypeBottom:
		{
			[bg setImage:[[UIImage imageNamed:@"tableBottomCellWhite.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10]];
			[bgSelected setImage:[[UIImage imageNamed:@"selectedBottomCell.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10]];
			
			break;
		}
			
		case kProjectCellTypeingle:
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

	if([value intValue] == 1)
	{
		[arrow setAlpha:1.0];
	}
	else
	{
		[arrow setAlpha:0.0];
	}
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

-(void)colorOn
{
	[bg setAlpha:0.0];
	[bgSelected setAlpha:1.0];
	[titleLabel setAlpha:0.0];
	[titleLabelSelected setAlpha:1.0];
}

-(void)colorOff
{
	[bg setAlpha:1.0];
	[bgSelected setAlpha:0.0];
	[titleLabel setAlpha:1.0];
	[titleLabelSelected setAlpha:0.0];
}

-(void)resize
{
	[bg setFrame:CGRectMake(10, self.frame.size.height - 42, dvc_width - 20, 42)];
	[bgSelected setFrame:CGRectMake(10, self.frame.size.height - 42, dvc_width - 20, 42)];
	[arrow setCenter:CGPointMake(dvc_width - 20, 21 + self.frame.size.height - 42)];
	[titleLabel setFrame:CGRectMake(20, self.frame.size.height - 42, (dvc_width - 40) * 0.6, 42)];
	[titleLabelSelected setFrame:CGRectMake(20, self.frame.size.height - 42, (dvc_width - 40) * 0.6, 42)];
}

@end
