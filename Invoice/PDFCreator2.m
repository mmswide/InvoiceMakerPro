//
//  PDFCreator2.m
//  Invoice
//
//  Created by XGRoup on 7/16/14.
//  Copyright (c) 2014 XGRoup. All rights reserved.
//

#import "PDFCreator2.h"

#import "Defines.h"
#import "ReceiptOBJ.h"

@implementation PDFCreator2

+ (NSString*)PDFPathFromUIView:(UIView*)aView
{
	NSString *path = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/receipts.pdf"];
	
	UIGraphicsBeginPDFContextToFile(path, CGRectZero, nil);
	
	CGContextRef pdfContext = UIGraphicsGetCurrentContext();
	
	NSInteger currentPage = 0;
	
	BOOL done = NO;
	
	do
	{
		CGRect currentPageRect = CGRectMake(0, 0, paper_size.width, paper_size.height);
		
		UIGraphicsBeginPDFPageWithInfo(currentPageRect, nil);
		
		[((UIView*)[aView.subviews objectAtIndex:currentPage]).layer renderInContext:pdfContext];
		
		if (currentPage + 1 == aView.subviews.count)
		{
			done = YES;
		}
		else
		{
			currentPage++;
		}
	}
	
	while (!done);
	
	UIGraphicsEndPDFContext();
	
	return path;
}

+(NSData*)PDFDataFromUIView:(UIView*)aView
{
	NSMutableData * pdfData = [[NSMutableData alloc] init];
	
	UIGraphicsBeginPDFContextToData(pdfData, CGRectZero, nil);
	
	CGContextRef pdfContext = UIGraphicsGetCurrentContext();
	
	NSInteger currentPage = 0;
	
	BOOL done = NO;
	
	do
	{
		
		CGRect currentPageRect = CGRectMake(0, 0, paper_size.width, paper_size.height);
		UIGraphicsBeginPDFPageWithInfo(currentPageRect, nil);
		
		[((UIView*)[aView.subviews objectAtIndex:currentPage]).layer renderInContext:pdfContext];
				
		if (currentPage + 1 == aView.subviews.count)
		{
			done = YES;
		}
		else
		{
			currentPage++;
		}
	}
	
	while (!done);
	
	aView = nil;
	
	UIGraphicsEndPDFContext();
	
	return pdfData;
}

#pragma mark - RECEIPT

+(UIView*)PDFViewForReceipts:(NSArray*)receiptsArray
{
	UIView * theView = [[UIView alloc] init];
	
	UIView * aPage = [[UIView alloc] initWithFrame:CGRectMake(0, 0, paper_size.width, paper_size.height)];
	[aPage setBackgroundColor:[UIColor whiteColor]];
	[aPage setTag:CURRENT_PAGE_TAG];
	[theView addSubview:aPage];
	
	[PDFCreator2 addTemplateImageTo:aPage];
	
	[aPage addSubview:[PDFCreator2 companyDetailsView]];
	[aPage addSubview:[PDFCreator2 detailsForReceipts]];
	
	BOOL finished = NO;
	
	int count = 0;
	float lastOriginY = paperHeightPercent(35.0);
	
	float receiptWidth = (paper_size.width - paperWidthPercent(1.5) - paperHeightPercent(1.5) - paperWidthPercent(2.0)) / 2;
	float receiptHeight = (paper_size.height - 6 * paperHeightPercent(2.0))/5;
	
	for(int i=0;i<6;i++)
	{
		if(i >= receiptsArray.count)
		{
			finished = YES;
			
			break;
		}
		
		if(count % 2 == 0)
		{
			UIView *receiptPage = [[UIView alloc] initWithFrame:CGRectMake(paperWidthPercent(1.5), lastOriginY, receiptWidth, receiptHeight)];
			receiptPage.backgroundColor = [UIColor clearColor];
			receiptPage.layer.borderColor = [UIColor lightGrayColor].CGColor;
			receiptPage.layer.borderWidth = 0.3;
			[aPage addSubview:receiptPage];
			
			[self addReceiptDetails:[receiptsArray objectAtIndex:i] forView:receiptPage];
		}
		else
		{
			UIView *receiptPage = [[UIView alloc] initWithFrame:CGRectMake(paperWidthPercent(1.5) + receiptWidth + paperWidthPercent(2.0), lastOriginY, receiptWidth, receiptHeight)];
			receiptPage.backgroundColor = [UIColor clearColor];
			receiptPage.layer.borderColor = [UIColor lightGrayColor].CGColor;
			receiptPage.layer.borderWidth = 0.3;
			[aPage addSubview:receiptPage];
			
			lastOriginY = lastOriginY + receiptHeight + paperHeightPercent(2.0);
			
			[self addReceiptDetails:[receiptsArray objectAtIndex:i] forView:receiptPage];
		}
		
		count++;
	}
	
	if(finished == NO && receiptsArray.count - 6 != 0)
	{
		UIView *aPage = [[UIView alloc] initWithFrame:CGRectMake(0, paper_size.height, paper_size.width, paper_size.height)];
		[aPage setBackgroundColor:[UIColor whiteColor]];
		[aPage setTag:CURRENT_PAGE_TAG];
		[theView addSubview:aPage];
		
		int pages = 1;
		int count = 0;
		
		float lastOriginY = paperHeightPercent(2.0);
		
		float receiptWidth = (paper_size.width - paperWidthPercent(1.5) - paperHeightPercent(1.5) - paperWidthPercent(2.0)) / 2;
		float receiptHeight = (paper_size.height - 6 * paperHeightPercent(2.0))/5;
		
		UIView *superViewPage = aPage;
		
		for(int i=0;i<receiptsArray.count - 6;i++)
		{
			if(i % 10 == 0 && i != 0)
			{
				pages++;
				
				UIView *nextPage = [[UIView alloc] initWithFrame:CGRectMake(0, paper_size.height * pages, paper_size.width, paper_size.height)];
				[nextPage setBackgroundColor:[UIColor whiteColor]];
				[nextPage setTag:CURRENT_PAGE_TAG];
				[theView addSubview:nextPage];
				
				superViewPage = nextPage;
				
				lastOriginY = paperHeightPercent(2.0);
			}
			
			if(count % 2 == 0)
			{
				UIView *receiptPage = [[UIView alloc] initWithFrame:CGRectMake(paperWidthPercent(1.5), lastOriginY, receiptWidth, receiptHeight)];
				receiptPage.backgroundColor = [UIColor clearColor];
				receiptPage.layer.borderColor = [UIColor lightGrayColor].CGColor;
				receiptPage.layer.borderWidth = 0.3;
				[superViewPage addSubview:receiptPage];
				
				[self addReceiptDetails:[receiptsArray objectAtIndex:i + 6] forView:receiptPage];
			}
			else
			{
				UIView *receiptPage = [[UIView alloc] initWithFrame:CGRectMake(paperWidthPercent(1.5) + receiptWidth + paperWidthPercent(2.0), lastOriginY, receiptWidth, receiptHeight)];
				receiptPage.backgroundColor = [UIColor clearColor];
				receiptPage.layer.borderColor = [UIColor lightGrayColor].CGColor;
				receiptPage.layer.borderWidth = 0.3;
				
				[superViewPage addSubview:receiptPage];
				
				lastOriginY = lastOriginY + receiptHeight + paperHeightPercent(2.0);
				
				[self addReceiptDetails:[receiptsArray objectAtIndex:i + 6] forView:receiptPage];
			}
			
			count++;
		}
	}
	
	NSMutableDictionary *settingsDict = [[NSMutableDictionary alloc] initWithDictionary:[CustomDefaults customObjectForKey:kSettingsKeyForNSUserDefaults]];
	NSString *imagePath = [NSHomeDirectory() stringByAppendingString:[settingsDict objectForKey:@"background_image"]];
	
	if(![imagePath isEqual:@""])
	{
		NSData *imageData = [[NSData alloc] initWithContentsOfFile:imagePath];
		
		for(int i=0;i<theView.subviews.count;i++)
		{
			UIView *aPage = [[theView subviews] objectAtIndex:i];
			
			UIImageView *backgroundImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, aPage.frame.size.width, aPage.frame.size.height)];
			backgroundImage.image = [UIImage imageWithData:imageData];
			[aPage addSubview:backgroundImage];
			
			[aPage sendSubviewToBack:backgroundImage];
		}
	}

	return theView;
}

+(UIView*)detailsForReceipts
{
	NSMutableDictionary *receiptDict = [[NSMutableDictionary alloc] initWithDictionary:[[CustomDefaults customObjectForKey:kLanguageKeyForNSUserDefaults] objectForKey:@"receipt"]];
	
	CGRect theViewFrame = CGRectMake(paper_size.width - paperWidthPercent(7.6) - paperWidthPercent(35), paperHeightPercent(8.3), paperWidthPercent(30), paperHeightPercent(16));
	
	UIView * theView = [[UIView alloc] initWithFrame:theViewFrame];
	[theView setBackgroundColor:[UIColor clearColor]];
	
	UILabel * titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, theView.frame.size.width, paperHeightPercent(5))];
	[titleLabel setText:[receiptDict objectForKey:@"Receipts"]];
	[titleLabel setTextAlignment:NSTextAlignmentLeft];
	[titleLabel setTextColor:[UIColor blackColor]];
	[titleLabel setFont:HelveticaNeueBold(paperWidthPercent(6))];
	[titleLabel setBackgroundColor:[UIColor clearColor]];
	[titleLabel setAdjustsFontSizeToFitWidth:YES];
	[theView addSubview:titleLabel];
	
	return theView;
}

