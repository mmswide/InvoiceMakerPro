//
//  PDFCreator.m
//  Invoice
//
//  Created by XGRoup5 on 8/27/13.
//  Copyright (c) 2013 XGRoup. All rights reserved.
//

#import "PDFCreator.h"

#import "Defines.h"
#import "BaseOBJ.h"


#define DETAILS_BOTTOM_OFFSET 20.f

@implementation PDFCreator

+(NSData*)PDFDataFromUIView:(UIView*)aView
{
    if(!aView) {
        return nil;
    }
    
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
	
	UIGraphicsEndPDFContext();
		
	return pdfData;
}

+(UIView*)PDFViewFromBaseObject:(BaseOBJ*)baseOBJ {
    if([baseOBJ isKindOfClass:[InvoiceOBJ class]]) {
        return [PDFCreator PDFViewFromInvoice:(InvoiceOBJ*)baseOBJ];
    } else if ([baseOBJ isKindOfClass:[QuoteOBJ class]]) {
        return [PDFCreator PDFViewFromQuote:(QuoteOBJ*)baseOBJ];
    } else if ([baseOBJ isKindOfClass:[EstimateOBJ class]]) {
        return [PDFCreator PDFViewFromEstimate:(EstimateOBJ*)baseOBJ];
    } else if ([baseOBJ isKindOfClass:[PurchaseOrderOBJ class]]) {
        return [PDFCreator PDFViewFromPurchaseOrder:(PurchaseOrderOBJ*)baseOBJ];
    }
    return nil;
}

#pragma mark - INVOICE

+(UIView*)PDFViewFromInvoice:(InvoiceOBJ*)invoice {
	UIView * theView = [[UIView alloc] init];
	[theView setBackgroundColor:[UIColor darkGrayColor]];
	
	UIView * aPage = [[UIView alloc] initWithFrame:CGRectMake(0, 0, paper_size.width, paper_size.height)];
	[aPage setBackgroundColor:[UIColor whiteColor]];
	[aPage setTag:CURRENT_PAGE_TAG];
	[theView addSubview:aPage];
    
	UILabel * noteLabel = [[UILabel alloc] initWithFrame:CGRectMake(paperWidthPercent(7.6), paperHeightPercent(92), paper_size.width - paperWidthPercent(15.2), paperHeightPercent(6))];
	[noteLabel setBackgroundColor:[UIColor clearColor]];
	[noteLabel setText:[invoice note]];
	[noteLabel setTextAlignment:NSTextAlignmentCenter];
	[noteLabel setTextColor:[UIColor blackColor]];
	[noteLabel setFont:HelveticaNeue(paperWidthPercent(2))];
	[noteLabel setNumberOfLines:3];
	[noteLabel setTag:123];
	[aPage addSubview:noteLabel];
	
	[PDFCreator addTemplateImageTo:aPage];
	
  UIView *companyDetailsView = [PDFCreator companyDetailsViewForObject:invoice];
  UIView *detailsView = [PDFCreator detailsForInvoice:invoice];
  
  if(![invoice companyAlignLeft]) {
    CGRect swapFrame = companyDetailsView.frame;
    CGFloat frameX = swapFrame.origin.x;
    swapFrame.origin.x = detailsView.frame.origin.x;
    companyDetailsView.frame = swapFrame;
    
    swapFrame = detailsView.frame;
    swapFrame.origin.x = frameX;
    detailsView.frame = swapFrame;
  }
  
  //shift views up
  if(![data_manager templateImage]) {
    CGFloat newY = paperHeightPercent(8.3) * (2.f/3.f);
    CGRect swapFrame = companyDetailsView.frame;
    swapFrame.origin.y = newY;
    companyDetailsView.frame = swapFrame;
    
    swapFrame = detailsView.frame;
    swapFrame.origin.y = newY;
    detailsView.frame = swapFrame;
  }
  
  CGFloat detailsHeight = MAX(CGRectGetMaxY(detailsView.frame), CGRectGetMaxY(companyDetailsView.frame));
    
	[aPage addSubview:companyDetailsView];
	[aPage addSubview:detailsView];
  
  NSArray *clientOrder = [invoice clientFieldsOrder];
  CGFloat maxDetailY = detailsHeight;
  
  NSInteger orderIndex = 0;
  if([clientOrder count] > 0) {
    for(NSNumber *clientType in clientOrder) {
      AddressOBJ *clientAddress = nil;
      NSString *addressTitle = @"";
      
      if([clientType integerValue] == ClientBilling) {
        clientAddress = [[invoice client] billingAddress];
        addressTitle = [CustomDefaults customObjectForKey:kInvoiceBillingAddressTitleKeyForNSUserDefaults];
      } else if ([clientType integerValue] == ClientShipping) {
        clientAddress = [[invoice client] shippingAddress];
        addressTitle = [CustomDefaults customObjectForKey:kInvoiceShippingAddressTitleKeyForNSUserDefaults];
      }
      clientAddress.billingKey = kInvoiceBillingAddressTitleKeyForNSUserDefaults;
      clientAddress.shippingKey = kInvoiceShippingAddressTitleKeyForNSUserDefaults;
      
      if (clientAddress.fullStringRepresentation.length > 0 || ([clientType integerValue] == ClientBilling && [[[invoice client] firstName] length] > 0)) {
        UIView * clientAddressView = [PDFCreator viewFromAddress:clientAddress
                                                     withTitle:[NSString stringWithFormat:@"%@:",addressTitle]
                                                   companyName:[[invoice client] company]
                                                  customerName:[NSString stringWithFormat:@"%@ %@", [[invoice client] firstName], [[invoice client] lastName]]];
        
        CGFloat addressX = orderIndex == 0?paperWidthPercent(7.6):paper_size.width - paperWidthPercent(7.6) - clientAddressView.frame.size.width;
        [clientAddressView setFrame:CGRectMake(addressX,
                                             detailsHeight + paperHeightPercent(1),
                                             clientAddressView.frame.size.width,
                                             clientAddressView.frame.size.height)];
        [aPage addSubview:clientAddressView];
        
        maxDetailY = MAX(maxDetailY, CGRectGetMaxY(clientAddressView.frame));
        
        orderIndex++;
      }
    }
  }
	
	BOOL has_discount = NO;
	
	for (NSDictionary * object in [invoice products]) {
		if ([[object allKeys] containsObject:@"class"] && NSClassFromString([object objectForKey:@"class"]) == [ProductOBJ class]) {
			ProductOBJ * product = [[ProductOBJ alloc] initWithContentsDictionary:object];
			
			if ([product discount] > 0.0f) {
				has_discount = YES;
				break;
			}
		} else if ([[object allKeys] containsObject:@"class"] && NSClassFromString([object objectForKey:@"class"]) == [ServiceOBJ class]) {
			ServiceOBJ * service = [[ServiceOBJ alloc] initWithContentsDictionary:object];
			
			if ([service discount] > 0.0f) {
				has_discount = YES;
				break;
			}
		}
	}
	
    //products
	[aPage addSubview:[PDFCreator headerViewWithY:maxDetailY + paperHeightPercent(2)
                                      hasDiscount:has_discount
                                          andType:1
                                        andObject:invoice]];
	
//	UIImage * rightSignature = [invoice rightSignature];
//	UIImage * leftSignature = [invoice leftSignature];
	
	BOOL hasSignature = NO;
	
//	if (rightSignature || leftSignature)
//	{
//		hasSignature = YES;
//	}
	
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
	
	for (NSDictionary * object in [invoice products])
	{
		[PDFCreator addObject:object toView:theView andObject:invoice];
	}
	
	UIView * currentPage = [PDFCreator currentPageFrom:theView];
	UIView * latestView = [currentPage.subviews lastObject];
	CGFloat last_Y = latestView.frame.origin.y + latestView.frame.size.height;

	if (last_Y < paperHeightPercent(60))
	{
		CGFloat difference = paperHeightPercent(60) - last_Y;
		int count = (int)difference / paperHeightPercent(1.8);
		
		for (int i = 0; i < count; i++)
		{
			[PDFCreator addObject:nil toView:theView andObject:nil];
		}
	}
	
	latestView = [currentPage.subviews lastObject];
	UIView * lineBottom = [[UIView alloc] initWithFrame:CGRectMake(0, latestView.frame.size.height - paperHeightPercent(0.05), latestView.frame.size.width, paperHeightPercent(0.05))];
	[lineBottom setBackgroundColor:[UIColor blackColor]];
	[latestView addSubview:lineBottom];
	
	aPage = [PDFCreator currentPageFrom:theView];
	
	[PDFCreator statisticsPartForInvoice:invoice inView:theView];
	
	aPage = [PDFCreator currentPageFrom:theView];
	
	if ([invoice bigNote].length > 0)
	{
		[aPage setTag:0];
			
		aPage = [[UIView alloc] initWithFrame:CGRectMake(0, theView.subviews.count * (paper_size.height + paperHeightPercent(1)), paper_size.width, paper_size.height)];
		[aPage setBackgroundColor:[UIColor whiteColor]];
		[aPage setTag:CURRENT_PAGE_TAG];
		[theView addSubview:aPage];
			
		[PDFCreator addTemplateImageTo:aPage];
			
		CGFloat last_Y = paperHeightPercent(8.3);
		
		CGSize maxSize = CGSizeMake(paper_size.width - paperWidthPercent(15.2), paper_size.height);
		CGSize size = [data_manager sizeForString:[invoice bigNote] withFont:HelveticaNeue(paperWidthPercent(2)) constrainedToSize:maxSize];
		
		UILabel * otherNotes = [[UILabel alloc] initWithFrame:CGRectMake(paperWidthPercent(7.6), last_Y, paper_size.width - paperWidthPercent(15.2), size.height)];
		[otherNotes setText:[invoice bigNote]];
		[otherNotes setTextAlignment:NSTextAlignmentLeft];
		[otherNotes setTextColor:[UIColor blackColor]];
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

+(UIView*)detailsForInvoice:(InvoiceOBJ*)invoice {
	NSMutableDictionary *invoiceDict = [[NSMutableDictionary alloc] initWithDictionary:[[CustomDefaults customObjectForKey:kLanguageKeyForNSUserDefaults] objectForKey:@"invoice"]];
	
	CGRect theViewFrame = CGRectMake(paper_size.width - paperWidthPercent(7.6) - paperWidthPercent(35),
                                   paperHeightPercent(8.3),
                                   paperWidthPercent(35),
                                   paperHeightPercent(18));
	
	UIView * theView = [[UIView alloc] initWithFrame:theViewFrame];
	[theView setBackgroundColor:[UIColor clearColor]];
  
  BOOL alignRight = ![invoice companyAlignLeft];
	
	UILabel * titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, theView.frame.size.width, paperHeightPercent(4))];
	[titleLabel setText:[invoice title]];
  [titleLabel setTextAlignment:alignRight?NSTextAlignmentLeft:NSTextAlignmentRight];
	[titleLabel setTextColor:[UIColor blackColor]];
	[titleLabel setFont:HelveticaNeueBold(paperWidthPercent(6))];
	[titleLabel setBackgroundColor:[UIColor clearColor]];
	[titleLabel setAdjustsFontSizeToFitWidth:YES];
	[theView addSubview:titleLabel];
	
  CGFloat labelWidth = theViewFrame.size.width / 2.f;
  NSMutableArray *valueLabels = [NSMutableArray new];
  NSMutableArray *titleLabels = [NSMutableArray new];
  CGFloat nextY = titleLabel.frame.origin.y + titleLabel.frame.size.height + paperHeightPercent(1.5);
  
  NSArray *visibleDetails = [invoice visibleRowsInDetailsSection];
  
  for(NSDictionary *detailSetting in visibleDetails) {
    switch ([detailSetting[TYPE] integerValue]) {
      case DetailDueDate: {
        UILabel *titleLabel = [self labelWithText:[NSString stringWithFormat:@"%@:",[invoiceDict objectForKey:@"Due date"]]
                                            frame:CGRectMake(0,
                                                             nextY,
                                                             labelWidth,
                                                             paperHeightPercent(2))
                                        alignment:NSTextAlignmentLeft];
        [theView addSubview:titleLabel];
        [titleLabels addObject:titleLabel];
        
        UILabel *valueLabel = [self labelWithText:[invoice dueDate]
                                            frame:CGRectMake(titleLabel.frame.size.width,
                                                             titleLabel.frame.origin.y,
                                                             labelWidth,
                                                             paperHeightPercent(2))
                                        alignment:NSTextAlignmentLeft];
        [theView addSubview:valueLabel];
        [valueLabels addObject:valueLabel];
        
        nextY += paperHeightPercent(2);
      }
        
        break;
        
      case DetailDate: {
        UILabel *titleLabel = [self labelWithText:[NSString stringWithFormat:@"%@:",[invoiceDict objectForKey:@"Invoice date"]]
                                            frame:CGRectMake(0,
                                                             nextY,
                                                             labelWidth,
                                                             paperHeightPercent(2))
                                        alignment:NSTextAlignmentLeft];
        [theView addSubview:titleLabel];
        [titleLabels addObject:titleLabel];
        
        UILabel *valueLabel = [self labelWithText:[invoice date]
                                            frame:CGRectMake(titleLabel.frame.size.width,
                                                             titleLabel.frame.origin.y,
                                                             labelWidth,
                                                             paperHeightPercent(2))
                                        alignment:NSTextAlignmentLeft];
        [theView addSubview:valueLabel];
        [valueLabels addObject:valueLabel];
        
        nextY += paperHeightPercent(2);
      }
        
        break;
        
      case DetailProjNumber: {
        UILabel *titleLabel = [self labelWithText:[NSString stringWithFormat:@"%@:",[invoiceDict objectForKey:@"Invoice No"]]
                                            frame:CGRectMake(0,
                                                             nextY,
                                                             labelWidth,
                                                             paperHeightPercent(2))
                                        alignment:NSTextAlignmentLeft];
        [theView addSubview:titleLabel];
        [titleLabels addObject:titleLabel];
        
        UILabel *valueLabel = [self labelWithText:[invoice number]
                                            frame:CGRectMake(titleLabel.frame.size.width,
                                                             titleLabel.frame.origin.y,
                                                             labelWidth,
                                                             paperHeightPercent(2))
                                        alignment:NSTextAlignmentLeft];
        [theView addSubview:valueLabel];
        [valueLabels addObject:valueLabel];
        
        nextY += paperHeightPercent(2);
      }
        
        break;
        
      case DetailCustom1:
      case DetailCustom2:
      case DetailCustom3:
      case DetailCustom4:
      case DetailCustom5: {
        UILabel *customTitle = [self labelWithText:[NSString stringWithFormat:@"%@:", detailSetting[TITLE]]
                                             frame:CGRectMake(0,
                                                              nextY,
                                                              labelWidth,
                                                              paperHeightPercent(2))
                                         alignment:NSTextAlignmentLeft];
        [theView addSubview:customTitle];
        [titleLabels addObject:customTitle];
        
        UILabel *customValue = [self labelWithText:detailSetting[VALUE]
                                             frame:CGRectMake(customTitle.frame.size.width,
                                                              customTitle.frame.origin.y,
                                                              customTitle.frame.size.width,
                                                              paperHeightPercent(2))
                                         alignment:NSTextAlignmentLeft];
        [theView addSubview:customValue];
        [valueLabels addObject:customValue];
        
        nextY += paperHeightPercent(2);
        
        break;
      }
        
      case DetailProjectName: {
        if(![[[invoice project] projectName] isEqual:@""]) {
          UILabel * invoiceProjectName = [self labelWithText:[NSString stringWithFormat:@"%@:",[invoiceDict objectForKey:@"Project Name"]]
                                                       frame:CGRectMake(0,
                                                                        nextY,
                                                                        labelWidth,
                                                                        paperHeightPercent(2))
                                                   alignment:NSTextAlignmentLeft];
          [theView addSubview:invoiceProjectName];
          [titleLabels addObject:invoiceProjectName];
          
          UILabel * projectName = [self labelWithText:[[invoice project] projectName]
                                                frame:CGRectMake(invoiceProjectName.frame.size.width,
                                                                 invoiceProjectName.frame.origin.y,
                                                                 labelWidth,
                                                                 paperHeightPercent(2))
                                            alignment:NSTextAlignmentLeft];
          projectName.numberOfLines = 0;
          //check if text fits into label's bound
          CGSize textSize = [projectName.text sizeWithFont:projectName.font constrainedToSize:CGSizeMake(projectName.bounds.size.width, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
          if(textSize.height > projectName.frame.size.height) {
            CGRect labelFrame = projectName.frame;
            labelFrame.size.height = textSize.height;
            projectName.frame = labelFrame;
          }
          
          [theView addSubview:projectName];
          [valueLabels addObject:projectName];
          nextY += projectName.frame.size.height;
        }
        
        break;
      }
        
      case DetailProjectNo: {
        if(![[[invoice project] projectNumber] isEqual:@""]) {
          UILabel * invoiceProjectNumber = [self labelWithText:[NSString stringWithFormat:@"%@:",[invoiceDict objectForKey:@"Project No"]]
                                                         frame:CGRectMake(0,
                                                                          nextY,
                                                                          labelWidth,
                                                                          paperHeightPercent(2))
                                                     alignment:NSTextAlignmentLeft];
          
          [theView addSubview:invoiceProjectNumber];
          [titleLabels addObject:invoiceProjectNumber];
          
          UILabel * projectNumber = [self labelWithText:[[invoice project] projectNumber]
                                                  frame:CGRectMake(invoiceProjectNumber.frame.size.width,
                                                                   invoiceProjectNumber.frame.origin.y,
                                                                   labelWidth,
                                                                   paperHeightPercent(2))
                                              alignment:NSTextAlignmentLeft];
          
          [theView addSubview:projectNumber];
          [valueLabels addObject:projectNumber];
          nextY += paperHeightPercent(2);
        }
        
        break;
      }
        
      default:
        break;
    }
  }
  
  theViewFrame.size.height = nextY + paperHeightPercent(1);
  theView.frame = theViewFrame;
  
  //adjust labels position to move them to the right edge
  //values labels
  CGFloat adjustedValueX = labelWidth;
  for(UILabel *label in valueLabels) {
    CGFloat textWidth = [label.text sizeWithFont:label.font constrainedToSize:CGSizeMake(999999, label.frame.size.height) lineBreakMode:label.lineBreakMode].width;
    adjustedValueX = MIN(adjustedValueX, labelWidth - textWidth);
  }
  
  CGFloat adjustedTitleX = labelWidth;
  for(UILabel *label in titleLabels) {
    CGFloat textWidth = [label.text sizeWithFont:label.font constrainedToSize:CGSizeMake(999999, label.frame.size.height) lineBreakMode:label.lineBreakMode].width;
    adjustedTitleX = MIN(adjustedTitleX, labelWidth - textWidth);
  }
  adjustedTitleX -= 5;
  
  if(adjustedValueX > 0 && !alignRight)
    adjustedTitleX += adjustedValueX;
  
  if(adjustedTitleX > 0 || adjustedValueX > 0) {
    for(NSInteger i = 0; i < titleLabels.count; i++) {
      CGRect frame = CGRectZero;
      UILabel *label = nil;
      if(adjustedValueX > 0) {
        label = valueLabels[i];
        frame = label.frame;
        if(alignRight) {
          frame.origin.x -= adjustedTitleX;
        } else {
          frame.origin.x += adjustedValueX;
        }
        label.frame = frame;
      }
      if(adjustedTitleX > 0 && !alignRight) {
        label = titleLabels[i];
        frame = label.frame;
        frame.origin.x += adjustedTitleX;
        label.frame = frame;
      }
    }
  }

	return theView;
}

+(void)statisticsPartForInvoice:(InvoiceOBJ*)invoice inView:(UIView*)view {
	NSMutableDictionary *invoiceDict = [[NSMutableDictionary alloc] initWithDictionary:[[CustomDefaults customObjectForKey:kLanguageKeyForNSUserDefaults] objectForKey:@"invoice"]];
	
	UIView * currentPage = [PDFCreator currentPageFrom:view];
	UIView * latestView = [currentPage.subviews lastObject];
	
	for (UIView * temp in currentPage.subviews) {
		if (temp.tag != 123) {
			[temp setFrame:CGRectMake(temp.frame.origin.x, temp.frame.origin.y - paperHeightPercent(4), temp.frame.size.width, temp.frame.size.height)];
		}
	}
	
	UIImage * rightSignature = [invoice rightSignature];
	UIImage * leftSignature = [invoice leftSignature];
	
	CGFloat viewHeight = paperHeightPercent(11);
	
	if (rightSignature || leftSignature)
	{
		viewHeight = paperHeightPercent(18.4);
	}
	
	CGFloat last_Y = latestView.frame.origin.y + latestView.frame.size.height + viewHeight;

	if (last_Y >= paperHeightPercent(85))
	{
		[currentPage setTag:0];
		
		currentPage = [[UIView alloc] initWithFrame:CGRectMake(0, view.subviews.count * (paper_size.height + paperHeightPercent(1)), paper_size.width, paper_size.height)];
		[currentPage setBackgroundColor:[UIColor whiteColor]];
		[currentPage setTag:CURRENT_PAGE_TAG];
		[view addSubview:currentPage];
		
		[PDFCreator addTemplateImageTo:currentPage];
		
		last_Y = paperHeightPercent(8.3);
	}
	else
	{
		last_Y -= viewHeight;
		last_Y += paperHeightPercent(3);
	}
	
	NSString * subtotal = [data_manager currencyAdjustedValue:[invoice subtotal]];
	NSString * discount = [data_manager currencyAdjustedValue:[invoice discount]];
	NSString * total = [data_manager currencyAdjustedValue:[invoice total]];
	NSString * balance = [data_manager currencyAdjustedValue:[invoice balanceDue]];
	
	CGSize size_subtotal = [data_manager sizeForString:subtotal withFont:HelveticaNeueBold(paperWidthPercent(2)) constrainedToSize:paper_size];
	CGSize size_discount = [data_manager sizeForString:discount withFont:HelveticaNeueBold(paperWidthPercent(2)) constrainedToSize:paper_size];
	CGSize size_total = [data_manager sizeForString:total withFont:HelveticaNeueBold(paperWidthPercent(2)) constrainedToSize:paper_size];
	CGSize size_balance = [data_manager sizeForString:balance withFont:HelveticaNeueBold(paperWidthPercent(2)) constrainedToSize:paper_size];
	
	CGFloat max_width = size_subtotal.width;
	
	if (size_total.width > max_width)
		max_width = size_total.width;
	
	if (size_discount.width > max_width)
		max_width = size_discount.width;
	
	if (size_balance.width > max_width)
		max_width = size_balance.width;
	
	UIView * theView = [[UIView alloc] initWithFrame:CGRectMake(paperWidthPercent(7.6), last_Y, paperWidthPercent(84.8), viewHeight)];
	[theView setBackgroundColor:[UIColor clearColor]];
	
	CGFloat left_width = paper_size.width - max_width - paperWidthPercent(2) - paperWidthPercent(15.2);
	CGFloat right_x = left_width + paperWidthPercent(2);
	CGFloat label_y = 0;
	
	CGFloat discount_width = [data_manager sizeForString:[NSString stringWithFormat:@"%@ (%.2f%c)",[invoiceDict objectForKey:@"Discount"], [invoice discountPercentage], '%'] withFont:HelveticaNeue(paperWidthPercent(2)) constrainedToSize:paper_size].width;
	CGFloat comments_width = paper_size.width - paperWidthPercent(15.2) - max_width - paperWidthPercent(4) - discount_width;
		
	if((![[invoice tax1Name] isEqual:@""] || [invoice discountPercentage] != 0.0 || [invoice shippingValue] != 0.0) &&
       [invoice isVisibleFigureType:FigureSubtotal])
	{
		[theView addSubview:[PDFCreator leftStatusLabelWithText:[invoiceDict objectForKey:@"Subtotal"] size:left_width andY:label_y isBold:NO andMaxWidth:max_width]];
		[theView addSubview:[PDFCreator rightStatusLabelWithText:subtotal X:right_x andY:label_y isBold:NO]];
		label_y += paperHeightPercent(1.6);
	}
	
	if([invoice discountPercentage] != 0 && [invoice isVisibleFigureType:FigureDiscount])
	{
		[theView addSubview:[PDFCreator leftStatusLabelWithText:[NSString stringWithFormat:@"%@ (%.2f%c)",[invoiceDict objectForKey:@"Discount"], [invoice discountPercentage], '%'] size:left_width andY:label_y isBold:NO andMaxWidth:max_width]];
		[theView addSubview:[PDFCreator rightStatusLabelWithText:discount X:right_x andY:label_y isBold:NO]];
		label_y += paperHeightPercent(1.6);
	}
	
	if (![[invoice tax1Name] isEqual:@""] && [invoice isVisibleFigureType:FigureTax1])
	{
		[theView addSubview:[PDFCreator leftStatusLabelWithText:[NSString stringWithFormat:@"%@ (%.2f%c)", [invoice tax1Name], [invoice tax1Percentage], '%'] size:left_width andY:label_y isBold:NO andMaxWidth:max_width]];
		[theView addSubview:[PDFCreator rightStatusLabelWithText:[data_manager currencyAdjustedValue:[invoice tax1Value]] X:right_x andY:label_y isBold:NO]];
		label_y += paperHeightPercent(1.6);
	}
	
	if (![[invoice tax2Name] isEqual:@""] && [invoice isVisibleFigureType:FigureTax2])
	{
		[theView addSubview:[PDFCreator leftStatusLabelWithText:[NSString stringWithFormat:@"%@ (%.2f%c)", [invoice tax2Name], [invoice tax2Percentage], '%'] size:left_width andY:label_y isBold:NO andMaxWidth:max_width]];
		[theView addSubview:[PDFCreator rightStatusLabelWithText:[data_manager currencyAdjustedValue:[invoice tax2Value]] X:right_x andY:label_y isBold:NO]];
		label_y += paperHeightPercent(1.6);
	}
	if([invoice shippingValue] != 0 && [invoice isVisibleFigureType:FigureShipping])
	{
		[theView addSubview:[PDFCreator leftStatusLabelWithText:[invoiceDict objectForKey:@"Shipping"] size:left_width andY:label_y isBold:NO andMaxWidth:max_width]];
		[theView addSubview:[PDFCreator rightStatusLabelWithText:[data_manager currencyAdjustedValue:[invoice shippingValue]] X:right_x andY:label_y isBold:NO]];
		label_y += paperHeightPercent(1.6);
	}
	
  if([invoice isVisibleFigureType:FigureTotal]) {
      [theView addSubview:[PDFCreator leftStatusLabelWithText:[invoiceDict objectForKey:@"Total"] size:left_width andY:label_y isBold:YES andMaxWidth:max_width]];
      [theView addSubview:[PDFCreator rightStatusLabelWithText:total X:right_x andY:label_y isBold:YES]];
      label_y += paperHeightPercent(1.6);
  }

  if([invoice isVisibleFigureType:FigurePaid]) {
      [theView addSubview:[PDFCreator leftStatusLabelWithText:[invoiceDict objectForKey:@"Paid"] size:left_width andY:label_y isBold:NO andMaxWidth:max_width]];
      [theView addSubview:[PDFCreator rightStatusLabelWithText:[data_manager currencyAdjustedValue:[invoice paid]] X:right_x andY:label_y isBold:NO]];
      label_y += paperHeightPercent(1.6);
  }

  if([invoice isVisibleFigureType:FigureBalanceDue]) {
      [theView addSubview:[PDFCreator leftStatusLabelWithText:[invoiceDict objectForKey:@"Balance due"] size:left_width andY:label_y isBold:YES andMaxWidth:max_width]];
      [theView addSubview:[PDFCreator rightStatusLabelWithText:balance X:right_x andY:label_y isBold:YES]];
      label_y += paperHeightPercent(1.6);
  }
	
	if ([invoice otherCommentsText].length > 0)
	{
		UIView * otherCommentsView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, comments_width, paperHeightPercent(11.8))];
		[otherCommentsView setBackgroundColor:[UIColor clearColor]];
		[theView addSubview:otherCommentsView];
		
    UIView *titleGrayStrip = [[UIView alloc] initWithFrame:CGRectMake(0, 0, comments_width, paperHeightPercent(2.2))];
    [titleGrayStrip setBackgroundColor:[UIColor darkGrayColor]];
    [otherCommentsView addSubview:titleGrayStrip];
    titleGrayStrip.layer.borderWidth = paperHeightPercent(0.05);
    titleGrayStrip.layer.borderColor = [UIColor blackColor].CGColor;
    
		UILabel * titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(paperHeightPercent(0.5), paperHeightPercent(0.2), comments_width - paperHeightPercent(0.7), paperHeightPercent(1.8))];
		[titleLabel setText:[invoice otherCommentsTitle]];
		[titleLabel setTextAlignment:NSTextAlignmentLeft];
		[titleLabel setTextColor:[UIColor whiteColor]];
		[titleLabel setFont:HelveticaNeueBold(paperWidthPercent(2))];
		[titleLabel setBackgroundColor:[UIColor clearColor]];
		[otherCommentsView addSubview:titleLabel];
    
		UIView * commentContent = [[UIView alloc] initWithFrame:CGRectMake(0, paperHeightPercent(2.2), otherCommentsView.frame.size.width, paperHeightPercent(9.5))];
		[commentContent setBackgroundColor:[UIColor clearColor]];
		[otherCommentsView addSubview:commentContent];
    commentContent.layer.borderWidth = paperHeightPercent(0.05);
    commentContent.layer.borderColor = [UIColor blackColor].CGColor;
		
		CGSize maxSize = CGSizeMake(titleLabel.frame.size.width, paperHeightPercent(9.1));
		CGSize size = [data_manager sizeForString:[invoice otherCommentsText] withFont:HelveticaNeueBold(paperWidthPercent(2)) constrainedToSize:maxSize];
		
		UILabel * textLabel = [[UILabel alloc] initWithFrame:CGRectMake(paperHeightPercent(0.3), paperHeightPercent(0.2), titleLabel.frame.size.width, size.height)];
		[textLabel setText:[invoice otherCommentsText]];
		[textLabel setTextAlignment:NSTextAlignmentLeft];
		[textLabel setTextColor:[UIColor blackColor]];
		[textLabel setFont:HelveticaNeue(paperWidthPercent(2))];
		[textLabel setBackgroundColor:[UIColor clearColor]];
		[textLabel setNumberOfLines:5];
		[commentContent addSubview:textLabel];
	}
	
	if (rightSignature)
	{
		CGFloat imageSize = ([invoice rightSignatureFrame].size.width * paperWidthPercent(25)) / (dvc_width - 20);
		
		CGSize imgSize = [data_manager sizeOfAspectScaledSize:[invoice rightSignatureFrame].size inSize:CGSizeMake(paperWidthPercent(25), paperWidthPercent(25))];
		
		CGFloat diff = (paperWidthPercent(30) - imgSize.height) / 2;
		
		UIView * checkView = [[UIView alloc] initWithFrame:CGRectMake(paperWidthPercent(55), paperHeightPercent(6) + diff, imgSize.width, imgSize.height)];
		
		UIImageView * sigView = [[UIImageView alloc] initWithFrame:CGRectMake(paperWidthPercent(55), paperHeightPercent(6), imageSize, imageSize)];
		[sigView setCenter:checkView.center];
		[sigView setImage:rightSignature];
		[sigView setContentMode:UIViewContentModeScaleAspectFit];
		[theView addSubview:sigView];
		
		UILabel * dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(paperWidthPercent(68), paperHeightPercent(18.5), theView.frame.size.width - paperWidthPercent(68), paperHeightPercent(1.2))];
		[dateLabel setText:[invoice rightSignatureDate]];
		[dateLabel setTextAlignment:NSTextAlignmentRight];
		[dateLabel setTextColor:[UIColor blackColor]];
		[dateLabel setFont:HelveticaNeue(paperWidthPercent(2))];
		[dateLabel setBackgroundColor:[UIColor clearColor]];
		[theView addSubview:dateLabel];
		
		UIView * line = [[UIView alloc] initWithFrame:CGRectMake(paperWidthPercent(55), paperHeightPercent(20), theView.frame.size.width - paperWidthPercent(55), paperHeightPercent(0.1))];
		[line setBackgroundColor:[UIColor darkGrayColor]];
		[theView addSubview:line];
		
    CGSize titleSize = [data_manager sizeForString:[invoice rightSignatureTitle]
                                          withFont:HelveticaNeue(paperWidthPercent(2))
                                 constrainedToSize:CGSizeMake(theView.frame.size.width - paperWidthPercent(68), paperHeightPercent(5.4))];
    
		UILabel * signatureTitle = [[UILabel alloc] initWithFrame:CGRectMake(paperWidthPercent(55), paperHeightPercent(20.2), theView.frame.size.width - paperWidthPercent(68), titleSize.height)];
		[signatureTitle setText:[invoice rightSignatureTitle]];
		[signatureTitle setTextAlignment:NSTextAlignmentLeft];
		[signatureTitle setTextColor:[UIColor blackColor]];
		[signatureTitle setFont:HelveticaNeue(paperWidthPercent(2))];
		[signatureTitle setBackgroundColor:[UIColor clearColor]];
        signatureTitle.numberOfLines = 3;
		[signatureTitle setAdjustsFontSizeToFitWidth:YES];
		[theView addSubview:signatureTitle];
		
		UILabel * dateTitle = [[UILabel alloc] initWithFrame:CGRectMake(paperWidthPercent(72), paperHeightPercent(20.2), theView.frame.size.width - paperWidthPercent(72), paperHeightPercent(1.7))];
		[dateTitle setText:@"Date"];
		[dateTitle setTextAlignment:NSTextAlignmentLeft];
		[dateTitle setTextColor:[UIColor blackColor]];
		[dateTitle setFont:HelveticaNeue(paperWidthPercent(2))];
		[dateTitle setBackgroundColor:[UIColor clearColor]];
		[theView addSubview:dateTitle];
	}
	
	if (leftSignature)
	{
		CGFloat imageSize = ([invoice leftSignatureFrame].size.width * paperWidthPercent(25)) / (dvc_width - 20);
		
		CGSize imgSize = [data_manager sizeOfAspectScaledSize:[invoice leftSignatureFrame].size inSize:CGSizeMake(paperWidthPercent(25), paperWidthPercent(25))];
		
		CGFloat diff = (paperWidthPercent(30) - imgSize.height) / 2;
		
		UIView * checkView = [[UIView alloc] initWithFrame:CGRectMake(paperWidthPercent(0), paperHeightPercent(6) + diff, imgSize.width, imgSize.height)];
		
		UIImageView * sigView = [[UIImageView alloc] initWithFrame:CGRectMake(paperWidthPercent(0), paperHeightPercent(6), imageSize, imageSize)];
		[sigView setCenter:checkView.center];
		[sigView setImage:leftSignature];
		[sigView setContentMode:UIViewContentModeScaleAspectFit];
		[theView addSubview:sigView];
		
		UILabel * dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(paperWidthPercent(13), paperHeightPercent(18.5), theView.frame.size.width - paperWidthPercent(68), paperHeightPercent(1.2))];
		[dateLabel setText:[invoice leftSignatureDate]];
		[dateLabel setTextAlignment:NSTextAlignmentRight];
		[dateLabel setTextColor:[UIColor blackColor]];
		[dateLabel setFont:HelveticaNeue(paperWidthPercent(2))];
		[dateLabel setBackgroundColor:[UIColor clearColor]];
		[theView addSubview:dateLabel];
		
		UIView * line = [[UIView alloc] initWithFrame:CGRectMake(paperWidthPercent(0), paperHeightPercent(20), theView.frame.size.width - paperWidthPercent(55), paperHeightPercent(0.1))];
		[line setBackgroundColor:[UIColor darkGrayColor]];
		[theView addSubview:line];
		
    CGSize titleSize = [data_manager sizeForString:[invoice leftSignatureTitle]
                                          withFont:HelveticaNeue(paperWidthPercent(2))
                                 constrainedToSize:CGSizeMake(theView.frame.size.width - paperWidthPercent(55), paperHeightPercent(5.4))];
    
		UILabel * signatureTitle = [[UILabel alloc] initWithFrame:CGRectMake(paperWidthPercent(0), paperHeightPercent(20.2), theView.frame.size.width - paperWidthPercent(68), titleSize.height)];
		[signatureTitle setText:[invoice leftSignatureTitle]];
		[signatureTitle setTextAlignment:NSTextAlignmentLeft];
		[signatureTitle setTextColor:[UIColor blackColor]];
		[signatureTitle setFont:HelveticaNeue(paperWidthPercent(2))];
		[signatureTitle setBackgroundColor:[UIColor clearColor]];
        signatureTitle.numberOfLines = 3;
		[signatureTitle setAdjustsFontSizeToFitWidth:YES];
		[theView addSubview:signatureTitle];
		
		UILabel * dateTitle = [[UILabel alloc] initWithFrame:CGRectMake(paperWidthPercent(17), paperHeightPercent(20.2), theView.frame.size.width - paperWidthPercent(72), paperHeightPercent(1.7))];
		[dateTitle setText:@"Date"];
		[dateTitle setTextAlignment:NSTextAlignmentLeft];
		[dateTitle setTextColor:[UIColor blackColor]];
		[dateTitle setFont:HelveticaNeue(paperWidthPercent(2))];
		[dateTitle setBackgroundColor:[UIColor clearColor]];
		[theView addSubview:dateTitle];
	}
	
	[currentPage addSubview:theView];
}

