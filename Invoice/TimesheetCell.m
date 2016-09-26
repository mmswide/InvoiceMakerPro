//
//  TimesheetCell.m
//  Invoice
//
//  Created by XGRoup on 7/17/14.
//  Copyright (c) 2014 XGRoup. All rights reserved.
//

#import "TimesheetCell.h"

#import "Defines.h"

@implementation TimesheetCell

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
		
		background = [[UIImageView alloc] initWithFrame:CGRectMake(10, 0, dvc_width - 20, 84)];
		[self addSubview:background];
		
		titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, (dvc_width - 30) / 2, 42)];
		[titleLabel setTextAlignment:NSTextAlignmentLeft];
		[titleLabel setTextColor:[UIColor grayColor]];
		[titleLabel setFont:HelveticaNeue(16)];
		[titleLabel setBackgroundColor:[UIColor clearColor]];
		[self addSubview:titleLabel];
		
		nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 42, (dvc_width - 30) / 2, 42)];
		[nameLabel setTextAlignment:NSTextAlignmentLeft];
		[nameLabel setTextColor:[UIColor grayColor]];
		[nameLabel setFont:HelveticaNeue(16)];
		[nameLabel setBackgroundColor:[UIColor clearColor]];
		[self addSubview:nameLabel];
		
		priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(15 + (dvc_width - 30) / 2, 0, (dvc_width - 30) / 2, 42)];
		[priceLabel setTextAlignment:NSTextAlignmentRight];
		[priceLabel setTextColor:[UIColor darkGrayColor]];
		[priceLabel setFont:HelveticaNeue(15)];
		[priceLabel setBackgroundColor:[UIColor clearColor]];
		[self addSubview:priceLabel];
		
		dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(15 + (dvc_width - 30) / 2, 42, (dvc_width - 30) / 2, 42)];
		[dateLabel setTextAlignment:NSTextAlignmentRight];
		[dateLabel setTextColor:[UIColor darkGrayColor]];
		[dateLabel setFont:HelveticaNeue(15)];
		[dateLabel setBackgroundColor:[UIColor clearColor]];
		[self addSubview:dateLabel];
	}
	
	return self;
}

-(void)willTransitionToState:(UITableViewCellStateMask)state
{
	[super willTransitionToState:state];
	
	if (sys_version < 7)
	{
		dispatch_async(dispatch_get_main_queue(), ^{
			
			if (state == UITableViewCellStateShowingDeleteConfirmationMask)
			{
				[UIView animateWithDuration:0.25 animations:^{
					
					[background setFrame:CGRectMake(background.frame.origin.x, background.frame.origin.y, background.frame.size.width - 65, background.frame.size.height)];
					[priceLabel setFrame:CGRectMake(priceLabel.frame.origin.x - 65, priceLabel.frame.origin.y, priceLabel.frame.size.width, priceLabel.frame.size.height)];
					[dateLabel setFrame:CGRectMake(dateLabel.frame.origin.x - 65, dateLabel.frame.origin.y, dateLabel.frame.size.width, dateLabel.frame.size.height)];
					
				}];
			}
			else if (state == UITableViewCellStateDefaultMask)
			{
				[UIView animateWithDuration:0.25 animations:^{
					
					[background setFrame:CGRectMake(background.frame.origin.x, background.frame.origin.y, background.frame.size.width + 65, background.frame.size.height)];
					[priceLabel setFrame:CGRectMake(priceLabel.frame.origin.x + 65, priceLabel.frame.origin.y, priceLabel.frame.size.width, priceLabel.frame.size.height)];
					[dateLabel setFrame:CGRectMake(dateLabel.frame.origin.x + 65, dateLabel.frame.origin.y, dateLabel.frame.size.width, dateLabel.frame.size.height)];
					
				}];
			}
			
		});
	}
}

-(void)loadTimesheet:(TimeSheetOBJ *)sender withCellType:(kCellType)type
{
	switch (type)
	{
		case kCellTypeTop:
		{
			[background setImage:[[UIImage imageNamed:@"tableTopCellWhite.png"] stretchableImageWithLeftCapWidth:20 topCapHeight:15]];
			break;
		}
			
		case kCellTypeMiddle:
		{
			[background setImage:[[UIImage imageNamed:@"tableMiddleCellWhite.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10]];
			break;
		}
			
		case kCellTypeBottom:
		{
			[background setImage:[[UIImage imageNamed:@"tableBottomCellWhite.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10]];
			break;
		}
			
		case kCellTypeSingle:
		{
			[background setImage:[[UIImage imageNamed:@"tableSingleCellWhite.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10]];
			break;
		}
			
		default:
			break;
	}
	
	ClientOBJ * theClient = [sender client];
	
	[bgView setFrame:CGRectMake(0, 0, dvc_width, self.frame.size.height)];
		
	NSString *priceValue = [sender getTotalHours];
	[priceLabel setText:priceValue];

	NSString *clientName = [theClient firstName];
	
	if([clientName isEqual:@""])
	{
		clientName = [theClient lastName];
	}
	else
	{
		clientName = [NSString stringWithFormat:@"%@ %@",clientName,[theClient lastName]];
	}
	
	[nameLabel setText:clientName];
	[titleLabel setText:[theClient company]];

	[date_formatter setDateFormat:[DELEGATE userSelectedDateFormat]];
	[dateLabel setText:[date_formatter stringFromDate:[sender date]]];
}

-(void)prepareForReuse
{
	[super prepareForReuse];
	
	[background setImage:nil];
	[titleLabel setText:@""];
	[nameLabel setText:@""];
	[priceLabel setText:@""];
	[dateLabel setText:@""];
}

-(void)setSelected:(BOOL)selected animated:(BOOL)animated
{
	[super setSelected:selected animated:animated];
}

-(void)resize
{
	[background setFrame:CGRectMake(10, self.frame.size.height - 84, dvc_width - 20, 84)];
	[titleLabel setFrame:CGRectMake(15, self.frame.size.height - 84, (dvc_width - 30) / 2, 42)];
	[nameLabel setFrame:CGRectMake(15, 42 + self.frame.size.height - 84, (dvc_width - 30) / 2, 42)];
	[priceLabel setFrame:CGRectMake(15 + (dvc_width - 30) / 2, self.frame.size.height - 84, (dvc_width - 30) / 2, 42)];
	[dateLabel setFrame:CGRectMake(15 + (dvc_width - 30) / 2, 42 + self.frame.size.height - 84, (dvc_width - 30) / 2, 42)];
}


@end
