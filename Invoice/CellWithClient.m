//
//  CellWithClient.m
//  Invoice
//
//  Created by XGRoup5 on 8/19/13.
//  Copyright (c) 2013 XGRoup. All rights reserved.
//

#import "CellWithClient.h"

#import "Defines.h"

@implementation CellWithClient

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString*)reuseIdentifier
{
	self = [super initWithStyle:style reuseIdentifier:nil];
	
	if (self)
	{
		[self.layer setMasksToBounds:YES];
		
		[self setBackgroundColor:[UIColor clearColor]];
		
		[self setSelectionStyle:UITableViewCellSelectionStyleNone];
		
		background = [[UIImageView alloc] initWithFrame:CGRectMake(10, 0, dvc_width - 20, 52)];
		[self addSubview:background];
		
		clientNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, (dvc_width - 40) / 2, 26)];
		[clientNameLabel setTextAlignment:NSTextAlignmentLeft];
		[clientNameLabel setTextColor:[UIColor grayColor]];
		[clientNameLabel setFont:HelveticaNeue(16)];
		[clientNameLabel setBackgroundColor:[UIColor clearColor]];
		[self addSubview:clientNameLabel];
		
		companyNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 26, (dvc_width - 40) / 2, 26)];
		[companyNameLabel setTextAlignment:NSTextAlignmentLeft];
		[companyNameLabel setTextColor:[UIColor grayColor]];
		[companyNameLabel setFont:HelveticaNeue(15)];
		[companyNameLabel setBackgroundColor:[UIColor clearColor]];
		[self addSubview:companyNameLabel];
		
		priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(dvc_width / 2, 0, (dvc_width - 40) / 2, 26)];
		[priceLabel setTextAlignment:NSTextAlignmentRight];
		[priceLabel setTextColor:[UIColor darkGrayColor]];
		[priceLabel setFont:HelveticaNeue(15)];
		[priceLabel setBackgroundColor:[UIColor clearColor]];
		[self addSubview:priceLabel];
		
		dueLabel = [[UILabel alloc] initWithFrame:CGRectMake(dvc_width / 2, 26, (dvc_width - 40) / 2, 26)];
		[dueLabel setTextAlignment:NSTextAlignmentRight];
		[dueLabel setTextColor:[UIColor darkGrayColor]];
		[dueLabel setFont:HelveticaNeue(15)];
		[dueLabel setBackgroundColor:[UIColor clearColor]];
		[self addSubview:dueLabel];
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
					
				}];
			}
			else if (state == UITableViewCellStateDefaultMask)
			{
				[UIView animateWithDuration:0.25 animations:^{
					
					[background setFrame:CGRectMake(background.frame.origin.x, background.frame.origin.y, background.frame.size.width + 65, background.frame.size.height)];
					[priceLabel setFrame:CGRectMake(priceLabel.frame.origin.x + 65, priceLabel.frame.origin.y, priceLabel.frame.size.width, priceLabel.frame.size.height)];
					[dueLabel setFrame:CGRectMake(dueLabel.frame.origin.x + 65, dueLabel.frame.origin.y, dueLabel.frame.size.width, dueLabel.frame.size.height)];
					
					
				}];
			}
			
		});
	}
}

-(void)prepareForReuse
{
	[super prepareForReuse];
	
	[background setImage:nil];
	[companyNameLabel setText:@""];
	[clientNameLabel setText:@""];
	[priceLabel setText:@""];
	[dueLabel setText:@""];
}

-(void)loadClient:(ClientOBJ*)client withType:(kClientCellType)type
{
	switch (type)
	{
		case kClientCellTypeTop:
		{
			[background setImage:[[UIImage imageNamed:@"tableTopCellWhite.png"] stretchableImageWithLeftCapWidth:20 topCapHeight:15]];
			break;
		}
			
		case kClientCellTypeMiddle:
		{
			[background setImage:[[UIImage imageNamed:@"tableMiddleCellWhite.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10]];
			break;
		}
			
		case kClientCellTypeBottom:
		{
			[background setImage:[[UIImage imageNamed:@"tableBottomCellWhite.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10]];
			break;
		}
			
		case kClientCellTypeSingle:
		{
			[background setImage:[[UIImage imageNamed:@"tableSingleCellWhite.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10]];
			break;
		}
			
		default:
			break;
	}
	
	[companyNameLabel setText:[client company]];
	[clientNameLabel setText:[NSString stringWithFormat:@"%@ %@", [client firstName], [client lastName]]];
	
	InvoiceOBJ * invoice = [data_manager nextInvoiceForClient:client];
	
	if (invoice)
	{
		[priceLabel setText:[data_manager currencyAdjustedValue:[invoice total]]];
		
		[date_formatter setDateFormat:[DELEGATE userSelectedDateFormat]];
		[dueLabel setText:[data_manager dueStringForDate:[NSDate date] andDate:[date_formatter dateFromString:[invoice dueDate]]]];
		
		if ([invoice status] == kInvoiceStatusPaid)
		{
			[dueLabel setText:@""];
		}
        
        priceLabel.hidden = NO;
        dueLabel.hidden = NO;
        
        clientNameLabel.frame = CGRectMake(20, clientNameLabel.frame.origin.y, (dvc_width - 40) / 2, 26);
        companyNameLabel.frame = CGRectMake(20, companyNameLabel.frame.origin.y, (dvc_width - 40) / 2, 26);
    } else {
        priceLabel.hidden = YES;
        dueLabel.hidden = YES;
        
        clientNameLabel.frame = CGRectMake(20, clientNameLabel.frame.origin.y, (dvc_width - 40), 26);
        companyNameLabel.frame = CGRectMake(20, companyNameLabel.frame.origin.y, (dvc_width - 40), 26);
    }
}
-(void)loadProject:(ProjectOBJ*)project withType:(kClientCellType)type
{
	switch (type)
	{
		case kClientCellTypeTop:
		{
			[background setImage:[[UIImage imageNamed:@"tableTopCellWhite.png"] stretchableImageWithLeftCapWidth:20 topCapHeight:15]];
			break;
		}
			
		case kClientCellTypeMiddle:
		{
			[background setImage:[[UIImage imageNamed:@"tableMiddleCellWhite.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10]];
			break;
		}
			
		case kClientCellTypeBottom:
		{
			[background setImage:[[UIImage imageNamed:@"tableBottomCellWhite.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10]];
			break;
		}
			
		case kClientCellTypeSingle:
		{
			[background setImage:[[UIImage imageNamed:@"tableSingleCellWhite.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10]];
			break;
		}
			
		default:
			break;
	}
	
	[companyNameLabel setText:[project projectNumber]];
	[clientNameLabel setText:[project projectName]];
}

-(void)setSelected:(BOOL)selected animated:(BOOL)animated
{
	[super setSelected:selected animated:animated];
}

-(void)resize
{
	[background setFrame:CGRectMake(10, self.frame.size.height - 52, dvc_width - 20, 52)];
	[clientNameLabel setFrame:CGRectMake(20, self.frame.size.height - 52, clientNameLabel.frame.size.width, 26)];
	[companyNameLabel setFrame:CGRectMake(20, self.frame.size.height - 26, companyNameLabel.frame.size.width, 26)];
	[priceLabel setFrame:CGRectMake(dvc_width / 2, self.frame.size.height - 52, priceLabel.frame.size.width, 26)];
	[dueLabel setFrame:CGRectMake(dvc_width / 2, self.frame.size.height - 26, dueLabel.frame.size.width, 26)];
}

@end