#pragma mark - QUOTE

+(UIView*)PDFViewFromQuote:(QuoteOBJ*)quote
{
	UIView * theView = [[UIView alloc] init];
	
	UIView * aPage = [[UIView alloc] initWithFrame:CGRectMake(0, 0, paper_size.width, paper_size.height)];
	[aPage setBackgroundColor:[UIColor whiteColor]];
	[aPage setTag:CURRENT_PAGE_TAG];
	[theView addSubview:aPage];
	
	UILabel * noteLabel = [[UILabel alloc] initWithFrame:CGRectMake(paperWidthPercent(7.6), paperHeightPercent(92), paper_size.width - paperWidthPercent(15.2), paperHeightPercent(6))];
	[noteLabel setBackgroundColor:[UIColor clearColor]];
	[noteLabel setText:[quote note]];
	[noteLabel setTextAlignment:NSTextAlignmentCenter];
	[noteLabel setTextColor:[UIColor blackColor]];
	[noteLabel setFont:HelveticaNeue(paperWidthPercent(2))];
	[noteLabel setNumberOfLines:3];
	[noteLabel setTag:123];
	[aPage addSubview:noteLabel];
	
	[PDFCreator addTemplateImageTo:aPage];
	
  UIView *companyDetailsView = [PDFCreator companyDetailsViewForObject:quote];
  UIView *detailsView = [PDFCreator detailsForQuote:quote];
  
  if(![quote companyAlignLeft]) {
    CGRect swapFrame = companyDetailsView.frame;
    CGFloat frameX = swapFrame.origin.x;
    swapFrame.origin.x = detailsView.frame.origin.x;
    companyDetailsView.frame = swapFrame;
    
    swapFrame = detailsView.frame;
    swapFrame.origin.x = frameX;
    detailsView.frame = swapFrame;
  }
  
  //shift views up
  if(![data_manager templateImage]) {
    CGFloat newY = paperHeightPercent(8.3) * (2.f/3.f);
    CGRect swapFrame = companyDetailsView.frame;
    swapFrame.origin.y = newY;
    companyDetailsView.frame = swapFrame;
    
    swapFrame = detailsView.frame;
    swapFrame.origin.y = newY;
    detailsView.frame = swapFrame;
  }
    
  CGFloat detailsHeight = MAX(CGRectGetMaxY(detailsView.frame), CGRectGetMaxY(companyDetailsView.frame));
  
  [aPage addSubview:companyDetailsView];
  [aPage addSubview:detailsView];
  
  
	//----
  NSArray *clientOrder = [quote clientFieldsOrder];
  CGFloat maxDetailY = MAX(paperHeightPercent(29.3), detailsHeight);
  
  NSInteger orderIndex = 0;
  if([clientOrder count] > 0) {
    for(NSNumber *clientType in clientOrder) {
      AddressOBJ *clientAddress = nil;
      NSString *addressTitle = @"";
      
      if([clientType integerValue] == ClientBilling) {
        clientAddress = [[quote client] billingAddress];
        addressTitle = [clientAddress billingTitle];
      } else if ([clientType integerValue] == ClientShipping) {
        clientAddress = [[quote client] shippingAddress];
        addressTitle = [clientAddress shippingTitle];
      }
      
      clientAddress.billingKey = kQuoteBillingAddressTitleKeyForNSUserDefaults;
      clientAddress.shippingKey = kQuoteShippingAddressTitleKeyForNSUserDefaults;
      
      if (clientAddress.fullStringRepresentation.length > 0 || ([clientType integerValue] == ClientBilling && [[[quote client] firstName] length] > 0)) {
        UIView * clientAddressView = [PDFCreator viewFromAddress:clientAddress
                                                       withTitle:[NSString stringWithFormat:@"%@:",addressTitle]
                                                     companyName:[[quote client] company]
                                                    customerName:[NSString stringWithFormat:@"%@ %@", [[quote client] firstName], [[quote client] lastName]]];
        
        CGFloat addressX = orderIndex == 0?paperWidthPercent(7.6):paper_size.width - paperWidthPercent(7.6) - clientAddressView.frame.size.width;
        [clientAddressView setFrame:CGRectMake(addressX,
                                               detailsHeight + paperHeightPercent(1),
                                               clientAddressView.frame.size.width,
                                               clientAddressView.frame.size.height)];
        [aPage addSubview:clientAddressView];
        
        maxDetailY = MAX(maxDetailY, CGRectGetMaxY(clientAddressView.frame));
        
        orderIndex++;
      }
    }
  }
	//------
	BOOL has_discount = NO;
	
	for (NSDictionary * object in [quote products])
	{
		if ([[object allKeys] containsObject:@"class"] && NSClassFromString([object objectForKey:@"class"]) == [ProductOBJ class])
		{
			ProductOBJ * product = [[ProductOBJ alloc] initWithContentsDictionary:object];
			
			if ([product discount] > 0.0f)
			{
				has_discount = YES;
				break;
			}
		}
		else if ([[object allKeys] containsObject:@"class"] && NSClassFromString([object objectForKey:@"class"]) == [ServiceOBJ class])
		{
			ServiceOBJ * service = [[ServiceOBJ alloc] initWithContentsDictionary:object];
			
			if ([service discount] > 0.0f)
			{
				has_discount = YES;
				break;
			}
		}
	}
	
	[aPage addSubview:[PDFCreator headerViewWithY:maxDetailY + paperHeightPercent(2)
                                      hasDiscount:has_discount
                                          andType:2
                                        andObject:quote]];
	
//	UIImage * rightSignature = [quote rightSignature];
//	UIImage * leftSignature = [quote leftSignature];
	
	BOOL hasSignature = NO;
	
//	if (rightSignature || leftSignature)
//	{
//		hasSignature = YES;
//	}
	
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
	
	for (NSDictionary * object in [quote products])
	{
		[PDFCreator addObject:object toView:theView andObject:quote];
	}
	
	UIView * currentPage = [PDFCreator currentPageFrom:theView];
	UIView * latestView = [currentPage.subviews lastObject];
	CGFloat last_Y = latestView.frame.origin.y + latestView.frame.size.height;
	
	if (last_Y < paperHeightPercent(60))
	{
		CGFloat difference = paperHeightPercent(60) - last_Y;
		int count = (int)difference / paperHeightPercent(1.5);
		
		for (int i = 0; i < count; i++)
		{
			[PDFCreator addObject:nil toView:theView andObject:nil];
		}
	}
	
	latestView = [currentPage.subviews lastObject];
	UIView * lineBottom = [[UIView alloc] initWithFrame:CGRectMake(0, latestView.frame.size.height - paperHeightPercent(0.05), latestView.frame.size.width, paperHeightPercent(0.05))];
	[lineBottom setBackgroundColor:[UIColor blackColor]];
	[latestView addSubview:lineBottom];
	
	aPage = [PDFCreator currentPageFrom:theView];
	
	[PDFCreator statisticsPartForQuote:quote inView:theView];
	
	aPage = [PDFCreator currentPageFrom:theView];
	
	if ([quote bigNote].length > 0)
	{
		[aPage setTag:0];
		
		aPage = [[UIView alloc] initWithFrame:CGRectMake(0, theView.subviews.count * (paper_size.height + paperHeightPercent(1)), paper_size.width, paper_size.height)];
		[aPage setBackgroundColor:[UIColor whiteColor]];
		[aPage setTag:CURRENT_PAGE_TAG];
		[theView addSubview:aPage];
		
		[PDFCreator addTemplateImageTo:aPage];
		
		CGFloat last_Y = paperHeightPercent(8.3);
		
		CGSize maxSize = CGSizeMake(paper_size.width - paperWidthPercent(15.2), paper_size.height);
		CGSize size = [data_manager sizeForString:[quote bigNote] withFont:HelveticaNeue(paperWidthPercent(2)) constrainedToSize:maxSize];
		
		UILabel * otherNotes = [[UILabel alloc] initWithFrame:CGRectMake(paperWidthPercent(7.6), last_Y, paper_size.width - paperWidthPercent(15.2), size.height)];
		[otherNotes setText:[quote bigNote]];
		[otherNotes setTextAlignment:NSTextAlignmentLeft];
		[otherNotes setTextColor:[UIColor blackColor]];
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

+(UIView*)detailsForQuote:(QuoteOBJ*)quote
{
	NSMutableDictionary *quoteDict = [[NSMutableDictionary alloc] initWithDictionary:[[CustomDefaults customObjectForKey:kLanguageKeyForNSUserDefaults] objectForKey:@"quote"]];
	
	CGRect theViewFrame = CGRectMake(paper_size.width - paperWidthPercent(7.6) - paperWidthPercent(35),
                                   paperHeightPercent(8.3),
                                   paperWidthPercent(35),
                                   paperHeightPercent(18));
	
	UIView * theView = [[UIView alloc] initWithFrame:theViewFrame];
	[theView setBackgroundColor:[UIColor clearColor]];
  
  BOOL alignRight = ![quote companyAlignLeft];
	
	UILabel * titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                                   0,
                                                                   theView.frame.size.width,
                                                                   paperHeightPercent(4))];
//	[titleLabel setText:@"Quote"];
	[titleLabel setText:[quote title]];
	[titleLabel setTextAlignment:alignRight?NSTextAlignmentLeft:NSTextAlignmentRight];
	[titleLabel setTextColor:[UIColor blackColor]];
	[titleLabel setFont:HelveticaNeueBold(paperWidthPercent(6))];
	[titleLabel setBackgroundColor:[UIColor clearColor]];
	[titleLabel setAdjustsFontSizeToFitWidth:YES];
	[theView addSubview:titleLabel];
	
  CGFloat labelWidth = theViewFrame.size.width / 2.f;
  NSMutableArray *valueLabels = [NSMutableArray new];
  NSMutableArray *titleLabels = [NSMutableArray new];
  CGFloat nextY = titleLabel.frame.origin.y + titleLabel.frame.size.height + paperHeightPercent(1.5);
  
  NSArray *visibleDetails = [quote visibleRowsInDetailsSection];
  
  for(NSDictionary *detailSetting in visibleDetails) {
    switch ([detailSetting[TYPE] integerValue]) {
      case DetailProjNumber: {
        UILabel *titleLabel = [self labelWithText:[NSString stringWithFormat:@"%@:",[quoteDict objectForKey:@"Quote No"]]
                                            frame:CGRectMake(0,
                                                             nextY,
                                                             labelWidth,
                                                             paperHeightPercent(2))
                                        alignment:NSTextAlignmentLeft];
        [theView addSubview:titleLabel];
        [titleLabels addObject:titleLabel];
        
        UILabel *valueLabel = [self labelWithText:[quote number]
                                            frame:CGRectMake(titleLabel.frame.size.width,
                                                             titleLabel.frame.origin.y,
                                                             labelWidth,
                                                             paperHeightPercent(2))
                                        alignment:NSTextAlignmentLeft];
        [theView addSubview:valueLabel];
        [valueLabels addObject:valueLabel];
        
        nextY += paperHeightPercent(2);
      }
        
        break;
        
      case DetailCustom1:
      case DetailCustom2:
      case DetailCustom3:
      case DetailCustom4:
      case DetailCustom5: {
        UILabel * customTitle = [self labelWithText:[NSString stringWithFormat:@"%@:", detailSetting[TITLE]]
                                              frame:CGRectMake(0,
                                                               nextY,
                                                               labelWidth,
                                                               paperHeightPercent(2))
                                          alignment:NSTextAlignmentLeft];
        [theView addSubview:customTitle];
        [titleLabels addObject:customTitle];
        
        UILabel * customValue = [self labelWithText:detailSetting[VALUE]
                                              frame:CGRectMake(customTitle.frame.size.width,
                                                               customTitle.frame.origin.y,
                                                               customTitle.frame.size.width,
                                                               paperHeightPercent(2))
                                          alignment:NSTextAlignmentLeft];
        [theView addSubview:customValue];
        [valueLabels addObject:customValue];
        
        nextY += paperHeightPercent(2);
        
        break;
      }
        
      case DetailProjectName: {
        if(![[[quote project] projectName] isEqual:@""]) {
          UILabel * invoiceProjectName = [self labelWithText:[NSString stringWithFormat:@"%@:",[quoteDict objectForKey:@"Project Name"]]
                                                       frame:CGRectMake(0,
                                                                        nextY,
                                                                        labelWidth,
                                                                        paperHeightPercent(2))
                                                   alignment:NSTextAlignmentLeft];
          [theView addSubview:invoiceProjectName];
          [titleLabels addObject:invoiceProjectName];
          
          UILabel * projectName = [self labelWithText:[[quote project] projectName]
                                                frame:CGRectMake(invoiceProjectName.frame.size.width,
                                                                 invoiceProjectName.frame.origin.y,
                                                                 labelWidth,
                                                                 paperHeightPercent(2))
                                            alignment:NSTextAlignmentLeft];
          projectName.numberOfLines = 0;
          //check if text fits into label's bound
          CGSize textSize = [projectName.text sizeWithFont:projectName.font constrainedToSize:CGSizeMake(projectName.bounds.size.width, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
          if(textSize.height > projectName.frame.size.height) {
            CGRect labelFrame = projectName.frame;
            labelFrame.size.height = textSize.height;
            projectName.frame = labelFrame;
          }
          
          [theView addSubview:projectName];
          [valueLabels addObject:projectName];
          nextY += projectName.frame.size.height;
        }
        
        break;
      }
        
      case DetailProjectNo: {
        if(![[[quote project] projectNumber] isEqual:@""]) {
          UILabel * invoiceProjectNumber = [self labelWithText:[NSString stringWithFormat:@"%@:",[quoteDict objectForKey:@"Project No"]]
                                                         frame:CGRectMake(0,
                                                                          nextY,
                                                                          labelWidth,
                                                                          paperHeightPercent(2))
                                                     alignment:NSTextAlignmentLeft];
          
          [theView addSubview:invoiceProjectNumber];
          [titleLabels addObject:invoiceProjectNumber];
          
          UILabel * projectNumber = [self labelWithText:[[quote project] projectNumber]
                                                  frame:CGRectMake(invoiceProjectNumber.frame.size.width,
                                                                   invoiceProjectNumber.frame.origin.y,
                                                                   labelWidth,
                                                                   paperHeightPercent(2))
                                              alignment:NSTextAlignmentLeft];
          
          [theView addSubview:projectNumber];
          [valueLabels addObject:projectNumber];
          nextY += paperHeightPercent(2);
        }
        
        break;
      }

        
      default:
        break;
    }
  }
  
  UILabel *dateLabel = [self labelWithText:[NSString stringWithFormat:@"%@:",[quoteDict objectForKey:@"Quote date"]]
                                      frame:CGRectMake(0,
                                                       nextY,
                                                       labelWidth,
                                                       paperHeightPercent(2))
                                  alignment:NSTextAlignmentLeft];
  [theView addSubview:dateLabel];
  [titleLabels addObject:dateLabel];
  
  UILabel *dateValueLabel = [self labelWithText:[quote creationDate]
                                      frame:CGRectMake(dateLabel.frame.size.width,
                                                       dateLabel.frame.origin.y,
                                                       labelWidth,
                                                       paperHeightPercent(2))
                                  alignment:NSTextAlignmentLeft];
  [theView addSubview:dateValueLabel];
  [valueLabels addObject:dateValueLabel];
  nextY += paperHeightPercent(2);
  
  theViewFrame.size.height = nextY + paperHeightPercent(2);
  theView.frame = theViewFrame;
  
  //adjust labels position to move them to the right edge
  //values labels
  CGFloat adjustedValueX = labelWidth;
  for(UILabel *label in valueLabels) {
    CGFloat textWidth = [label.text sizeWithFont:label.font constrainedToSize:CGSizeMake(999999, label.frame.size.height) lineBreakMode:label.lineBreakMode].width;
    adjustedValueX = MIN(adjustedValueX, labelWidth - textWidth);
  }
  
  CGFloat adjustedTitleX = labelWidth;
  for(UILabel *label in titleLabels) {
    CGFloat textWidth = [label.text sizeWithFont:label.font constrainedToSize:CGSizeMake(999999, label.frame.size.height) lineBreakMode:label.lineBreakMode].width;
    adjustedTitleX = MIN(adjustedTitleX, labelWidth - textWidth);
  }
  adjustedTitleX -= 5;
  
  if(adjustedValueX > 0 && !alignRight)
    adjustedTitleX += adjustedValueX;
  
  if(adjustedTitleX > 0 || adjustedValueX > 0) {
    for(NSInteger i = 0; i < titleLabels.count; i++) {
      CGRect frame = CGRectZero;
      UILabel *label = nil;
      if(adjustedValueX > 0) {
        label = valueLabels[i];
        frame = label.frame;
        if(alignRight) {
          frame.origin.x -= adjustedTitleX;
        } else {
          frame.origin.x += adjustedValueX;
        }
        label.frame = frame;
      }
      if(adjustedTitleX > 0 && !alignRight) {
        label = titleLabels[i];
        frame = label.frame;
        frame.origin.x += adjustedTitleX;
        label.frame = frame;
      }
    }
  }
		
	return theView;
}

+(void)statisticsPartForQuote:(QuoteOBJ*)quote inView:(UIView*)view
{
	NSMutableDictionary *quoteDict = [[NSMutableDictionary alloc] initWithDictionary:[[CustomDefaults customObjectForKey:kLanguageKeyForNSUserDefaults] objectForKey:@"quote"]];
	
	UIView * currentPage = [PDFCreator currentPageFrom:view];
	UIView * latestView = [currentPage.subviews lastObject];
	
	for (UIView * temp in currentPage.subviews)
	{
		if (temp.tag != 123)
		{
			[temp setFrame:CGRectMake(temp.frame.origin.x, temp.frame.origin.y - paperHeightPercent(4), temp.frame.size.width, temp.frame.size.height)];
		}
	}
	
	UIImage * rightSignature = [quote rightSignature];
	UIImage * leftSignature = [quote leftSignature];
	
	CGFloat viewHeight = paperHeightPercent(11);
	
	if (rightSignature || leftSignature)
	{
		viewHeight = paperHeightPercent(18.4);
	}
	
	CGFloat last_Y = latestView.frame.origin.y + latestView.frame.size.height + viewHeight;
	
	if (last_Y >= paperHeightPercent(85))
	{
		[currentPage setTag:0];
		
		currentPage = [[UIView alloc] initWithFrame:CGRectMake(0, view.subviews.count * (paper_size.height + paperHeightPercent(1)), paper_size.width, paper_size.height)];
		[currentPage setBackgroundColor:[UIColor whiteColor]];
		[currentPage setTag:CURRENT_PAGE_TAG];
		[view addSubview:currentPage];
		
		[PDFCreator addTemplateImageTo:currentPage];
		
		last_Y = paperHeightPercent(8.3);
	}
	else
	{
		last_Y -= viewHeight;
		last_Y += paperHeightPercent(3);
	}
	
	NSString * subtotal = [data_manager currencyAdjustedValue:[quote subtotal]];
	NSString * discount = [data_manager currencyAdjustedValue:[quote discount]];
	NSString * total = [data_manager currencyAdjustedValue:[quote total]];
	
	CGSize size_subtotal = [data_manager sizeForString:subtotal withFont:HelveticaNeueBold(paperWidthPercent(2)) constrainedToSize:paper_size];
	CGSize size_discount = [data_manager sizeForString:discount withFont:HelveticaNeueBold(paperWidthPercent(2)) constrainedToSize:paper_size];
	CGSize size_total = [data_manager sizeForString:total withFont:HelveticaNeueBold(paperWidthPercent(2)) constrainedToSize:paper_size];
	
	CGFloat max_width = size_subtotal.width;
	
	if (size_total.width > max_width)
		max_width = size_total.width;
	
	if (size_discount.width > max_width)
		max_width = size_discount.width;
	
	UIView * theView = [[UIView alloc] initWithFrame:CGRectMake(paperWidthPercent(7.6), last_Y, paperWidthPercent(84.8), viewHeight)];
	[theView setBackgroundColor:[UIColor clearColor]];
	
	CGFloat left_width = paper_size.width - max_width - paperWidthPercent(2) - paperWidthPercent(15.2);
	CGFloat right_x = left_width + paperWidthPercent(2);
	CGFloat label_y = 0;
	
	CGFloat discount_width = [data_manager sizeForString:[NSString stringWithFormat:@"%@ (%.2f%c)",[quoteDict objectForKey:@"Discount"], [quote discountPercentage], '%'] withFont:HelveticaNeue(paperWidthPercent(2)) constrainedToSize:paper_size].width;
	CGFloat comments_width = paper_size.width - paperWidthPercent(15.2) - max_width - paperWidthPercent(4) - discount_width;

	if(![[quote tax1Name] isEqual:@""] || [quote discountPercentage] != 0 || [quote shippingValue] != 0)
	{
		[theView addSubview:[PDFCreator leftStatusLabelWithText:[quoteDict objectForKey:@"Subtotal"] size:left_width andY:label_y isBold:NO andMaxWidth:max_width]];
		[theView addSubview:[PDFCreator rightStatusLabelWithText:subtotal X:right_x andY:label_y isBold:NO]];
		label_y += paperHeightPercent(1.6);
	}
	
	if([quote discountPercentage] != 0)
	{
		[theView addSubview:[PDFCreator leftStatusLabelWithText:[NSString stringWithFormat:@"%@ (%.2f%c)",[quoteDict objectForKey:@"Discount"], [quote discountPercentage], '%'] size:left_width andY:label_y isBold:NO andMaxWidth:max_width]];
		[theView addSubview:[PDFCreator rightStatusLabelWithText:discount X:right_x andY:label_y isBold:NO]];
		label_y += paperHeightPercent(1.6);
	}
	
	if (![[quote tax1Name] isEqual:@""])
	{
		[theView addSubview:[PDFCreator leftStatusLabelWithText:[NSString stringWithFormat:@"%@ (%.2f%c)", [quote tax1Name], [quote tax1Percentage], '%'] size:left_width andY:label_y isBold:NO andMaxWidth:max_width]];
		[theView addSubview:[PDFCreator rightStatusLabelWithText:[data_manager currencyAdjustedValue:[quote tax1Value]] X:right_x andY:label_y isBold:NO]];
		label_y += paperHeightPercent(1.6);
	}
	
	if (![[quote tax2Name] isEqual:@""])
	{
		[theView addSubview:[PDFCreator leftStatusLabelWithText:[NSString stringWithFormat:@"%@ (%.2f%c)", [quote tax2Name], [quote tax2Percentage], '%'] size:left_width andY:label_y isBold:NO andMaxWidth:max_width]];
		[theView addSubview:[PDFCreator rightStatusLabelWithText:[data_manager currencyAdjustedValue:[quote tax2Value]] X:right_x andY:label_y isBold:NO]];
		label_y += paperHeightPercent(1.6);
	}
	
	if([quote shippingValue] != 0)
	{
		[theView addSubview:[PDFCreator leftStatusLabelWithText:[quoteDict objectForKey:@"Shipping"] size:left_width andY:label_y isBold:NO andMaxWidth:max_width]];
		[theView addSubview:[PDFCreator rightStatusLabelWithText:[data_manager currencyAdjustedValue:[quote shippingValue]] X:right_x andY:label_y isBold:NO]];
		label_y += paperHeightPercent(1.6);
	}
	
	[theView addSubview:[PDFCreator leftStatusLabelWithText:[quoteDict objectForKey:@"Total"] size:left_width andY:label_y isBold:YES andMaxWidth:max_width]];
	[theView addSubview:[PDFCreator rightStatusLabelWithText:total X:right_x andY:label_y isBold:YES]];
	label_y += paperHeightPercent(1.6);
	
	if ([quote otherCommentsText].length > 0)
	{
		UIView * otherCommentsView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, comments_width, paperHeightPercent(11.8))];
		[otherCommentsView setBackgroundColor:[UIColor clearColor]];
		[theView addSubview:otherCommentsView];
    
    UIView *titleGrayStrip = [[UIView alloc] initWithFrame:CGRectMake(0, 0, comments_width, paperHeightPercent(2.2))];
    [titleGrayStrip setBackgroundColor:[UIColor darkGrayColor]];
    [otherCommentsView addSubview:titleGrayStrip];
    titleGrayStrip.layer.borderWidth = paperHeightPercent(0.05);
    titleGrayStrip.layer.borderColor = [UIColor blackColor].CGColor;
		
		UILabel * titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(paperHeightPercent(0.5), paperHeightPercent(0.2), comments_width - paperHeightPercent(0.7), paperHeightPercent(1.8))];
		[titleLabel setText:[quote otherCommentsTitle]];
		[titleLabel setTextAlignment:NSTextAlignmentLeft];
		[titleLabel setTextColor:[UIColor whiteColor]];
		[titleLabel setFont:HelveticaNeueBold(paperWidthPercent(2))];
		[titleLabel setBackgroundColor:[UIColor clearColor]];
		[otherCommentsView addSubview:titleLabel];
		
		UIView * commentContent = [[UIView alloc] initWithFrame:CGRectMake(0, paperHeightPercent(2.2), otherCommentsView.frame.size.width, paperHeightPercent(9.5))];
		[commentContent setBackgroundColor:[UIColor clearColor]];
		[otherCommentsView addSubview:commentContent];
    commentContent.layer.borderWidth = paperHeightPercent(0.05);
    commentContent.layer.borderColor = [UIColor blackColor].CGColor;
		
		CGSize maxSize = CGSizeMake(titleLabel.frame.size.width, paperHeightPercent(9.1));
		CGSize size = [data_manager sizeForString:[quote otherCommentsText] withFont:HelveticaNeueBold(paperWidthPercent(2)) constrainedToSize:maxSize];
		
		UILabel * textLabel = [[UILabel alloc] initWithFrame:CGRectMake(paperHeightPercent(0.3), paperHeightPercent(0.2), titleLabel.frame.size.width, size.height)];
		[textLabel setText:[quote otherCommentsText]];
		[textLabel setTextAlignment:NSTextAlignmentLeft];
		[textLabel setTextColor:[UIColor blackColor]];
		[textLabel setFont:HelveticaNeue(paperWidthPercent(2))];
		[textLabel setBackgroundColor:[UIColor clearColor]];
		[textLabel setNumberOfLines:5];
		[commentContent addSubview:textLabel];
	}
	
	if (rightSignature)
	{
		CGFloat imageSize = ([quote rightSignatureFrame].size.width * paperWidthPercent(25)) / (dvc_width - 20);
		
		CGSize imgSize = [data_manager sizeOfAspectScaledSize:[quote rightSignatureFrame].size inSize:CGSizeMake(paperWidthPercent(25), paperWidthPercent(25))];
		
		CGFloat diff = (paperWidthPercent(30) - imgSize.height) / 2;
		
		UIView * checkView = [[UIView alloc] initWithFrame:CGRectMake(paperWidthPercent(55), paperHeightPercent(6) + diff, imgSize.width, imgSize.height)];
		
		UIImageView * sigView = [[UIImageView alloc] initWithFrame:CGRectMake(paperWidthPercent(55), paperHeightPercent(6), imageSize, imageSize)];
		[sigView setCenter:checkView.center];
		[sigView setImage:rightSignature];
		[sigView setContentMode:UIViewContentModeScaleAspectFit];
		[theView addSubview:sigView];
		
		UILabel * dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(paperWidthPercent(68), paperHeightPercent(18.5), theView.frame.size.width - paperWidthPercent(68), paperHeightPercent(1.2))];
		[dateLabel setText:[quote rightSignatureDate]];
		[dateLabel setTextAlignment:NSTextAlignmentRight];
		[dateLabel setTextColor:[UIColor blackColor]];
		[dateLabel setFont:HelveticaNeue(paperWidthPercent(2))];
		[dateLabel setBackgroundColor:[UIColor clearColor]];
		[theView addSubview:dateLabel];
		
		UIView * line = [[UIView alloc] initWithFrame:CGRectMake(paperWidthPercent(55), paperHeightPercent(20), theView.frame.size.width - paperWidthPercent(55), paperHeightPercent(0.1))];
		[line setBackgroundColor:[UIColor darkGrayColor]];
		[theView addSubview:line];
		
    CGSize titleSize = [data_manager sizeForString:[quote rightSignatureTitle]
                                          withFont:HelveticaNeue(paperWidthPercent(2))
                                 constrainedToSize:CGSizeMake(theView.frame.size.width - paperWidthPercent(68), paperHeightPercent(5.4))];
    
		UILabel * signatureTitle = [[UILabel alloc] initWithFrame:CGRectMake(paperWidthPercent(55), paperHeightPercent(20.2), theView.frame.size.width - paperWidthPercent(68), titleSize.height)];
		[signatureTitle setText:[quote rightSignatureTitle]];
		[signatureTitle setTextAlignment:NSTextAlignmentLeft];
		[signatureTitle setTextColor:[UIColor blackColor]];
		[signatureTitle setFont:HelveticaNeue(paperWidthPercent(2))];
		[signatureTitle setBackgroundColor:[UIColor clearColor]];
        signatureTitle.numberOfLines = 3;
		[signatureTitle setAdjustsFontSizeToFitWidth:YES];
		[theView addSubview:signatureTitle];
		
		UILabel * dateTitle = [[UILabel alloc] initWithFrame:CGRectMake(paperWidthPercent(72), paperHeightPercent(20.2), theView.frame.size.width - paperWidthPercent(72), paperHeightPercent(1.7))];
		[dateTitle setText:@"Date"];
		[dateTitle setTextAlignment:NSTextAlignmentLeft];
		[dateTitle setTextColor:[UIColor blackColor]];
		[dateTitle setFont:HelveticaNeue(paperWidthPercent(2))];
		[dateTitle setBackgroundColor:[UIColor clearColor]];
		[theView addSubview:dateTitle];
	}
	
	if (leftSignature)
	{
    CGFloat imageSize = ([quote leftSignatureFrame].size.width * paperWidthPercent(25)) / (dvc_width - 20);
		
		CGSize imgSize = [data_manager sizeOfAspectScaledSize:[quote leftSignatureFrame].size inSize:CGSizeMake(paperWidthPercent(25), paperWidthPercent(25))];
		
		CGFloat diff = (paperWidthPercent(30) - imgSize.height) / 2;
		
		UIView * checkView = [[UIView alloc] initWithFrame:CGRectMake(paperWidthPercent(0), paperHeightPercent(6) + diff, imgSize.width, imgSize.height)];
		
		UIImageView * sigView = [[UIImageView alloc] initWithFrame:CGRectMake(paperWidthPercent(0), paperHeightPercent(6), imageSize, imageSize)];
		[sigView setCenter:checkView.center];
		[sigView setImage:leftSignature];
		[sigView setContentMode:UIViewContentModeScaleAspectFit];
		[theView addSubview:sigView];
		
		UILabel * dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(paperWidthPercent(13), paperHeightPercent(18.5), theView.frame.size.width - paperWidthPercent(68), paperHeightPercent(1.2))];
		[dateLabel setText:[quote leftSignatureDate]];
		[dateLabel setTextAlignment:NSTextAlignmentRight];
		[dateLabel setTextColor:[UIColor blackColor]];
		[dateLabel setFont:HelveticaNeue(paperWidthPercent(2))];
		[dateLabel setBackgroundColor:[UIColor clearColor]];
		[theView addSubview:dateLabel];
		
		UIView * line = [[UIView alloc] initWithFrame:CGRectMake(paperWidthPercent(0), paperHeightPercent(20), theView.frame.size.width - paperWidthPercent(55), paperHeightPercent(0.1))];
		[line setBackgroundColor:[UIColor darkGrayColor]];
		[theView addSubview:line];
    
    CGSize titleSize = [data_manager sizeForString:[quote leftSignatureTitle]
                                          withFont:HelveticaNeue(paperWidthPercent(2))
                                 constrainedToSize:CGSizeMake(theView.frame.size.width - paperWidthPercent(68), paperHeightPercent(5.4))];
		
		UILabel * signatureTitle = [[UILabel alloc] initWithFrame:CGRectMake(paperWidthPercent(0), paperHeightPercent(20.2), theView.frame.size.width - paperWidthPercent(68), titleSize.height)];
		[signatureTitle setText:[quote leftSignatureTitle]];
		[signatureTitle setTextAlignment:NSTextAlignmentLeft];
		[signatureTitle setTextColor:[UIColor blackColor]];
		[signatureTitle setFont:HelveticaNeue(paperWidthPercent(2))];
		[signatureTitle setBackgroundColor:[UIColor clearColor]];
        signatureTitle.numberOfLines = 3;
		[signatureTitle setAdjustsFontSizeToFitWidth:YES];
		[theView addSubview:signatureTitle];
		
		UILabel * dateTitle = [[UILabel alloc] initWithFrame:CGRectMake(paperWidthPercent(17), paperHeightPercent(20.2), theView.frame.size.width - paperWidthPercent(72), paperHeightPercent(1.7))];
		[dateTitle setText:@"Date"];
		[dateTitle setTextAlignment:NSTextAlignmentLeft];
		[dateTitle setTextColor:[UIColor blackColor]];
		[dateTitle setFont:HelveticaNeue(paperWidthPercent(2))];
		[dateTitle setBackgroundColor:[UIColor clearColor]];
		[theView addSubview:dateTitle];
	}
	
	[currentPage addSubview:theView];
}