+(void)addReceiptDetails:(ReceiptOBJ*)receipt forView:(UIView*)view
{
	NSMutableDictionary *receiptDict = [[NSMutableDictionary alloc] initWithDictionary:[[CustomDefaults customObjectForKey:kLanguageKeyForNSUserDefaults] objectForKey:@"receipt"]];
	
	float marginLeft = paperWidthPercent(0.5);
	
	if(![[receipt imageString] isEqual:@""] && [receipt getImage] != nil)
	{
		float receiptImageHeight = view.frame.size.height - paperWidthPercent(0.2);
		float receiptImageWidth = view.frame.size.height - paperWidthPercent(0.2);
		
		UIImageView *receiptImage = [[UIImageView alloc] initWithFrame:CGRectMake(paperWidthPercent(0.1), paperWidthPercent(0.1), receiptImageWidth, receiptImageHeight)];
		receiptImage.image = [data_manager scaleAndRotateImage:[receipt getImage] andResolution:106];
		[view addSubview:receiptImage];
		
		CGSize imageSize = receiptImage.image.size;
		CGSize newImageSize = CGSizeZero;
		
		if(imageSize.height < imageSize.width)
		{
			float height = (receiptImage.frame.size.width * imageSize.height) / imageSize.width;
			newImageSize = CGSizeMake(receiptImage.frame.size.width, height);
		}
		else
		{
			float width = (receiptImage.frame.size.height * imageSize.width) / imageSize.height;
			newImageSize = CGSizeMake(width, receiptImage.frame.size.height);
		}
		
		receiptImage.frame = CGRectMake(receiptImage.frame.origin.x, paperWidthPercent(0.1) + (receiptImageHeight - newImageSize.height) / 2, newImageSize.width,newImageSize.height);
		
		marginLeft = receiptImage.frame.size.width + paperWidthPercent(0.5);
	}
	
	UIView *labelsView = [[UIView alloc] initWithFrame:CGRectMake(marginLeft, 0, view.frame.size.width - marginLeft, 0)];
	labelsView.backgroundColor = [UIColor clearColor];
	[view addSubview:labelsView];
	
	int originY = 0;
	int maxWidth = [self calculateMaxWidth:receipt];
	
	int width = labelsView.frame.size.width - paperWidthPercent(1.0) - maxWidth;
	int originX = maxWidth + paperWidthPercent(0.5);
	
	// Title
	if(![[receipt title] isEqual:@""])
	{
		UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, originY, maxWidth, paperHeightPercent(1.5))];
		[titleLabel setText:[NSString stringWithFormat:@"%@:",[receiptDict objectForKey:@"Title"]]];
		[titleLabel setTextAlignment:NSTextAlignmentRight];
		[titleLabel setTextColor:[UIColor darkGrayColor]];
		[titleLabel setFont:HelveticaNeue(paperWidthPercent(1.2))];
		[titleLabel setBackgroundColor:[UIColor clearColor]];
		[labelsView addSubview:titleLabel];
		
		UILabel *categoryLabel = [[UILabel alloc] initWithFrame:CGRectMake(originX, originY, width, paperHeightPercent(1.5))];
		[categoryLabel setText:[NSString stringWithFormat:@"%@",[receipt title]]];
		[categoryLabel setTextAlignment:NSTextAlignmentLeft];
		[categoryLabel setTextColor:[UIColor grayColor]];
		[categoryLabel setFont:HelveticaNeue(paperWidthPercent(1.2))];
		[categoryLabel setBackgroundColor:[UIColor clearColor]];
		[labelsView addSubview:categoryLabel];
		
		originY += paperHeightPercent(1.5);
	}
	
	// Number
	{
		UILabel *numberLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, originY, maxWidth, paperHeightPercent(1.5))];
		[numberLabel setText:[NSString stringWithFormat:@"%@:",[receiptDict objectForKey:@"Number"]]];
		[numberLabel setTextAlignment:NSTextAlignmentRight];
		[numberLabel setTextColor:[UIColor darkGrayColor]];
		[numberLabel setFont:HelveticaNeue(paperWidthPercent(1.2))];
		[numberLabel setBackgroundColor:[UIColor clearColor]];
		[labelsView addSubview:numberLabel];
		
		UILabel *categoryLabel = [[UILabel alloc] initWithFrame:CGRectMake(originX, originY, width, paperHeightPercent(1.5))];
		[categoryLabel setText:[NSString stringWithFormat:@"%@",[receipt number]]];
		[categoryLabel setTextAlignment:NSTextAlignmentLeft];
		[categoryLabel setTextColor:[UIColor grayColor]];
		[categoryLabel setFont:HelveticaNeue(paperWidthPercent(1.2))];
		[categoryLabel setBackgroundColor:[UIColor clearColor]];
		[labelsView addSubview:categoryLabel];
		
		originY += paperHeightPercent(1.5);
	}
	
	// Category
	if(![[receipt category] isEqual:@""])
	{
		UILabel *categoryLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, originY, maxWidth, paperHeightPercent(1.5))];
		[categoryLabel setText:[NSString stringWithFormat:@"%@:",[receiptDict objectForKey:@"Category"]]];
		[categoryLabel setTextAlignment:NSTextAlignmentRight];
		[categoryLabel setTextColor:[UIColor darkGrayColor]];
		[categoryLabel setFont:HelveticaNeue(paperWidthPercent(1.2))];
		[categoryLabel setBackgroundColor:[UIColor clearColor]];
		[labelsView addSubview:categoryLabel];
		
		UILabel *categoryValueLabel = [[UILabel alloc] initWithFrame:CGRectMake(originX, originY, width, paperHeightPercent(1.5))];
		[categoryValueLabel setText:[NSString stringWithFormat:@"%@",[receipt category]]];
		[categoryValueLabel setTextAlignment:NSTextAlignmentLeft];
		[categoryValueLabel setTextColor:[UIColor grayColor]];
		[categoryValueLabel setFont:HelveticaNeue(paperWidthPercent(1.2))];
		[categoryValueLabel setBackgroundColor:[UIColor clearColor]];
		[labelsView addSubview:categoryValueLabel];
		
		originY += paperHeightPercent(1.5);
	}
	
	// Project Number
	if(![[[receipt project] projectNumber] isEqual:@""])
	{
		UILabel *projectLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, originY, maxWidth, paperHeightPercent(1.5))];
		[projectLabel setText:[NSString stringWithFormat:@"%@:",[receiptDict objectForKey:@"Project No"]]];
		[projectLabel setTextAlignment:NSTextAlignmentRight];
		[projectLabel setTextColor:[UIColor darkGrayColor]];
		[projectLabel setFont:HelveticaNeue(paperWidthPercent(1.2))];
		[projectLabel setBackgroundColor:[UIColor clearColor]];
		[labelsView addSubview:projectLabel];
		
		UILabel *categoryLabel = [[UILabel alloc] initWithFrame:CGRectMake(originX, originY, width, paperHeightPercent(1.5))];
		[categoryLabel setText:[NSString stringWithFormat:@"%@",[[receipt project] projectNumber]]];
		[categoryLabel setTextAlignment:NSTextAlignmentLeft];
		[categoryLabel setTextColor:[UIColor grayColor]];
		[categoryLabel setFont:HelveticaNeue(paperWidthPercent(1.2))];
		[categoryLabel setBackgroundColor:[UIColor clearColor]];
		[labelsView addSubview:categoryLabel];
		
		originY += paperHeightPercent(1.5);
	}
	
	// Client
	if(![[[receipt client] firstName] isEqual:@""] || ![[[receipt client] lastName] isEqual:@""])
	{
		UILabel *vendorLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, originY, maxWidth, paperHeightPercent(1.5))];
		[vendorLabel setText:[NSString stringWithFormat:@"%@:",[receiptDict objectForKey:@"Vendor"]]];
		[vendorLabel setTextAlignment:NSTextAlignmentRight];
		[vendorLabel setTextColor:[UIColor darkGrayColor]];
		[vendorLabel setFont:HelveticaNeue(paperWidthPercent(1.2))];
		[vendorLabel setBackgroundColor:[UIColor clearColor]];
		[labelsView addSubview:vendorLabel];
		
		NSString *vendorName = [[receipt client] firstName];
		
		if([vendorName isEqual:@""])
			vendorName = [[receipt client] lastName];
		else
			vendorName = [NSString stringWithFormat:@"%@ %@",vendorName,[[receipt client] lastName]];
		
		UILabel *categoryLabel = [[UILabel alloc] initWithFrame:CGRectMake(originX, originY, width, paperHeightPercent(1.5))];
		[categoryLabel setText:[NSString stringWithFormat:@"%@",vendorName]];
		[categoryLabel setTextAlignment:NSTextAlignmentLeft];
		[categoryLabel setTextColor:[UIColor grayColor]];
		[categoryLabel setFont:HelveticaNeue(paperWidthPercent(1.2))];
		[categoryLabel setBackgroundColor:[UIColor clearColor]];
		[labelsView addSubview:categoryLabel];
		
		originY += paperHeightPercent(1.5);
	}
	
	// Date
	{
		UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, originY, maxWidth, paperHeightPercent(1.5))];
		[dateLabel setText:[NSString stringWithFormat:@"%@:",[receiptDict objectForKey:@"Date"]]];
		[dateLabel setTextAlignment:NSTextAlignmentRight];
		[dateLabel setTextColor:[UIColor darkGrayColor]];
		[dateLabel setFont:HelveticaNeue(paperWidthPercent(1.2))];
		[dateLabel setBackgroundColor:[UIColor clearColor]];
		[labelsView addSubview:dateLabel];
		
		[date_formatter setDateFormat:[DELEGATE userSelectedDateFormat]];
		
		UILabel *categoryLabel = [[UILabel alloc] initWithFrame:CGRectMake(originX, originY, width, paperHeightPercent(1.5))];
		[categoryLabel setText:[NSString stringWithFormat:@"%@",[date_formatter stringFromDate:[receipt date]]]];
		[categoryLabel setTextAlignment:NSTextAlignmentLeft];
		[categoryLabel setTextColor:[UIColor grayColor]];
		[categoryLabel setFont:HelveticaNeue(paperWidthPercent(1.2))];
		[categoryLabel setBackgroundColor:[UIColor clearColor]];
		[labelsView addSubview:categoryLabel];
		
		originY += paperHeightPercent(1.5);
	}
	
	// Total
	if([receipt getTotal] != 0)
	{
		UILabel *totalLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, originY, maxWidth, paperHeightPercent(1.5))];
		[totalLabel setText:[NSString stringWithFormat:@"%@:",[receiptDict objectForKey:@"Total"]]];
		[totalLabel setTextAlignment:NSTextAlignmentRight];
		[totalLabel setTextColor:[UIColor darkGrayColor]];
		[totalLabel setFont:HelveticaNeue(paperWidthPercent(1.2))];
		[totalLabel setBackgroundColor:[UIColor clearColor]];
		[labelsView addSubview:totalLabel];
		
		UILabel *categoryLabel = [[UILabel alloc] initWithFrame:CGRectMake(originX, originY, width, paperHeightPercent(1.5))];
		[categoryLabel setText:[data_manager currencyAdjustedValue:[receipt getTotal] forSign:[receipt sign]]];
		[categoryLabel setTextAlignment:NSTextAlignmentLeft];
		[categoryLabel setTextColor:[UIColor grayColor]];
		[categoryLabel setFont:HelveticaNeue(paperWidthPercent(1.2))];
		[categoryLabel setBackgroundColor:[UIColor clearColor]];
		[labelsView addSubview:categoryLabel];
		
		originY += paperHeightPercent(1.5);
	}
	
	// Tax1 Percentage
	if([receipt tax1Percentage] != 0)
	{
		UILabel *tax1Label = [[UILabel alloc] initWithFrame:CGRectMake(0, originY, maxWidth, paperHeightPercent(1.5))];
		[tax1Label setText:[NSString stringWithFormat:@"%@ (%@%c):",[receipt tax1Name],[data_manager valueAdjusted:[receipt tax1ShowValue]],'%']];
		[tax1Label setTextAlignment:NSTextAlignmentRight];
		[tax1Label setTextColor:[UIColor darkGrayColor]];
		[tax1Label setFont:HelveticaNeue(paperWidthPercent(1.2))];
		[tax1Label setBackgroundColor:[UIColor clearColor]];
		[labelsView addSubview:tax1Label];
		
		UILabel *categoryLabel = [[UILabel alloc] initWithFrame:CGRectMake(originX, originY, width, paperHeightPercent(1.5))];
		[categoryLabel setText:[data_manager currencyAdjustedValue:[receipt tax1Percentage] forSign:[receipt sign]]];
		[categoryLabel setTextAlignment:NSTextAlignmentLeft];
		[categoryLabel setTextColor:[UIColor grayColor]];
		[categoryLabel setFont:HelveticaNeue(paperWidthPercent(1.2))];
		[categoryLabel setBackgroundColor:[UIColor clearColor]];
		[labelsView addSubview:categoryLabel];
		
		originY += paperHeightPercent(1.5);
	}
	
	// Tax2 Percentage
	if([receipt tax2Percentage] != 0)
	{
		UILabel *tax2Label = [[UILabel alloc] initWithFrame:CGRectMake(0, originY, maxWidth, paperHeightPercent(1.5))];
		[tax2Label setText:[NSString stringWithFormat:@"%@ (%@%c):",[receipt tax2Name],[data_manager valueAdjusted:[receipt tax2ShowValue]],'%']];
		[tax2Label setTextAlignment:NSTextAlignmentRight];
		[tax2Label setTextColor:[UIColor darkGrayColor]];
		[tax2Label setFont:HelveticaNeue(paperWidthPercent(1.2))];
		[tax2Label setBackgroundColor:[UIColor clearColor]];
		[labelsView addSubview:tax2Label];
		
		UILabel *categoryLabel = [[UILabel alloc] initWithFrame:CGRectMake(originX, originY, width, paperHeightPercent(1.5))];
		[categoryLabel setText:[data_manager currencyAdjustedValue:[receipt tax2Percentage] forSign:[receipt sign]]];
		[categoryLabel setTextAlignment:NSTextAlignmentLeft];
		[categoryLabel setTextColor:[UIColor grayColor]];
		[categoryLabel setFont:HelveticaNeue(paperWidthPercent(1.2))];
		[categoryLabel setBackgroundColor:[UIColor clearColor]];
		[labelsView addSubview:categoryLabel];
		
		originY += paperHeightPercent(1.5);
	}
	
	if(![[receipt receiptDescription] isEqual:@""])
	{
		originY += paperHeightPercent(0.15);
		
		CGSize mySize = [data_manager sizeForString:[NSString stringWithFormat:@"%@:",[receiptDict objectForKey:@"Description"]] withFont:HelveticaNeue(paperWidthPercent(1.5)) constrainedToSize:CGSizeMake(width, 1000)];
		
		UILabel *descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, originY, maxWidth, mySize.height)];
		[descriptionLabel setText:[NSString stringWithFormat:@"%@:",[receiptDict objectForKey:@"Description"]]];
		[descriptionLabel setTextAlignment:NSTextAlignmentRight];
		[descriptionLabel setTextColor:[UIColor darkGrayColor]];
		[descriptionLabel setFont:HelveticaNeue(paperWidthPercent(1.2))];
		[descriptionLabel setBackgroundColor:[UIColor clearColor]];
		[labelsView addSubview:descriptionLabel];
		
		CGSize descSize = [data_manager sizeForString:[receipt receiptDescription] withFont:HelveticaNeue(paperWidthPercent(1.5)) constrainedToSize:CGSizeMake(width, 100000)];
		
		int totalHeight = view.frame.size.height - originY;
		
		if(descSize.height > totalHeight)
			descSize.height = totalHeight - paperHeightPercent(0.5);
		
		descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(originX, originY, width, descSize.height)];
		[descriptionLabel setText:[receipt receiptDescription]];
		descriptionLabel.numberOfLines = 100;
		descriptionLabel.lineBreakMode = NSLineBreakByWordWrapping;
		[descriptionLabel setTextAlignment:NSTextAlignmentLeft];
		[descriptionLabel setTextColor:[UIColor grayColor]];
		[descriptionLabel setFont:HelveticaNeue(paperWidthPercent(1.2))];
		[descriptionLabel setBackgroundColor:[UIColor clearColor]];
		[labelsView addSubview:descriptionLabel];
		
		originY += descSize.height;
	}
	
	[labelsView setFrame:CGRectMake(labelsView.frame.origin.x, labelsView.frame.origin.y + (view.frame.size.height - originY) / 2, labelsView.frame.size.width, originY)];
}

