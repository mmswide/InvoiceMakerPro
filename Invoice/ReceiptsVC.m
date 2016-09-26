//
//  ReceiptsVC.m
//  Invoice
//
//  Created by XGRoup on 7/15/14.
//  Copyright (c) 2014 XGRoup. All rights reserved.
//

#import "ReceiptsVC.h"

#import "Defines.h"
#import "ReceiptCell.h"
#import "CreateReceiptVC.h"
#import "ProductsVC.h"

@interface ReceiptsVC ()

<UITableViewDataSource,
UITableViewDelegate,
UIScrollViewDelegate,
MFMailComposeViewControllerDelegate ,
AlertViewDelegate ,
ReceiptCreatorDelegate,
CategorySelectDelegate>

@end

@implementation ReceiptsVC

-(id)init
{
	self = [super init];
	
	if(self)
	{
		
	}
	
	return self;
}

-(id)initWithReceipt:(NSArray *)sender
{
	self = [super init];
	
	if (self)
	{
		array_with_receipts = [[NSMutableArray alloc] initWithArray:sender];
	}
	
	return self;
}

#pragma mark - VIEW DID LOAD

-(void)viewDidLoad
{
	[super viewDidLoad];
		
	lastOriginX = 0;
	selected_section = kSectionWeek;
	
	theSelfView = [[UIView alloc] initWithFrame:CGRectMake(0, statusBarHeight, dvc_width, dvc_height)];
	[theSelfView setBackgroundColor:[UIColor clearColor]];
	[self.view addSubview:theSelfView];
	
	[self.view setBackgroundColor:app_background_color];
	
	topBarView = [[TopBar alloc] initWithFrame:CGRectMake(0, 0, dvc_width, 42 + statusBarHeight) andTitle:@"Receipts"];
	[topBarView setBackgroundColor:app_bar_update_color];
	
	if (app_version == 0)
	{
		BackButton * backButton = [[BackButton alloc] initWithFrame:CGRectMake(0, 42 + statusBarHeight - 40, 70, 40) andTitle:@"Back"];
		[backButton addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
		[topBarView addSubview:backButton];
	}
	else
	{
		menuView = [[MenuV alloc] initWithFrame:CGRectMake(0, 20 - statusBarHeight, 200, dvc_height + statusBarHeight)];
        menuView.alpha = 0.0f;
		menuView.backgroundColor = app_bar_update_color;
		[DELEGATE.window addSubview:menuView];
		
		[DELEGATE.window sendSubviewToBack:menuView];
		
		UIImageView *menuIcon = [[UIImageView alloc] initWithFrame:CGRectMake(10, topBarView.frame.size.height - 36, 30, 30)];
		[menuIcon setImage:[UIImage imageNamed:@"menuIcon.png"]];
		[topBarView addSubview:menuIcon];
		
		cancel = [[UIButton alloc] initWithFrame:CGRectMake(0, topBarView.frame.size.height - 42, 42, 42)];
		cancel.backgroundColor = [UIColor clearColor];
		[cancel addTarget:self action:@selector(exportCSV:) forControlEvents:UIControlEventTouchUpInside];
		[topBarView addSubview:cancel];
		
		UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(gestureRecognizer:)];
		[cancel addGestureRecognizer:panGesture];
	}
	
	if (!array_with_receipts)
	{
		array_with_receipts = [[NSMutableArray alloc] initWithArray:[data_manager loadReceiptsArrayFromUserDefaultsAtKey:kReceiptsKeyForNSUserDefaults]];
		
		UIButton * addReceipt = [[UIButton alloc] initWithFrame:CGRectMake(dvc_width - 40, 42 + statusBarHeight - 40, 40, 40)];
		[addReceipt setTitle:@"+" forState:UIControlStateNormal];
		[addReceipt setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		[addReceipt setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
		[addReceipt.titleLabel setFont:HelveticaNeueBold(33)];
		[addReceipt setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 10, 0)];
		[addReceipt addTarget:self action:@selector(createReceipt:) forControlEvents:UIControlEventTouchUpInside];
		[topBarView addSubview:addReceipt];
	}
	
	weekReceipts = [[NSMutableArray alloc] init];
	monthReceipts = [[NSMutableArray alloc] init];
	yearReceipts = [[NSMutableArray alloc] init];
		
	[self createArrays];
	
	receiptTableView = [[TableWithShadow alloc] initWithFrame:CGRectMake(0, theSelfView.frame.origin.y + 82 - statusBarHeight, dvc_width, dvc_height - 87 - 40) style:UITableViewStyleGrouped];
	[receiptTableView setDelegate:self];
	[receiptTableView setDataSource:self];
	[receiptTableView setSeparatorColor:[UIColor clearColor]];
	[receiptTableView setBackgroundColor:[UIColor clearColor]];
	[receiptTableView setBackgroundView:nil];
	[receiptTableView setTableHeaderView:[[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)]];
	[theSelfView addSubview:receiptTableView];
	
	[(TableWithShadow*)receiptTableView setUpperShadowAlpha:1.0];
	
	[self.view addSubview:topBarView];
	
	categoryBar = [[CategorySelectV alloc] initWithFrame:CGRectMake(0, theSelfView.frame.origin.y + 52 - statusBarHeight, dvc_width, 30) andType:kReceiptSelect andDelegate:self];
	categoryBar.backgroundColor = [UIColor clearColor];
	[theSelfView addSubview:categoryBar];
}

-(void)createArrays
{
	[weekReceipts removeAllObjects];
	[monthReceipts removeAllObjects];
	[yearReceipts removeAllObjects];
		
	for(ReceiptOBJ *receipt in array_with_receipts)
	{
		NSDate *receiptDate = [receipt date];
				
		switch (selected_section)
		{
			case kSectionWeek:
			{
				NSDate *firstDay = [data_manager getFirstDayOfWeek];
				NSDate *lastDay = [data_manager getLastDayOfWeek];
							
				int firstCompare = [data_manager compareDate:firstDay withEndDate:receiptDate];
				int secondCompare = [data_manager compareDate:receiptDate withEndDate:lastDay];

				if((firstCompare == -1 && secondCompare == -1) || firstCompare == 0 || secondCompare == 0)
				{
					[weekReceipts addObject:receipt];
				}
				
				break;
			}
				
			case kSectionMonth:
			{
				NSDate *firstDay = [data_manager getFirstDayOfMonth];
				NSDate *lastDay = [data_manager getLastDayOfMonth];

				int firstCompare = [data_manager compareDate:firstDay withEndDate:receiptDate];
				int secondCompare = [data_manager compareDate:receiptDate withEndDate:lastDay];
								
				if((firstCompare == -1 && secondCompare == -1) || firstCompare == 0 || secondCompare == 0)
				{
					[monthReceipts addObject:receipt];
				}
				
				break;
			}
				
			case kSectionYear:
			{
				[yearReceipts addObject:receipt];

				break;
			}
				
			default:
				break;
		}
	}
}

#pragma mark - TABLE VIEW DATASOURCE

-(NSInteger)numberOfSectionsInTableView:(UITableView*)tableView
{
	return 1;
}

-(NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
	NSInteger nrRows = 0;
	
	switch (selected_section)
	{
		case kSectionWeek:
		{
			nrRows = weekReceipts.count;
			break;
		}
			
		case kSectionMonth:
		{
			nrRows = monthReceipts.count;
			break;
		}
			
		case kSectionYear:
		{
			nrRows = yearReceipts.count;
			break;
		}
			
		default:
			break;
	}
    
    return nrRows;
}

-(UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
	ReceiptCell * theCell = [tableView dequeueReusableCellWithIdentifier:nil];
	
	if (!theCell)
	{
		theCell = [[ReceiptCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
	}
	
	switch (selected_section)
	{
		case kSectionWeek:
		{
			kCellType type = kCellTypeMiddle;
			
			if (indexPath.row == 0)
			{
				if (weekReceipts.count == 1)
				{
					type = kCellTypeSingle;
				}
				else
				{
					type = kCellTypeTop;
				}
			}
			else if (indexPath.row == weekReceipts.count - 1)
			{
				type = kCellTypeBottom;
			}

			[theCell loadReceipt:[weekReceipts objectAtIndex:indexPath.row] withCellType:type];
			
			break;
		}
			
		case kSectionMonth:
		{
			kCellType type = kCellTypeMiddle;
			
			if (indexPath.row == 0)
			{
				if (monthReceipts.count == 1)
				{
					type = kCellTypeSingle;
				}
				else
				{
					type = kCellTypeTop;
				}
			}
			else if (indexPath.row == monthReceipts.count - 1)
			{
				type = kCellTypeBottom;
			}

			[theCell loadReceipt:[monthReceipts objectAtIndex:indexPath.row] withCellType:type];
			
			break;
		}
			
		case kSectionYear:
		{
			kCellType type = kCellTypeMiddle;
			
			if (indexPath.row == 0)
			{
				if (yearReceipts.count == 1)
				{
					type = kCellTypeSingle;
				}
				else
				{
					type = kCellTypeTop;
				}
			}
			else if (indexPath.row == yearReceipts.count - 1)
			{
				type = kCellTypeBottom;
			}
			
			[theCell loadReceipt:[yearReceipts objectAtIndex:indexPath.row] withCellType:type];
			
			break;
		}
			
		default:
			break;
	}
	
	if ([tableView isKindOfClass:[TableWithShadow class]])
	{
		[(TableWithShadow*)tableView didScroll];
	}

    
	return theCell;
}

-(void)tableView:(UITableView*)tableView willDisplayCell:(UITableViewCell*)cell forRowAtIndexPath:(NSIndexPath*)indexPath
{
	if (indexPath.row == 0)
	{
		if ([cell respondsToSelector:@selector(resize)])
		{
			[(ReceiptCell*)cell resize];
		}
	}
}

#pragma mark - TABLE VIEW DELEGATE

-(CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath
{	
	if (indexPath.row == 0)
	{
		return 94.0f;
	}
	else
	{
		return 84.0f;
	}
}

-(BOOL)tableView:(UITableView*)tableView canEditRowAtIndexPath:(NSIndexPath*)indexPath
{
	return YES;
}

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"Delete"  handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
        
        switch (selected_section)
        {
            case kSectionWeek:
            {
                [sync_manager updateCloud:[(ReceiptOBJ*)[weekReceipts objectAtIndex:indexPath.row] dictionaryRepresentation] andPurposeForDelete:-1];
                [weekReceipts removeObjectAtIndex:indexPath.row];
                
                break;
            }
                
            case kSectionMonth:
            {
                [sync_manager updateCloud:[(ReceiptOBJ*)[monthReceipts objectAtIndex:indexPath.row] dictionaryRepresentation] andPurposeForDelete:-1];
                [monthReceipts removeObjectAtIndex:indexPath.row];
                
                break;
            }
                
            case kSectionYear:
            {
                [sync_manager updateCloud:[(ReceiptOBJ*)[yearReceipts objectAtIndex:indexPath.row] dictionaryRepresentation] andPurposeForDelete:-1];
                [yearReceipts removeObjectAtIndex:indexPath.row];
                
                break;
            }
                
            default:
                break;
        }
        
        [array_with_receipts removeAllObjects];
        [array_with_receipts addObjectsFromArray:weekReceipts];
        [array_with_receipts addObjectsFromArray:monthReceipts];
        [array_with_receipts addObjectsFromArray:yearReceipts];
        
        [data_manager saveReceiptsArrayToUserDefaults:array_with_receipts forKey:kReceiptsKeyForNSUserDefaults];
        
        [receiptTableView reloadData];
    }];
    
    return @[deleteAction];
}

-(void)tableView:(UITableView*)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath*)indexPath
{
	if (editingStyle == UITableViewCellEditingStyleDelete)
	{
		switch (selected_section)
		{
			case kSectionWeek:
			{
				[sync_manager updateCloud:[(ReceiptOBJ*)[weekReceipts objectAtIndex:indexPath.row] dictionaryRepresentation] andPurposeForDelete:-1];
				[weekReceipts removeObjectAtIndex:indexPath.row];
				
				break;
			}
				
			case kSectionMonth:
			{
				[sync_manager updateCloud:[(ReceiptOBJ*)[monthReceipts objectAtIndex:indexPath.row] dictionaryRepresentation] andPurposeForDelete:-1];
				[monthReceipts removeObjectAtIndex:indexPath.row];
				
				break;
			}
				
			case kSectionYear:
			{
				[sync_manager updateCloud:[(ReceiptOBJ*)[yearReceipts objectAtIndex:indexPath.row] dictionaryRepresentation] andPurposeForDelete:-1];
				[yearReceipts removeObjectAtIndex:indexPath.row];
				
				break;
			}
				
			default:
				break;
		}
		
        [array_with_receipts removeAllObjects];
		[array_with_receipts addObjectsFromArray:weekReceipts];
		[array_with_receipts addObjectsFromArray:monthReceipts];
		[array_with_receipts addObjectsFromArray:yearReceipts];
        
		[data_manager saveReceiptsArrayToUserDefaults:array_with_receipts forKey:kReceiptsKeyForNSUserDefaults];

        [tableView reloadData];
	}
}