#pragma mark - ESTIMATE

+(UIView*)PDFViewFromEstimate:(EstimateOBJ*)estimate
{
	UIView * theView = [[UIView alloc] init];
	
	UIView * aPage = [[UIView alloc] initWithFrame:CGRectMake(0, 0, paper_size.width, paper_size.height)];
	[aPage setBackgroundColor:[UIColor whiteColor]];
	[aPage setTag:CURRENT_PAGE_TAG];
	[theView addSubview:aPage];
	
	UILabel * noteLabel = [[UILabel alloc] initWithFrame:CGRectMake(paperWidthPercent(7.6), paperHeightPercent(92), paper_size.width - paperWidthPercent(15.2), paperHeightPercent(6))];
	[noteLabel setBackgroundColor:[UIColor clearColor]];
	[noteLabel setText:[estimate note]];
	[noteLabel setTextAlignment:NSTextAlignmentCenter];
	[noteLabel setTextColor:[UIColor blackColor]];
	[noteLabel setFont:HelveticaNeue(paperWidthPercent(2))];
	[noteLabel setNumberOfLines:3];
	[noteLabel setTag:123];
	[aPage addSubview:noteLabel];
	
	[PDFCreator addTemplateImageTo:aPage];
	
  UIView *companyDetailsView = [PDFCreator companyDetailsViewForObject:estimate];
  UIView *detailsView = [PDFCreator detailsForEstimate:estimate];
  
  if(![estimate companyAlignLeft]) {
    CGRect swapFrame = companyDetailsView.frame;
    CGFloat frameX = swapFrame.origin.x;
    swapFrame.origin.x = detailsView.frame.origin.x;
    companyDetailsView.frame = swapFrame;
    
    swapFrame = detailsView.frame;
    swapFrame.origin.x = frameX;
    detailsView.frame = swapFrame;
  }
  
  //shift views up
  if(![data_manager templateImage]) {
    CGFloat newY = paperHeightPercent(8.3) * (2.f/3.f);
    CGRect swapFrame = companyDetailsView.frame;
    swapFrame.origin.y = newY;
    companyDetailsView.frame = swapFrame;
    
    swapFrame = detailsView.frame;
    swapFrame.origin.y = newY;
    detailsView.frame = swapFrame;
  }
  
  CGFloat detailsHeight = MAX(CGRectGetMaxY(detailsView.frame), CGRectGetMaxY(companyDetailsView.frame));
  
  [aPage addSubview:companyDetailsView];
  [aPage addSubview:detailsView];
	//----
  NSArray *clientOrder = [estimate clientFieldsOrder];
  CGFloat maxDetailY = MAX(paperHeightPercent(29.3), detailsHeight);
  
  NSInteger orderIndex = 0;
  if([clientOrder count] > 0) {
    for(NSNumber *clientType in clientOrder) {
      AddressOBJ *clientAddress = nil;
      NSString *addressTitle = @"";
      
      if([clientType integerValue] == ClientBilling) {
        clientAddress = [[estimate client] billingAddress];
        addressTitle = [clientAddress billingTitle];
      } else if ([clientType integerValue] == ClientShipping) {
        clientAddress = [[estimate client] shippingAddress];
        addressTitle = [clientAddress shippingTitle];
      }
      
      clientAddress.billingKey = kEstimateBillingAddressTitleKeyForNSUserDefaults;
      clientAddress.shippingKey = kEstimateShippingAddressTitleKeyForNSUserDefaults;
      
      if (clientAddress.fullStringRepresentation.length > 0 || ([clientType integerValue] == ClientBilling && [[[estimate client] firstName] length] > 0)) {
        UIView * clientAddressView = [PDFCreator viewFromAddress:clientAddress
                                                       withTitle:[NSString stringWithFormat:@"%@:",addressTitle]
                                                     companyName:[[estimate client] company]
                                                    customerName:[NSString stringWithFormat:@"%@ %@", [[estimate client] firstName], [[estimate client] lastName]]];
        
        CGFloat addressX = orderIndex == 0?paperWidthPercent(7.6):paper_size.width - paperWidthPercent(7.6) - clientAddressView.frame.size.width;
        [clientAddressView setFrame:CGRectMake(addressX,
                                               detailsHeight + paperHeightPercent(1),
                                               clientAddressView.frame.size.width,
                                               clientAddressView.frame.size.height)];
        [aPage addSubview:clientAddressView];
        
        maxDetailY = MAX(maxDetailY, CGRectGetMaxY(clientAddressView.frame));
        
        orderIndex++;
      }
    }
  }
  //-----
	BOOL has_discount = NO;
	
	for (NSDictionary * object in [estimate products])
	{
		if ([[object allKeys] containsObject:@"class"] && NSClassFromString([object objectForKey:@"class"]) == [ProductOBJ class])
		{
			ProductOBJ * product = [[ProductOBJ alloc] initWithContentsDictionary:object];
			
			if ([product discount] > 0.0f)
			{
				has_discount = YES;
				break;
			}
		}
		else if ([[object allKeys] containsObject:@"class"] && NSClassFromString([object objectForKey:@"class"]) == [ServiceOBJ class])
		{
			ServiceOBJ * service = [[ServiceOBJ alloc] initWithContentsDictionary:object];
			
			if ([service discount] > 0.0f)
			{
				has_discount = YES;
				break;
			}
		}
	}
	
	[aPage addSubview:[PDFCreator headerViewWithY:maxDetailY + paperHeightPercent(2)
                                      hasDiscount:has_discount
                                          andType:3
                                        andObject:estimate]];
	
//	UIImage * rightSignature = [estimate rightSignature];
//	UIImage * leftSignature = [estimate leftSignature];
	
	BOOL hasSignature = NO;
	
//	if (rightSignature || leftSignature)
//	{
//		hasSignature = YES;
//	}
	
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
	
	for (NSDictionary * object in [estimate products])
	{
		[PDFCreator addObject:object toView:theView andObject:estimate];
	}
	
	UIView * currentPage = [PDFCreator currentPageFrom:theView];
	UIView * latestView = [currentPage.subviews lastObject];
	CGFloat last_Y = latestView.frame.origin.y + latestView.frame.size.height;
	
	if (last_Y < paperHeightPercent(60))
	{
		CGFloat difference = paperHeightPercent(60) - last_Y;
		int count = (int)difference / paperHeightPercent(1.5);
		
		for (int i = 0; i < count; i++)
		{
			[PDFCreator addObject:nil toView:theView andObject:estimate];
		}
	}
	
	latestView = [currentPage.subviews lastObject];
	UIView * lineBottom = [[UIView alloc] initWithFrame:CGRectMake(0, latestView.frame.size.height - paperHeightPercent(0.05), latestView.frame.size.width, paperHeightPercent(0.05))];
	[lineBottom setBackgroundColor:[UIColor blackColor]];
	[latestView addSubview:lineBottom];
	
	aPage = [PDFCreator currentPageFrom:theView];
	
	[PDFCreator statisticsPartForEstimate:estimate inView:theView];
	
	aPage = [PDFCreator currentPageFrom:theView];
	
	if ([estimate bigNote].length > 0)
	{
		[aPage setTag:0];
		
		aPage = [[UIView alloc] initWithFrame:CGRectMake(0, theView.subviews.count * (paper_size.height + paperHeightPercent(1)), paper_size.width, paper_size.height)];
		[aPage setBackgroundColor:[UIColor whiteColor]];
		[aPage setTag:CURRENT_PAGE_TAG];
		[theView addSubview:aPage];
		
		[PDFCreator addTemplateImageTo:aPage];
		
		CGFloat last_Y = paperHeightPercent(8.3);
		
		CGSize maxSize = CGSizeMake(paper_size.width - paperWidthPercent(15.2), paper_size.height);
		CGSize size = [data_manager sizeForString:[estimate bigNote] withFont:HelveticaNeue(paperWidthPercent(2)) constrainedToSize:maxSize];
		
		UILabel * otherNotes = [[UILabel alloc] initWithFrame:CGRectMake(paperWidthPercent(7.6), last_Y, paper_size.width - paperWidthPercent(15.2), size.height)];
		[otherNotes setText:[estimate bigNote]];
		[otherNotes setTextAlignment:NSTextAlignmentLeft];
		[otherNotes setTextColor:[UIColor blackColor]];
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

+(UIView*)detailsForEstimate:(EstimateOBJ*)estimate
{
	NSMutableDictionary *estimateDict = [[NSMutableDictionary alloc] initWithDictionary:[[CustomDefaults customObjectForKey:kLanguageKeyForNSUserDefaults] objectForKey:@"estimate"]];
	
	CGRect theViewFrame = CGRectMake(paper_size.width - paperWidthPercent(7.6) - paperWidthPercent(35),
                                   paperHeightPercent(8.3),
                                   paperWidthPercent(35),
                                   paperHeightPercent(18));
	
	UIView * theView = [[UIView alloc] initWithFrame:theViewFrame];
	[theView setBackgroundColor:[UIColor clearColor]];
  
  BOOL alignRight = ![estimate companyAlignLeft];
	
	UILabel * titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                                   0,
                                                                   theView.frame.size.width,
                                                                   paperHeightPercent(4))];
//	[titleLabel setText:@"Estimate"];
	[titleLabel setText:[estimate title]];
	[titleLabel setTextAlignment:alignRight?NSTextAlignmentLeft:NSTextAlignmentRight];
	[titleLabel setTextColor:[UIColor blackColor]];
	[titleLabel setFont:HelveticaNeueBold(paperWidthPercent(6))];
	[titleLabel setBackgroundColor:[UIColor clearColor]];
	[titleLabel setAdjustsFontSizeToFitWidth:YES];
	[theView addSubview:titleLabel];
	
  CGFloat labelWidth = theViewFrame.size.width / 2.f;
  NSMutableArray *valueLabels = [NSMutableArray new];
  NSMutableArray *titleLabels = [NSMutableArray new];
  CGFloat nextY = titleLabel.frame.origin.y + titleLabel.frame.size.height + paperHeightPercent(1.5);
  
  NSArray *visibleDetails = [estimate visibleRowsInDetailsSection];
  
  for(NSDictionary *detailSetting in visibleDetails) {
    switch ([detailSetting[TYPE] integerValue]) {
      case DetailProjNumber: {
        UILabel *titleLabel = [self labelWithText:[NSString stringWithFormat:@"%@:",[estimateDict objectForKey:@"Estimate No"]]
                                            frame:CGRectMake(0,
                                                             nextY,
                                                             labelWidth,
                                                             paperHeightPercent(2))
                                        alignment:NSTextAlignmentLeft];
        [theView addSubview:titleLabel];
        [titleLabels addObject:titleLabel];
        
        UILabel *valueLabel = [self labelWithText:[estimate number]
                                            frame:CGRectMake(titleLabel.frame.size.width,
                                                             titleLabel.frame.origin.y,
                                                             labelWidth,
                                                             paperHeightPercent(2))
                                        alignment:NSTextAlignmentLeft];
        [theView addSubview:valueLabel];
        [valueLabels addObject:valueLabel];
        
        nextY += paperHeightPercent(2);
      }
        
        break;
        
      case DetailCustom1:
      case DetailCustom2:
      case DetailCustom3:
      case DetailCustom4:
      case DetailCustom5: {
        UILabel * customTitle = [self labelWithText:[NSString stringWithFormat:@"%@:", detailSetting[TITLE]]
                                              frame:CGRectMake(0,
                                                               nextY,
                                                               labelWidth,
                                                               paperHeightPercent(2))
                                          alignment:NSTextAlignmentLeft];
        [theView addSubview:customTitle];
        [titleLabels addObject:customTitle];
        
        UILabel * customValue = [self labelWithText:detailSetting[VALUE]
                                              frame:CGRectMake(customTitle.frame.size.width,
                                                               customTitle.frame.origin.y,
                                                               customTitle.frame.size.width,
                                                               paperHeightPercent(2))
                                          alignment:NSTextAlignmentLeft];
        [theView addSubview:customValue];
        [valueLabels addObject:customValue];
        
        nextY += paperHeightPercent(2);
        
        break;
      }
        
      case DetailProjectName: {
        if(![[[estimate project] projectName] isEqual:@""]) {
          UILabel * invoiceProjectName = [self labelWithText:[NSString stringWithFormat:@"%@:",[estimateDict objectForKey:@"Project Name"]]
                                                       frame:CGRectMake(0,
                                                                        nextY,
                                                                        labelWidth,
                                                                        paperHeightPercent(2))
                                                   alignment:NSTextAlignmentLeft];
          [theView addSubview:invoiceProjectName];
          [titleLabels addObject:invoiceProjectName];
          
          UILabel * projectName = [self labelWithText:[[estimate project] projectName]
                                                frame:CGRectMake(invoiceProjectName.frame.size.width,
                                                                 invoiceProjectName.frame.origin.y,
                                                                 labelWidth,
                                                                 paperHeightPercent(2))
                                            alignment:NSTextAlignmentLeft];
          projectName.numberOfLines = 0;
          //check if text fits into label's bound
          CGSize textSize = [projectName.text sizeWithFont:projectName.font constrainedToSize:CGSizeMake(projectName.bounds.size.width, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
          if(textSize.height > projectName.frame.size.height) {
            CGRect labelFrame = projectName.frame;
            labelFrame.size.height = textSize.height;
            projectName.frame = labelFrame;
          }
          
          [theView addSubview:projectName];
          [valueLabels addObject:projectName];
          nextY += projectName.frame.size.height;
        }
        
        break;
      }
        
      case DetailProjectNo: {
        if(![[[estimate project] projectNumber] isEqual:@""]) {
          UILabel * invoiceProjectNumber = [self labelWithText:[NSString stringWithFormat:@"%@:",[estimateDict objectForKey:@"Project No"]]
                                                         frame:CGRectMake(0,
                                                                          nextY,
                                                                          labelWidth,
                                                                          paperHeightPercent(2))
                                                     alignment:NSTextAlignmentLeft];
          
          [theView addSubview:invoiceProjectNumber];
          [titleLabels addObject:invoiceProjectNumber];
          
          UILabel * projectNumber = [self labelWithText:[[estimate project] projectNumber]
                                                  frame:CGRectMake(invoiceProjectNumber.frame.size.width,
                                                                   invoiceProjectNumber.frame.origin.y,
                                                                   labelWidth,
                                                                   paperHeightPercent(2))
                                              alignment:NSTextAlignmentLeft];
          
          [theView addSubview:projectNumber];
          [valueLabels addObject:projectNumber];
          nextY += paperHeightPercent(2);
        }
        
        break;
      }

        
      default:
        break;
    }
  }
  
  UILabel *dateLabel = [self labelWithText:[NSString stringWithFormat:@"%@:",[estimateDict objectForKey:@"Estimate date"]]
                                     frame:CGRectMake(0,
                                                      nextY,
                                                      labelWidth,
                                                      paperHeightPercent(2))
                                 alignment:NSTextAlignmentLeft];
  [theView addSubview:dateLabel];
  [titleLabels addObject:dateLabel];
  
  UILabel *dateValueLabel = [self labelWithText:[estimate creationDate]
                                          frame:CGRectMake(dateLabel.frame.size.width,
                                                           dateLabel.frame.origin.y,
                                                           labelWidth,
                                                           paperHeightPercent(2))
                                      alignment:NSTextAlignmentLeft];
  [theView addSubview:dateValueLabel];
  [valueLabels addObject:dateValueLabel];
  nextY += paperHeightPercent(2);
  
  theViewFrame.size.height = nextY + paperHeightPercent(2);
  theView.frame = theViewFrame;
  
  //adjust labels position to move them to the right edge
  //values labels
  CGFloat adjustedValueX = labelWidth;
  for(UILabel *label in valueLabels) {
    CGFloat textWidth = [label.text sizeWithFont:label.font constrainedToSize:CGSizeMake(999999, label.frame.size.height) lineBreakMode:label.lineBreakMode].width;
    adjustedValueX = MIN(adjustedValueX, labelWidth - textWidth);
  }
  
  CGFloat adjustedTitleX = labelWidth;
  for(UILabel *label in titleLabels) {
    CGFloat textWidth = [label.text sizeWithFont:label.font constrainedToSize:CGSizeMake(999999, label.frame.size.height) lineBreakMode:label.lineBreakMode].width;
    adjustedTitleX = MIN(adjustedTitleX, labelWidth - textWidth);
  }
  adjustedTitleX -= 5;
  
  if(adjustedValueX > 0 && !alignRight)
    adjustedTitleX += adjustedValueX;
  
  if(adjustedTitleX > 0 || adjustedValueX > 0) {
    for(NSInteger i = 0; i < titleLabels.count; i++) {
      CGRect frame = CGRectZero;
      UILabel *label = nil;
      if(adjustedValueX > 0) {
        label = valueLabels[i];
        frame = label.frame;
        if(alignRight) {
          frame.origin.x -= adjustedTitleX;
        } else {
          frame.origin.x += adjustedValueX;
        }
        label.frame = frame;
      }
      if(adjustedTitleX > 0 && !alignRight) {
        label = titleLabels[i];
        frame = label.frame;
        frame.origin.x += adjustedTitleX;
        label.frame = frame;
      }
    }
  }

	return theView;
}

+(void)statisticsPartForEstimate:(EstimateOBJ*)estimate inView:(UIView*)view
{
	NSMutableDictionary *estimateDict = [[NSMutableDictionary alloc] initWithDictionary:[[CustomDefaults customObjectForKey:kLanguageKeyForNSUserDefaults] objectForKey:@"estimate"]];
	
	UIView * currentPage = [PDFCreator currentPageFrom:view];
	UIView * latestView = [currentPage.subviews lastObject];
	
	for (UIView * temp in currentPage.subviews)
	{
		if (temp.tag != 123)
		{
			[temp setFrame:CGRectMake(temp.frame.origin.x, temp.frame.origin.y - paperHeightPercent(4), temp.frame.size.width, temp.frame.size.height)];
		}
	}
	
	UIImage * rightSignature = [estimate rightSignature];
	UIImage * leftSignature = [estimate leftSignature];
	
	CGFloat viewHeight = paperHeightPercent(11);
	
	if (rightSignature || leftSignature)
	{
		viewHeight = paperHeightPercent(18.4);
	}
	
	CGFloat last_Y = latestView.frame.origin.y + latestView.frame.size.height + viewHeight;
	
	if (last_Y >= paperHeightPercent(85))
	{
		[currentPage setTag:0];
		
		currentPage = [[UIView alloc] initWithFrame:CGRectMake(0, view.subviews.count * (paper_size.height + paperHeightPercent(1)), paper_size.width, paper_size.height)];
		[currentPage setBackgroundColor:[UIColor whiteColor]];
		[currentPage setTag:CURRENT_PAGE_TAG];
		[view addSubview:currentPage];
		
		[PDFCreator addTemplateImageTo:currentPage];
		
		last_Y = paperHeightPercent(8.3);
	}
	else
	{
		last_Y -= viewHeight;
		last_Y += paperHeightPercent(3);
	}
	
	NSString * subtotal = [data_manager currencyAdjustedValue:[estimate subtotal]];
	NSString * discount = [data_manager currencyAdjustedValue:[estimate discount]];
	NSString * total = [data_manager currencyAdjustedValue:[estimate total]];
	
	CGSize size_subtotal = [data_manager sizeForString:subtotal withFont:HelveticaNeue(paperWidthPercent(2)) constrainedToSize:paper_size];
	CGSize size_discount = [data_manager sizeForString:discount withFont:HelveticaNeue(paperWidthPercent(2)) constrainedToSize:paper_size];
	CGSize size_total = [data_manager sizeForString:total withFont:HelveticaNeue(paperWidthPercent(2)) constrainedToSize:paper_size];
	
	CGFloat max_width = size_subtotal.width;
	
	if (size_total.width > max_width)
		max_width = size_total.width;
	
	if (size_discount.width > max_width)
		max_width = size_discount.width;
	
	UIView * theView = [[UIView alloc] initWithFrame:CGRectMake(paperWidthPercent(7.6), last_Y, paperWidthPercent(84.8), viewHeight)];
	[theView setBackgroundColor:[UIColor clearColor]];
	
	CGFloat left_width = paper_size.width - max_width - paperWidthPercent(2) - paperWidthPercent(15.2);
	CGFloat right_x = left_width + paperWidthPercent(2);
	CGFloat label_y = 0;
	
	CGFloat discount_width = [data_manager sizeForString:[NSString stringWithFormat:@"%@ (%.2f%c)",[estimateDict objectForKey:@"Discount"], [estimate discountPercentage], '%'] withFont:HelveticaNeue(paperWidthPercent(2)) constrainedToSize:paper_size].width;
	CGFloat comments_width = paper_size.width - paperWidthPercent(15.2) - max_width - paperWidthPercent(4) - discount_width;
	
	if(![[estimate tax1Name] isEqual:@""] || [estimate discountPercentage] != 0 || [estimate shippingValue] != 0)
	{
		[theView addSubview:[PDFCreator leftStatusLabelWithText:[estimateDict objectForKey:@"Subtotal"] size:left_width andY:label_y isBold:NO andMaxWidth:max_width]];
		[theView addSubview:[PDFCreator rightStatusLabelWithText:subtotal X:right_x andY:label_y isBold:NO]];
		label_y += paperHeightPercent(1.6);
	}
	
	if([estimate discountPercentage] != 0)
	{
		[theView addSubview:[PDFCreator leftStatusLabelWithText:[NSString stringWithFormat:@"%@ (%.2f%c)",[estimateDict objectForKey:@"Discount"], [estimate discountPercentage], '%'] size:left_width andY:label_y isBold:NO andMaxWidth:max_width]];
		[theView addSubview:[PDFCreator rightStatusLabelWithText:discount X:right_x andY:label_y isBold:NO]];
		label_y += paperHeightPercent(1.6);
	}
	
	if (![[estimate tax1Name] isEqual:@""])
	{
		[theView addSubview:[PDFCreator leftStatusLabelWithText:[NSString stringWithFormat:@"%@ (%.2f%c)", [estimate tax1Name], [estimate tax1Percentage], '%'] size:left_width andY:label_y isBold:NO andMaxWidth:max_width]];
		[theView addSubview:[PDFCreator rightStatusLabelWithText:[data_manager currencyAdjustedValue:[estimate tax1Value]] X:right_x andY:label_y isBold:NO]];
		label_y += paperHeightPercent(1.6);
	}
	
	if (![[estimate tax2Name] isEqual:@""])
	{
		[theView addSubview:[PDFCreator leftStatusLabelWithText:[NSString stringWithFormat:@"%@ (%.2f%c)", [estimate tax2Name], [estimate tax2Percentage], '%'] size:left_width andY:label_y isBold:NO andMaxWidth:max_width]];
		[theView addSubview:[PDFCreator rightStatusLabelWithText:[data_manager currencyAdjustedValue:[estimate tax2Value]] X:right_x andY:label_y isBold:NO]];
		label_y += paperHeightPercent(1.6);
	}
	
	if([estimate shippingValue] != 0)
	{
		[theView addSubview:[PDFCreator leftStatusLabelWithText:[estimateDict objectForKey:@"Shipping"] size:left_width andY:label_y isBold:NO andMaxWidth:max_width]];
		[theView addSubview:[PDFCreator rightStatusLabelWithText:[data_manager currencyAdjustedValue:[estimate shippingValue]] X:right_x andY:label_y isBold:NO]];
		label_y += paperHeightPercent(1.6);
	}
	
	[theView addSubview:[PDFCreator leftStatusLabelWithText:[estimateDict objectForKey:@"Total"] size:left_width andY:label_y isBold:YES andMaxWidth:max_width]];
	[theView addSubview:[PDFCreator rightStatusLabelWithText:total X:right_x andY:label_y isBold:YES]];
	label_y += paperHeightPercent(1.6);
	
	if ([estimate otherCommentsText].length > 0)
	{
		UIView * otherCommentsView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, comments_width, paperHeightPercent(11.8))];
		[otherCommentsView setBackgroundColor:[UIColor clearColor]];
		[theView addSubview:otherCommentsView];
    
    UIView *titleGrayStrip = [[UIView alloc] initWithFrame:CGRectMake(0, 0, comments_width, paperHeightPercent(2.2))];
    [titleGrayStrip setBackgroundColor:[UIColor darkGrayColor]];
    [otherCommentsView addSubview:titleGrayStrip];
    titleGrayStrip.layer.borderWidth = paperHeightPercent(0.05);
    titleGrayStrip.layer.borderColor = [UIColor blackColor].CGColor;
		
		UILabel * titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(paperHeightPercent(0.5), paperHeightPercent(0.2), comments_width - paperHeightPercent(0.7), paperHeightPercent(1.8))];
		[titleLabel setText:[estimate otherCommentsTitle]];
		[titleLabel setTextAlignment:NSTextAlignmentLeft];
		[titleLabel setTextColor:[UIColor whiteColor]];
		[titleLabel setFont:HelveticaNeueBold(paperWidthPercent(2))];
		[titleLabel setBackgroundColor:[UIColor clearColor]];
		[otherCommentsView addSubview:titleLabel];
		
		UIView * commentContent = [[UIView alloc] initWithFrame:CGRectMake(0, paperHeightPercent(2.2), otherCommentsView.frame.size.width, paperHeightPercent(9.5))];
		[commentContent setBackgroundColor:[UIColor clearColor]];
		[otherCommentsView addSubview:commentContent];
    commentContent.layer.borderWidth = paperHeightPercent(0.05);
    commentContent.layer.borderColor = [UIColor blackColor].CGColor;
		
		CGSize maxSize = CGSizeMake(titleLabel.frame.size.width, paperHeightPercent(9.1));
		CGSize size = [data_manager sizeForString:[estimate otherCommentsText] withFont:HelveticaNeueBold(paperWidthPercent(2)) constrainedToSize:maxSize];
		
		UILabel * textLabel = [[UILabel alloc] initWithFrame:CGRectMake(paperHeightPercent(0.3), paperHeightPercent(0.2), titleLabel.frame.size.width, size.height)];
		[textLabel setText:[estimate otherCommentsText]];
		[textLabel setTextAlignment:NSTextAlignmentLeft];
		[textLabel setTextColor:[UIColor blackColor]];
		[textLabel setFont:HelveticaNeue(paperWidthPercent(2))];
		[textLabel setBackgroundColor:[UIColor clearColor]];
		[textLabel setNumberOfLines:5];
		[commentContent addSubview:textLabel];
	}
	
	if (rightSignature)
	{
		CGFloat imageSize = ([estimate rightSignatureFrame].size.width * paperWidthPercent(25)) / (dvc_width - 20);
		
		CGSize imgSize = [data_manager sizeOfAspectScaledSize:[estimate rightSignatureFrame].size inSize:CGSizeMake(paperWidthPercent(25), paperWidthPercent(25))];
		
		CGFloat diff = (paperWidthPercent(30) - imgSize.height) / 2;
		
		UIView * checkView = [[UIView alloc] initWithFrame:CGRectMake(paperWidthPercent(55), paperHeightPercent(6) + diff, imgSize.width, imgSize.height)];
		
		UIImageView * sigView = [[UIImageView alloc] initWithFrame:CGRectMake(paperWidthPercent(55), paperHeightPercent(6), imageSize, imageSize)];
		[sigView setCenter:checkView.center];
		[sigView setImage:rightSignature];
		[sigView setContentMode:UIViewContentModeScaleAspectFit];
		[theView addSubview:sigView];
		
		UILabel * dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(paperWidthPercent(68), paperHeightPercent(18.5), theView.frame.size.width - paperWidthPercent(68), paperHeightPercent(1.2))];
		[dateLabel setText:[estimate rightSignatureDate]];
		[dateLabel setTextAlignment:NSTextAlignmentRight];
		[dateLabel setTextColor:[UIColor blackColor]];
		[dateLabel setFont:HelveticaNeue(paperWidthPercent(2))];
		[dateLabel setBackgroundColor:[UIColor clearColor]];
		[theView addSubview:dateLabel];
		
		UIView * line = [[UIView alloc] initWithFrame:CGRectMake(paperWidthPercent(55), paperHeightPercent(20), theView.frame.size.width - paperWidthPercent(55), paperHeightPercent(0.1))];
		[line setBackgroundColor:[UIColor blackColor]];
		[theView addSubview:line];
		
    CGSize titleSize = [data_manager sizeForString:[estimate rightSignatureTitle]
                                          withFont:HelveticaNeue(paperWidthPercent(2))
                                 constrainedToSize:CGSizeMake(theView.frame.size.width - paperWidthPercent(68), paperHeightPercent(5.4))];
    
		UILabel * signatureTitle = [[UILabel alloc] initWithFrame:CGRectMake(paperWidthPercent(55), paperHeightPercent(20.2), theView.frame.size.width - paperWidthPercent(68), titleSize.height)];
		[signatureTitle setText:[estimate rightSignatureTitle]];
		[signatureTitle setTextAlignment:NSTextAlignmentLeft];
		[signatureTitle setTextColor:[UIColor blackColor]];
		[signatureTitle setFont:HelveticaNeue(paperWidthPercent(2))];
		[signatureTitle setBackgroundColor:[UIColor clearColor]];
        signatureTitle.numberOfLines = 3;
		[signatureTitle setAdjustsFontSizeToFitWidth:YES];
		[theView addSubview:signatureTitle];
		
		UILabel * dateTitle = [[UILabel alloc] initWithFrame:CGRectMake(paperWidthPercent(72), paperHeightPercent(20.2), theView.frame.size.width - paperWidthPercent(72), paperHeightPercent(1.7))];
		[dateTitle setText:@"Date"];
		[dateTitle setTextAlignment:NSTextAlignmentLeft];
		[dateTitle setTextColor:[UIColor blackColor]];
		[dateTitle setFont:HelveticaNeue(paperWidthPercent(2))];
		[dateTitle setBackgroundColor:[UIColor clearColor]];
		[theView addSubview:dateTitle];
	}
	
	if (leftSignature)
	{
		CGFloat imageSize = ([estimate leftSignatureFrame].size.width * paperWidthPercent(25)) / (dvc_width - 20);
		
		CGSize imgSize = [data_manager sizeOfAspectScaledSize:[estimate leftSignatureFrame].size inSize:CGSizeMake(paperWidthPercent(25), paperWidthPercent(25))];
		
		CGFloat diff = (paperWidthPercent(30) - imgSize.height) / 2;
		
		UIView * checkView = [[UIView alloc] initWithFrame:CGRectMake(paperWidthPercent(0), paperHeightPercent(6) + diff, imgSize.width, imgSize.height)];
		
		UIImageView * sigView = [[UIImageView alloc] initWithFrame:CGRectMake(paperWidthPercent(0), paperHeightPercent(6), imageSize, imageSize)];
		[sigView setCenter:checkView.center];
		[sigView setImage:leftSignature];
		[sigView setContentMode:UIViewContentModeScaleAspectFit];
		[theView addSubview:sigView];
		
		UILabel * dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(paperWidthPercent(13), paperHeightPercent(18.5), theView.frame.size.width - paperWidthPercent(68), paperHeightPercent(1.2))];
		[dateLabel setText:[estimate leftSignatureDate]];
		[dateLabel setTextAlignment:NSTextAlignmentRight];
		[dateLabel setTextColor:[UIColor blackColor]];
		[dateLabel setFont:HelveticaNeue(paperWidthPercent(2))];
		[dateLabel setBackgroundColor:[UIColor clearColor]];
		[theView addSubview:dateLabel];
		
		UIView * line = [[UIView alloc] initWithFrame:CGRectMake(paperWidthPercent(0), paperHeightPercent(20), theView.frame.size.width - paperWidthPercent(55), paperHeightPercent(0.1))];
		[line setBackgroundColor:[UIColor blackColor]];
		[theView addSubview:line];
		
    CGSize titleSize = [data_manager sizeForString:[estimate leftSignatureTitle]
                                          withFont:HelveticaNeue(paperWidthPercent(2))
                                 constrainedToSize:CGSizeMake(theView.frame.size.width - paperWidthPercent(68), paperHeightPercent(5.4))];
    
		UILabel * signatureTitle = [[UILabel alloc] initWithFrame:CGRectMake(paperWidthPercent(0), paperHeightPercent(20.2), theView.frame.size.width - paperWidthPercent(68), titleSize.height)];
		[signatureTitle setText:[estimate leftSignatureTitle]];
		[signatureTitle setTextAlignment:NSTextAlignmentLeft];
		[signatureTitle setTextColor:[UIColor blackColor]];
		[signatureTitle setFont:HelveticaNeue(paperWidthPercent(2))];
		[signatureTitle setBackgroundColor:[UIColor clearColor]];
        signatureTitle.numberOfLines = 3;
		[signatureTitle setAdjustsFontSizeToFitWidth:YES];
		[theView addSubview:signatureTitle];
		
		UILabel * dateTitle = [[UILabel alloc] initWithFrame:CGRectMake(paperWidthPercent(17), paperHeightPercent(20.2), theView.frame.size.width - paperWidthPercent(72), paperHeightPercent(1.7))];
		[dateTitle setText:@"Date"];
		[dateTitle setTextAlignment:NSTextAlignmentLeft];
		[dateTitle setTextColor:[UIColor blackColor]];
		[dateTitle setFont:HelveticaNeue(paperWidthPercent(2))];
		[dateTitle setBackgroundColor:[UIColor clearColor]];
		[theView addSubview:dateTitle];
	}
	
	[currentPage addSubview:theView];
}