+(int)calculateMaxWidth:(ReceiptOBJ*)receipt
{
	NSMutableDictionary *receiptDict = [[NSMutableDictionary alloc] initWithDictionary:[[CustomDefaults customObjectForKey:kLanguageKeyForNSUserDefaults] objectForKey:@"receipt"]];
	
	int maxWidth = 0;
	
	if(![[receipt title] isEqual:@""])
	{
		CGSize size = [data_manager sizeForString:[NSString stringWithFormat:@"%@:",[receiptDict objectForKey:@"Title"]] withFont:HelveticaNeue(paperWidthPercent(1.2)) constrainedToSize:CGSizeMake(100000, 100)];
		
		if(size.width > maxWidth)
			maxWidth = size.width;
	}
	
	CGSize size = [data_manager sizeForString:[NSString stringWithFormat:@"%@:",[receiptDict objectForKey:@"Number"]] withFont:HelveticaNeue(paperWidthPercent(1.2)) constrainedToSize:CGSizeMake(100000, 100)];
	
	if(size.width > maxWidth)
		maxWidth = size.width;
	
	if(![[receipt category] isEqual:@""])
	{
		CGSize size = [data_manager sizeForString:[NSString stringWithFormat:@"%@:",[receiptDict objectForKey:@"Category"]] withFont:HelveticaNeue(paperWidthPercent(1.2)) constrainedToSize:CGSizeMake(100000, 100)];
		
		if(size.width > maxWidth)
			maxWidth = size.width;
	}
	
	if(![[[receipt project] projectNumber] isEqual:@""])
	{
		CGSize size = [data_manager sizeForString:[NSString stringWithFormat:@"%@:",[receiptDict objectForKey:@"Project No"]] withFont:HelveticaNeue(paperWidthPercent(1.2)) constrainedToSize:CGSizeMake(100000, 100)];
		
		if(size.width > maxWidth)
			maxWidth = size.width;
	}
	
	if(![[[receipt client] firstName] isEqual:@""] || ![[[receipt client] lastName] isEqual:@""])
	{
		CGSize size = [data_manager sizeForString:[NSString stringWithFormat:@"%@:",[receiptDict objectForKey:@"Vendor"]] withFont:HelveticaNeue(paperWidthPercent(1.2)) constrainedToSize:CGSizeMake(100000, 100)];
		
		if(size.width > maxWidth)
			maxWidth = size.width;
	}
	
	size = [data_manager sizeForString:[NSString stringWithFormat:@"%@:",[receiptDict objectForKey:@"Date"]] withFont:HelveticaNeue(paperWidthPercent(1.2)) constrainedToSize:CGSizeMake(100000, 100)];
	
	if(size.width > maxWidth)
		maxWidth = size.width;
	
	if([receipt getTotal] != 0)
	{
		CGSize size = [data_manager sizeForString:[NSString stringWithFormat:@"%@:",[receiptDict objectForKey:@"Total"]] withFont:HelveticaNeue(paperWidthPercent(1.2)) constrainedToSize:CGSizeMake(100000, 100)];
		
		if(size.width > maxWidth)
			maxWidth = size.width;
	}
	
	if([receipt tax1Percentage] != 0)
	{
		CGSize size = [data_manager sizeForString:[NSString stringWithFormat:@"%@ (%@%c):",[receipt tax1Name],[data_manager valueAdjusted:[receipt tax1Percentage]],'%'] withFont:HelveticaNeue(paperWidthPercent(1.2)) constrainedToSize:CGSizeMake(100000, 100)];
		
		if(size.width > maxWidth)
			maxWidth = size.width;
	}
	
	if([receipt tax2Percentage] != 0)
	{
		CGSize size = [data_manager sizeForString:[NSString stringWithFormat:@"%@ (%@%c):",[receipt tax2Name],[data_manager valueAdjusted:[receipt tax2Percentage]],'%'] withFont:HelveticaNeue(paperWidthPercent(1.2)) constrainedToSize:CGSizeMake(100000, 100)];
		
		if(size.width > maxWidth)
			maxWidth = size.width;
	}
	
	if(![[receipt receiptDescription] isEqual:@""])
	{
		CGSize size = [data_manager sizeForString:[NSString stringWithFormat:@"%@:",[receiptDict objectForKey:@"Description"]] withFont:HelveticaNeue(paperWidthPercent(1.2)) constrainedToSize:CGSizeMake(100000, 100)];
		
		if(size.width > maxWidth)
			maxWidth = size.width;
	}
	
	return maxWidth + paperWidthPercent(0.5);
}

#pragma mark - TIMESHEET