-(void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
	index_of_receipt = (int)indexPath.row;
	
	[[[AlertView alloc] initWithTitle:@"What would you like to do?" message:@"" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:[NSArray arrayWithObjects:@"Preview PDF", @"Send as PDF", @"Print", @"View Details", nil]] show];
}

#pragma mark - MAIL COMPOSER DELEGATE

-(void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
	[controller dismissViewControllerAnimated:YES completion:nil];
	
	if(result == MFMailComposeResultFailed && error != nil)
	{
		[[[UIAlertView alloc] initWithTitle:@"Failed to send email" message:error.localizedDescription delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
	}
}

#pragma mark - ALERTVIEW DELEGATE

-(void)closePreview:(UITapGestureRecognizer*)sender
{
	[UIView animateWithDuration:0.25 animations:^{
		
		[[DELEGATE.window viewWithTag:666] setAlpha:0.0];
		
	} completion:^(BOOL finished) {
		
		[[DELEGATE.window viewWithTag:666] removeFromSuperview];
		
	}];
}

-(void)alertView:(AlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == 1)
	{
		CGFloat width = paper_size.width;
		CGFloat height = paper_size.height;
		changePaperSize(dvc_width, dvc_width * height / width)
						
		ReceiptOBJ * selectedReceipt;
		
		switch (selected_section)
		{
			case kSectionWeek:
			{
				selectedReceipt = [weekReceipts objectAtIndex:index_of_receipt];
				
				break;
			}
				
			case kSectionMonth:
			{
				selectedReceipt = [monthReceipts objectAtIndex:index_of_receipt];
				
				break;
			}
				
			case kSectionYear:
			{
				selectedReceipt = [yearReceipts objectAtIndex:index_of_receipt];
				
				break;
			}
				
			default:
				break;
		}
		
		NSMutableArray *receiptsArray = [[NSMutableArray alloc] initWithArray:[data_manager loadReceiptsArrayFromUserDefaultsAtKey:kReceiptsKeyForNSUserDefaults]];
		
		UIView *myView;
		
		if(receiptsArray.count <= 206)
		{
			myView = [PDFCreator2 PDFViewForReceipts:receiptsArray];
		}
		else
		{
			NSRange range = NSMakeRange(0, 206);
			NSMutableArray *tempReceipts = [[NSMutableArray alloc] initWithArray:[receiptsArray subarrayWithRange:range]];
			
			myView = [PDFCreator2 PDFViewForReceipts:tempReceipts];
		}
		 
		NSData *pdfData = [[NSData alloc] initWithData:[PDFCreator2 PDFDataFromUIView:myView]];
				
		UIWebView * webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 20, dvc_width, dvc_height)];
		[webView loadData:pdfData MIMEType:@"application/pdf" textEncodingName:@"" baseURL:nil];
		[webView setAlpha:0.0];
		[webView setTag:666];
		[DELEGATE.window addSubview:webView];
		
		UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closePreview:)];
		[webView addGestureRecognizer:tap];
		
		[UIView animateWithDuration:0.25 animations:^{
			
			[webView setAlpha:1.0];
			
		} completion:^(BOOL finished) {
		
			if(receiptsArray.count > 206)
			{
				[[[AlertView alloc] initWithTitle:@"Warning" message:@"There are too many receipts for the PDF file, so the number of pages is limited!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] showInWindow];
			}
			
		}];
	}
	else if (buttonIndex == 2)
	{
		if ([MFMailComposeViewController canSendMail])
		{
			revertPaperSize;
			
			NSMutableArray *receiptsArray = [[NSMutableArray alloc] initWithArray:[data_manager loadReceiptsArrayFromUserDefaultsAtKey:kReceiptsKeyForNSUserDefaults]];
			NSMutableArray *temp = [[NSMutableArray alloc] initWithArray:receiptsArray];
			
			if(receiptsArray.count > 206)
			{
				[[[AlertView alloc] initWithTitle:@"Warning" message:@"There are too many receipts for the PDF file, so the number of pages is limited!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] showInWindow];
				
				NSRange range = NSMakeRange(0, 206);
				
				[temp removeAllObjects];
				[temp addObjectsFromArray:[receiptsArray subarrayWithRange:range]];
			}
		
			UIView *theView = [PDFCreator2 PDFViewForReceipts:temp];
			
			NSString *filePath = [[NSString alloc] initWithString:[PDFCreator2 PDFPathFromUIView:theView]];

			MFMailComposeViewController * vc = [[MFMailComposeViewController alloc] init];
			[vc setSubject:[NSString stringWithFormat:@"Receipts"]];
			[vc setToRecipients:nil];
			[vc setMailComposeDelegate:self];

			[vc addAttachmentData:[[NSData alloc] initWithContentsOfFile:filePath] mimeType:@"application/pdf" fileName:@"receipts.pdf"];
			[self presentViewController:vc animated:YES completion:nil];
		}
		else
		{
			[[[AlertView alloc] initWithTitle:@"" message:@"You must configure an email account in the device settings to be able to send emails." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
		}
	}
	else if (buttonIndex == 3)
	{
		UIPrintInteractionController * pic = [UIPrintInteractionController sharedPrintController];
		
//		ReceiptOBJ * selectedReceipt;
//		
//		switch (selected_section)
//		{
//			case kSectionWeek:
//			{
//				selectedReceipt = [weekReceipts objectAtIndex:index_of_receipt];
//				
//				break;
//			}
//				
//			case kSectionMonth:
//			{
//				selectedReceipt = [monthReceipts objectAtIndex:index_of_receipt];
//				
//				break;
//			}
//				
//			case kSectionYear:
//			{
//				selectedReceipt = [yearReceipts objectAtIndex:index_of_receipt];
//				
//				break;
//			}
//				
//			default:
//				break;
//		}
		
		NSMutableArray *receiptsArray = [[NSMutableArray alloc] initWithArray:[data_manager loadReceiptsArrayFromUserDefaultsAtKey:kReceiptsKeyForNSUserDefaults]];
		NSMutableArray *temp = [[NSMutableArray alloc] initWithArray:receiptsArray];
		
		if(receiptsArray.count > 206)
		{
			[[[AlertView alloc] initWithTitle:@"Warning" message:@"There are too many receipts for the PDF file, so the number of pages is limited!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] showInWindow];
		
			NSRange range = NSMakeRange(0, 206);
			
			[temp removeAllObjects];
			[temp addObjectsFromArray:[receiptsArray subarrayWithRange:range]];
		}

		UIView *theView = [PDFCreator2 PDFViewForReceipts:temp];
		NSData *fileData = [PDFCreator2 PDFDataFromUIView:theView];
		
		if (pic && [UIPrintInteractionController canPrintData:fileData])
		{
			UIPrintInfo * printInfo = [UIPrintInfo printInfo];
			[printInfo setOutputType:UIPrintInfoOutputGeneral];
			[printInfo setJobName:@"Print Receipts"];
			[printInfo setDuplex:UIPrintInfoDuplexNone];
			[printInfo setOrientation:UIPrintInfoOrientationLandscape];
			
			[pic setPrintInfo:printInfo];
			[pic setShowsPageRange:YES];
			[pic setPrintingItem:fileData];
						
			void (^completionHandler)(UIPrintInteractionController*, BOOL, NSError*) = ^(UIPrintInteractionController * pic, BOOL completed, NSError * error) {
				
				if (!completed && error)
				{
					NSLog(@"FAILED! due to error in domain %@ with error code %ld", error.domain, (long)error.code);
				}
			};
			
			if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
			{
				[pic presentFromRect:[alertView viewWithTag:buttonIndex].frame inView:alertView.content animated:YES completionHandler:completionHandler];
			}
			else
			{
				[pic presentAnimated:YES completionHandler:completionHandler];
			}
		}
	}
	else if (buttonIndex == 4)
	{
		ReceiptOBJ * selectedReceipt;
		
		switch (selected_section)
		{
			case kSectionWeek:
			{
				selectedReceipt = [weekReceipts objectAtIndex:index_of_receipt];
				
				break;
			}
				
			case kSectionMonth:
			{
				selectedReceipt = [monthReceipts objectAtIndex:index_of_receipt];
				
				break;
			}
				
			case kSectionYear:
			{
				selectedReceipt = [yearReceipts objectAtIndex:index_of_receipt];
				
				break;
			}
				
			default:
				break;
		}
		
		CreateReceiptVC *vc = [[CreateReceiptVC alloc] initWithReceipt:selectedReceipt delegate:self];
		
		UINavigationController * nvc = [[UINavigationController alloc] initWithRootViewController:vc];
		[nvc setNavigationBarHidden:YES];
		[self.navigationController presentViewController:nvc animated:YES completion:nil];
	}
}

#pragma mark - RECEIPT CREATOR DELEGATE

-(void)creatorViewController:(CreateReceiptVC *)viewController createdReceipt:(ReceiptOBJ *)receipt
{
	if (index_of_receipt == -1)
	{		
		if ([[receipt number] isEqual:@"RT00001"])
		{
			int number = (int)[CustomDefaults customIntegerForKey:kNumberOfRecipeKeyForNSUserDefaults];
			
			NSString * valueSTR = [receipt number];
			
			if ([valueSTR isEqual:@"RT00001"])
			{
				if (number < 10)
				{
					valueSTR = [NSString stringWithFormat:@"RT0000%d", number];
				}
				else if (number < 100)
				{
					valueSTR = [NSString stringWithFormat:@"RT000%d", number];
				}
				else if (number < 1000)
				{
					valueSTR = [NSString stringWithFormat:@"RT00%d", number];
				}
				else if (number < 10000)
				{
					valueSTR = [NSString stringWithFormat:@"RT0%d", number];
				}
				else
				{
					valueSTR = [NSString stringWithFormat:@"RT%d", number];
				}
			}
			
			[receipt setNumber:valueSTR];
			number++;
			
			[CustomDefaults setCustomInteger:number forKey:kNumberOfRecipeKeyForNSUserDefaults];
		}
		
		[DELEGATE incrementDocumentsCount];

		[sync_manager updateCloud:[receipt dictionaryRepresentation] andPurposeForDelete:1];
		
		[array_with_receipts insertObject:receipt atIndex:0];
		
		[self createArrays];
	}
	else
	{
		[sync_manager updateCloud:[receipt dictionaryRepresentation] andPurposeForDelete:0];
		
		switch (selected_section)
		{
			case kSectionWeek:
			{
				[weekReceipts replaceObjectAtIndex:index_of_receipt withObject:receipt];
				
				break;
			}
				
			case kSectionMonth:
			{
				[monthReceipts replaceObjectAtIndex:index_of_receipt withObject:receipt];
				
				break;
			}
				
			case kSectionYear:
			{
				[yearReceipts replaceObjectAtIndex:index_of_receipt withObject:receipt];
				
				break;
			}
				
			default:
				break;
		}
		
		[array_with_receipts removeAllObjects];
		
		[array_with_receipts addObjectsFromArray:weekReceipts];
		[array_with_receipts addObjectsFromArray:monthReceipts];
		[array_with_receipts addObjectsFromArray:yearReceipts];
	}
	
	[data_manager saveReceiptsArrayToUserDefaults:array_with_receipts forKey:kReceiptsKeyForNSUserDefaults];
	
	[receiptTableView reloadData];
}

#pragma mark - SCROLL VIEW DELEGATE

-(void)scrollViewDidScroll:(UIScrollView*)scrollView
{
	if ([scrollView isKindOfClass:[TableWithShadow class]])
		[(TableWithShadow*)scrollView didScroll];
}

#pragma mark - CATEGORY SELECT DELEGATE

-(void)categorySelectDelegate:(CategorySelectV*)view selectedCategory:(int)category
{
	if(category == 1)
		selected_section = kSectionWeek;
	else
	if(category == 2)
		selected_section = kSectionMonth;
	else
	if(category == 3)
		selected_section = kSectionYear;
		
	[self createArrays];
	
	[receiptTableView reloadData];
}

#pragma mark - GESTURE RECOGNIZER

-(void)gestureRecognizer:(UIPanGestureRecognizer*)recognizer
{
    if(menuView.alpha == 0.0f)
    {
        menuView.alpha = 1.0f;
        [DELEGATE.window sendSubviewToBack:menuView];
    }
    
	if(recognizer.state == UIGestureRecognizerStateBegan)
	{
		lastOriginX = self.navigationController.view.frame.origin.x;
	}
	
	CGPoint translation = [recognizer translationInView:DELEGATE.window];
	translation = CGPointMake(translation.x + lastOriginX, translation.y);
	
	if(translation.x < 0)
	{
		[UIView animateWithDuration:0.3 animations:^{
			self.navigationController.view.frame = CGRectMake(0, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height);
		}];
		
		theSelfView.userInteractionEnabled = YES;
		[(UIView*)DELEGATE.bottomBar setUserInteractionEnabled:YES];
		
		return;
	}
	
	if(recognizer.state == UIGestureRecognizerStateEnded)
	{
		if(translation.x > 200)
		{
			[self.navigationController.view setFrame:CGRectMake(200, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height)];
			lastOriginX = 200;
			
			theSelfView.userInteractionEnabled = NO;
			[(UIView*)DELEGATE.bottomBar setUserInteractionEnabled:NO];
			
			return;
		}
		
		[UIView animateWithDuration:0.3 animations:^{
			self.navigationController.view.frame = CGRectMake(0, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height);
		}];
		
		theSelfView.userInteractionEnabled = YES;
		[(UIView*)DELEGATE.bottomBar setUserInteractionEnabled:YES];
		
		lastOriginX = 0;
		
		return;
	}
	
	if(translation.x > 200)
	{
		theSelfView.userInteractionEnabled = NO;
		[(UIView*)DELEGATE.bottomBar setUserInteractionEnabled:NO];
		
		[self.navigationController.view setFrame:CGRectMake(200, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height)];
		return;
	}
	
	
	[self.navigationController.view setFrame:CGRectMake(translation.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height)];
}

#pragma mark - FUNCTIONS

-(void)back:(UIButton*)sender
{
	[self.navigationController popViewControllerAnimated:YES];
}

-(void)createReceipt:(UIButton *)sender
{
	if ([DELEGATE documentsLimitReached])
		return;
	
	index_of_receipt = -1;
	
	CreateReceiptVC *vc = [[CreateReceiptVC alloc] initForCreationWithDelegate:self];
	
	UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:vc];
	[nvc setNavigationBarHidden:YES];
	[self.navigationController presentViewController:nvc animated:YES completion:nil];
}

-(void)exportCSV:(UIButton*)sender
{
    if(menuView.alpha == 0.0f)
    {
        menuView.alpha = 1.0f;
        [DELEGATE.window sendSubviewToBack:menuView];
    }
    
	if(lastOriginX == 0)
	{
		[UIView animateWithDuration:0.3 animations:^{
			self.navigationController.view.frame = CGRectMake(menuView.frame.size.width, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height);
		}];
		
		theSelfView.userInteractionEnabled = NO;
		[(UIView*)DELEGATE.bottomBar setUserInteractionEnabled:NO];
		
		lastOriginX = 200;
	}
	else
	{
		[UIView animateWithDuration:0.3 animations:^{
			self.navigationController.view.frame = CGRectMake(0, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height);
		}];
		
		theSelfView.userInteractionEnabled = YES;
		[(UIView*)DELEGATE.bottomBar setUserInteractionEnabled:YES];
		
		lastOriginX = 0;
	}
}

#pragma mark - VIEW CONTROLLER FUNCTIONS

-(void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	kApplicationVersion version = app_version;
	
	switch (version)
	{
		case kApplicationVersionReceipts:
		{
			[array_with_receipts removeAllObjects];
			[array_with_receipts addObjectsFromArray:[data_manager loadReceiptsArrayFromUserDefaultsAtKey:kReceiptsKeyForNSUserDefaults]];
			
			break;
		}
			
		default:
			break;
	}
	
	[self createArrays];
	
	[receiptTableView reloadData];
}

-(void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
}

-(void)dealloc
{
	[receiptTableView setEditing:NO];
	[receiptTableView setDelegate:nil];
}

@end