#pragma mark - PURCHASE ORDER

+(UIView*)PDFViewFromPurchaseOrder:(PurchaseOrderOBJ*)purchaseOrder
{
	UIView * theView = [[UIView alloc] init];
	
	UIView * aPage = [[UIView alloc] initWithFrame:CGRectMake(0, 0, paper_size.width, paper_size.height)];
	[aPage setBackgroundColor:[UIColor whiteColor]];
	[aPage setTag:CURRENT_PAGE_TAG];
	[theView addSubview:aPage];
	
	UILabel * noteLabel = [[UILabel alloc] initWithFrame:CGRectMake(paperWidthPercent(7.6), paperHeightPercent(92), paper_size.width - paperWidthPercent(15.2), paperHeightPercent(6))];
	[noteLabel setBackgroundColor:[UIColor clearColor]];
	[noteLabel setText:[purchaseOrder note]];
	[noteLabel setTextAlignment:NSTextAlignmentCenter];
	[noteLabel setTextColor:[UIColor blackColor]];
	[noteLabel setFont:HelveticaNeue(paperWidthPercent(2))];
	[noteLabel setNumberOfLines:3];
	[noteLabel setTag:123];
	[aPage addSubview:noteLabel];
	
	[PDFCreator addTemplateImageTo:aPage];
	
  UIView *companyDetailsView = [PDFCreator companyDetailsViewForObject:purchaseOrder];
  UIView *detailsView = [PDFCreator detailsForPO:purchaseOrder];
  
  if(![purchaseOrder companyAlignLeft]) {
    CGRect swapFrame = companyDetailsView.frame;
    CGFloat frameX = swapFrame.origin.x;
    swapFrame.origin.x = detailsView.frame.origin.x;
    companyDetailsView.frame = swapFrame;
    
    swapFrame = detailsView.frame;
    swapFrame.origin.x = frameX;
    detailsView.frame = swapFrame;
  }
  
  //shift views up
  if(![data_manager templateImage]) {
    CGFloat newY = paperHeightPercent(8.3) * (2.f/3.f);
    CGRect swapFrame = companyDetailsView.frame;
    swapFrame.origin.y = newY;
    companyDetailsView.frame = swapFrame;
    
    swapFrame = detailsView.frame;
    swapFrame.origin.y = newY;
    detailsView.frame = swapFrame;
  }
  
  CGFloat detailsHeight = MAX(CGRectGetMaxY(detailsView.frame), CGRectGetMaxY(companyDetailsView.frame));
  
  [aPage addSubview:companyDetailsView];
  [aPage addSubview:detailsView];
	//----
  NSArray *clientOrder = [purchaseOrder clientFieldsOrder];
  CGFloat maxDetailY = MAX(paperHeightPercent(29.3), detailsHeight);
  
  NSInteger orderIndex = 0;
  if([clientOrder count] > 0) {
    for(NSNumber *clientType in clientOrder) {
      AddressOBJ *clientAddress = nil;
      NSString *addressTitle = @"";
      
      if([clientType integerValue] == ClientBilling) {
        clientAddress = [[purchaseOrder client] billingAddress];
        
        addressTitle = [clientAddress billingTitle];
      } else if ([clientType integerValue] == ClientShipping) {
        clientAddress = [[purchaseOrder client] shippingAddress];
        
        addressTitle = [clientAddress shippingTitle];
      }
      
      clientAddress.billingKey = kPurchaseBillingAddressTitleKeyForNSUserDefaults;
      clientAddress.shippingKey = kPurchaseShippingAddressTitleKeyForNSUserDefaults;
      
      if (clientAddress.fullStringRepresentation.length > 0 || ([clientType integerValue] == ClientBilling && [[[purchaseOrder client] firstName] length] > 0)) {
        UIView * clientAddressView = [PDFCreator viewFromAddress:clientAddress
                                                       withTitle:[NSString stringWithFormat:@"%@:",addressTitle]
                                                     companyName:[[purchaseOrder client] company]
                                                    customerName:[NSString stringWithFormat:@"%@ %@", [[purchaseOrder client] firstName], [[purchaseOrder client] lastName]]];
        
        CGFloat addressX = orderIndex == 0?paperWidthPercent(7.6):paper_size.width - paperWidthPercent(7.6) - clientAddressView.frame.size.width;
        [clientAddressView setFrame:CGRectMake(addressX,
                                               detailsHeight + paperHeightPercent(1),
                                               clientAddressView.frame.size.width,
                                               clientAddressView.frame.size.height)];
        [aPage addSubview:clientAddressView];
        
        maxDetailY = MAX(maxDetailY, CGRectGetMaxY(clientAddressView.frame));
        
        orderIndex++;
      }
    }
  }
	//-----
	BOOL has_discount = NO;
	
	for (NSDictionary * object in [purchaseOrder products]) {
		if ([[object allKeys] containsObject:@"class"] && NSClassFromString([object objectForKey:@"class"]) == [ProductOBJ class]){
			ProductOBJ * product = [[ProductOBJ alloc] initWithContentsDictionary:object];
			
			if ([product discount] > 0.0f) {
				has_discount = YES;
				break;
			}
		}
		else if ([[object allKeys] containsObject:@"class"] && NSClassFromString([object objectForKey:@"class"]) == [ServiceOBJ class]) {
			ServiceOBJ * service = [[ServiceOBJ alloc] initWithContentsDictionary:object];
			
			if ([service discount] > 0.0f)
			{
				has_discount = YES;
				break;
			}
		}
	}
	
	[aPage addSubview:[PDFCreator headerViewWithY:maxDetailY + paperHeightPercent(2)
                                      hasDiscount:has_discount
                                          andType:4
                                        andObject:purchaseOrder]];
	
//	UIImage * rightSignature = [purchaseOrder rightSignature];
//	UIImage * leftSignature = [purchaseOrder leftSignature];
	
	BOOL hasSignature = NO;
	
//	if (rightSignature || leftSignature)
//	{
//		hasSignature = YES;
//	}
	
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
	
	for (NSDictionary * object in [purchaseOrder products]) {
		[PDFCreator addObject:object toView:theView andObject:purchaseOrder];
	}
	
	UIView * currentPage = [PDFCreator currentPageFrom:theView];
	UIView * latestView = [currentPage.subviews lastObject];
	CGFloat last_Y = latestView.frame.origin.y + latestView.frame.size.height;
	
	if (last_Y < paperHeightPercent(60)) {
		CGFloat difference = paperHeightPercent(60) - last_Y;
		int count = (int)difference / paperHeightPercent(1.5);
		
		for (int i = 0; i < count; i++)
		{
			[PDFCreator addObject:nil toView:theView andObject:nil];
		}
	}
	
	latestView = [currentPage.subviews lastObject];
	UIView * lineBottom = [[UIView alloc] initWithFrame:CGRectMake(0, latestView.frame.size.height - paperHeightPercent(0.05), latestView.frame.size.width, paperHeightPercent(0.05))];
	[lineBottom setBackgroundColor:[UIColor blackColor]];
	[latestView addSubview:lineBottom];
	
	aPage = [PDFCreator currentPageFrom:theView];
	
	[PDFCreator statisticsPartForPO:purchaseOrder inView:theView];
	
	aPage = [PDFCreator currentPageFrom:theView];
	
	if ([purchaseOrder bigNote].length > 0)
	{
		[aPage setTag:0];
		
		aPage = [[UIView alloc] initWithFrame:CGRectMake(0, theView.subviews.count * (paper_size.height + paperHeightPercent(1)), paper_size.width, paper_size.height)];
		[aPage setBackgroundColor:[UIColor whiteColor]];
		[aPage setTag:CURRENT_PAGE_TAG];
		[theView addSubview:aPage];
		
		[PDFCreator addTemplateImageTo:aPage];
		
		CGFloat last_Y = paperHeightPercent(8.3);
		
		CGSize maxSize = CGSizeMake(paper_size.width - paperWidthPercent(15.2), paper_size.height);
		CGSize size = [data_manager sizeForString:[purchaseOrder bigNote] withFont:HelveticaNeue(paperWidthPercent(2)) constrainedToSize:maxSize];
		
		UILabel * otherNotes = [[UILabel alloc] initWithFrame:CGRectMake(paperWidthPercent(7.6), last_Y, paper_size.width - paperWidthPercent(15.2), size.height)];
		[otherNotes setText:[purchaseOrder bigNote]];
		[otherNotes setTextAlignment:NSTextAlignmentLeft];
		[otherNotes setTextColor:[UIColor blackColor]];
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

+(UIView*)detailsForPO:(PurchaseOrderOBJ*)purchaseOrder
{
	NSMutableDictionary *purchaseDict = [[NSMutableDictionary alloc] initWithDictionary:[[CustomDefaults customObjectForKey:kLanguageKeyForNSUserDefaults] objectForKey:@"purchase"]];
	
	CGRect theViewFrame = CGRectMake(paper_size.width - paperWidthPercent(7.6) - paperWidthPercent(35),
                                   paperHeightPercent(8.3),
                                   paperWidthPercent(35),
                                   paperHeightPercent(18));
	
	UIView * theView = [[UIView alloc] initWithFrame:theViewFrame];
	[theView setBackgroundColor:[UIColor clearColor]];
  
  BOOL alignRight = ![purchaseOrder companyAlignLeft];
	
	UILabel * titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                                   0,
                                                                   theView.frame.size.width,
                                                                   paperHeightPercent(4))];
//	[titleLabel setText:@"Purchase Order"];
	[titleLabel setText:[purchaseOrder title]];
	[titleLabel setTextAlignment:alignRight?NSTextAlignmentLeft:NSTextAlignmentRight];
	[titleLabel setTextColor:[UIColor blackColor]];
	[titleLabel setFont:HelveticaNeueBold(paperWidthPercent(6))];
	[titleLabel setBackgroundColor:[UIColor clearColor]];
	[titleLabel setAdjustsFontSizeToFitWidth:YES];
	[theView addSubview:titleLabel];
		
  CGFloat labelWidth = theViewFrame.size.width / 2.f;
  NSMutableArray *valueLabels = [NSMutableArray new];
  NSMutableArray *titleLabels = [NSMutableArray new];
  CGFloat nextY = titleLabel.frame.origin.y + titleLabel.frame.size.height + paperHeightPercent(1.5);
  
  NSArray *visibleDetails = [purchaseOrder visibleRowsInDetailsSection];
  
  for(NSDictionary *detailSetting in visibleDetails) {
    switch ([detailSetting[TYPE] integerValue]) {
      case DetailProjNumber: {
        UILabel *titleLabel = [self labelWithText:[NSString stringWithFormat:@"%@:",[purchaseDict objectForKey:@"P.O. No"]]
                                            frame:CGRectMake(0,
                                                             nextY,
                                                             labelWidth,
                                                             paperHeightPercent(2))
                                        alignment:NSTextAlignmentLeft];
        [theView addSubview:titleLabel];
        [titleLabels addObject:titleLabel];
        
        UILabel *valueLabel = [self labelWithText:[purchaseOrder number]
                                            frame:CGRectMake(titleLabel.frame.size.width,
                                                             titleLabel.frame.origin.y,
                                                             labelWidth,
                                                             paperHeightPercent(2))
                                        alignment:NSTextAlignmentLeft];
        [theView addSubview:valueLabel];
        [valueLabels addObject:valueLabel];
        
        nextY += paperHeightPercent(2);
      }
        
        break;
        
      case DetailCustom1:
      case DetailCustom2:
      case DetailCustom3:
      case DetailCustom4:
      case DetailCustom5: {
        UILabel * customTitle = [self labelWithText:[NSString stringWithFormat:@"%@:", detailSetting[TITLE]]
                                              frame:CGRectMake(0,
                                                               nextY,
                                                               labelWidth,
                                                               paperHeightPercent(2))
                                          alignment:NSTextAlignmentLeft];
        [theView addSubview:customTitle];
        [titleLabels addObject:customTitle];
        
        UILabel * customValue = [self labelWithText:detailSetting[VALUE]
                                              frame:CGRectMake(customTitle.frame.size.width,
                                                               customTitle.frame.origin.y,
                                                               customTitle.frame.size.width,
                                                               paperHeightPercent(2))
                                          alignment:NSTextAlignmentLeft];
        [theView addSubview:customValue];
        [valueLabels addObject:customValue];
        
        nextY += paperHeightPercent(2);
        
        break;
      }
        
      case DetailProjectName: {
        if(![[[purchaseOrder project] projectName] isEqual:@""]) {
          UILabel * invoiceProjectName = [self labelWithText:[NSString stringWithFormat:@"%@:",[purchaseDict objectForKey:@"Project Name"]]
                                                       frame:CGRectMake(0,
                                                                        nextY,
                                                                        labelWidth,
                                                                        paperHeightPercent(2))
                                                   alignment:NSTextAlignmentLeft];
          [theView addSubview:invoiceProjectName];
          [titleLabels addObject:invoiceProjectName];
          
          UILabel * projectName = [self labelWithText:[[purchaseOrder project] projectName]
                                                frame:CGRectMake(invoiceProjectName.frame.size.width,
                                                                 invoiceProjectName.frame.origin.y,
                                                                 labelWidth,
                                                                 paperHeightPercent(2))
                                            alignment:NSTextAlignmentLeft];
          projectName.numberOfLines = 0;
          //check if text fits into label's bound
          CGSize textSize = [projectName.text sizeWithFont:projectName.font constrainedToSize:CGSizeMake(projectName.bounds.size.width, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
          if(textSize.height > projectName.frame.size.height) {
            CGRect labelFrame = projectName.frame;
            labelFrame.size.height = textSize.height;
            projectName.frame = labelFrame;
          }
          
          [theView addSubview:projectName];
          [valueLabels addObject:projectName];
          nextY += projectName.frame.size.height;
        }
        
        break;
      }
        
      case DetailProjectNo: {
        if(![[[purchaseOrder project] projectNumber] isEqual:@""]) {
          UILabel * invoiceProjectNumber = [self labelWithText:[NSString stringWithFormat:@"%@:",[purchaseDict objectForKey:@"Project No"]]
                                                         frame:CGRectMake(0,
                                                                          nextY,
                                                                          labelWidth,
                                                                          paperHeightPercent(2))
                                                     alignment:NSTextAlignmentLeft];
          
          [theView addSubview:invoiceProjectNumber];
          [titleLabels addObject:invoiceProjectNumber];
          
          UILabel * projectNumber = [self labelWithText:[[purchaseOrder project] projectNumber]
                                                  frame:CGRectMake(invoiceProjectNumber.frame.size.width,
                                                                   invoiceProjectNumber.frame.origin.y,
                                                                   labelWidth,
                                                                   paperHeightPercent(2))
                                              alignment:NSTextAlignmentLeft];
          
          [theView addSubview:projectNumber];
          [valueLabels addObject:projectNumber];
          nextY += paperHeightPercent(2);
        }
        
        break;
      }

        
      default:
        break;
    }
  }
  
  UILabel *dateLabel = [self labelWithText:[NSString stringWithFormat:@"%@:",[purchaseDict objectForKey:@"P.O. date"]]
                                     frame:CGRectMake(0,
                                                      nextY,
                                                      labelWidth,
                                                      paperHeightPercent(2))
                                 alignment:NSTextAlignmentLeft];
  [theView addSubview:dateLabel];
  [titleLabels addObject:dateLabel];
  
  UILabel *dateValueLabel = [self labelWithText:[purchaseOrder creationDate]
                                          frame:CGRectMake(dateLabel.frame.size.width,
                                                           dateLabel.frame.origin.y,
                                                           labelWidth,
                                                           paperHeightPercent(2))
                                      alignment:NSTextAlignmentLeft];
  [theView addSubview:dateValueLabel];
  [valueLabels addObject:dateValueLabel];
  nextY += paperHeightPercent(2);
  
  theViewFrame.size.height = nextY + paperHeightPercent(2);
  theView.frame = theViewFrame;
  
  //adjust labels position to move them to the right edge
  //values labels
  CGFloat adjustedValueX = labelWidth;
  for(UILabel *label in valueLabels) {
    CGFloat textWidth = [label.text sizeWithFont:label.font constrainedToSize:CGSizeMake(999999, label.frame.size.height) lineBreakMode:label.lineBreakMode].width;
    adjustedValueX = MIN(adjustedValueX, labelWidth - textWidth);
  }
  
  CGFloat adjustedTitleX = labelWidth;
  for(UILabel *label in titleLabels) {
    CGFloat textWidth = [label.text sizeWithFont:label.font constrainedToSize:CGSizeMake(999999, label.frame.size.height) lineBreakMode:label.lineBreakMode].width;
    adjustedTitleX = MIN(adjustedTitleX, labelWidth - textWidth);
  }
  adjustedTitleX -= 5;
  
  if(adjustedValueX > 0 && !alignRight)
    adjustedTitleX += adjustedValueX;
  
  if(adjustedTitleX > 0 || adjustedValueX > 0) {
    for(NSInteger i = 0; i < titleLabels.count; i++) {
      CGRect frame = CGRectZero;
      UILabel *label = nil;
      if(adjustedValueX > 0) {
        label = valueLabels[i];
        frame = label.frame;
        if(alignRight) {
          frame.origin.x -= adjustedTitleX;
        } else {
          frame.origin.x += adjustedValueX;
        }
        label.frame = frame;
      }
      if(adjustedTitleX > 0 && !alignRight) {
        label = titleLabels[i];
        frame = label.frame;
        frame.origin.x += adjustedTitleX;
        label.frame = frame;
      }
    }
  }
	
	return theView;
}

+(void)statisticsPartForPO:(PurchaseOrderOBJ*)purchaseOrder inView:(UIView*)view
{
	NSMutableDictionary *purchaseDict = [[NSMutableDictionary alloc] initWithDictionary:[[CustomDefaults customObjectForKey:kLanguageKeyForNSUserDefaults] objectForKey:@"purchase"]];
	
	UIView * currentPage = [PDFCreator currentPageFrom:view];
	UIView * latestView = [currentPage.subviews lastObject];
	
	for (UIView * temp in currentPage.subviews)
	{
		if (temp.tag != 123)
		{
			[temp setFrame:CGRectMake(temp.frame.origin.x, temp.frame.origin.y - paperHeightPercent(4), temp.frame.size.width, temp.frame.size.height)];
		}
	}
	
	UIImage * rightSignature = [purchaseOrder rightSignature];
	UIImage * leftSignature = [purchaseOrder leftSignature];
	
	CGFloat viewHeight = paperHeightPercent(11);
	
	if (rightSignature || leftSignature)
	{
		viewHeight = paperHeightPercent(18.4);
	}
	
	CGFloat last_Y = latestView.frame.origin.y + latestView.frame.size.height + viewHeight;
	
	if (last_Y >= paperHeightPercent(85))
	{
		[currentPage setTag:0];
		
		currentPage = [[UIView alloc] initWithFrame:CGRectMake(0, view.subviews.count * (paper_size.height + paperHeightPercent(1)), paper_size.width, paper_size.height)];
		[currentPage setBackgroundColor:[UIColor whiteColor]];
		[currentPage setTag:CURRENT_PAGE_TAG];
		[view addSubview:currentPage];
		
		[PDFCreator addTemplateImageTo:currentPage];
		
		last_Y = paperHeightPercent(8.3);
	}
	else
	{
		last_Y -= viewHeight;
		last_Y += paperHeightPercent(3);
	}
	
	NSString * subtotal = [data_manager currencyAdjustedValue:[purchaseOrder subtotal]];
	NSString * discount = [data_manager currencyAdjustedValue:[purchaseOrder discount]];
	NSString * total = [data_manager currencyAdjustedValue:[purchaseOrder total]];
	
	CGSize size_subtotal = [data_manager sizeForString:subtotal withFont:HelveticaNeueBold(paperWidthPercent(2)) constrainedToSize:paper_size];
	CGSize size_discount = [data_manager sizeForString:discount withFont:HelveticaNeueBold(paperWidthPercent(2)) constrainedToSize:paper_size];
	CGSize size_total = [data_manager sizeForString:total withFont:HelveticaNeueBold(paperWidthPercent(2)) constrainedToSize:paper_size];
	
	CGFloat max_width = size_subtotal.width;
	
	if (size_total.width > max_width)
		max_width = size_total.width;
	
	if (size_discount.width > max_width)
		max_width = size_discount.width;
	
	UIView * theView = [[UIView alloc] initWithFrame:CGRectMake(paperWidthPercent(7.6), last_Y, paperWidthPercent(84.8), viewHeight)];
	[theView setBackgroundColor:[UIColor clearColor]];
	
	CGFloat left_width = paper_size.width - max_width - paperWidthPercent(2) - paperWidthPercent(15.2);
	CGFloat right_x = left_width + paperWidthPercent(2);
	CGFloat label_y = 0;
	
	CGFloat discount_width = [data_manager sizeForString:[NSString stringWithFormat:@"%@ (%.2f%c)",[purchaseDict objectForKey:@"Discount"],[purchaseOrder discountPercentage], '%'] withFont:HelveticaNeue(paperWidthPercent(2)) constrainedToSize:paper_size].width;
	CGFloat comments_width = paper_size.width - paperWidthPercent(15.2) - max_width - paperWidthPercent(4) - discount_width;

	if(![[purchaseOrder tax1Name] isEqual:@""] || [purchaseOrder discountPercentage] != 0 || [purchaseOrder shippingValue] != 0)
	{
		[theView addSubview:[PDFCreator leftStatusLabelWithText:[purchaseDict objectForKey:@"Subtotal"] size:left_width andY:label_y isBold:NO andMaxWidth:max_width]];
		[theView addSubview:[PDFCreator rightStatusLabelWithText:subtotal X:right_x andY:label_y isBold:NO]];
		label_y += paperHeightPercent(1.6);
	}
	
	if([purchaseOrder discountPercentage] != 0)
	{
		[theView addSubview:[PDFCreator leftStatusLabelWithText:[NSString stringWithFormat:@"%@ (%.2f%c)",[purchaseDict objectForKey:@"Discount"], [purchaseOrder discountPercentage], '%'] size:left_width andY:label_y isBold:NO andMaxWidth:max_width]];
		[theView addSubview:[PDFCreator rightStatusLabelWithText:discount X:right_x andY:label_y isBold:NO]];
		label_y += paperHeightPercent(1.6);
	}
	
	if (![[purchaseOrder tax1Name] isEqual:@""])
	{
		[theView addSubview:[PDFCreator leftStatusLabelWithText:[NSString stringWithFormat:@"%@ (%.2f%c)", [purchaseOrder tax1Name], [purchaseOrder tax1Percentage], '%'] size:left_width andY:label_y isBold:NO andMaxWidth:max_width]];
		[theView addSubview:[PDFCreator rightStatusLabelWithText:[data_manager currencyAdjustedValue:[purchaseOrder tax1Value]] X:right_x andY:label_y isBold:NO]];
		label_y += paperHeightPercent(1.6);
	}
	
	if (![[purchaseOrder tax2Name] isEqual:@""])
	{
		[theView addSubview:[PDFCreator leftStatusLabelWithText:[NSString stringWithFormat:@"%@ (%.2f%c)", [purchaseOrder tax2Name], [purchaseOrder tax2Percentage], '%'] size:left_width andY:label_y isBold:NO andMaxWidth:max_width]];
		[theView addSubview:[PDFCreator rightStatusLabelWithText:[data_manager currencyAdjustedValue:[purchaseOrder tax2Value]] X:right_x andY:label_y isBold:NO]];
		label_y += paperHeightPercent(1.6);
	}
	
	if([purchaseOrder shippingValue] != 0)
	{
		[theView addSubview:[PDFCreator leftStatusLabelWithText:[purchaseDict objectForKey:@"Shipping"] size:left_width andY:label_y isBold:NO andMaxWidth:max_width]];
		[theView addSubview:[PDFCreator rightStatusLabelWithText:[data_manager currencyAdjustedValue:[purchaseOrder shippingValue]] X:right_x andY:label_y isBold:NO]];
		label_y += paperHeightPercent(1.6);		
	}
	
	[theView addSubview:[PDFCreator leftStatusLabelWithText:[purchaseDict objectForKey:@"Total"] size:left_width andY:label_y isBold:YES andMaxWidth:max_width]];
	[theView addSubview:[PDFCreator rightStatusLabelWithText:total X:right_x andY:label_y isBold:YES]];
	label_y += paperHeightPercent(1.6);
	
	if ([purchaseOrder otherCommentsText].length > 0)
	{
		UIView * otherCommentsView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, comments_width, paperHeightPercent(11.8))];
		[otherCommentsView setBackgroundColor:[UIColor clearColor]];
		[theView addSubview:otherCommentsView];
    
    UIView *titleGrayStrip = [[UIView alloc] initWithFrame:CGRectMake(0, 0, comments_width, paperHeightPercent(2.2))];
    [titleGrayStrip setBackgroundColor:[UIColor darkGrayColor]];
    [otherCommentsView addSubview:titleGrayStrip];
    titleGrayStrip.layer.borderWidth = paperHeightPercent(0.05);
    titleGrayStrip.layer.borderColor = [UIColor blackColor].CGColor;
		
		UILabel * titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(paperHeightPercent(0.5), paperHeightPercent(0.2), comments_width - paperHeightPercent(0.7), paperHeightPercent(1.8))];
		[titleLabel setText:[purchaseOrder otherCommentsTitle]];
		[titleLabel setTextAlignment:NSTextAlignmentLeft];
		[titleLabel setTextColor:[UIColor whiteColor]];
		[titleLabel setFont:HelveticaNeueBold(paperWidthPercent(2))];
		[titleLabel setBackgroundColor:[UIColor clearColor]];
		[otherCommentsView addSubview:titleLabel];
		
		UIView * commentContent = [[UIView alloc] initWithFrame:CGRectMake(0, paperHeightPercent(2.2), otherCommentsView.frame.size.width, paperHeightPercent(9.5))];
		[commentContent setBackgroundColor:[UIColor clearColor]];
		[otherCommentsView addSubview:commentContent];
    commentContent.layer.borderWidth = paperHeightPercent(0.05);
    commentContent.layer.borderColor = [UIColor blackColor].CGColor;
		
		CGSize maxSize = CGSizeMake(titleLabel.frame.size.width, paperHeightPercent(9.1));
		CGSize size = [data_manager sizeForString:[purchaseOrder otherCommentsText] withFont:HelveticaNeueBold(paperWidthPercent(2)) constrainedToSize:maxSize];
		
		UILabel * textLabel = [[UILabel alloc] initWithFrame:CGRectMake(paperHeightPercent(0.3), paperHeightPercent(0.2), titleLabel.frame.size.width, size.height)];
		[textLabel setText:[purchaseOrder otherCommentsText]];
		[textLabel setTextAlignment:NSTextAlignmentLeft];
		[textLabel setTextColor:[UIColor blackColor]];
		[textLabel setFont:HelveticaNeue(paperWidthPercent(2))];
		[textLabel setBackgroundColor:[UIColor clearColor]];
		[textLabel setNumberOfLines:5];
		[commentContent addSubview:textLabel];
	}
	
	if (rightSignature)
	{
		CGFloat imageSize = ([purchaseOrder rightSignatureFrame].size.width * paperWidthPercent(25)) / (dvc_width - 20);
		
		CGSize imgSize = [data_manager sizeOfAspectScaledSize:[purchaseOrder rightSignatureFrame].size inSize:CGSizeMake(paperWidthPercent(25), paperWidthPercent(25))];
		
		CGFloat diff = (paperWidthPercent(30) - imgSize.height) / 2;
		
		UIView * checkView = [[UIView alloc] initWithFrame:CGRectMake(paperWidthPercent(55), paperHeightPercent(6) + diff, imgSize.width, imgSize.height)];
		
		UIImageView * sigView = [[UIImageView alloc] initWithFrame:CGRectMake(paperWidthPercent(55), paperHeightPercent(6), imageSize, imageSize)];
		[sigView setCenter:checkView.center];
		[sigView setImage:rightSignature];
		[sigView setContentMode:UIViewContentModeScaleAspectFit];
		[theView addSubview:sigView];
		
		UILabel * dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(paperWidthPercent(68), paperHeightPercent(18.5), theView.frame.size.width - paperWidthPercent(68), paperHeightPercent(1.2))];
		[dateLabel setText:[purchaseOrder rightSignatureDate]];
		[dateLabel setTextAlignment:NSTextAlignmentRight];
		[dateLabel setTextColor:[UIColor blackColor]];
		[dateLabel setFont:HelveticaNeue(paperWidthPercent(2))];
		[dateLabel setBackgroundColor:[UIColor clearColor]];
		[theView addSubview:dateLabel];
		
		UIView * line = [[UIView alloc] initWithFrame:CGRectMake(paperWidthPercent(55), paperHeightPercent(20), theView.frame.size.width - paperWidthPercent(55), paperHeightPercent(0.1))];
		[line setBackgroundColor:[UIColor blackColor]];
		[theView addSubview:line];
		
    CGSize titleSize = [data_manager sizeForString:[purchaseOrder rightSignatureTitle]
                                          withFont:HelveticaNeue(paperWidthPercent(2))
                                 constrainedToSize:CGSizeMake(theView.frame.size.width - paperWidthPercent(68), paperHeightPercent(5.4))];
    
		UILabel * signatureTitle = [[UILabel alloc] initWithFrame:CGRectMake(paperWidthPercent(55), paperHeightPercent(20.2), theView.frame.size.width - paperWidthPercent(68), titleSize.height)];
		[signatureTitle setText:[purchaseOrder rightSignatureTitle]];
		[signatureTitle setTextAlignment:NSTextAlignmentLeft];
		[signatureTitle setTextColor:[UIColor blackColor]];
		[signatureTitle setFont:HelveticaNeue(paperWidthPercent(2))];
		[signatureTitle setBackgroundColor:[UIColor clearColor]];
        signatureTitle.numberOfLines = 3;
		[signatureTitle setAdjustsFontSizeToFitWidth:YES];
		[theView addSubview:signatureTitle];
		
		UILabel * dateTitle = [[UILabel alloc] initWithFrame:CGRectMake(paperWidthPercent(72), paperHeightPercent(20.2), theView.frame.size.width - paperWidthPercent(72), paperHeightPercent(1.7))];
		[dateTitle setText:@"Date"];
		[dateTitle setTextAlignment:NSTextAlignmentLeft];
		[dateTitle setTextColor:[UIColor blackColor]];
		[dateTitle setFont:HelveticaNeue(paperWidthPercent(2))];
		[dateTitle setBackgroundColor:[UIColor clearColor]];
		[theView addSubview:dateTitle];
	}
	
	if (leftSignature)
	{
		CGFloat imageSize = ([purchaseOrder leftSignatureFrame].size.width * paperWidthPercent(25)) / (dvc_width - 20);
		
		CGSize imgSize = [data_manager sizeOfAspectScaledSize:[purchaseOrder leftSignatureFrame].size inSize:CGSizeMake(paperWidthPercent(25), paperWidthPercent(25))];
		
		CGFloat diff = (paperWidthPercent(30) - imgSize.height) / 2;
		
		UIView * checkView = [[UIView alloc] initWithFrame:CGRectMake(paperWidthPercent(0), paperHeightPercent(6) + diff, imgSize.width, imgSize.height)];
		
		UIImageView * sigView = [[UIImageView alloc] initWithFrame:CGRectMake(paperWidthPercent(0), paperHeightPercent(6), imageSize, imageSize)];
		[sigView setCenter:checkView.center];
		[sigView setImage:leftSignature];
		[sigView setContentMode:UIViewContentModeScaleAspectFit];
		[theView addSubview:sigView];
		
		UILabel * dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(paperWidthPercent(13), paperHeightPercent(18.5), theView.frame.size.width - paperWidthPercent(68), paperHeightPercent(1.2))];
		[dateLabel setText:[purchaseOrder leftSignatureDate]];
		[dateLabel setTextAlignment:NSTextAlignmentRight];
		[dateLabel setTextColor:[UIColor blackColor]];
		[dateLabel setFont:HelveticaNeue(paperWidthPercent(2))];
		[dateLabel setBackgroundColor:[UIColor clearColor]];
		[theView addSubview:dateLabel];
		
		UIView * line = [[UIView alloc] initWithFrame:CGRectMake(paperWidthPercent(0), paperHeightPercent(20), theView.frame.size.width - paperWidthPercent(55), paperHeightPercent(0.1))];
		[line setBackgroundColor:[UIColor blackColor]];
		[theView addSubview:line];
		
    CGSize titleSize = [data_manager sizeForString:[purchaseOrder leftSignatureTitle]
                                          withFont:HelveticaNeue(paperWidthPercent(2))
                                 constrainedToSize:CGSizeMake(theView.frame.size.width - paperWidthPercent(68), paperHeightPercent(5.4))];
    
		UILabel * signatureTitle = [[UILabel alloc] initWithFrame:CGRectMake(paperWidthPercent(0), paperHeightPercent(20.2), theView.frame.size.width - paperWidthPercent(68), titleSize.height)];
		[signatureTitle setText:[purchaseOrder leftSignatureTitle]];
		[signatureTitle setTextAlignment:NSTextAlignmentLeft];
		[signatureTitle setTextColor:[UIColor blackColor]];
		[signatureTitle setFont:HelveticaNeue(paperWidthPercent(2))];
		[signatureTitle setBackgroundColor:[UIColor clearColor]];
        signatureTitle.numberOfLines = 3;
		[signatureTitle setAdjustsFontSizeToFitWidth:YES];
		[theView addSubview:signatureTitle];
		
		UILabel * dateTitle = [[UILabel alloc] initWithFrame:CGRectMake(paperWidthPercent(17), paperHeightPercent(20.2), theView.frame.size.width - paperWidthPercent(72), paperHeightPercent(1.7))];
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