+(UIView*)PDFViewFromTimesheet:(TimeSheetOBJ*)timesheet
{
	NSMutableDictionary *timesheetDict = [[NSMutableDictionary alloc] initWithDictionary:[[CustomDefaults customObjectForKey:kLanguageKeyForNSUserDefaults] objectForKey:@"timesheet"]];
	
	UIView * theView = [[UIView alloc] init];
	[theView setBackgroundColor:[UIColor darkGrayColor]];
	
	UIView * aPage = [[UIView alloc] initWithFrame:CGRectMake(0, 0, paper_size.width, paper_size.height)];
	[aPage setBackgroundColor:[UIColor whiteColor]];
	[aPage setTag:CURRENT_PAGE_TAG];
	[theView addSubview:aPage];
	
	UILabel * noteLabel = [[UILabel alloc] initWithFrame:CGRectMake(paperWidthPercent(7.6), paperHeightPercent(92), paper_size.width - paperWidthPercent(15.2), paperHeightPercent(6))];
	[noteLabel setBackgroundColor:[UIColor clearColor]];
	[noteLabel setText:[timesheet note]];
	[noteLabel setTextAlignment:NSTextAlignmentCenter];
	[noteLabel setTextColor:[UIColor darkGrayColor]];
	[noteLabel setFont:HelveticaNeue(paperWidthPercent(2))];
	[noteLabel setNumberOfLines:3];
	[noteLabel setTag:123];
	[aPage addSubview:noteLabel];
	
	[self addTemplateImageTo:aPage];
	
	[aPage addSubview:[PDFCreator2 companyDetailsView]];
	[aPage addSubview:[PDFCreator2 detailsForTimesheet:timesheet]];
	
	UIView * billingAddress = [PDFCreator2 viewFromAddress:[[timesheet client] billingAddress] withTitle:[NSString stringWithFormat:@"%@:",[timesheetDict objectForKey:@"Timesheet to"]]
								 companyName:[[timesheet client] company]
								customerName:[NSString stringWithFormat:@"%@ %@", [[timesheet client] firstName], [[timesheet client] lastName]]];
	
	[billingAddress setFrame:CGRectMake(paperWidthPercent(7.6), paperHeightPercent(29.3), billingAddress.frame.size.width, billingAddress.frame.size.height)];
	[aPage addSubview:billingAddress];
	
	if ([[timesheet client] shippingAddress].fullStringRepresentation.length > 0)
	{
		UIView * shippingAddress = [PDFCreator2 viewFromAddress:[[timesheet client] shippingAddress] withTitle:[NSString stringWithFormat:@"%@:",[timesheetDict objectForKey:@"Ship to"]]
									  companyName:[[timesheet client] company]
									 customerName:[NSString stringWithFormat:@"%@ %@", [[timesheet client] firstName], [[timesheet client] lastName]]];
		
		[shippingAddress setFrame:CGRectMake(paper_size.width - paperWidthPercent(7.6) - shippingAddress.frame.size.width, paperHeightPercent(29.3), billingAddress.frame.size.width, billingAddress.frame.size.height)];
		[aPage addSubview:shippingAddress];
	}
	
	BOOL has_discount = NO;
	
	for(int i=0;i<timesheet.services.count;i++)
	{
		ServiceTimeOBJ *time = [timesheet serviceTimeAtIndex:i];
		ProductOBJ *product = [time product];
		
		if([product discount] > 0.0f)
		{
			has_discount = YES;
			break;
		}
	}
	
	[aPage addSubview:[PDFCreator2 headerViewWithY:paperHeightPercent(43) hasDiscount:has_discount]];
	
	UIImage * rightSignature = [timesheet rightSignature];
	UIImage * leftSignature = [timesheet leftSignature];
	
	BOOL hasSignature = NO;
	
	if (rightSignature || leftSignature)
	{
		hasSignature = YES;
	}
	
	if (!hasSignature)
	{
		for (UIView * temp in aPage.subviews)
		{
			if (![temp isKindOfClass:[UIImageView class]] && temp.tag != 123)
			{
				[temp setFrame:CGRectMake(temp.frame.origin.x, temp.frame.origin.y + paperWidthPercent(10), temp.frame.size.width, temp.frame.size.height)];
			}
		}
	}
	
	for(int i=0;i<timesheet.services.count;i++)
	{
		ServiceTimeOBJ *time = [timesheet serviceTimeAtIndex:i];
		[PDFCreator2 addObject:[time dictionaryRepresentation] toView:theView];
	}
	
	UIView * currentPage = [PDFCreator2 currentPageFrom:theView];
	UIView * latestView = [currentPage.subviews lastObject];
	CGFloat last_Y = latestView.frame.origin.y + latestView.frame.size.height;
	
	if (last_Y < paperHeightPercent(65))
	{
		CGFloat difference = paperHeightPercent(65) - last_Y;
		int count = (int)difference / paperHeightPercent(1.5);
		
		for (int i = 0; i < count; i++)
		{
			[PDFCreator2 addObject:nil toView:theView];
		}
	}
	
	latestView = [currentPage.subviews lastObject];
	UIView * lineBottom = [[UIView alloc] initWithFrame:CGRectMake(0, latestView.frame.size.height - paperHeightPercent(0.05), latestView.frame.size.width, paperHeightPercent(0.05))];
	[lineBottom setBackgroundColor:[UIColor blackColor]];
	[latestView addSubview:lineBottom];
	
	aPage = [PDFCreator2 currentPageFrom:theView];
	
	[PDFCreator2 statisticsPartForTimesheet:timesheet inView:theView];
	
	aPage = [PDFCreator2 currentPageFrom:theView];
	
	if ([timesheet bigNote].length > 0)
	{
		[aPage setTag:0];
		
		aPage = [[UIView alloc] initWithFrame:CGRectMake(0, theView.subviews.count * (paper_size.height + paperHeightPercent(1)), paper_size.width, paper_size.height)];
		[aPage setBackgroundColor:[UIColor whiteColor]];
		[aPage setTag:CURRENT_PAGE_TAG];
		[theView addSubview:aPage];
		
		[PDFCreator2 addTemplateImageTo:aPage];
		
		CGFloat last_Y = paperHeightPercent(8.3);
		
		CGSize maxSize = CGSizeMake(paper_size.width - paperWidthPercent(15.2), paper_size.height);
		CGSize size = [data_manager sizeForString:[timesheet bigNote] withFont:HelveticaNeue(paperWidthPercent(2)) constrainedToSize:maxSize];
		
		UILabel * otherNotes = [[UILabel alloc] initWithFrame:CGRectMake(paperWidthPercent(7.6), last_Y, paper_size.width - paperWidthPercent(15.2), size.height)];
		[otherNotes setText:[timesheet bigNote]];
		[otherNotes setTextAlignment:NSTextAlignmentLeft];
		[otherNotes setTextColor:[UIColor darkGrayColor]];
		[otherNotes setFont:HelveticaNeue(paperWidthPercent(2))];
		[otherNotes setNumberOfLines:0];
		[otherNotes setBackgroundColor:[UIColor clearColor]];
		[aPage addSubview:otherNotes];
	}
	
	[theView setFrame:CGRectMake(0, 0, paper_size.width, aPage.frame.origin.y + aPage.frame.size.height)];
	
	NSMutableDictionary *settingsDict = [[NSMutableDictionary alloc] initWithDictionary:[CustomDefaults customObjectForKey:kSettingsKeyForNSUserDefaults]];
	NSString *imagePath = [NSHomeDirectory() stringByAppendingString:[settingsDict objectForKey:@"background_image"]];
	
	if(![imagePath isEqual:@""])
	{
		NSData *imageData = [[NSData alloc] initWithContentsOfFile:imagePath];
		
		for(int i=0;i<theView.subviews.count;i++)
		{
			UIView *aPage = [[theView subviews] objectAtIndex:i];
			
			UIImageView *backgroundImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, aPage.frame.size.width, aPage.frame.size.height)];
			backgroundImage.image = [UIImage imageWithData:imageData];
			[aPage addSubview:backgroundImage];
			
			[aPage sendSubviewToBack:backgroundImage];
		}
	}

	return theView;
}

+(UIView*)detailsForTimesheet:(TimeSheetOBJ*)timesheet
{
	NSMutableDictionary *timesheetDict = [[NSMutableDictionary alloc] initWithDictionary:[[CustomDefaults customObjectForKey:kLanguageKeyForNSUserDefaults] objectForKey:@"timesheet"]];
	
	CGRect theViewFrame = ([[[timesheet project] projectNumber] isEqual:@""]) ? CGRectMake(paper_size.width - paperWidthPercent(7.6) - paperWidthPercent(35), paperHeightPercent(8.3), paperWidthPercent(29), paperHeightPercent(16)) :
	CGRectMake(paper_size.width - paperWidthPercent(7.6) - paperWidthPercent(35), paperHeightPercent(8.3), paperWidthPercent(36), paperHeightPercent(20));
	
	UIView * theView = [[UIView alloc] initWithFrame:theViewFrame];
	[theView setBackgroundColor:[UIColor clearColor]];
	
	UILabel * titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, theView.frame.size.width, paperHeightPercent(5))];
	[titleLabel setText:[timesheet title]];
	[titleLabel setTextAlignment:NSTextAlignmentLeft];
	[titleLabel setTextColor:[UIColor blackColor]];
	[titleLabel setFont:HelveticaNeueBold(paperWidthPercent(6))];
	[titleLabel setBackgroundColor:[UIColor clearColor]];
	[titleLabel setAdjustsFontSizeToFitWidth:YES];
	[theView addSubview:titleLabel];
	
	UILabel * invoiceNumber = [[UILabel alloc] initWithFrame:CGRectMake(0, titleLabel.frame.origin.y + titleLabel.frame.size.height + paperHeightPercent(4), (theView.frame.size.width - paperWidthPercent(7.6)), paperHeightPercent(2))];
	[invoiceNumber setText:[NSString stringWithFormat:@"%@:",[timesheetDict objectForKey:@"Timesheet No"]]];
	[invoiceNumber setTextAlignment:NSTextAlignmentLeft];
	[invoiceNumber setTextColor:[UIColor darkGrayColor]];
	[invoiceNumber setFont:HelveticaNeue(paperWidthPercent(2))];
	[invoiceNumber setBackgroundColor:[UIColor clearColor]];
	[invoiceNumber setAdjustsFontSizeToFitWidth:YES];
	[theView addSubview:invoiceNumber];
	
	int additional = (dvc_height > 568) ? 8 : 4;
	
	UILabel * invoiceNumberValue = [[UILabel alloc] initWithFrame:CGRectMake(invoiceNumber.frame.size.width / 2 + additional, invoiceNumber.frame.origin.y, invoiceNumber.frame.size.width / 2 + additional, paperHeightPercent(2))];
	[invoiceNumberValue setText:[timesheet number]];
	[invoiceNumberValue setTextAlignment:NSTextAlignmentRight];
	[invoiceNumberValue setTextColor:[UIColor darkGrayColor]];
	[invoiceNumberValue setFont:HelveticaNeue(paperWidthPercent(2))];
	[invoiceNumberValue setBackgroundColor:[UIColor clearColor]];
	[invoiceNumberValue setAdjustsFontSizeToFitWidth:YES];
	[theView addSubview:invoiceNumberValue];
	
	UILabel * invoiceDate = [[UILabel alloc] initWithFrame:CGRectMake(invoiceNumber.frame.origin.x, invoiceNumber.frame.origin.y + invoiceNumber.frame.size.height, invoiceNumber.frame.size.width / 2 + additional, paperHeightPercent(2))];
	[invoiceDate setText:[NSString stringWithFormat:@"%@:",[timesheetDict objectForKey:@"Timesheet date"]]];
	[invoiceDate setTextAlignment:NSTextAlignmentLeft];
	[invoiceDate setTextColor:[UIColor darkGrayColor]];
	[invoiceDate setFont:HelveticaNeue(paperWidthPercent(2))];
	[invoiceDate setBackgroundColor:[UIColor clearColor]];
	[invoiceDate setAdjustsFontSizeToFitWidth:YES];
	[theView addSubview:invoiceDate];
	
	[date_formatter setDateFormat:[DELEGATE userSelectedDateFormat]];
	
	UILabel * dateText = [[UILabel alloc] initWithFrame:CGRectMake(invoiceDate.frame.size.width, invoiceDate.frame.origin.y, invoiceDate.frame.size.width, paperHeightPercent(2))];
	[dateText setText:[date_formatter stringFromDate:[timesheet date]]];
	[dateText setTextAlignment:NSTextAlignmentRight];
	[dateText setTextColor:[UIColor darkGrayColor]];
	[dateText setFont:HelveticaNeue(paperWidthPercent(2))];
	[dateText setAdjustsFontSizeToFitWidth:YES];
	[theView addSubview:dateText];
	
	if(![[[timesheet project] projectName] isEqual:@""])
	{
		UILabel * invoiceProjectName = [[UILabel alloc] initWithFrame:CGRectMake(0, invoiceDate.frame.origin.y + paperHeightPercent(2), invoiceDate.frame.size.width, paperHeightPercent(2))];
		[invoiceProjectName setText:[NSString stringWithFormat:@"%@:",[timesheetDict objectForKey:@"Project Name"]]];
		[invoiceProjectName setTextAlignment:NSTextAlignmentLeft];
		[invoiceProjectName setTextColor:[UIColor darkGrayColor]];
		[invoiceProjectName setFont:HelveticaNeue(paperWidthPercent(2))];
		[invoiceProjectName setBackgroundColor:[UIColor clearColor]];
		[invoiceProjectName setAdjustsFontSizeToFitWidth:YES];
		[theView addSubview:invoiceProjectName];
		
		UILabel * projectName = [[UILabel alloc] initWithFrame:CGRectMake(invoiceProjectName.frame.size.width, invoiceProjectName.frame.origin.y, invoiceProjectName.frame.size.width, paperHeightPercent(2))];
		[projectName setText:[[timesheet project] projectName]];
		[projectName setTextAlignment:NSTextAlignmentRight];
		[projectName setTextColor:[UIColor darkGrayColor]];
		[projectName setFont:HelveticaNeue(paperWidthPercent(2))];
		[projectName setBackgroundColor:[UIColor clearColor]];
		[projectName setAdjustsFontSizeToFitWidth:YES];
		[theView addSubview:projectName];
		
		UILabel * invoiceProjectNumber = [[UILabel alloc] initWithFrame:CGRectMake(0, invoiceProjectName.frame.origin.y + paperHeightPercent(2), invoiceProjectName.frame.size.width, paperHeightPercent(2))];
		[invoiceProjectNumber setText:[NSString stringWithFormat:@"%@:",[timesheetDict objectForKey:@"Project No"]]];
		[invoiceProjectNumber setTextAlignment:NSTextAlignmentLeft];
		[invoiceProjectNumber setTextColor:[UIColor darkGrayColor]];
		[invoiceProjectNumber setFont:HelveticaNeue(paperWidthPercent(2))];
		[invoiceProjectNumber setBackgroundColor:[UIColor clearColor]];
		[invoiceProjectNumber setAdjustsFontSizeToFitWidth:YES];
		[theView addSubview:invoiceProjectNumber];
		
		UILabel * projectNumber = [[UILabel alloc] initWithFrame:CGRectMake(invoiceProjectNumber.frame.size.width, invoiceProjectNumber.frame.origin.y, invoiceProjectNumber.frame.size.width, paperHeightPercent(2))];
		[projectNumber setText:[[timesheet project] projectNumber]];
		[projectNumber setTextAlignment:NSTextAlignmentRight];
		[projectNumber setTextColor:[UIColor darkGrayColor]];
		[projectNumber setFont:HelveticaNeue(paperWidthPercent(2))];
		[projectNumber setBackgroundColor:[UIColor clearColor]];
		[projectNumber setAdjustsFontSizeToFitWidth:YES];
		[theView addSubview:projectNumber];
	}
	
	return theView;
}

