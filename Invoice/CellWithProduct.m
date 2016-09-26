//
//  CellWithProduct.m
//  Invoice
//
//  Created by XGRoup5 on 8/19/13.
//  Copyright (c) 2013 XGRoup. All rights reserved.
//

#import "CellWithProduct.h"

#import "Defines.h"

@implementation CellWithProduct

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString*)reuseIdentifier
{
	self = [super initWithStyle:style reuseIdentifier:nil];
	
	if (self)
	{
		[self.layer setMasksToBounds:YES];
		
		[self setBackgroundColor:[UIColor clearColor]];
		
		[self setSelectionStyle:UITableViewCellSelectionStyleNone];
		
		background = [[UIImageView alloc] initWithFrame:CGRectMake(10, 0, dvc_width - 20, 42)];
		[self addSubview:background];
		
		titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, (dvc_width - 40) / 2, 42)];
		[titleLabel setTextAlignment:NSTextAlignmentLeft];
		[titleLabel setTextColor:[UIColor grayColor]];
		[titleLabel setFont:HelveticaNeue(16)];
		[titleLabel setBackgroundColor:[UIColor clearColor]];
		[titleLabel setNumberOfLines:2];
		[self addSubview:titleLabel];
		
		if (sys_version > 5)
		{
			[titleLabel setAdjustsLetterSpacingToFitWidth:YES];
		}
		
		priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(dvc_width / 2, 0, (dvc_width - 40) / 2, 42)];
		[priceLabel setTextAlignment:NSTextAlignmentRight];
		[priceLabel setTextColor:[UIColor darkGrayColor]];
		[priceLabel setFont:HelveticaNeue(16)];
		[priceLabel setBackgroundColor:[UIColor clearColor]];
		[self addSubview:priceLabel];
	}
	
	return self;
}

-(void)prepareForReuse
{
	[super prepareForReuse];
	
	[background setImage:nil];
	[titleLabel setText:@""];
	[priceLabel setText:@""];
}

-(void)loadProduct:(ProductOBJ*)product withType:(kProductCellType)type
{
	switch (type)
	{
		case kProductCellTypeTop:
		{
			[background setImage:[[UIImage imageNamed:@"tableTopCellWhite.png"] stretchableImageWithLeftCapWidth:20 topCapHeight:15]];
			
			if (sys_version >= 7)
			{
				[background setFrame:CGRectMake(10, 0, dvc_width - 20, 42)];
			}
			else
			{
				[background setFrame:CGRectMake(10, 0, dvc_width - 20, 43)];
			}
			
			break;
		}
		
		case kProductCellTypeMiddle:
		{
			[background setImage:[[UIImage imageNamed:@"tableMiddleCellWhite.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10]];
			break;
		}
			
		case kProductCellTypeBottom:
		{
			[background setImage:[[UIImage imageNamed:@"tableBottomCellWhite.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10]];
			break;
		}
			
		case kProductCellTypeSingle:
		{
			[background setImage:[[UIImage imageNamed:@"tableSingleCellWhite.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10]];
			break;
		}
			
		default:
			break;
	}
	
	NSString * string = [NSString stringWithFormat:@"%@/%@", [data_manager currencyAdjustedValue:[product price]], [product rawUnit]];
	CGSize priceSize = [data_manager sizeForString:string withFont:priceLabel.font constrainedToSize:CGSizeMake(MAXFLOAT, MAXFLOAT)];
	
	[priceLabel setFrame:CGRectMake(dvc_width - priceSize.width - 20, self.frame.size.height - 42, priceSize.width, 42)];
	[titleLabel setFrame:CGRectMake(20, self.frame.size.height - 42, dvc_width - 20 - priceLabel.frame.size.width - 30, 42)];
	
	[titleLabel setText:[product name]];
	[priceLabel setText:string];
}

-(void)setSelected:(BOOL)selected animated:(BOOL)animated
{
	[super setSelected:selected animated:animated];
}

-(void)resize
{
	[background setFrame:CGRectMake(10, self.frame.size.height - 42, dvc_width - 20, 42)];
	CGSize priceSize = [data_manager sizeForString:priceLabel.text withFont:priceLabel.font constrainedToSize:CGSizeMake(MAXFLOAT, MAXFLOAT)];
	
	[priceLabel setFrame:CGRectMake(dvc_width - priceSize.width - 20, self.frame.size.height - 42, priceSize.width, 42)];
	[titleLabel setFrame:CGRectMake(20, self.frame.size.height - 42, dvc_width - 20 - priceLabel.frame.size.width - 30, 42)];
}

@end