+(UIView*)currentPageFrom:(UIView*)sender {
	return [sender viewWithTag:CURRENT_PAGE_TAG];
}

+ (UILabel *)labelWithText:(NSString *)text frame:(CGRect)frame alignment:(NSTextAlignment)alignment {
  UILabel * detailLabel = [[UILabel alloc] initWithFrame:frame];
  [detailLabel setText:text];
  [detailLabel setTextAlignment:alignment];
  [detailLabel setTextColor:[UIColor blackColor]];
  [detailLabel setFont:HelveticaNeue(paperWidthPercent(2))];
  [detailLabel setBackgroundColor:[UIColor clearColor]];
  [detailLabel setAdjustsFontSizeToFitWidth:YES];
  return detailLabel;
}

+(UIView*)companyDetailsViewForObject:(BaseOBJ *)object {
  CGRect viewFrame = CGRectMake(paperWidthPercent(7.6),
                                paperHeightPercent(8.3),
                                paperWidthPercent(35),
                                paperHeightPercent(18));
	UIView * theView = [[UIView alloc] initWithFrame:viewFrame];
	[theView setBackgroundColor:[UIColor clearColor]];
	
	CompanyOBJ * myCompany = [[CompanyOBJ alloc] initWithContentsDictionary:[CustomDefaults customObjectForKey:kCompanyKeyForNSUserDefaults]];
  
	CGFloat nextY = 0;
	
  BOOL alignRight = ![object companyAlignLeft];
  
  CGFloat labelWidth = viewFrame.size.width / 2.f;
  NSMutableArray *valueLabels = [NSMutableArray new];
  NSMutableArray *titleLabels = [NSMutableArray new];
  
  NSArray *profileSettings = [object visibleRowsInProfileSection];
  for(NSDictionary *profSettings in profileSettings) {
    switch ([profSettings[TYPE] integerValue]) {
      case ProfileLogo: {
        if ([myCompany logo]) {
          UIImage *logoImage = [myCompany logo];
          CGFloat widthOffset = paper_size.height / 11.f;
          if(logoImage.size.width > logoImage.size.height) {
            CGFloat sizeRatio = (logoImage.size.width / logoImage.size.height);
            widthOffset = (paper_size.height / 11) * sizeRatio;
          }
          
          CGFloat imageWidth = MIN(widthOffset, viewFrame.size.width);
          
          CGFloat logoX = alignRight?viewFrame.size.width - imageWidth:0;
          UIImageView * logo = [[UIImageView alloc] initWithFrame:CGRectMake(logoX, nextY, imageWidth, paper_size.height / 11)];
          [logo setImage:logoImage];
          [logo setBackgroundColor:[UIColor clearColor]];
          [logo setContentMode:UIViewContentModeScaleAspectFit];
          [theView addSubview:logo];
          
          nextY += paper_size.height / 11;
        }
      }
        break;
        
      case ProfileName: {
        if([[myCompany name] length] == 0) break;
        
        CGFloat actualFontSize;
        CGFloat labelHeight = paperHeightPercent(5);
        for(CGFloat i = paperWidthPercent(4); i >= paperWidthPercent(4) / 2.f; i--) {
          actualFontSize = i;
          CGFloat tempHeight = [[myCompany name] sizeWithFont:HelveticaNeueBold(actualFontSize)
                                            constrainedToSize:CGSizeMake(theView.frame.size.width, 9999)
                                                lineBreakMode:NSLineBreakByWordWrapping].height;
          if(tempHeight <= paperHeightPercent(5)) {
            if(actualFontSize == paperWidthPercent(4)) {
              labelHeight = tempHeight;
            } else {
              labelHeight = paperHeightPercent(5);
            }
            break;
          }
        }
        
        UILabel * companyName = [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                                          nextY,
                                                                          theView.frame.size.width,
                                                                          labelHeight)];
        nextY += labelHeight;
        [companyName setText:[myCompany name]];
        [companyName setTextAlignment:alignRight?NSTextAlignmentRight:NSTextAlignmentLeft];
        [companyName setTextColor:[UIColor blackColor]];
        [companyName setFont:HelveticaNeueBold(actualFontSize)];
        [companyName setBackgroundColor:[UIColor clearColor]];
        [companyName setNumberOfLines:0];
        [theView addSubview:companyName];
      }
        break;
      case ProfileWebsite: {
        if([[myCompany website] length] == 0) break;
        
        UILabel * websiteLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                                           nextY,
                                                                           theView.frame.size.width,
                                                                           paperHeightPercent(2))];
        nextY += paperHeightPercent(2);
        
        [websiteLabel setText:[myCompany website]];
        [websiteLabel setTextAlignment:alignRight?NSTextAlignmentRight:NSTextAlignmentLeft];
        [websiteLabel setTextColor:[UIColor blackColor]];
        [websiteLabel setFont:HelveticaNeue(paperWidthPercent(2))];
        [websiteLabel setAdjustsFontSizeToFitWidth:YES];
        [websiteLabel setBackgroundColor:[UIColor clearColor]];
        [theView addSubview:websiteLabel];
      }
        break;
        
      case ProfileEmail: {
        if([[myCompany email] length] == 0) break;
        
        UILabel * emailLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                                         nextY,
                                                                         theView.frame.size.width,
                                                                         paperHeightPercent(2))];
        nextY += paperHeightPercent(2);
        
        [emailLabel setText:[myCompany email]];
        [emailLabel setTextAlignment:alignRight?NSTextAlignmentRight:NSTextAlignmentLeft];
        [emailLabel setTextColor:[UIColor blackColor]];
        [emailLabel setFont:HelveticaNeue(paperWidthPercent(2))];
        [emailLabel setAdjustsFontSizeToFitWidth:YES];
        [emailLabel setBackgroundColor:[UIColor clearColor]];
        [theView addSubview:emailLabel];
      }
        break;
        
      case ProfileAddress: {
        AddressOBJ * address = [[AddressOBJ alloc] initWithContentsDictionary:[CustomDefaults customObjectForKey:kAddressKeyForNSUserDefaults]];
        
        UILabel * addressLine1 = [[UILabel alloc] initWithFrame:CGRectMake(0, nextY, theView.frame.size.width, paperHeightPercent(2))];
        [addressLine1 setText:[address representationLine1]];
        if([addressLine1.text length] > 0) {
          [addressLine1 setTextAlignment:alignRight?NSTextAlignmentRight:NSTextAlignmentLeft];
          [addressLine1 setTextColor:[UIColor blackColor]];
          [addressLine1 setFont:HelveticaNeue(paperWidthPercent(2))];
          [addressLine1 setBackgroundColor:[UIColor clearColor]];
          [addressLine1 setAdjustsFontSizeToFitWidth:YES];
          [theView addSubview:addressLine1];
          
          nextY += paperHeightPercent(2);
        } else {
          CGRect frame = addressLine1.frame;
          frame.size.height = 0;
          addressLine1.frame = frame;
        }
        
        UILabel * addressLine2 = [[UILabel alloc] initWithFrame:CGRectMake(0, nextY, theView.frame.size.width, paperHeightPercent(2))];
        [addressLine2 setText:[address representationLine2]];
        if([addressLine2.text length] > 0) {
          [addressLine2 setTextAlignment:alignRight?NSTextAlignmentRight:NSTextAlignmentLeft];
          [addressLine2 setTextColor:[UIColor blackColor]];
          [addressLine2 setFont:HelveticaNeue(paperWidthPercent(2))];
          [addressLine2 setBackgroundColor:[UIColor clearColor]];
          [addressLine2 setAdjustsFontSizeToFitWidth:YES];
          [theView addSubview:addressLine2];
          
          nextY += paperHeightPercent(2);
        } else {
          CGRect frame = addressLine2.frame;
          frame.size.height = 0;
          addressLine2.frame = frame;
        }
        
        UILabel * addressLine3 = [[UILabel alloc] initWithFrame:CGRectMake(0, nextY, theView.frame.size.width, paperHeightPercent(2))];
        [addressLine3 setText:[address representationLine3]];
        if([addressLine3.text length] > 0) {
          [addressLine3 setTextAlignment:alignRight?NSTextAlignmentRight:NSTextAlignmentLeft];
          [addressLine3 setTextColor:[UIColor blackColor]];
          [addressLine3 setFont:HelveticaNeue(paperWidthPercent(2))];
          [addressLine3 setBackgroundColor:[UIColor clearColor]];
          [addressLine3 setAdjustsFontSizeToFitWidth:YES];
          [theView addSubview:addressLine3];
          
          nextY += paperHeightPercent(2);
        } else {
          CGRect frame = addressLine3.frame;
          frame.size.height = 0;
          addressLine3.frame = frame;
        }
      }
        break;
        
      case ProfilePhone: {
        if([[myCompany phone] length] == 0) break;
        
        UILabel * phoneNumber = [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                                          nextY,
                                                                          theView.frame.size.width,
                                                                          paperHeightPercent(2))];
        nextY += paperHeightPercent(2);
        
        [phoneNumber setText:[myCompany phone]];
        [phoneNumber setTextAlignment:alignRight?NSTextAlignmentRight:NSTextAlignmentLeft];
        [phoneNumber setTextColor:[UIColor blackColor]];
        [phoneNumber setFont:HelveticaNeue(paperWidthPercent(2))];
        [phoneNumber setBackgroundColor:[UIColor clearColor]];
        [phoneNumber setAdjustsFontSizeToFitWidth:YES];
        [theView addSubview:phoneNumber];
      }
        break;
        
      case ProfileMobile: {
        
      }
        break;
      case ProfileFax: {
        
      }
        break;
        
      case ProfileCustom1:
      case ProfileCustom2:
      case ProfileCustom3:
      case ProfileCustom4:
      case ProfileCustom5: {
        UILabel * customTitle = [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                                          nextY,
                                                                          theView.frame.size.width / 2.f,
                                                                          paperHeightPercent(2))];
        [customTitle setText:[NSString stringWithFormat:@"%@:", profSettings[TITLE]]];
        [customTitle setTextAlignment:NSTextAlignmentLeft];
        [customTitle setTextColor:[UIColor blackColor]];
        [customTitle setFont:HelveticaNeue(paperWidthPercent(2))];
        [customTitle setBackgroundColor:[UIColor clearColor]];
        [customTitle setAdjustsFontSizeToFitWidth:YES];
        [theView addSubview:customTitle];
        [titleLabels addObject:customTitle];
        
        UILabel * customValue = [[UILabel alloc] initWithFrame:CGRectMake(customTitle.frame.size.width,
                                                                          customTitle.frame.origin.y,
                                                                          customTitle.frame.size.width,
                                                                          paperHeightPercent(2))];
        [customValue setText:profSettings[VALUE]];
        [customValue setTextAlignment:NSTextAlignmentLeft];
        [customValue setTextColor:[UIColor blackColor]];
        [customValue setFont:HelveticaNeue(paperWidthPercent(2))];
        [customValue setBackgroundColor:[UIColor clearColor]];
        [customValue setAdjustsFontSizeToFitWidth:YES];
        [theView addSubview:customValue];
        [valueLabels addObject:customValue];
        
        nextY += paperHeightPercent(2);
      }
        
      default:
        break;
    }
  }
  
  //adjust labels position to move them to the right edge
  //values labels
  CGFloat adjustedValueX = labelWidth;
  for(UILabel *label in valueLabels) {
    CGFloat textWidth = [label.text sizeWithFont:label.font constrainedToSize:CGSizeMake(999999, label.frame.size.height) lineBreakMode:label.lineBreakMode].width;
    adjustedValueX = MIN(adjustedValueX, labelWidth - textWidth);
  }
  
  CGFloat adjustedTitleX = labelWidth;
  for(UILabel *label in titleLabels) {
    CGFloat textWidth = [label.text sizeWithFont:label.font constrainedToSize:CGSizeMake(999999, label.frame.size.height) lineBreakMode:label.lineBreakMode].width;
    adjustedTitleX = MIN(adjustedTitleX, labelWidth - textWidth);
  }
  adjustedTitleX -= 5;
  
  if(adjustedValueX > 0)
    adjustedTitleX += adjustedValueX;
  
  if(adjustedTitleX > 0 || adjustedValueX > 0) {
    for(NSInteger i = 0; i < titleLabels.count; i++) {
      CGRect frame = CGRectZero;
      UILabel *label = nil;
      if(adjustedValueX > 0) {
        label = valueLabels[i];
        frame = label.frame;
        if(alignRight) {
          frame.origin.x += adjustedValueX;
        } else {
          frame.origin.x -= (adjustedTitleX - adjustedValueX);
        }
        label.frame = frame;
      }
      if(adjustedTitleX > 0 && alignRight) {
        label = titleLabels[i];
        frame = label.frame;
        if(alignRight) {
          frame.origin.x += adjustedTitleX;
        }
        label.frame = frame;
      }
    }
  }
  
  NSString * bName = [[CustomDefaults customObjectForKey:kSettingsKeyForNSUserDefaults] objectForKey:@"businessName"];
  NSString * bNumber = [[CustomDefaults customObjectForKey:kSettingsKeyForNSUserDefaults] objectForKey:@"businessNumber"];
  
  if (bNumber && ![bNumber isEqual:@""])
  {
    UILabel * businessLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                                        nextY,
                                                                        theView.frame.size.width,
                                                                        paperHeightPercent(2))];
    [businessLabel setText:[NSString stringWithFormat:@"%@: %@", bName, bNumber]];
    [businessLabel setTextAlignment:alignRight?NSTextAlignmentRight:NSTextAlignmentLeft];
    [businessLabel setTextColor:[UIColor blackColor]];
    [businessLabel setFont:HelveticaNeue(paperWidthPercent(2))];
    [businessLabel setAdjustsFontSizeToFitWidth:YES];
    [businessLabel setBackgroundColor:[UIColor clearColor]];
    [theView addSubview:businessLabel];
    
    nextY += paperHeightPercent(2);
  }
  
  nextY += paperHeightPercent(2);
  
  viewFrame.size.height = nextY;
  theView.frame = viewFrame;
  
	return theView;
}