+(void)statisticsPartForTimesheet:(TimeSheetOBJ*)timesheet inView:(UIView*)view
{
	NSMutableDictionary *timesheetDict = [[NSMutableDictionary alloc] initWithDictionary:[[CustomDefaults customObjectForKey:kLanguageKeyForNSUserDefaults] objectForKey:@"timesheet"]];
	
	UIView * currentPage = [PDFCreator currentPageFrom:view];
	UIView * latestView = [currentPage.subviews lastObject];
	
	for (UIView * temp in currentPage.subviews)
	{
		if (temp.tag != 123)
		{
			[temp setFrame:CGRectMake(temp.frame.origin.x, temp.frame.origin.y - paperHeightPercent(4), temp.frame.size.width, temp.frame.size.height)];
		}
	}
	
	UIImage * rightSignature = [timesheet rightSignature];
	UIImage * leftSignature = [timesheet leftSignature];
	
	CGFloat viewHeight = paperHeightPercent(11);
	
	if (rightSignature || leftSignature)
	{
		viewHeight = paperHeightPercent(18.4);
	}
	
	CGFloat last_Y = latestView.frame.origin.y + latestView.frame.size.height + viewHeight;
	
	if (last_Y >= paperHeightPercent(88))
	{
		[currentPage setTag:0];
		
		currentPage = [[UIView alloc] initWithFrame:CGRectMake(0, view.subviews.count * (paper_size.height + paperHeightPercent(1)), paper_size.width, paper_size.height)];
		[currentPage setBackgroundColor:[UIColor whiteColor]];
		[currentPage setTag:CURRENT_PAGE_TAG];
		[view addSubview:currentPage];
		
		[PDFCreator2 addTemplateImageTo:currentPage];
		
		last_Y = paperHeightPercent(8.3);
	}
	else
	{
		last_Y -= viewHeight;
		last_Y += paperHeightPercent(3);
	}
	
	NSString *totalHours = [timesheet getTotalHours];
	
	CGSize size_hours = [data_manager sizeForString:totalHours withFont:HelveticaNeueBold(paperWidthPercent(2)) constrainedToSize:paper_size];
	
	CGFloat max_width = size_hours.width;
	
	UIView * theView = [[UIView alloc] initWithFrame:CGRectMake(paperWidthPercent(7.6), last_Y, paperWidthPercent(84.8), viewHeight)];
	[theView setBackgroundColor:[UIColor clearColor]];
	
	CGFloat left_width = paper_size.width - max_width - paperWidthPercent(2) - paperWidthPercent(15.2);
	CGFloat right_x = left_width + paperWidthPercent(2);
	CGFloat label_y = 0;
	
	CGFloat comments_width = paper_size.width - paperWidthPercent(15.2) - max_width - paperWidthPercent(4) - max_width;
	
	[theView addSubview:[PDFCreator leftStatusLabelWithText:[timesheetDict objectForKey:@"Total Hours"] size:left_width andY:label_y isBold:YES andMaxWidth:max_width]];
	[theView addSubview:[PDFCreator rightStatusLabelWithText:totalHours X:right_x andY:label_y isBold:NO]];
	label_y += paperHeightPercent(1.6);
	
	if ([timesheet otherComments].length > 0)
	{
		UIView * otherCommentsView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, comments_width, paperHeightPercent(11.8))];
		[otherCommentsView setBackgroundColor:[UIColor darkGrayColor]];
		[theView addSubview:otherCommentsView];
		
		UILabel * titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(paperHeightPercent(0.5), paperHeightPercent(0.2), comments_width - paperHeightPercent(0.7), paperHeightPercent(1.8))];
		[titleLabel setText:[timesheet otherCommentsTitle]];
		[titleLabel setTextAlignment:NSTextAlignmentLeft];
		[titleLabel setTextColor:[UIColor whiteColor]];
		[titleLabel setFont:HelveticaNeueBold(paperWidthPercent(2))];
		[titleLabel setBackgroundColor:[UIColor clearColor]];
		[otherCommentsView addSubview:titleLabel];
		
		UIView * commentContent = [[UIView alloc] initWithFrame:CGRectMake(paperHeightPercent(0.1), paperHeightPercent(2.2), otherCommentsView.frame.size.width - paperHeightPercent(0.2), paperHeightPercent(9.5))];
		[commentContent setBackgroundColor:[UIColor whiteColor]];
		[otherCommentsView addSubview:commentContent];
		
		CGSize maxSize = CGSizeMake(titleLabel.frame.size.width, paperHeightPercent(9.1));
		CGSize size = [data_manager sizeForString:[timesheet otherComments] withFont:HelveticaNeueBold(paperWidthPercent(2)) constrainedToSize:maxSize];
		
		UILabel * textLabel = [[UILabel alloc] initWithFrame:CGRectMake(paperHeightPercent(0.2), paperHeightPercent(0.2), titleLabel.frame.size.width, size.height)];
		[textLabel setText:[timesheet otherComments]];
		[textLabel setTextAlignment:NSTextAlignmentLeft];
		[textLabel setTextColor:[UIColor darkGrayColor]];
		[textLabel setFont:HelveticaNeue(paperWidthPercent(2))];
		[textLabel setBackgroundColor:[UIColor clearColor]];
		[textLabel setNumberOfLines:5];
		[commentContent addSubview:textLabel];
	}
	
	if (rightSignature)
	{
		CGFloat imageSize = ([timesheet rightSignatureFrame].size.width * paperWidthPercent(25)) / (dvc_width - 20);
		
		CGSize imgSize = [data_manager sizeOfAspectScaledSize:[timesheet rightSignatureFrame].size inSize:CGSizeMake(paperWidthPercent(25), paperWidthPercent(25))];
		
		CGFloat diff = (paperWidthPercent(30) - imgSize.height) / 2;
		
		UIView * checkView = [[UIView alloc] initWithFrame:CGRectMake(paperWidthPercent(55), paperHeightPercent(6) + diff, imgSize.width, imgSize.height)];
		
		UIImageView * sigView = [[UIImageView alloc] initWithFrame:CGRectMake(paperWidthPercent(55), paperHeightPercent(6), imageSize, imageSize)];
		[sigView setCenter:checkView.center];
		[sigView setImage:rightSignature];
		[sigView setContentMode:UIViewContentModeScaleAspectFit];
		[theView addSubview:sigView];
		
		[date_formatter setDateFormat:[DELEGATE userSelectedDateFormat]];
		
		UILabel * dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(paperWidthPercent(68), paperHeightPercent(18.5), theView.frame.size.width - paperWidthPercent(68), paperHeightPercent(1.2))];
		[dateLabel setText:[date_formatter stringFromDate:[timesheet rightSignatureDate]]];
		[dateLabel setTextAlignment:NSTextAlignmentRight];
		[dateLabel setTextColor:[UIColor blackColor]];
		[dateLabel setFont:HelveticaNeue(paperWidthPercent(2))];
		[dateLabel setBackgroundColor:[UIColor clearColor]];
		[theView addSubview:dateLabel];
		
		UIView * line = [[UIView alloc] initWithFrame:CGRectMake(paperWidthPercent(55), paperHeightPercent(20), theView.frame.size.width - paperWidthPercent(55), paperHeightPercent(0.1))];
		[line setBackgroundColor:[UIColor darkGrayColor]];
		[theView addSubview:line];
		
		UILabel * signatureTitle = [[UILabel alloc] initWithFrame:CGRectMake(paperWidthPercent(55), paperHeightPercent(20.2), theView.frame.size.width - paperWidthPercent(68), paperHeightPercent(1.8))];
		[signatureTitle setText:[timesheet rightSignatureTitle]];
		[signatureTitle setTextAlignment:NSTextAlignmentLeft];
		[signatureTitle setTextColor:[UIColor blackColor]];
		[signatureTitle setFont:HelveticaNeue(paperWidthPercent(2))];
		[signatureTitle setBackgroundColor:[UIColor clearColor]];
		[signatureTitle setAdjustsFontSizeToFitWidth:YES];
		[theView addSubview:signatureTitle];
		
		UILabel * dateTitle = [[UILabel alloc] initWithFrame:CGRectMake(paperWidthPercent(72), paperHeightPercent(20.2), theView.frame.size.width - paperWidthPercent(72), paperHeightPercent(1.2))];
		[dateTitle setText:@"Date"];
		[dateTitle setTextAlignment:NSTextAlignmentLeft];
		[dateTitle setTextColor:[UIColor blackColor]];
		[dateTitle setFont:HelveticaNeue(paperWidthPercent(2))];
		[dateTitle setBackgroundColor:[UIColor clearColor]];
		[theView addSubview:dateTitle];
	}
	
	if (leftSignature)
	{
		CGFloat imageSize = ([timesheet leftSignatureFrame].size.width * paperWidthPercent(25)) / (dvc_width - 20);
		
		CGSize imgSize = [data_manager sizeOfAspectScaledSize:[timesheet leftSignatureFrame].size inSize:CGSizeMake(paperWidthPercent(25), paperWidthPercent(25))];
		
		CGFloat diff = (paperWidthPercent(30) - imgSize.height) / 2;
		
		UIView * checkView = [[UIView alloc] initWithFrame:CGRectMake(paperWidthPercent(0), paperHeightPercent(6) + diff, imgSize.width, imgSize.height)];
		
		UIImageView * sigView = [[UIImageView alloc] initWithFrame:CGRectMake(paperWidthPercent(0), paperHeightPercent(6), imageSize, imageSize)];
		[sigView setCenter:checkView.center];
		[sigView setImage:leftSignature];
		[sigView setContentMode:UIViewContentModeScaleAspectFit];
		[theView addSubview:sigView];
		
		[date_formatter setDateFormat:[DELEGATE userSelectedDateFormat]];
		
		UILabel * dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(paperWidthPercent(13), paperHeightPercent(18.5), theView.frame.size.width - paperWidthPercent(68), paperHeightPercent(1.2))];
		[dateLabel setText:[date_formatter stringFromDate:[timesheet leftSignatureDate]]];
		[dateLabel setTextAlignment:NSTextAlignmentRight];
		[dateLabel setTextColor:[UIColor blackColor]];
		[dateLabel setFont:HelveticaNeue(paperWidthPercent(2))];
		[dateLabel setBackgroundColor:[UIColor clearColor]];
		[theView addSubview:dateLabel];
		
		UIView * line = [[UIView alloc] initWithFrame:CGRectMake(paperWidthPercent(0), paperHeightPercent(20), theView.frame.size.width - paperWidthPercent(55), paperHeightPercent(0.1))];
		[line setBackgroundColor:[UIColor darkGrayColor]];
		[theView addSubview:line];
		
		UILabel * signatureTitle = [[UILabel alloc] initWithFrame:CGRectMake(paperWidthPercent(0), paperHeightPercent(20.2), theView.frame.size.width - paperWidthPercent(68), paperHeightPercent(1.8))];
		[signatureTitle setText:[timesheet leftSignatureTitle]];
		[signatureTitle setTextAlignment:NSTextAlignmentLeft];
		[signatureTitle setTextColor:[UIColor blackColor]];
		[signatureTitle setFont:HelveticaNeue(paperWidthPercent(2))];
		[signatureTitle setBackgroundColor:[UIColor clearColor]];
		[signatureTitle setAdjustsFontSizeToFitWidth:YES];
		[theView addSubview:signatureTitle];
		
		UILabel * dateTitle = [[UILabel alloc] initWithFrame:CGRectMake(paperWidthPercent(17), paperHeightPercent(20.2), theView.frame.size.width - paperWidthPercent(72), paperHeightPercent(1.2))];
		[dateTitle setText:@"Date"];
		[dateTitle setTextAlignment:NSTextAlignmentLeft];
		[dateTitle setTextColor:[UIColor blackColor]];
		[dateTitle setFont:HelveticaNeue(paperWidthPercent(2))];
		[dateTitle setBackgroundColor:[UIColor clearColor]];
		[theView addSubview:dateTitle];
	}
	
	[currentPage addSubview:theView];
}

