//
//  InvoicesVC.m
//  Invoice
//
//  Created by XGRoup5 on 8/13/13.
//  Copyright (c) 2013 XGRoup. All rights reserved.
//

#import "InvoicesVC.h"

#import "Defines.h"
#import "INVCell.h"
#import "CreateInvoiceVC.h"

@interface InvoicesVC () <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, InvoiceCreatorDelegate, MFMailComposeViewControllerDelegate, AlertViewDelegate , CategorySelectDelegate>

@end

@implementation InvoicesVC

- (UIStatusBarStyle) preferredStatusBarStyle
{
	return UIStatusBarStyleLightContent;
}

-(id)init
{
	self = [super init];
	
	if (self)
	{

	}
	
	return self;
}

-(id)initWithInvoices:(NSArray*)sender
{
	self = [super init];
	
	if (self)
	{
		array_with_invoices = [[NSMutableArray alloc] initWithArray:sender];
	}
	
	return self;
}

#pragma mark - VIEW DID LOAD

-(void)viewDidLoad
{
	[super viewDidLoad];

	selected_section = kSectionOverdue;
	
	theSelfView = [[UIView alloc] initWithFrame:CGRectMake(0, statusBarHeight, dvc_width, dvc_height)];
	[theSelfView setBackgroundColor:[UIColor clearColor]];
	[self.view addSubview:theSelfView];
			
	[self.view setBackgroundColor:app_background_color];
	
	topBarView = [[TopBar alloc] initWithFrame:CGRectMake(0, 0, dvc_width, 42 + statusBarHeight) andTitle:@"Invoices"];
	[topBarView setBackgroundColor:app_bar_update_color];
		
	BackButton * backButton = [[BackButton alloc] initWithFrame:CGRectMake(0, 42 + statusBarHeight - 40, 70, 40) andTitle:@"Back"];
	[backButton addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
	[topBarView addSubview:backButton];
	
	if (!array_with_invoices)
	{
		array_with_invoices = [[NSMutableArray alloc] initWithArray:[data_manager loadInvoicesArrayFromUserDefaultsAtKey:kInvoicesKeyForNSUserDefaults]];
				
		UIButton * addInvoice = [[UIButton alloc] initWithFrame:CGRectMake(dvc_width - 40, 42 + statusBarHeight - 40, 40, 40)];
		[addInvoice setTitle:@"+" forState:UIControlStateNormal];
		[addInvoice setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		[addInvoice setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
		[addInvoice.titleLabel setFont:HelveticaNeueBold(33)];
		[addInvoice setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 10, 0)];
		[addInvoice addTarget:self action:@selector(createInvoice:) forControlEvents:UIControlEventTouchUpInside];
		[topBarView addSubview:addInvoice];
	}
	
	overdueInvoicesArray = [[NSMutableArray alloc] init];
	paidInvoicesArray = [[NSMutableArray alloc] init];
	openInvoicesArray = [[NSMutableArray alloc] init];
	
	[self createArrays];
	
	invoicesTableView = [[TableWithShadow alloc] initWithFrame:CGRectMake(0, theSelfView.frame.origin.y + 82 - statusBarHeight, dvc_width, dvc_height - 87 - 40) style:UITableViewStyleGrouped];
	[invoicesTableView setDelegate:self];
	[invoicesTableView setDataSource:self];
	[invoicesTableView setSeparatorColor:[UIColor clearColor]];
	[invoicesTableView setBackgroundColor:[UIColor clearColor]];
	[invoicesTableView setBackgroundView:nil];
	[invoicesTableView setTableHeaderView:[[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)]];
	[theSelfView addSubview:invoicesTableView];
	
	[(TableWithShadow*)invoicesTableView setUpperShadowAlpha:1.0];
	
	[self.view addSubview:topBarView];
	
	categoryBar = [[CategorySelectV alloc] initWithFrame:CGRectMake(0, theSelfView.frame.origin.y + 52 - statusBarHeight, dvc_width, 30) andType:kInvoiceSelect andDelegate:self];
	categoryBar.backgroundColor = [UIColor clearColor];
	[theSelfView addSubview:categoryBar];
}

-(void)createArrays
{
	[overdueInvoicesArray removeAllObjects];
	[paidInvoicesArray removeAllObjects];
	[openInvoicesArray removeAllObjects];
		
	for (InvoiceOBJ * obj in array_with_invoices)
	{
		switch ([obj status])
		{
			case kInvoiceStatusCurrent:
			{
				[openInvoicesArray addObject:obj];
				break;
			}
								
			case kInvoiceStatusPaid:
			{
				[paidInvoicesArray addObject:obj];
				break;
			}
				

			case kInvoiceStatusOverdue:
			{
				[overdueInvoicesArray addObject:obj];
				break;
			}
		}
	}
}

#pragma mark - FUNCTIONS

-(void)back:(UIButton*)sender
{
	[self.navigationController popViewControllerAnimated:YES];
}

-(void)createInvoice:(UIButton*)sender
{
	if ([DELEGATE documentsLimitReached])
		return;
	
	index_of_invoice = -1;
	
	CreateInvoiceVC * vc = [[CreateInvoiceVC alloc] initForCreationWithDelegate:self];
	UINavigationController * nvc = [[UINavigationController alloc] initWithRootViewController:vc];
	[nvc setNavigationBarHidden:YES];
	[self.navigationController presentViewController:nvc animated:YES completion:nil];
}

#pragma mark - INVOICE CREATOR DELEGATE

-(void)creatorViewController:(CreateInvoiceVC*)viewController createdInvoice:(InvoiceOBJ*)invoice
{
	if (index_of_invoice == -1)
	{	
		[DELEGATE incrementDocumentsCount];
		
		[sync_manager updateCloud:[invoice contentsDictionary] andPurposeForDelete:1];
		[array_with_invoices insertObject:invoice atIndex:0];
		
		[self createArrays];
	}
	else
	{
		[sync_manager updateCloud:[invoice contentsDictionary] andPurposeForDelete:0];
		
		switch (selected_section)
		{
			case kSectionOpen:
			{
				[openInvoicesArray replaceObjectAtIndex:index_of_invoice withObject:invoice];
				
				break;
			}
				
			case kSectionPaid:
			{
				[paidInvoicesArray replaceObjectAtIndex:index_of_invoice withObject:invoice];
				
				break;
			}
				
			case kSectionOverdue:
			{
				[overdueInvoicesArray replaceObjectAtIndex:index_of_invoice withObject:invoice];
				
				break;
			}
				
			default:
				break;
		}
		
		[array_with_invoices removeAllObjects];
		[array_with_invoices addObjectsFromArray:openInvoicesArray];
		[array_with_invoices addObjectsFromArray:paidInvoicesArray];
		[array_with_invoices addObjectsFromArray:overdueInvoicesArray];
	}
	
	[data_manager saveInvoicesArrayToUserDefaults:array_with_invoices forKey:kInvoicesKeyForNSUserDefaults];
	[invoicesTableView reloadData];
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
		case kSectionOpen:
		{
			nrRows = openInvoicesArray.count;
			break;
		}
			
		case kSectionPaid:
		{
			nrRows = paidInvoicesArray.count;
			break;
		}
			
		case kSectionOverdue:
		{
			nrRows = overdueInvoicesArray.count;
			break;
		}
			
		default:
			break;
	}
	
	return nrRows;
}

-(UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
	INVCell * theCell = [tableView dequeueReusableCellWithIdentifier:nil];
	
	if (!theCell)
	{
		theCell = [[INVCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
	}
	
	switch (selected_section)
	{
		case kSectionOpen:
		{
			kInvoiceCellType type = kInvoiceCellTypeMiddle;
			
			if (indexPath.row == 0)
			{
				if (openInvoicesArray.count == 1)
				{
					type = kInvoiceCellTypeSingle;
				}
				else
				{
					type = kInvoiceCellTypeTop;
				}
			}
			else if (indexPath.row == openInvoicesArray.count - 1)
			{
				type = kInvoiceCellTypeBottom;
			}
			
			[theCell loadInvoice:[openInvoicesArray objectAtIndex:indexPath.row] withCellType:type];
			
			break;
		}
		
		case kSectionPaid:
		{
			kInvoiceCellType type = kInvoiceCellTypeMiddle;
			
			if (indexPath.row == 0)
			{
				if (paidInvoicesArray.count == 1)
				{
					type = kInvoiceCellTypeSingle;
				}
				else
				{
					type = kInvoiceCellTypeTop;
				}
			}
			else if (indexPath.row == paidInvoicesArray.count - 1)
			{
				type = kInvoiceCellTypeBottom;
			}
			
			[theCell loadInvoice:[paidInvoicesArray objectAtIndex:indexPath.row] withCellType:type];
			
			break;
		}
			
		case kSectionOverdue:
		{
			kInvoiceCellType type = kInvoiceCellTypeMiddle;
			
			if (indexPath.row == 0)
			{
				if (overdueInvoicesArray.count == 1)
				{
					type = kInvoiceCellTypeSingle;
				}
				else
				{
					type = kInvoiceCellTypeTop;
				}
			}
			else if (indexPath.row == overdueInvoicesArray.count - 1)
			{
				type = kInvoiceCellTypeBottom;
			}
			
			[theCell loadInvoice:[overdueInvoicesArray objectAtIndex:indexPath.row] withCellType:type];
			
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
			[(INVCell*)cell resize];
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
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"Delete"  handler:^(UITableViewRowAction *action, NSIndexPath *indexPath)
    {
        switch (selected_section)
        {
            case kSectionOpen:
            {
                [sync_manager updateCloud:[(InvoiceOBJ*)[openInvoicesArray objectAtIndex:indexPath.row] contentsDictionary] andPurposeForDelete:-1];
                [openInvoicesArray removeObjectAtIndex:indexPath.row];
                
                break;
            }
                
            case kSectionPaid:
            {
                [sync_manager updateCloud:[(InvoiceOBJ*)[paidInvoicesArray objectAtIndex:indexPath.row] contentsDictionary] andPurposeForDelete:-1];
                [paidInvoicesArray removeObjectAtIndex:indexPath.row];
                
                break;
            }
                
            case kSectionOverdue:
            {
                [sync_manager updateCloud:[(InvoiceOBJ*)[overdueInvoicesArray objectAtIndex:indexPath.row] contentsDictionary] andPurposeForDelete:-1];
                [overdueInvoicesArray removeObjectAtIndex:indexPath.row];
                
                break;
            }
                
            default:
                break;
        }
        
        [array_with_invoices removeAllObjects];
        [array_with_invoices addObjectsFromArray:openInvoicesArray];
        [array_with_invoices addObjectsFromArray:paidInvoicesArray];
        [array_with_invoices addObjectsFromArray:overdueInvoicesArray];
        
        [invoicesTableView reloadData];
        
        [data_manager saveInvoicesArrayToUserDefaults:array_with_invoices forKey:kInvoicesKeyForNSUserDefaults];
        
    }];
    
    return @[deleteAction];
}

-(void)tableView:(UITableView*)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath*)indexPath
{
	if (editingStyle == UITableViewCellEditingStyleDelete)
	{
		switch (selected_section)
		{
			case kSectionOpen:
			{
				[sync_manager updateCloud:[(InvoiceOBJ*)[openInvoicesArray objectAtIndex:indexPath.row] contentsDictionary] andPurposeForDelete:-1];
				[openInvoicesArray removeObjectAtIndex:indexPath.row];
				
				break;
			}
				
			case kSectionPaid:
			{
				[sync_manager updateCloud:[(InvoiceOBJ*)[paidInvoicesArray objectAtIndex:indexPath.row] contentsDictionary] andPurposeForDelete:-1];
				[paidInvoicesArray removeObjectAtIndex:indexPath.row];
				
				break;
			}
				
			case kSectionOverdue:
			{
				[sync_manager updateCloud:[(InvoiceOBJ*)[overdueInvoicesArray objectAtIndex:indexPath.row] contentsDictionary] andPurposeForDelete:-1];
				[overdueInvoicesArray removeObjectAtIndex:indexPath.row];
				
				break;
			}
				
			default:
				break;
		}
		
		[array_with_invoices removeAllObjects];
		[array_with_invoices addObjectsFromArray:openInvoicesArray];
		[array_with_invoices addObjectsFromArray:paidInvoicesArray];
		[array_with_invoices addObjectsFromArray:overdueInvoicesArray];
        
        [invoicesTableView reloadData];
		
		[data_manager saveInvoicesArrayToUserDefaults:array_with_invoices forKey:kInvoicesKeyForNSUserDefaults];
	}
}

-(void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath {
	index_of_invoice = (int)indexPath.row;
	
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
        
		changePaperSize(dvc_width, dvc_width * height / width);
		
		InvoiceOBJ * selectedInvoice;
		
		switch (selected_section)
		{
			case kSectionOpen:
			{
				selectedInvoice = [openInvoicesArray objectAtIndex:index_of_invoice];
				
				break;
			}
				
			case kSectionOverdue:
			{
				selectedInvoice = [overdueInvoicesArray objectAtIndex:index_of_invoice];
				
				break;
			}
				
			case kSectionPaid:
			{
				selectedInvoice = [paidInvoicesArray objectAtIndex:index_of_invoice];
				
				break;
			}
				
			default:
				break;
		}
	
		NSData * pdfData = [PDFCreator PDFDataFromUIView:[PDFCreator PDFViewFromInvoice:selectedInvoice]];
		
		UIWebView * webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 20, dvc_width, dvc_height)];
		[webView loadData:pdfData MIMEType:@"application/pdf" textEncodingName:@"" baseURL:nil];
		[webView setAlpha:0.0];
		[webView setTag:666];
		[DELEGATE.window addSubview:webView];
		
		UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closePreview:)];
		[webView addGestureRecognizer:tap];
		
		[UIView animateWithDuration:0.25 animations:^{
			
			[webView setAlpha:1.0];
			
		}];
	}
	else
    if (buttonIndex == 2)
	{
		if ([MFMailComposeViewController canSendMail])
		{
			revertPaperSize;
			
			InvoiceOBJ * selectedInvoice;
			
			switch (selected_section)
			{
				case kSectionOpen:
				{
					selectedInvoice = [openInvoicesArray objectAtIndex:index_of_invoice];
					
					break;
				}
					
				case kSectionOverdue:
				{
					selectedInvoice = [overdueInvoicesArray objectAtIndex:index_of_invoice];
					
					break;
				}
					
				case kSectionPaid:
				{
					selectedInvoice = [paidInvoicesArray objectAtIndex:index_of_invoice];
					
					break;
				}
					
				default:
					break;
			}
			
			NSString * fileName = [NSString stringWithFormat:@"%@.pdf", [selectedInvoice number]];
			
			MFMailComposeViewController * vc = [[MFMailComposeViewController alloc] init];
			[vc setSubject:[NSString stringWithFormat:@"%@", [selectedInvoice number]]];
			[vc setToRecipients:[NSArray arrayWithObject:[[selectedInvoice client] email]]];
			[vc setMailComposeDelegate:self];
			[vc addAttachmentData:[PDFCreator PDFDataFromUIView:[PDFCreator PDFViewFromInvoice:selectedInvoice]] mimeType:@"application/pdf" fileName:fileName];
			[self presentViewController:vc animated:YES completion:nil];
		}
		else
		{
			[[[AlertView alloc] initWithTitle:@"" message:@"You must configure an email account in the device settings to be able to send emails." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
		}
	}
	else
    if (buttonIndex == 3)
	{
		UIPrintInteractionController * pic = [UIPrintInteractionController sharedPrintController];
		
		InvoiceOBJ * selectedInvoice;
		
		switch (selected_section)
		{
			case kSectionOpen:
			{
				selectedInvoice = [openInvoicesArray objectAtIndex:index_of_invoice];
				
				break;
			}
				
			case kSectionOverdue:
			{
				selectedInvoice = [overdueInvoicesArray objectAtIndex:index_of_invoice];
				
				break;
			}
				
			case kSectionPaid:
			{
				selectedInvoice = [paidInvoicesArray objectAtIndex:index_of_invoice];
				
				break;
			}
				
			default:
				break;
		}
        
		NSData * temp = [PDFCreator PDFDataFromUIView:[PDFCreator PDFViewFromInvoice:selectedInvoice]];
		
		if (pic && [UIPrintInteractionController canPrintData:temp])
		{
			UIPrintInfo * printInfo = [UIPrintInfo printInfo];
			[printInfo setOutputType:UIPrintInfoOutputGeneral];
			[printInfo setJobName:@"Print Invoice"];
			[printInfo setDuplex:UIPrintInfoDuplexNone];
			[printInfo setOrientation:UIPrintInfoOrientationLandscape];
			
			[pic setPrintInfo:printInfo];
			[pic setShowsPageRange:YES];
			[pic setPrintingItem:temp];
			
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
		InvoiceOBJ * selectedInvoice;
		
		switch (selected_section)
		{
			case kSectionOpen:
			{
				selectedInvoice = [openInvoicesArray objectAtIndex:index_of_invoice];
				
				break;
			}
				
			case kSectionOverdue:
			{
				selectedInvoice = [overdueInvoicesArray objectAtIndex:index_of_invoice];
				
				break;
			}
				
			case kSectionPaid:
			{
				selectedInvoice = [paidInvoicesArray objectAtIndex:index_of_invoice];
				
				break;
			}
				
			default:
				break;
		}
		
		CreateInvoiceVC * vc = [[CreateInvoiceVC alloc] initWithInvoice:selectedInvoice delegate:self];
		UINavigationController * nvc = [[UINavigationController alloc] initWithRootViewController:vc];
		[nvc setNavigationBarHidden:YES];
		[self.navigationController presentViewController:nvc animated:YES completion:nil];
	}
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
		selected_section = kSectionOverdue;
	else
	if(category == 2)
		selected_section = kSectionOpen;
	else
		selected_section = kSectionPaid;
	
	[self createArrays];
	
	[invoicesTableView reloadData];
}

#pragma mark - VIEW CONTROLLER FUNCTIONS

-(void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	[self createArrays];
	
	[invoicesTableView reloadData];
}

-(void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
}

-(void)dealloc
{
	[invoicesTableView setEditing:NO];
	[invoicesTableView setDelegate:nil];
  
  [array_with_invoices removeAllObjects];
  array_with_invoices = nil;
  
  [overdueInvoicesArray removeAllObjects];
  overdueInvoicesArray = nil;
  [paidInvoicesArray removeAllObjects];
  paidInvoicesArray = nil;
  [openInvoicesArray removeAllObjects];
  openInvoicesArray = nil;
}

@end