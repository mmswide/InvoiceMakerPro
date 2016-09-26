//
//  ProductDetailsVC.m
//  Invoice
//
//  Created by XGRoup5 on 8/19/13.
//  Copyright (c) 2013 XGRoup. All rights reserved.
//

#import "ProductDetailsVC.h"

#import "Defines.h"
#import "CreateOrEditProductVC.h"

@interface ProductDetailsVC () <ProductCreatorDelegate>

@end

@implementation ProductDetailsVC

-(id)initWithProduct:(ProductOBJ*)sender atIndex:(int)index
{
	self = [super init];
	
	if (self)
	{
		index_of_product = index;
		
		theProduct = [[ProductOBJ alloc] initWithProduct:sender];
	}
	
	return self;
}

#pragma mark - VIEW DID LOAD

-(void)viewDidLoad
{
	[super viewDidLoad];
	
	theSelfView = [[UIView alloc] initWithFrame:CGRectMake(0, statusBarHeight, dvc_width, dvc_height)];
	[theSelfView setBackgroundColor:[UIColor clearColor]];
	[self.view addSubview:theSelfView];
		
	[self.view setBackgroundColor:app_background_color];
	
	topBarView = [[TopBar alloc] initWithFrame:CGRectMake(0, 0, dvc_width, 42 + statusBarHeight) andTitle:@"Product Details"];
	[topBarView setBackgroundColor:app_bar_update_color];

	BackButton * backButton = [[BackButton alloc] initWithFrame:CGRectMake(0, 42 + statusBarHeight - 40, 70, 40) andTitle:@"Back"];
	[backButton addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
	[topBarView addSubview:backButton];
	
	UIButton * edit = [[UIButton alloc] initWithFrame:CGRectMake(dvc_width - 60, 42 + statusBarHeight - 40, 60, 40)];
	[edit setTitle:@"Edit" forState:UIControlStateNormal];
	[edit setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[edit setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
	[edit.titleLabel setFont:HelveticaNeueLight(17)];
	[edit addTarget:self action:@selector(edit:) forControlEvents:UIControlEventTouchUpInside];
	[topBarView addSubview:edit];
	
	//NAME, PRICE & DESCRIPTION
	{
		UIImageView * background = [[UIImageView alloc] initWithFrame:CGRectMake(10, 52, dvc_width - 20, 84)];
		[background setImage:[[UIImage imageNamed:@"tableSingleCellWhite.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10]];
		[theSelfView addSubview:background];
		
		nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 52, (dvc_width - 40) / 2, 42)];
		[nameLabel setText:[theProduct name]];
		[nameLabel setTextAlignment:NSTextAlignmentLeft];
		[nameLabel setTextColor:[UIColor darkGrayColor]];
		[nameLabel setFont:HelveticaNeue(16)];
		[nameLabel setBackgroundColor:[UIColor clearColor]];
		[nameLabel setNumberOfLines:2];
		[theSelfView addSubview:nameLabel];
		
		priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(dvc_width / 2, 52, (dvc_width - 40) / 2, 42)];
		[priceLabel setText:[data_manager currencyAdjustedValue:[theProduct price]]];
		[priceLabel setTextAlignment:NSTextAlignmentRight];
		[priceLabel setTextColor:[UIColor grayColor]];
		[priceLabel setFont:HelveticaNeue(15)];
		[priceLabel setBackgroundColor:[UIColor clearColor]];
		[theSelfView addSubview:priceLabel];
		
		noteLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 94, dvc_width - 40, 42)];
		[noteLabel setText:[theProduct note]];
		[noteLabel setTextAlignment:NSTextAlignmentLeft];
		[noteLabel setTextColor:[UIColor grayColor]];
		[noteLabel setFont:HelveticaNeue(15)];
		[noteLabel setBackgroundColor:[UIColor clearColor]];
		[noteLabel setNumberOfLines:2];
		[theSelfView addSubview:noteLabel];
		
//		CGSize priceSize = [data_manager sizeForString:priceLabel.text withFont:priceLabel.font constrainedToSize:CGSizeMake(MAXFLOAT, MAXFLOAT)];
		
//		[priceLabel setFrame:CGRectMake(theSelfView.frame.size.width - priceSize.width - 20, 52, priceSize.width, 42)];
//		[nameLabel setFrame:CGRectMake(20, 52, theSelfView.frame.size.width - 20 - priceLabel.frame.size.width - 30, 42)];
	}
	
	//CODE
	{
		UIImageView * background = [[UIImageView alloc] initWithFrame:CGRectMake(10, 156, dvc_width - 20, 42)];
		[background setImage:[[UIImage imageNamed:@"tableTopCellWhite.png"] stretchableImageWithLeftCapWidth:20 topCapHeight:15]];
		[theSelfView addSubview:background];
		
		UILabel * titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 156, (dvc_width - 40) / 2, 42)];
		[titleLabel setText:@"Code"];
		[titleLabel setTextAlignment:NSTextAlignmentLeft];
		[titleLabel setTextColor:[UIColor grayColor]];
		[titleLabel setFont:HelveticaNeue(16)];
		[titleLabel setBackgroundColor:[UIColor clearColor]];
		[theSelfView addSubview:titleLabel];
		
		codeLabel = [[UILabel alloc] initWithFrame:CGRectMake(dvc_width / 2, 156, (dvc_width - 40) / 2, 42)];
		[codeLabel setText:[theProduct code]];
		[codeLabel setTextAlignment:NSTextAlignmentRight];
		[codeLabel setTextColor:[UIColor darkGrayColor]];
		[codeLabel setFont:HelveticaNeue(15)];
		[codeLabel setBackgroundColor:[UIColor clearColor]];
		[theSelfView addSubview:codeLabel];
	}
	
	//TAXABLE
	{
		UIImageView * background = [[UIImageView alloc] initWithFrame:CGRectMake(10, 198, dvc_width - 20, 42)];
		[background setImage:[[UIImage imageNamed:@"tableBottomCellWhite.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10]];
		[theSelfView addSubview:background];
		
		UILabel * titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 198, (dvc_width - 40) / 2, 42)];
		[titleLabel setText:@"Taxable"];
		[titleLabel setTextAlignment:NSTextAlignmentLeft];
		[titleLabel setTextColor:[UIColor grayColor]];
		[titleLabel setFont:HelveticaNeue(16)];
		[titleLabel setBackgroundColor:[UIColor clearColor]];
		[theSelfView addSubview:titleLabel];
		
		NSString * taxableString = @"NO";
		
		if ([theProduct taxable])
			taxableString = @"YES";
		
		taxableLabel = [[UILabel alloc] initWithFrame:CGRectMake(dvc_width / 2, 198, (dvc_width - 40) / 2, 42)];
		[taxableLabel setText:taxableString];
		[taxableLabel setTextAlignment:NSTextAlignmentRight];
		[taxableLabel setTextColor:[UIColor darkGrayColor]];
		[taxableLabel setFont:HelveticaNeue(15)];
		[taxableLabel setBackgroundColor:[UIColor clearColor]];
		[theSelfView addSubview:taxableLabel];
	}
	
	[self.view addSubview:topBarView];
}