+(UIView*)viewFromAddress:(AddressOBJ*)address withTitle:(NSString*)title companyName:(NSString*)companyName customerName:(NSString*)customerName {
	UIView * theView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, paperWidthPercent(35), paperHeightPercent(11))];
	[theView setBackgroundColor:[UIColor clearColor]];
	
	UIView * topBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, paperWidthPercent(35), paperHeightPercent(1.8))];
	[topBar setBackgroundColor:[UIColor darkGrayColor]];
	[theView addSubview:topBar];
  
	UILabel * titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(paperWidthPercent(0.1), 0, paperWidthPercent(35) - paperWidthPercent(0.1) * 2, paperHeightPercent(1.8))];
	[titleLabel setText:title];
	[titleLabel setTextAlignment:NSTextAlignmentLeft];
	[titleLabel setTextColor:[UIColor whiteColor]];
	[titleLabel setFont:HelveticaNeueBold(paperWidthPercent(2))];
	[titleLabel setBackgroundColor:[UIColor clearColor]];
	[titleLabel setAdjustsFontSizeToFitWidth:YES];
	[theView addSubview:titleLabel];
  
  CGFloat theViewHeight = CGRectGetMaxY(topBar.frame);
	
  CGFloat labelHeight = [customerName length] > 0 && ![customerName isEqualToString:@" "]?paperHeightPercent(2):0;
	UILabel * nameLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(topBar.frame), theView.frame.size.width, labelHeight)];
	[nameLabel1 setText:customerName];
	[nameLabel1 setTextAlignment:NSTextAlignmentLeft];
	[nameLabel1 setTextColor:[UIColor blackColor]];
	[nameLabel1 setFont:HelveticaNeue(paperWidthPercent(2))];
	[nameLabel1 setBackgroundColor:[UIColor clearColor]];
	[nameLabel1 setAdjustsFontSizeToFitWidth:YES];
	[theView addSubview:nameLabel1];
  theViewHeight += labelHeight;
	
  labelHeight = [companyName length] > 0?paperHeightPercent(2):0;
	UILabel * nameLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(nameLabel1.frame), theView.frame.size.width, labelHeight)];
	[nameLabel2 setText:companyName];
	[nameLabel2 setTextAlignment:NSTextAlignmentLeft];
	[nameLabel2 setTextColor:[UIColor blackColor]];
	[nameLabel2 setFont:HelveticaNeue(paperWidthPercent(2))];
	[nameLabel2 setBackgroundColor:[UIColor clearColor]];
	[nameLabel2 setAdjustsFontSizeToFitWidth:YES];
	[theView addSubview:nameLabel2];
  theViewHeight += labelHeight;
	
  labelHeight = [[address representationLine1] length] > 0?paperHeightPercent(2):0;
	UILabel * addressLine1 = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(nameLabel2.frame), theView.frame.size.width, labelHeight)];
	[addressLine1 setText:[address representationLine1]];
	[addressLine1 setTextAlignment:NSTextAlignmentLeft];
	[addressLine1 setTextColor:[UIColor blackColor]];
	[addressLine1 setFont:HelveticaNeue(paperWidthPercent(2))];
	[addressLine1 setBackgroundColor:[UIColor clearColor]];
	[addressLine1 setAdjustsFontSizeToFitWidth:YES];
	[theView addSubview:addressLine1];
  theViewHeight += labelHeight;
	
  labelHeight = [[address representationLine2] length] > 0?paperHeightPercent(2):0;
	UILabel * addressLine2 = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(addressLine1.frame), theView.frame.size.width, labelHeight)];
	[addressLine2 setText:[address representationLine2]];
	[addressLine2 setTextAlignment:NSTextAlignmentLeft];
	[addressLine2 setTextColor:[UIColor blackColor]];
	[addressLine2 setFont:HelveticaNeue(paperWidthPercent(2))];
	[addressLine2 setBackgroundColor:[UIColor clearColor]];
	[addressLine2 setAdjustsFontSizeToFitWidth:YES];
	[theView addSubview:addressLine2];
  theViewHeight += labelHeight;
	
  labelHeight = [[address representationLine3] length] > 0?paperHeightPercent(2):0;
	UILabel * addressLine3 = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(addressLine2.frame), theView.frame.size.width, labelHeight)];
	[addressLine3 setText:[address representationLine3]];
	[addressLine3 setTextAlignment:NSTextAlignmentLeft];
	[addressLine3 setTextColor:[UIColor blackColor]];
	[addressLine3 setFont:HelveticaNeue(paperWidthPercent(2))];
	[addressLine3 setBackgroundColor:[UIColor clearColor]];
	[addressLine3 setAdjustsFontSizeToFitWidth:YES];
	[theView addSubview:addressLine3];
  theViewHeight += labelHeight;
  
  CGRect theViewFrame = theView.frame;
  theViewFrame.size.height = theViewHeight;
  theView.frame = theViewFrame;
	
	return theView;
}