#pragma mark - COMMON

+(UIView*)currentPageFrom:(UIView*)sender
{
	return [sender viewWithTag:CURRENT_PAGE_TAG];
}

+(UIView*)companyDetailsView
{
	UIView * theView = [[UIView alloc] initWithFrame:CGRectMake(paperWidthPercent(7.6), paperHeightPercent(8.3), paperWidthPercent(35), paperHeightPercent(18))];
	[theView setBackgroundColor:[UIColor clearColor]];
	
	CompanyOBJ * myCompany = [[CompanyOBJ alloc] initWithContentsDictionary:[CustomDefaults customObjectForKey:kCompanyKeyForNSUserDefaults]];
	
	CGFloat x = 0;
	
	if ([myCompany logo])
	{
		x = paper_size.height / 9;
		
		UIImageView * logo = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, paper_size.height / 11, paper_size.height / 11)];
		[logo setImage:[myCompany logo]];
		[logo setContentMode:UIViewContentModeScaleAspectFit];
		[theView addSubview:logo];
	}
	
	UILabel * companyName = [[UILabel alloc] initWithFrame:CGRectMake(x, 0, theView.frame.size.width - x, paperHeightPercent(5))];
	[companyName setText:[myCompany name]];
	[companyName setTextAlignment:NSTextAlignmentLeft];
	[companyName setTextColor:[UIColor blackColor]];
	[companyName setFont:HelveticaNeueBold(paperWidthPercent(4))];
	[companyName setAdjustsFontSizeToFitWidth:YES];
	[companyName setBackgroundColor:[UIColor clearColor]];
	[theView addSubview:companyName];
	
	UILabel * emailLabel = [[UILabel alloc] initWithFrame:CGRectMake(companyName.frame.origin.x, companyName.frame.origin.y + companyName.frame.size.height, companyName.frame.size.width, companyName.frame.size.height / 2.5)];
	[emailLabel setText:[myCompany email]];
	[emailLabel setTextAlignment:NSTextAlignmentLeft];
	[emailLabel setTextColor:[UIColor blackColor]];
	[emailLabel setFont:HelveticaNeueBold(paperWidthPercent(2))];
	[emailLabel setAdjustsFontSizeToFitWidth:YES];
	[emailLabel setBackgroundColor:[UIColor clearColor]];
	[theView addSubview:emailLabel];
	
	UILabel * websiteLabel = [[UILabel alloc] initWithFrame:CGRectMake(emailLabel.frame.origin.x, emailLabel.frame.origin.y + emailLabel.frame.size.height, emailLabel.frame.size.width, emailLabel.frame.size.height)];
	[websiteLabel setText:[myCompany website]];
	[websiteLabel setTextAlignment:NSTextAlignmentLeft];
	[websiteLabel setTextColor:[UIColor blackColor]];
	[websiteLabel setFont:HelveticaNeueBold(paperWidthPercent(2))];
	[websiteLabel setAdjustsFontSizeToFitWidth:YES];
	[websiteLabel setBackgroundColor:[UIColor clearColor]];
	[theView addSubview:websiteLabel];
	
	NSString * bName = [[CustomDefaults customObjectForKey:kSettingsKeyForNSUserDefaults] objectForKey:@"businessName"];
	NSString * bNumber = [[CustomDefaults customObjectForKey:kSettingsKeyForNSUserDefaults] objectForKey:@"businessNumber"];
	
	CGFloat line_size = paperHeightPercent(0.07);
	
	UIView * line = [[UIView alloc] initWithFrame:CGRectMake(0, paper_size.height / 10 - line_size, theView.frame.size.width, line_size)];
	[line setBackgroundColor:[UIColor grayColor]];
	[theView addSubview:line];
	
	if (bNumber && ![bNumber isEqual:@""])
	{
		UILabel * businessLabel = [[UILabel alloc] initWithFrame:CGRectMake(websiteLabel.frame.origin.x, websiteLabel.frame.origin.y + websiteLabel.frame.size.height, websiteLabel.frame.size.width, websiteLabel.frame.size.height)];
		[businessLabel setText:[NSString stringWithFormat:@"%@: %@", bName, bNumber]];
		[businessLabel setTextAlignment:NSTextAlignmentLeft];
		[businessLabel setTextColor:[UIColor blackColor]];
		[businessLabel setFont:HelveticaNeueBold(paperWidthPercent(2))];
		[businessLabel setAdjustsFontSizeToFitWidth:YES];
		[businessLabel setBackgroundColor:[UIColor clearColor]];
		[theView addSubview:businessLabel];
		
		[line setFrame:CGRectMake(line.frame.origin.x, line.frame.origin.y + websiteLabel.frame.size.height, line.frame.size.width, line.frame.size.height)];
	}
	
	AddressOBJ * address = [[AddressOBJ alloc] initWithContentsDictionary:[CustomDefaults customObjectForKey:kAddressKeyForNSUserDefaults]];
	
	UILabel * addressLine1 = [[UILabel alloc] initWithFrame:CGRectMake(0, line.frame.origin.y + line_size * 10, theView.frame.size.width, paperHeightPercent(2))];
	[addressLine1 setText:[address representationLine1]];
	[addressLine1 setTextAlignment:NSTextAlignmentLeft];
	[addressLine1 setTextColor:[UIColor darkGrayColor]];
	[addressLine1 setFont:HelveticaNeue(paperWidthPercent(2))];
	[addressLine1 setBackgroundColor:[UIColor clearColor]];
	[addressLine1 setAdjustsFontSizeToFitWidth:YES];
	[theView addSubview:addressLine1];
	
	UILabel * addressLine2 = [[UILabel alloc] initWithFrame:CGRectMake(0, addressLine1.frame.origin.y + addressLine1.frame.size.height, theView.frame.size.width, paperHeightPercent(2))];
	[addressLine2 setText:[address representationLine2]];
	[addressLine2 setTextAlignment:NSTextAlignmentLeft];
	[addressLine2 setTextColor:[UIColor darkGrayColor]];
	[addressLine2 setFont:HelveticaNeue(paperWidthPercent(2))];
	[addressLine2 setBackgroundColor:[UIColor clearColor]];
	[addressLine2 setAdjustsFontSizeToFitWidth:YES];
	[theView addSubview:addressLine2];
	
	UILabel * addressLine3 = [[UILabel alloc] initWithFrame:CGRectMake(0, addressLine2.frame.origin.y + addressLine2.frame.size.height, theView.frame.size.width, paperHeightPercent(2))];
	[addressLine3 setText:[address representationLine3]];
	[addressLine3 setTextAlignment:NSTextAlignmentLeft];
	[addressLine3 setTextColor:[UIColor darkGrayColor]];
	[addressLine3 setFont:HelveticaNeue(paperWidthPercent(2))];
	[addressLine3 setBackgroundColor:[UIColor clearColor]];
	[addressLine3 setAdjustsFontSizeToFitWidth:YES];
	[theView addSubview:addressLine3];
	
	UILabel * phoneNumber = [[UILabel alloc] initWithFrame:CGRectMake(0, addressLine3.frame.origin.y + addressLine3.frame.size.height, theView.frame.size.width, paperHeightPercent(2))];
	[phoneNumber setText:[myCompany phone]];
	[phoneNumber setTextAlignment:NSTextAlignmentLeft];
	[phoneNumber setTextColor:[UIColor darkGrayColor]];
	[phoneNumber setFont:HelveticaNeue(paperWidthPercent(2))];
	[phoneNumber setBackgroundColor:[UIColor clearColor]];
	[phoneNumber setAdjustsFontSizeToFitWidth:YES];
	[theView addSubview:phoneNumber];
	
	return theView;
}