#pragma mark - FUNCTIONS

-(void)back:(UIButton*)sender
{
	[self.navigationController popViewControllerAnimated:YES];
}

-(void)edit:(UIButton*)sender
{
	CreateOrEditProductVC * vc = [[CreateOrEditProductVC alloc] initWithProduct:theProduct index:index_of_product delegate:self];
	UINavigationController * nvc = [[UINavigationController alloc] initWithRootViewController:vc];
	[nvc setNavigationBarHidden:YES];
	[self.navigationController presentViewController:nvc animated:YES completion:nil];
}

#pragma mark - PRODUCT CREATOR DELEGATE

-(void)creatorViewController:(CreateOrEditProductVC*)viewController createdObject:(ProductOBJ*)product
{
	theProduct = [[ProductOBJ alloc] initWithProduct:product];
	
	NSMutableArray * array = [[NSMutableArray alloc] initWithArray:[data_manager loadProductsArrayFromUserDefaultsAtKey:kProductsKeyForNSUserDefaults]];
	
	NSMutableArray * temp = [[NSMutableArray alloc] init];
	
	for (NSObject * obj in array)
	{
		if ([obj isKindOfClass:[ProductOBJ class]])
		{
			[temp addObject:obj];
		}
	}
	
	[sync_manager updateCloud:[theProduct contentsDictionary] andPurposeForDelete:0];
	[temp replaceObjectAtIndex:index_of_product withObject:theProduct];
	
	BOOL still_has_services = YES;
	
	while (still_has_services)
	{
		still_has_services = NO;
		
		int index = -1;
		
		for (int i = 0; i < array.count; i++)
		{
			if ([[array objectAtIndex:i] isKindOfClass:[ProductOBJ class]])
			{
				index = i;
				break;
			}
		}
		
		if (index >= 0)
		{
			still_has_services = YES;
			[array removeObjectAtIndex:index];
		}
	}
	
	[array addObjectsFromArray:temp];
	
	[data_manager saveProductsArrayToUserDefaults:array forKey:kProductsKeyForNSUserDefaults];
	
	[nameLabel setText:[theProduct name]];
	[priceLabel setText:[data_manager currencyAdjustedValue:[theProduct price]]];
	[noteLabel setText:[theProduct note]];
	[codeLabel setText:[theProduct code]];
	
	NSString * taxableString = @"NO";
	
	if ([theProduct taxable])
		taxableString = @"YES";
	
	[taxableLabel setText:taxableString];
}