+(UIView*)headerViewWithY:(CGFloat)Y hasDiscount:(BOOL)has_discount andType:(int)type andObject:(BaseOBJ*)object {
	NSMutableDictionary *languageDict;
	
	if(type == 1) {
		languageDict = [[NSMutableDictionary alloc] initWithDictionary:[[CustomDefaults customObjectForKey:kLanguageKeyForNSUserDefaults] objectForKey:@"invoice"]];
	} else if(type == 2) {
		languageDict = [[NSMutableDictionary alloc] initWithDictionary:[[CustomDefaults customObjectForKey:kLanguageKeyForNSUserDefaults] objectForKey:@"quote"]];
	} else if(type == 3) {
		languageDict = [[NSMutableDictionary alloc] initWithDictionary:[[CustomDefaults customObjectForKey:kLanguageKeyForNSUserDefaults] objectForKey:@"estimate"]];
	} else {
		languageDict = [[NSMutableDictionary alloc] initWithDictionary:[[CustomDefaults customObjectForKey:kLanguageKeyForNSUserDefaults] objectForKey:@"purchase"]];
	}
	
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
    
  NSArray *fieldsTitle = @[@"Item", @"Description", @"Rate", @"Code", @"Qty", @"D(%)",  @"Amount"];
  CGFloat additionalPercents = 0;
  NSArray *visibleTypes = [object productFieldsOrder];
  NSArray *visibleFields = [object visibleRowsInAddItemDetailsSection];
  for(NSNumber *fieldType in [self possibleFields]) {
      if(![visibleTypes containsObject:fieldType]) {
          additionalPercents += [self percentForType:[fieldType integerValue]];
      }
  }
  additionalPercents = additionalPercents / visibleTypes.count;
  
  CGFloat x = paperWidthPercent(0.5);
  for(NSDictionary *visibleField in visibleFields) {
      AddItemDetailType fieldType = [visibleField[TYPE] integerValue];
      CGRect labelFrame = CGRectMake(x, 0,
                                     paperWidthPercent([self percentForType:fieldType]) + paperWidthPercent(additionalPercents),
                                     theView.frame.size.height);
      NSString *title = @"";
    if(fieldType >= RowCustom1 && fieldType <= RowCustom2) {
      title = [object addItemDetailTitleForType:fieldType];
    } else {
      title = [languageDict objectForKey:fieldsTitle[fieldType]];
    }
      UILabel *headerLabel = [self titleLabelForType:[visibleField[TYPE] integerValue]
                                               frame:labelFrame
                                                text:title];
      x = headerLabel.frame.origin.x + headerLabel.frame.size.width + paperWidthPercent(0.5);
      [theView addSubview:headerLabel];
  }
	
	return theView;
}