+(UIView*)viewFromAddress:(AddressOBJ*)address withTitle:(NSString*)title companyName:(NSString*)companyName customerName:(NSString*)customerName
{
	UIView * theView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, paperWidthPercent(35), paperHeightPercent(11))];
	[theView setBackgroundColor:[UIColor clearColor]];
	
	UIView * topBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, paperWidthPercent(35), paperHeightPercent(1.8))];
	[topBar setBackgroundColor:[UIColor darkGrayColor]];
	[theView addSubview:topBar];
	
	if ([title isEqual:[CustomDefaults customObjectForKey:kBillingAddressTitleKeyForNSUserDefaults]])
	{
		if ([address billingTitle].length > 0)
		{
			title = [address billingTitle];
		}
	}
	else if ([title isEqual:[CustomDefaults customObjectForKey:kShippingAddressTitleKeyForNSUserDefaults]])
	{
		if ([address shippingTitle].length > 0)
		{
			title = [address shippingTitle];
		}
	}
	
	UILabel * titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(paperWidthPercent(0.1), 0, paperWidthPercent(35) - paperWidthPercent(0.1) * 2, paperHeightPercent(1.8))];
	[titleLabel setText:title];
	[titleLabel setTextAlignment:NSTextAlignmentLeft];
	[titleLabel setTextColor:[UIColor whiteColor]];
	[titleLabel setFont:HelveticaNeueBold(paperWidthPercent(2))];
	[titleLabel setBackgroundColor:[UIColor clearColor]];
	[titleLabel setAdjustsFontSizeToFitWidth:YES];
	[theView addSubview:titleLabel];
	
	UILabel * nameLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(0, topBar.frame.origin.y + topBar.frame.size.height * 1.5, theView.frame.size.width, paperHeightPercent(2))];
	[nameLabel1 setText:customerName];
	[nameLabel1 setTextAlignment:NSTextAlignmentLeft];
	[nameLabel1 setTextColor:[UIColor darkGrayColor]];
	[nameLabel1 setFont:HelveticaNeueBold(paperWidthPercent(2))];
	[nameLabel1 setBackgroundColor:[UIColor clearColor]];
	[nameLabel1 setAdjustsFontSizeToFitWidth:YES];
	[theView addSubview:nameLabel1];
	
	UILabel * nameLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(0, nameLabel1.frame.origin.y + nameLabel1.frame.size.height, theView.frame.size.width, paperHeightPercent(2))];
	[nameLabel2 setText:companyName];
	[nameLabel2 setTextAlignment:NSTextAlignmentLeft];
	[nameLabel2 setTextColor:[UIColor darkGrayColor]];
	[nameLabel2 setFont:HelveticaNeueBold(paperWidthPercent(2))];
	[nameLabel2 setBackgroundColor:[UIColor clearColor]];
	[nameLabel2 setAdjustsFontSizeToFitWidth:YES];
	[theView addSubview:nameLabel2];
	
	UILabel * addressLine1 = [[UILabel alloc] initWithFrame:CGRectMake(0, nameLabel2.frame.origin.y + nameLabel2.frame.size.height, theView.frame.size.width, paperHeightPercent(2))];
	[addressLine1 setText:[address representationLine1]];
	[addressLine1 setTextAlignment:NSTextAlignmentLeft];
	[addressLine1 setTextColor:[UIColor darkGrayColor]];
	[addressLine1 setFont:HelveticaNeueBold(paperWidthPercent(2))];
	[addressLine1 setBackgroundColor:[UIColor clearColor]];
	[addressLine1 setAdjustsFontSizeToFitWidth:YES];
	[theView addSubview:addressLine1];
	
	UILabel * addressLine2 = [[UILabel alloc] initWithFrame:CGRectMake(0, addressLine1.frame.origin.y + addressLine1.frame.size.height, theView.frame.size.width, paperHeightPercent(2))];
	[addressLine2 setText:[address representationLine2]];
	[addressLine2 setTextAlignment:NSTextAlignmentLeft];
	[addressLine2 setTextColor:[UIColor darkGrayColor]];
	[addressLine2 setFont:HelveticaNeueBold(paperWidthPercent(2))];
	[addressLine2 setBackgroundColor:[UIColor clearColor]];
	[addressLine2 setAdjustsFontSizeToFitWidth:YES];
	[theView addSubview:addressLine2];
	
	UILabel * addressLine3 = [[UILabel alloc] initWithFrame:CGRectMake(0, addressLine2.frame.origin.y + addressLine2.frame.size.height, theView.frame.size.width, paperHeightPercent(2))];
	[addressLine3 setText:[address representationLine3]];
	[addressLine3 setTextAlignment:NSTextAlignmentLeft];
	[addressLine3 setTextColor:[UIColor darkGrayColor]];
	[addressLine3 setFont:HelveticaNeueBold(paperWidthPercent(2))];
	[addressLine3 setBackgroundColor:[UIColor clearColor]];
	[addressLine3 setAdjustsFontSizeToFitWidth:YES];
	[theView addSubview:addressLine3];
	
	return theView;
}

+(UIView*)headerViewWithY:(CGFloat)Y hasDiscount:(BOOL)has_discount
{
	NSMutableDictionary *timesheetDict = [[NSMutableDictionary alloc] initWithDictionary:[[CustomDefaults customObjectForKey:kLanguageKeyForNSUserDefaults] objectForKey:@"timesheet"]];
	
	UIView * theView = [[UIView alloc] initWithFrame:CGRectMake(paperWidthPercent(7.6), Y, paper_size.width - paperWidthPercent(15.2), paperHeightPercent(1.6))];
	[theView setBackgroundColor:[UIColor darkGrayColor]];
	
	UIView * lineTop = [[UIView alloc] initWithFrame:CGRectMake(0, 0, theView.frame.size.width, paperHeightPercent(0.05))];
	[lineTop setBackgroundColor:[UIColor blackColor]];
	[theView addSubview:lineTop];
	
	UIView * lineBottom = [[UIView alloc] initWithFrame:CGRectMake(0, theView.frame.size.height - lineTop.frame.size.height, theView.frame.size.width, paperHeightPercent(0.05))];
	[lineBottom setBackgroundColor:[UIColor blackColor]];
	[theView addSubview:lineBottom];
	
	UIView * lineLeft = [[UIView alloc] initWithFrame:CGRectMake(0, 0, paperHeightPercent(0.05), theView.frame.size.height)];
	[lineLeft setBackgroundColor:[UIColor blackColor]];
	[theView addSubview:lineLeft];
	
	UIView * lineRight = [[UIView alloc] initWithFrame:CGRectMake(theView.frame.size.width - paperHeightPercent(0.05), 0, paperHeightPercent(0.05), theView.frame.size.height)];
	[lineRight setBackgroundColor:[UIColor blackColor]];
	[theView addSubview:lineRight];
	
	float witdh = (paper_size.width - paperWidthPercent(15.2)) / 7 - paperWidthPercent(0.5);
	
	UILabel * itemLabel = [[UILabel alloc] initWithFrame:CGRectMake(paperWidthPercent(0.25), 0, witdh, theView.frame.size.height)];
	[itemLabel setText:[timesheetDict objectForKey:@"Date"]];
	[itemLabel setTextAlignment:NSTextAlignmentCenter];
	[itemLabel setTextColor:[UIColor whiteColor]];
	[itemLabel setFont:HelveticaNeueBold(paperWidthPercent(2))];
	[itemLabel setBackgroundColor:[UIColor clearColor]];
	[theView addSubview:itemLabel];
	
	CGFloat x = itemLabel.frame.origin.x + itemLabel.frame.size.width + paperWidthPercent(0.25);
	
	UILabel * descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, 0, witdh, theView.frame.size.height)];
	[descriptionLabel setText:[timesheetDict objectForKey:@"Day"]];
	[descriptionLabel setTextAlignment:NSTextAlignmentCenter];
	[descriptionLabel setTextColor:[UIColor whiteColor]];
	[descriptionLabel setFont:HelveticaNeueBold(paperWidthPercent(2))];
	[descriptionLabel setBackgroundColor:[UIColor clearColor]];
	[theView addSubview:descriptionLabel];
	
	x = descriptionLabel.frame.origin.x + descriptionLabel.frame.size.width + paperWidthPercent(0.5);
	
	UILabel * quantityLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, 0, witdh, theView.frame.size.height)];
	[quantityLabel setText:[timesheetDict objectForKey:@"Start"]];
	[quantityLabel setTextAlignment:NSTextAlignmentCenter];
	[quantityLabel setTextColor:[UIColor whiteColor]];
	[quantityLabel setFont:HelveticaNeueBold(paperWidthPercent(2))];
	[quantityLabel setBackgroundColor:[UIColor clearColor]];
	[theView addSubview:quantityLabel];
	
	x = quantityLabel.frame.origin.x + quantityLabel.frame.size.width + paperWidthPercent(0.5);
	
	UILabel * rateLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, 0, witdh, theView.frame.size.height)];
	[rateLabel setText:[timesheetDict objectForKey:@"Finish"]];
	[rateLabel setTextAlignment:NSTextAlignmentCenter];
	[rateLabel setTextColor:[UIColor whiteColor]];
	[rateLabel setFont:HelveticaNeueBold(paperWidthPercent(2))];
	[rateLabel setBackgroundColor:[UIColor clearColor]];
	[theView addSubview:rateLabel];
	
	x = rateLabel.frame.origin.x + rateLabel.frame.size.width + paperWidthPercent(0.5);
	
	UILabel * amountLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, 0, witdh, theView.frame.size.height)];
	[amountLabel setText:[timesheetDict objectForKey:@"Break"]];
	[amountLabel setTextAlignment:NSTextAlignmentCenter];
	[amountLabel setTextColor:[UIColor whiteColor]];
	[amountLabel setFont:HelveticaNeueBold(paperWidthPercent(2))];
	[amountLabel setBackgroundColor:[UIColor clearColor]];
	[theView addSubview:amountLabel];
	
	x = amountLabel.frame.origin.x + amountLabel.frame.size.width + paperWidthPercent(0.5);
	
	UILabel * overtimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, 0, witdh, theView.frame.size.height)];
	[overtimeLabel setText:[timesheetDict objectForKey:@"Overtime"]];
	[overtimeLabel setTextAlignment:NSTextAlignmentCenter];
	[overtimeLabel setTextColor:[UIColor whiteColor]];
	[overtimeLabel setFont:HelveticaNeueBold(paperWidthPercent(2))];
	[overtimeLabel setBackgroundColor:[UIColor clearColor]];
	[theView addSubview:overtimeLabel];
	
	x = overtimeLabel.frame.origin.x + overtimeLabel.frame.size.width + paperWidthPercent(0.5);
	
	UILabel * totalLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, 0, witdh, theView.frame.size.height)];
	[totalLabel setText:[timesheetDict objectForKey:@"Total"]];
	[totalLabel setTextAlignment:NSTextAlignmentCenter];
	[totalLabel setTextColor:[UIColor whiteColor]];
	[totalLabel setFont:HelveticaNeueBold(paperWidthPercent(2))];
	[totalLabel setBackgroundColor:[UIColor clearColor]];
	[theView addSubview:totalLabel];
	
	return theView;
}