-(void)editorViewController:(CreateOrEditProductVC*)viewController editedObject:(ProductOBJ*)product atIndex:(NSInteger)index
{
	theProduct = [[ProductOBJ alloc] initWithProduct:product];
	
	NSMutableArray * array = [[NSMutableArray alloc] initWithArray:[data_manager loadProductsArrayFromUserDefaultsAtKey:kProductsKeyForNSUserDefaults]];
	
	NSMutableArray * temp = [[NSMutableArray alloc] init];
	
	for (NSObject * obj in array)
	{
		if ([obj isKindOfClass:[ProductOBJ class]])
		{
			[temp addObject:obj];
		}
	}
	
	[sync_manager updateCloud:[theProduct contentsDictionary] andPurposeForDelete:0];
	[temp replaceObjectAtIndex:index_of_product withObject:theProduct];
	
	BOOL still_has_services = YES;
	
	while (still_has_services)
	{
		still_has_services = NO;
		
		int index = -1;
		
		for (int i = 0; i < array.count; i++)
		{
			if ([[array objectAtIndex:i] isKindOfClass:[ProductOBJ class]])
			{
				index = i;
				break;
			}
		}
		
		if (index >= 0)
		{
			still_has_services = YES;
			[array removeObjectAtIndex:index];
		}
	}
	
	[array addObjectsFromArray:temp];
	
	[data_manager saveProductsArrayToUserDefaults:array forKey:kProductsKeyForNSUserDefaults];
	
	[nameLabel setText:[theProduct name]];
	[priceLabel setText:[data_manager currencyAdjustedValue:[theProduct price]]];
	[noteLabel setText:[theProduct note]];
	[codeLabel setText:[theProduct code]];
	
	NSString * taxableString = @"NO";
	
	if ([theProduct taxable])
		taxableString = @"YES";
	
	[taxableLabel setText:taxableString];
}

#pragma mark - VIEW CONTROLLER FUNCTIONS

-(void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
}

@end