+ (UILabel *)titleLabelForType:(AddItemDetailType)type frame:(CGRect)frame text:(NSString *)text {
    UILabel * titleLabel = [[UILabel alloc] initWithFrame:frame];
    [titleLabel setText:text];
    [titleLabel setTextAlignment:NSTextAlignmentLeft];
    [titleLabel setTextColor:[UIColor whiteColor]];
    [titleLabel setFont:HelveticaNeueBold(paperWidthPercent(2))];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [titleLabel setAdjustsFontSizeToFitWidth:YES];
  
    return titleLabel;
}

+ (NSArray *)possibleFields {
    NSArray *possibleFields = @[[NSNumber numberWithInteger:RowAddItem],
                                [NSNumber numberWithInteger:RowDescription],
                                [NSNumber numberWithInteger:RowDiscount],
                                [NSNumber numberWithInteger:RowCode],
                                [NSNumber numberWithInteger:RowQuantity],
                                [NSNumber numberWithInteger:RowRate],
                                [NSNumber numberWithInteger:RowTotal],
                                [NSNumber numberWithInteger:RowCustom1],
                                [NSNumber numberWithInteger:RowCustom2]];
    return possibleFields;
}

/*
 RowAddItem,
 RowDescription,
 RowRate,
 RowCode,
 RowQuantity,
 RowDiscount,
 RowTotal,
 RowCustom1,
 RowCustom2
 */
+ (CGFloat)percentForType:(AddItemDetailType)type {
    return [[@[@13.2,
               @21,
               @9,
               @5,
               @4,
               @6,//@11.4,
               @8,
               @7,
               @7] objectAtIndex:type] floatValue];
}

+ (void)addObject:(NSDictionary*)object toView:(UIView*)view andObject:(BaseOBJ*)baseObject {
	UIView * currentPage = [PDFCreator currentPageFrom:view];
	UIView * latestView = [currentPage.subviews lastObject];
	
	CGFloat last_Y = latestView.frame.origin.y + latestView.frame.size.height;
	
	if (last_Y >= paperHeightPercent(88.5)) {
		[currentPage setTag:0];
		
		currentPage = [[UIView alloc] initWithFrame:CGRectMake(0, view.subviews.count * (paper_size.height + paperHeightPercent(1)), paper_size.width, paper_size.height)];
		[currentPage setBackgroundColor:[UIColor whiteColor]];
		[currentPage setTag:CURRENT_PAGE_TAG];
		[view addSubview:currentPage];
		
		[PDFCreator addTemplateImageTo:currentPage];
		
		last_Y = paperHeightPercent(8.3);
	}
	
	UIView * theView = [[UIView alloc] initWithFrame:CGRectMake(paperWidthPercent(7.6), last_Y, paper_size.width - paperWidthPercent(15.2), paperHeightPercent(1.6))];
	[theView setBackgroundColor:[UIColor clearColor]];
	[currentPage addSubview:theView];
    
    CGFloat additionalPercents = 0;
    NSArray *visibleTypes = [baseObject productFieldsOrder];
    NSArray *visibleFields = [baseObject visibleRowsInAddItemDetailsSection];
    for(NSNumber *fieldType in [self possibleFields]) {
        if(![visibleTypes containsObject:fieldType]) {
            additionalPercents += [self percentForType:[fieldType integerValue]];
        }
    }
    additionalPercents = additionalPercents / visibleTypes.count;
	
	CGSize nameSize;
	CGSize descriptionSize;
	
	CGFloat descWidth = paperWidthPercent([self percentForType:RowDescription]) + additionalPercents;
//	BOOL hasDiscount = YES;
    
	if ([[object allKeys] containsObject:@"class"] && NSClassFromString([object objectForKey:@"class"]) == [ProductOBJ class]) {
		ProductOBJ * product = [[ProductOBJ alloc] initWithContentsDictionary:object];
		
		UIFont * font = HelveticaNeue(paperWidthPercent(2));
		
//		if ([product discount] == 0.0f)
//		{
//			descWidth = paperWidthPercent(35);
//			hasDiscount = NO;
//		}
		
		nameSize = [data_manager sizeForString:[product name] withFont:font constrainedToSize:CGSizeMake(paperWidthPercent([self percentForType:RowAddItem]), MAXFLOAT)];
		descriptionSize = [data_manager sizeForString:[product note] withFont:font constrainedToSize:CGSizeMake(descWidth, MAXFLOAT)];
		
		CGFloat max = nameSize.height;
		
		if (max < descriptionSize.height) {
			max = descriptionSize.height;
		}
		
		if (max < paperHeightPercent(1.6)) {
			max = paperHeightPercent(1.6);
		}
		
		[theView setFrame:CGRectMake(paperWidthPercent(7.6), last_Y, theView.frame.size.width, max)];
	} else if ([[object allKeys] containsObject:@"class"] && NSClassFromString([object objectForKey:@"class"]) == [ServiceOBJ class]) {
		ServiceOBJ * service = [[ServiceOBJ alloc] initWithContentsDictionary:object];
		
		UIFont * font = HelveticaNeue(paperWidthPercent(2));
		
//		if ([service discount] == 0.0f) {
//			descWidth = paperWidthPercent(35);
//			hasDiscount = NO;
//		}

		nameSize = [data_manager sizeForString:[service name] withFont:font constrainedToSize:CGSizeMake(paperWidthPercent([self percentForType:RowAddItem]), MAXFLOAT)];
		descriptionSize = [data_manager sizeForString:[service note] withFont:font constrainedToSize:CGSizeMake(descWidth, MAXFLOAT)];
		
		CGFloat max = nameSize.height;
		
		if (max < descriptionSize.height) {
			max = descriptionSize.height;
		}
		
		if (max < paperHeightPercent(1.6)) {
			max = paperHeightPercent(1.6);
		}
		
		[theView setFrame:CGRectMake(paperWidthPercent(7.6), last_Y, theView.frame.size.width, max)];
	}
    
    NSArray *fieldsTitle = [NSArray new];
    
    if ([[object allKeys] containsObject:@"class"] && NSClassFromString([object objectForKey:@"class"]) == [ProductOBJ class]) {
        ProductOBJ * product = [[ProductOBJ alloc] initWithContentsDictionary:object];
        
        fieldsTitle = @[[product name],
                        [product note],
                        [NSString stringWithFormat:@"%.2f/%@", [product price], [product rawUnit]],
                        [product code],
                        [NSString stringWithFormat:@"%g", [data_manager trimmedQuantity:[product quantity]]],
                        [NSString stringWithFormat:@"%.0f%c", [product discount], '%'],
                        [NSString stringWithFormat:@"%.2f", [product total]],
                        [product valueForCustomType:RowCustom1],
                        [product valueForCustomType:RowCustom2]];
    } else if ([[object allKeys] containsObject:@"class"] && NSClassFromString([object objectForKey:@"class"]) == [ServiceOBJ class]) {
        ServiceOBJ * service = [[ServiceOBJ alloc] initWithContentsDictionary:object];
        
        fieldsTitle = @[[service name],
                        [service note],
                        [NSString stringWithFormat:@"%.2f/%@", [service price], [service rawUnit]],
                        @"",
                        [NSString stringWithFormat:@"%g", [data_manager trimmedQuantity:[service quantity]]],
                        [NSString stringWithFormat:@"%.0f%c", [service discount], '%'],
                        [NSString stringWithFormat:@"%.2f", [service total]],
                        [service valueForCustomType:RowCustom1],
                        [service valueForCustomType:RowCustom1]];
    }
    
    
    CGFloat x = paperWidthPercent(0.5);
    for(NSDictionary *visibleField in visibleFields) {
        AddItemDetailType fieldType = [visibleField[TYPE] integerValue];
        CGFloat labelHeight = paperHeightPercent(1.8);
        if(fieldType == RowAddItem) {
            labelHeight = nameSize.height;
        } else if(fieldType == RowDescription) {
            labelHeight = descriptionSize.height;
        }
        CGRect labelFrame = CGRectMake(x, 0,
                                       paperWidthPercent([self percentForType:fieldType]) + paperWidthPercent(additionalPercents),
                                       labelHeight);
        
        NSString *title = @"";
        if(fieldsTitle.count > fieldType) {
            title = fieldsTitle[fieldType];
        }
        UILabel *headerLabel = [self contentLabelForType:[visibleField[TYPE] integerValue]
                                                   frame:labelFrame
                                                    text:title];
        x = headerLabel.frame.origin.x + headerLabel.frame.size.width + paperWidthPercent(0.5);
        [theView addSubview:headerLabel];
    }
	
	[theView setFrame:CGRectMake(paperWidthPercent(7.6), last_Y, theView.frame.size.width, theView.frame.size.height + paperHeightPercent(0.5))];
	
	UIView * lineLeft = [[UIView alloc] initWithFrame:CGRectMake(0, 0, paperHeightPercent(0.05), theView.frame.size.height)];
	[lineLeft setBackgroundColor:[UIColor blackColor]];
	[theView addSubview:lineLeft];
	
	UIView * lineRight = [[UIView alloc] initWithFrame:CGRectMake(theView.frame.size.width - paperHeightPercent(0.05), 0, paperHeightPercent(0.05), theView.frame.size.height)];
	[lineRight setBackgroundColor:[UIColor blackColor]];
	[theView addSubview:lineRight];
}

+ (UILabel *)contentLabelForType:(AddItemDetailType)type frame:(CGRect)frame text:(NSString *)text {
    UILabel * titleLabel = [[UILabel alloc] initWithFrame:frame];
    [titleLabel setText:text];
  [titleLabel setTextAlignment:NSTextAlignmentLeft];
    if(type == RowAddItem || type == RowDescription) {
        [titleLabel setNumberOfLines:0];
    } else {
        [titleLabel setAdjustsFontSizeToFitWidth:YES];
    }
    [titleLabel setTextColor:[UIColor blackColor]];
    [titleLabel setFont:HelveticaNeue(paperWidthPercent(2))];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    
    return titleLabel;
}

+(UILabel*)leftStatusLabelWithText:(NSString*)text size:(CGFloat)size andY:(CGFloat)Y isBold:(BOOL)bold andMaxWidth:(CGFloat)maxWidth
{
	UILabel * theLabel = [[UILabel alloc] initWithFrame:CGRectMake(paper_size.width - size - maxWidth - paperWidthPercent(7.6), Y, size - paperWidthPercent(9.6), paperHeightPercent(1.8))];
	[theLabel setText:text];
	[theLabel setTextAlignment:NSTextAlignmentRight];
	[theLabel setTextColor:[UIColor blackColor]];
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

+(void)addTemplateImageTo:(UIView*)view {
	if ([data_manager templateImage]) {
		CGSize size = [data_manager sizeOfAspectScaledSize:[data_manager templateImage].size inSize:view.frame.size];
		
		UIImageView * templateImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
		[templateImage setImage:[data_manager templateImage]];
		[templateImage setContentMode:UIViewContentModeScaleAspectFit];
		[view addSubview:templateImage];
		[view sendSubviewToBack:templateImage];
	}
}

+ (NSArray *)addCustomFieldForObject:(BaseOBJ *)obj onView:(UIView *)view lastY:(CGFloat)lastLabelY {
  NSArray *customFields = [obj customDetailFieldsVisibleOnly:YES];
  CGRect viewFrame = view.frame;
  viewFrame.size.height += paperHeightPercent(2) * customFields.count;
  view.frame = viewFrame;
  
  NSMutableArray *titleLabels = [NSMutableArray new];
  NSMutableArray *valueLabels = [NSMutableArray new];
  for(NSDictionary *customField in customFields) {
    UILabel * customTitle = [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                                      lastLabelY,
                                                                      view.frame.size.width / 2.f,
                                                                      paperHeightPercent(2))];
    [customTitle setText:customField[TITLE]];
    [customTitle setTextAlignment:NSTextAlignmentLeft];
    [customTitle setTextColor:[UIColor blackColor]];
    [customTitle setFont:HelveticaNeue(paperWidthPercent(2))];
    [customTitle setBackgroundColor:[UIColor clearColor]];
    [customTitle setAdjustsFontSizeToFitWidth:YES];
    [view addSubview:customTitle];
    [titleLabels addObject:customTitle];
    
    UILabel * customValue = [[UILabel alloc] initWithFrame:CGRectMake(customTitle.frame.size.width,
                                                                      customTitle.frame.origin.y,
                                                                      customTitle.frame.size.width,
                                                                      paperHeightPercent(2))];
    [customValue setText:customField[VALUE]];
    [customValue setTextAlignment:NSTextAlignmentLeft];
    [customValue setTextColor:[UIColor blackColor]];
    [customValue setFont:HelveticaNeue(paperWidthPercent(2))];
    [customValue setBackgroundColor:[UIColor clearColor]];
    [customValue setAdjustsFontSizeToFitWidth:YES];
    [view addSubview:customValue];
    [valueLabels addObject:customValue];
    
    lastLabelY = CGRectGetMaxY(customValue.frame);
  }
  
  return [NSArray arrayWithObjects:titleLabels, valueLabels, nil];
}

@end