+(void)addObject:(NSDictionary*)object toView:(UIView*)view
{
	UIView * currentPage = [PDFCreator currentPageFrom:view];
	UIView * latestView = [currentPage.subviews lastObject];
	
	CGFloat last_Y = latestView.frame.origin.y + latestView.frame.size.height;
	
	if (last_Y >= paperHeightPercent(88.5))
	{
		[currentPage setTag:0];
		
		currentPage = [[UIView alloc] initWithFrame:CGRectMake(0, view.subviews.count * (paper_size.height + paperHeightPercent(1)), paper_size.width, paper_size.height)];
		[currentPage setBackgroundColor:[UIColor whiteColor]];
		[currentPage setTag:CURRENT_PAGE_TAG];
		[view addSubview:currentPage];
		
		[PDFCreator2 addTemplateImageTo:currentPage];
		
		last_Y = paperHeightPercent(8.3);
	}
	
	UIView * theView = [[UIView alloc] initWithFrame:CGRectMake(paperWidthPercent(7.6), last_Y, paper_size.width - paperWidthPercent(15.2), paperHeightPercent(1.6))];
	[theView setBackgroundColor:[UIColor clearColor]];
	[currentPage addSubview:theView];
	
	CGFloat width = (paper_size.width - paperWidthPercent(15.2)) / 7 - paperWidthPercent(0.5);
	
	UILabel * dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(paperWidthPercent(0.25), 0, width, paperHeightPercent(1.8))];
	[dateLabel setTextAlignment:NSTextAlignmentCenter];
	[dateLabel setTextColor:[UIColor darkGrayColor]];
	[dateLabel setFont:HelveticaNeue(paperWidthPercent(2))];
	[dateLabel setBackgroundColor:[UIColor clearColor]];
	dateLabel.adjustsFontSizeToFitWidth = YES;
	[dateLabel setNumberOfLines:0];
	[theView addSubview:dateLabel];
	
	CGFloat x = dateLabel.frame.origin.x + dateLabel.frame.size.width + paperWidthPercent(0.5);
	
	UILabel * dayLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, 0, width, paperHeightPercent(1.8))];
	[dayLabel setTextAlignment:NSTextAlignmentCenter];
	[dayLabel setTextColor:[UIColor darkGrayColor]];
	[dayLabel setFont:HelveticaNeue(paperWidthPercent(2))];
	[dayLabel setBackgroundColor:[UIColor clearColor]];
	[dayLabel setNumberOfLines:0];
	[theView addSubview:dayLabel];
	
	x = dayLabel.frame.origin.x + dayLabel.frame.size.width + paperWidthPercent(0.5);
	
	UILabel * startLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, 0, width, paperHeightPercent(1.8))];
	[startLabel setTextAlignment:NSTextAlignmentCenter];
	[startLabel setTextColor:[UIColor darkGrayColor]];
	[startLabel setFont:HelveticaNeue(paperWidthPercent(2))];
	[startLabel setBackgroundColor:[UIColor clearColor]];
	[startLabel setAdjustsFontSizeToFitWidth:YES];
	[theView addSubview:startLabel];
	
	x = startLabel.frame.origin.x + startLabel.frame.size.width + paperWidthPercent(0.5);
	
	UILabel * finishLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, 0, width, paperHeightPercent(1.8))];
	[finishLabel setTextAlignment:NSTextAlignmentCenter];
	[finishLabel setTextColor:[UIColor darkGrayColor]];
	[finishLabel setFont:HelveticaNeue(paperWidthPercent(2))];
	[finishLabel setBackgroundColor:[UIColor clearColor]];
	[finishLabel setAdjustsFontSizeToFitWidth:YES];
	[theView addSubview:finishLabel];
	
	x = finishLabel.frame.origin.x + finishLabel.frame.size.width + paperWidthPercent(0.5);
	
	UILabel * breakLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, 0, width, paperHeightPercent(1.8))];
	[breakLabel setTextAlignment:NSTextAlignmentCenter];
	[breakLabel setTextColor:[UIColor darkGrayColor]];
	[breakLabel setFont:HelveticaNeue(paperWidthPercent(2))];
	[breakLabel setBackgroundColor:[UIColor clearColor]];
	[breakLabel setAdjustsFontSizeToFitWidth:YES];
	[theView addSubview:breakLabel];
	
	x = breakLabel.frame.origin.x + breakLabel.frame.size.width + paperWidthPercent(0.5);
	
	UILabel * overtimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, 0, width, paperHeightPercent(1.8))];
	[overtimeLabel setTextAlignment:NSTextAlignmentCenter];
	[overtimeLabel setTextColor:[UIColor darkGrayColor]];
	[overtimeLabel setFont:HelveticaNeue(paperWidthPercent(2))];
	[overtimeLabel setBackgroundColor:[UIColor clearColor]];
	[overtimeLabel setAdjustsFontSizeToFitWidth:YES];
	[theView addSubview:overtimeLabel];
	
	x = overtimeLabel.frame.origin.x + overtimeLabel.frame.size.width + paperWidthPercent(0.5);
	
	UILabel * totalLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, 0, width, paperHeightPercent(1.8))];
	[totalLabel setTextAlignment:NSTextAlignmentCenter];
	[totalLabel setTextColor:[UIColor darkGrayColor]];
	[totalLabel setFont:HelveticaNeue(paperWidthPercent(2))];
	[totalLabel setBackgroundColor:[UIColor clearColor]];
	[totalLabel setAdjustsFontSizeToFitWidth:YES];
	[theView addSubview:totalLabel];
	
	[theView setFrame:CGRectMake(paperWidthPercent(7.6), last_Y, theView.frame.size.width, theView.frame.size.height + paperHeightPercent(0.5))];
	
	UIView * lineLeft = [[UIView alloc] initWithFrame:CGRectMake(0, 0, paperHeightPercent(0.05), theView.frame.size.height)];
	[lineLeft setBackgroundColor:[UIColor blackColor]];
	[theView addSubview:lineLeft];
	
	UIView * lineRight = [[UIView alloc] initWithFrame:CGRectMake(theView.frame.size.width - paperHeightPercent(0.05), 0, paperHeightPercent(0.05), theView.frame.size.height)];
	[lineRight setBackgroundColor:[UIColor blackColor]];
	[theView addSubview:lineRight];
	
	if (!object)
		return;
	
	ServiceTimeOBJ *time = [[ServiceTimeOBJ alloc] initWithDictionaryRepresentation:object];
	
	[date_formatter setDateFormat:[DELEGATE userSelectedDateFormat]];
	
	[dateLabel setText:[date_formatter stringFromDate:[time date]]];
	
	[date_formatter setDateFormat:@"EE"];
	
	[dayLabel setText:[date_formatter stringFromDate:[time date]]];
	
	[date_formatter setDateFormat:@"HH:mm"];
	
	[startLabel setText:[date_formatter stringFromDate:[time startTime]]];
	[finishLabel setText:[date_formatter stringFromDate:[time finishTime]]];
	[breakLabel setText:[time breakString]];
	[overtimeLabel setText:[time overtimeString]];
	[totalLabel setText:[time totalHours]];
}

+(UILabel*)leftStatusLabelWithText:(NSString*)text size:(CGFloat)size andY:(CGFloat)Y isBold:(BOOL)bold andMaxWidth:(CGFloat)maxWidth
{
	UILabel * theLabel = [[UILabel alloc] initWithFrame:CGRectMake(paper_size.width - size - maxWidth - paperWidthPercent(7.6), Y, size - paperWidthPercent(9.6), paperHeightPercent(1.8))];
	[theLabel setText:text];
	[theLabel setTextAlignment:NSTextAlignmentRight];
	[theLabel setTextColor:[UIColor darkGrayColor]];
	[theLabel setFont:HelveticaNeue(paperWidthPercent(2))];
	if (bold) [theLabel setFont:HelveticaNeueBold(paperWidthPercent(2))];
	[theLabel setBackgroundColor:[UIColor clearColor]];
	
	return theLabel;
}

+(UILabel*)rightStatusLabelWithText:(NSString*)text X:(CGFloat)X andY:(CGFloat)Y isBold:(BOOL)bold
{
	UILabel * theLabel = [[UILabel alloc] initWithFrame:CGRectMake(X, Y, paper_size.width - X - paperWidthPercent(7.6) - paperWidthPercent(7.6), paperHeightPercent(1.6))];
	[theLabel setText:text];
	[theLabel setTextAlignment:NSTextAlignmentRight];
	[theLabel setTextColor:[UIColor blackColor]];
	[theLabel setFont:HelveticaNeue(paperWidthPercent(2))];
	if (bold) [theLabel setFont:HelveticaNeueBold(paperWidthPercent(2))];
	[theLabel setBackgroundColor:[UIColor clearColor]];
	
	return theLabel;
}

+(void)addTemplateImageTo:(UIView*)view
{
	if ([data_manager templateImage])
	{
		CGSize size = [data_manager sizeOfAspectScaledSize:[data_manager templateImage].size inSize:view.frame.size];
		
		UIImageView * templateImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
		[templateImage setImage:[data_manager templateImage]];
		[templateImage setContentMode:UIViewContentModeScaleAspectFit];
		[view addSubview:templateImage];
		[view sendSubviewToBack:templateImage];
	}
}

@end
