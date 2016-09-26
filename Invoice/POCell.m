//
//  POCell.m
//  Invoice
//
//  Created by XGRoup5 on 8/27/13.
//  Copyright (c) 2013 XGRoup. All rights reserved.
//

#import "POCell.h"

#import "Defines.h"

@implementation POCell

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
		
		titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, (dvc_width - 30) / 2, 28)];
		[titleLabel setTextAlignment:NSTextAlignmentLeft];
		[titleLabel setTextColor:[UIColor grayColor]];
		[titleLabel setFont:HelveticaNeue(16)];
		[titleLabel setBackgroundColor:[UIColor clearColor]];
		[self addSubview:titleLabel];
        
        clientNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 28, (dvc_width - 30) / 2, 28)];
        [clientNameLabel setTextAlignment:NSTextAlignmentLeft];
        [clientNameLabel setTextColor:[UIColor grayColor]];
        [clientNameLabel setFont:HelveticaNeue(16)];
        [clientNameLabel setBackgroundColor:[UIColor clearColor]];
        [self addSubview:clientNameLabel];
		
		nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 56, (dvc_width - 30) / 2, 28)];
		[nameLabel setTextAlignment:NSTextAlignmentLeft];
		[nameLabel setTextColor:[UIColor grayColor]];
		[nameLabel setFont:HelveticaNeue(16)];
		[nameLabel setBackgroundColor:[UIColor clearColor]];
		[self addSubview:nameLabel];
		
		priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(15 + (dvc_width - 30) / 2, 0, (dvc_width - 30) / 2, 28)];
		[priceLabel setTextAlignment:NSTextAlignmentRight];
		[priceLabel setTextColor:[UIColor darkGrayColor]];
		[priceLabel setFont:HelveticaNeue(15)];
		[priceLabel setBackgroundColor:[UIColor clearColor]];
		[self addSubview:priceLabel];
		
		dueLabel = [[UILabel alloc] initWithFrame:CGRectMake(15 + (dvc_width - 30) / 2, 28, (dvc_width - 30) / 2, 28)];
		[dueLabel setTextAlignment:NSTextAlignmentRight];
		[dueLabel setTextColor:[UIColor darkGrayColor]];
		[dueLabel setFont:HelveticaNeue(14)];
		[dueLabel setBackgroundColor:[UIColor clearColor]];
		[self addSubview:dueLabel];
		
		statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(15 + (dvc_width - 30) / 2, 56, (dvc_width - 30) / 2, 28)];
		[statusLabel setTextAlignment:NSTextAlignmentRight];
		[statusLabel setTextColor:[UIColor darkGrayColor]];
		[statusLabel setFont:HelveticaNeue(15)];
		[statusLabel setBackgroundColor:[UIColor clearColor]];
		[self addSubview:statusLabel];
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
					[dueLabel setFrame:CGRectMake(dueLabel.frame.origin.x - 65, dueLabel.frame.origin.y, dueLabel.frame.size.width, dueLabel.frame.size.height)];
					[statusLabel setFrame:CGRectMake(statusLabel.frame.origin.x - 65, statusLabel.frame.origin.y, statusLabel.frame.size.width, statusLabel.frame.size.height)];
					
				}];
			}
			else if (state == UITableViewCellStateDefaultMask)
			{
				[UIView animateWithDuration:0.25 animations:^{
					
					[background setFrame:CGRectMake(background.frame.origin.x, background.frame.origin.y, background.frame.size.width + 65, background.frame.size.height)];
					[priceLabel setFrame:CGRectMake(priceLabel.frame.origin.x + 65, priceLabel.frame.origin.y, priceLabel.frame.size.width, priceLabel.frame.size.height)];
					[dueLabel setFrame:CGRectMake(dueLabel.frame.origin.x + 65, dueLabel.frame.origin.y, dueLabel.frame.size.width, dueLabel.frame.size.height)];
					[statusLabel setFrame:CGRectMake(statusLabel.frame.origin.x + 65, statusLabel.frame.origin.y, statusLabel.frame.size.width, statusLabel.frame.size.height)];
					
				}];
			}
			
		});
	}
}

-(void)loadPO:(PurchaseOrderOBJ*)sender withCellType:(kPOCellType)type
{
	switch (type)
	{
		case kPOCellTypeTop:
		{
			[background setImage:[[UIImage imageNamed:@"tableTopCellWhite.png"] stretchableImageWithLeftCapWidth:20 topCapHeight:15]];
			break;
		}
			
		case kPOCellTypeMiddle:
		{
			[background setImage:[[UIImage imageNamed:@"tableMiddleCellWhite.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10]];
			break;
		}
			
		case kPOCellTypeBottom:
		{
			[background setImage:[[UIImage imageNamed:@"tableBottomCellWhite.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10]];
			break;
		}
			
		case kPOCellTypeSingle:
		{
			[background setImage:[[UIImage imageNamed:@"tableSingleCellWhite.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10]];
			break;
		}
			
		default:
			break;
	}
	
	ClientOBJ * theClient = [sender client];
	
	[bgView setFrame:CGRectMake(0, 0, dvc_width, self.frame.size.height)];
	
	[titleLabel setText:[theClient company]];
    [clientNameLabel setText:[NSString stringWithFormat:@"%@ %@", [theClient firstName], [theClient lastName]?:@""]];
    if([sender number]) {
        [nameLabel setText:[sender number]];
    }
	[priceLabel setText:[data_manager currencyAdjustedValue:[sender total]]];
}

-(void)prepareForReuse
{
	[super prepareForReuse];
	
	[background setImage:nil];
	[titleLabel setText:@""];
	[nameLabel setText:@""];
	[priceLabel setText:@""];
	[dueLabel setText:@""];
	[statusLabel setText:@""];
}

-(void)setSelected:(BOOL)selected animated:(BOOL)animated
{
	[super setSelected:selected animated:animated];
}

-(void)resize
{
	[background setFrame:CGRectMake(10, self.frame.size.height - 84, dvc_width - 20, 84)];
    
	[titleLabel setFrame:CGRectMake(15, self.frame.size.height - 84, (dvc_width - 30) / 2, 28)];
    [clientNameLabel setFrame:CGRectMake(15, 28 + self.frame.size.height - 84, (dvc_width - 30) / 2, 28)];
	[nameLabel setFrame:CGRectMake(15, 56 + self.frame.size.height - 84, (dvc_width - 30) / 2, 28)];
    
	[priceLabel setFrame:CGRectMake(15 + (dvc_width - 30) / 2, self.frame.size.height - 84, (dvc_width - 30) / 2, 28)];
	[dueLabel setFrame:CGRectMake(15 + (dvc_width - 30) / 2, 28 + self.frame.size.height - 84, (dvc_width - 30) / 2, 28)];
	[statusLabel setFrame:CGRectMake(15 + (dvc_width - 30) / 2, 56 + self.frame.size.height - 84, (dvc_width - 30) / 2, 28)];
}

@end