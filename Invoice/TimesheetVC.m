//
//  TimesheetVC.m
//  Invoice
//
//  Created by XGRoup on 7/17/14.
//  Copyright (c) 2014 XGRoup. All rights reserved.
//

#import "TimesheetVC.h"

#import "Defines.h"
#import "TimesheetCell.h"
#import "CreateTimesheetVC.h"
#import "CategorySelectV.h"

@interface TimesheetVC ()

<
UITableViewDataSource,
UITableViewDelegate,
UIScrollViewDelegate,
MFMailComposeViewControllerDelegate ,
AlertViewDelegate ,
CategorySelectDelegate,
TimesheetCreatorDelegate
>

@end

@implementation TimesheetVC

-(id)init
{
	self = [super init];
	
	if(self)
	{
		
	}
	
	return self;
}

-(id)initWithTimesheets:(NSArray *)sender
{
	self = [super init];
	
	if (self)
	{
		array_with_timesheets = [[NSMutableArray alloc] initWithArray:sender];
	}
	
	return self;
}

#pragma mark - VIEW DID LOAD

-(void)viewDidLoad
{
	[super viewDidLoad];
	
	selected_section = kSectionWeek;
	
	theSelfView = [[UIView alloc] initWithFrame:CGRectMake(0, statusBarHeight, dvc_width, dvc_height)];
	[theSelfView setBackgroundColor:[UIColor clearColor]];
	[self.view addSubview:theSelfView];
	
	[self.view setBackgroundColor:app_background_color];
	
	topBarView = [[TopBar alloc] initWithFrame:CGRectMake(0, 0, dvc_width, 42 + statusBarHeight) andTitle:@"Timesheets"];
	[topBarView setBackgroundColor:app_bar_update_color];
	
	if(app_version == 0)
	{
		BackButton * backButton = [[BackButton alloc] initWithFrame:CGRectMake(0, 42 + statusBarHeight - 40, 70, 40) andTitle:@"Back"];
		[backButton addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
		[topBarView addSubview:backButton];

	}
	else
	{
		menuView = [[MenuV alloc] initWithFrame:CGRectMake(0, 20 - statusBarHeight, 200, dvc_height + statusBarHeight)];
		menuView.backgroundColor = app_bar_update_color;
        menuView.alpha = 0.0f;
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
		
	if (!array_with_timesheets)
	{		
		array_with_timesheets = [[NSMutableArray alloc] initWithArray:[data_manager loadTimesheetsArrayFromUserDefaultsAtKey:kTimeSheetKeyForNSUserDefaults]];
		
		UIButton * addReceipt = [[UIButton alloc] initWithFrame:CGRectMake(dvc_width - 40, 42 + statusBarHeight - 40, 40, 40)];
		[addReceipt setTitle:@"+" forState:UIControlStateNormal];
		[addReceipt setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		[addReceipt setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
		[addReceipt.titleLabel setFont:HelveticaNeueBold(33)];
		[addReceipt setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 10, 0)];
		[addReceipt addTarget:self action:@selector(createTimesheet:) forControlEvents:UIControlEventTouchUpInside];
		[topBarView addSubview:addReceipt];
	}
	
	weekTimesheets = [[NSMutableArray alloc] init];
	monthTimesheets = [[NSMutableArray alloc] init];
	yearTimesheets = [[NSMutableArray alloc] init];
	
	[self createArrays];
	
	timesheetTableView = [[TableWithShadow alloc] initWithFrame:CGRectMake(0, theSelfView.frame.origin.y + 82 - statusBarHeight, dvc_width, dvc_height - 87 - 40) style:UITableViewStyleGrouped];
	[timesheetTableView setDelegate:self];
	[timesheetTableView setDataSource:self];
	[timesheetTableView setSeparatorColor:[UIColor clearColor]];
	[timesheetTableView setBackgroundColor:[UIColor clearColor]];
	[timesheetTableView setBackgroundView:nil];
	[timesheetTableView setTableHeaderView:[[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)]];
	[theSelfView addSubview:timesheetTableView];
	
	[(TableWithShadow*)timesheetTableView setUpperShadowAlpha:1.0];
	
	[self.view addSubview:topBarView];
	
	categoryBar = [[CategorySelectV alloc] initWithFrame:CGRectMake(0, theSelfView.frame.origin.y + 52 - statusBarHeight, dvc_width, 30) andType:kTimesheetSelect andDelegate:self];
	categoryBar.backgroundColor = [UIColor clearColor];
	[theSelfView addSubview:categoryBar];
}

-(void)createArrays
{
	[weekTimesheets removeAllObjects];
	[monthTimesheets removeAllObjects];
	[yearTimesheets removeAllObjects];
	
	for(TimeSheetOBJ *timesheet in array_with_timesheets)
	{
		NSDate *receiptDate = [timesheet date];
		
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
					[weekTimesheets addObject:timesheet];
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
					[monthTimesheets addObject:timesheet];
				}
				
				break;
			}
				
			case kSectionYear:
			{
				[yearTimesheets addObject:timesheet];
				
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
			nrRows = weekTimesheets.count;
			break;
		}
			
		case kSectionMonth:
		{
			nrRows = monthTimesheets.count;
			break;
		}
			
		case kSectionYear:
		{
			nrRows = yearTimesheets.count;
			break;
		}
			
		default:
			break;
	}
	
	return nrRows;
}

-(UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
	TimesheetCell * theCell = [tableView dequeueReusableCellWithIdentifier:nil];
	
	if (!theCell)
	{
		theCell = [[TimesheetCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
	}
	
	switch (selected_section)
	{
		case kSectionWeek:
		{
			kCellType type = kCellTypeMiddle;
			
			if (indexPath.row == 0)
			{
				if (weekTimesheets.count == 1)
				{
					type = kCellTypeSingle;
				}
				else
				{
					type = kCellTypeTop;
				}
			}
			else if (indexPath.row == weekTimesheets.count - 1)
			{
				type = kCellTypeBottom;
			}
			
			[theCell loadTimesheet:[weekTimesheets objectAtIndex:indexPath.row] withCellType:type];
			
			break;
		}
			
		case kSectionMonth:
		{
			kCellType type = kCellTypeMiddle;
			
			if (indexPath.row == 0)
			{
				if (monthTimesheets.count == 1)
				{
					type = kCellTypeSingle;
				}
				else
				{
					type = kCellTypeTop;
				}
			}
			else if (indexPath.row == monthTimesheets.count - 1)
			{
				type = kCellTypeBottom;
			}

			[theCell loadTimesheet:[monthTimesheets objectAtIndex:indexPath.row] withCellType:type];
			
			break;
		}
			
		case kSectionYear:
		{
			kCellType type = kCellTypeMiddle;
			
			if (indexPath.row == 0)
			{
				if (yearTimesheets.count == 1)
				{
					type = kCellTypeSingle;
				}
				else
				{
					type = kCellTypeTop;
				}
			}
			else if (indexPath.row == yearTimesheets.count - 1)
			{
				type = kCellTypeBottom;
			}
			
			[theCell loadTimesheet:[yearTimesheets objectAtIndex:indexPath.row] withCellType:type];
			
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
			[(TimesheetCell*)cell resize];
		}
	}
}

#pragma mark - TABLE VIEW DELEGATE

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	if(selected_section == kSectionWeek)
	{
		if(weekTimesheets.count == 0)
			return 0.0f;
	}
	else
	if(selected_section == kSectionMonth)
	{
		if(monthTimesheets.count == 0)
			return 0.0f;
	}
	else
	if(selected_section == kSectionYear)
	{
		if(yearTimesheets.count == 0)
			return 0.0f;
	}
	
	return 30.0f;
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 30)];
	view.backgroundColor = [UIColor clearColor];
	
	UILabel * title = [[UILabel alloc] initWithFrame:CGRectMake(22, 10, dvc_width - 44, 20)];
	[title setTextAlignment:NSTextAlignmentRight];
	[title setTextColor:app_title_color];
	[title setFont:HelveticaNeueMedium(15)];
	[title setBackgroundColor:[UIColor clearColor]];
	[view addSubview:title];

	NSString *timeWorked = @"";
	
	if(selected_section == kSectionWeek)
	{
		timeWorked = [data_manager getTotalHoursForThisWeek:array_with_timesheets];
	}
	else
	if(selected_section == kSectionMonth)
	{
		timeWorked = [data_manager getTotalHoursForThisMonth:array_with_timesheets];
	}
	else
	if(selected_section == kSectionYear)
	{
		timeWorked = [data_manager getTotalHoursForThisYear:array_with_timesheets];
	}
	
	timeWorked = [NSString stringWithFormat:@"Total time worked: %@",timeWorked];
		
	[title setText:timeWorked];
	
	return view;
}

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
            case kSectionWeek:
            {
                [sync_manager updateCloud:[(TimeSheetOBJ*)[weekTimesheets objectAtIndex:indexPath.row] dictionaryRepresentation] andPurposeForDelete:-1];
                [weekTimesheets removeObjectAtIndex:indexPath.row];
                
                break;
            }
                
            case kSectionMonth:
            {
                [sync_manager updateCloud:[(TimeSheetOBJ*)[monthTimesheets objectAtIndex:indexPath.row] dictionaryRepresentation] andPurposeForDelete:-1];
                [monthTimesheets removeObjectAtIndex:indexPath.row];
                
                break;
            }
                
            case kSectionYear:
            {
                [sync_manager updateCloud:[(TimeSheetOBJ*)[yearTimesheets objectAtIndex:indexPath.row] dictionaryRepresentation] andPurposeForDelete:-1];
                [yearTimesheets removeObjectAtIndex:indexPath.row];
                
                break;
            }
                
            default:
                break;
        }
        
        [array_with_timesheets removeAllObjects];
        [array_with_timesheets addObjectsFromArray:weekTimesheets];
        [array_with_timesheets addObjectsFromArray:monthTimesheets];
        [array_with_timesheets addObjectsFromArray:yearTimesheets];
        
        [data_manager saveTimesheetArrayToUserDefaults:array_with_timesheets forKey:kTimeSheetKeyForNSUserDefaults];
        
        [timesheetTableView reloadData];
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
				[sync_manager updateCloud:[(TimeSheetOBJ*)[weekTimesheets objectAtIndex:indexPath.row] dictionaryRepresentation] andPurposeForDelete:-1];
				[weekTimesheets removeObjectAtIndex:indexPath.row];
				
				break;
			}
				
			case kSectionMonth:
			{
				[sync_manager updateCloud:[(TimeSheetOBJ*)[monthTimesheets objectAtIndex:indexPath.row] dictionaryRepresentation] andPurposeForDelete:-1];
				[monthTimesheets removeObjectAtIndex:indexPath.row];
				
				break;
			}
				
			case kSectionYear:
			{
				[sync_manager updateCloud:[(TimeSheetOBJ*)[yearTimesheets objectAtIndex:indexPath.row] dictionaryRepresentation] andPurposeForDelete:-1];
				[yearTimesheets removeObjectAtIndex:indexPath.row];
				
				break;
			}
				
			default:
				break;
		}
				
		[array_with_timesheets removeAllObjects];
		[array_with_timesheets addObjectsFromArray:weekTimesheets];
		[array_with_timesheets addObjectsFromArray:monthTimesheets];
		[array_with_timesheets addObjectsFromArray:yearTimesheets];
		
		[data_manager saveTimesheetArrayToUserDefaults:array_with_timesheets forKey:kTimeSheetKeyForNSUserDefaults];
        
        [timesheetTableView reloadData];
	}
}

-(void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
	index_of_timesheet = (int)indexPath.row;
	
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
		
		TimeSheetOBJ * selectedTimesheet;
		
		switch (selected_section)
		{
			case kSectionWeek:
			{
				selectedTimesheet = [weekTimesheets objectAtIndex:index_of_timesheet];
				
				break;
			}
				
			case kSectionMonth:
			{
				selectedTimesheet = [monthTimesheets objectAtIndex:index_of_timesheet];
				
				break;
			}
				
			case kSectionYear:
			{
				selectedTimesheet = [yearTimesheets objectAtIndex:index_of_timesheet];
				
				break;
			}
				
			default:
				break;
		}
		
		NSData * pdfData = [PDFCreator2 PDFDataFromUIView:[PDFCreator2 PDFViewFromTimesheet:selectedTimesheet]];
		
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
	else if (buttonIndex == 2)
	{
		if ([MFMailComposeViewController canSendMail])
		{
			revertPaperSize;
			
			TimeSheetOBJ * selectedTimesheet;
			
			switch (selected_section)
			{
				case kSectionWeek:
				{
					selectedTimesheet = [weekTimesheets objectAtIndex:index_of_timesheet];
					
					break;
				}
					
				case kSectionMonth:
				{
					selectedTimesheet = [monthTimesheets objectAtIndex:index_of_timesheet];
					
					break;
				}
					
				case kSectionYear:
				{
					selectedTimesheet = [yearTimesheets objectAtIndex:index_of_timesheet];
					
					break;
				}
					
				default:
					break;
			}
			
			NSString * fileName = [NSString stringWithFormat:@"timesheet.pdf"];
			
			MFMailComposeViewController * vc = [[MFMailComposeViewController alloc] init];
			[vc setSubject:[NSString stringWithFormat:@"Timesheet"]];
			[vc setToRecipients:nil];
			[vc setMailComposeDelegate:self];
			[vc addAttachmentData:[PDFCreator2 PDFDataFromUIView:[PDFCreator2 PDFViewFromTimesheet:selectedTimesheet]] mimeType:@"application/pdf" fileName:fileName];
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
		
		TimeSheetOBJ * selectedTimesheet;
		
		switch (selected_section)
		{
			case kSectionWeek:
			{
				selectedTimesheet = [weekTimesheets objectAtIndex:index_of_timesheet];
				
				break;
			}
				
			case kSectionMonth:
			{
				selectedTimesheet = [monthTimesheets objectAtIndex:index_of_timesheet];
				
				break;
			}
				
			case kSectionYear:
			{
				selectedTimesheet = [yearTimesheets objectAtIndex:index_of_timesheet];
				
				break;
			}
				
			default:
				break;
		}
		
		NSData * temp = [PDFCreator2 PDFDataFromUIView:[PDFCreator2 PDFViewFromTimesheet:selectedTimesheet]];
		
		if (pic && [UIPrintInteractionController canPrintData:temp])
		{
			UIPrintInfo * printInfo = [UIPrintInfo printInfo];
			[printInfo setOutputType:UIPrintInfoOutputGeneral];
			[printInfo setJobName:@"Print Timesheet"];
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
		TimeSheetOBJ * selectedTimesheet;
		
		switch (selected_section)
		{
			case kSectionWeek:
			{
				selectedTimesheet = [weekTimesheets objectAtIndex:index_of_timesheet];
				
				break;
			}
				
			case kSectionMonth:
			{
				selectedTimesheet = [monthTimesheets objectAtIndex:index_of_timesheet];
				
				break;
			}
				
			case kSectionYear:
			{
				selectedTimesheet = [yearTimesheets objectAtIndex:index_of_timesheet];
				
				break;
			}
				
			default:
				break;
		}
	
		CreateTimesheetVC *vc = [[CreateTimesheetVC alloc] initWithTimesheet:selectedTimesheet delegate:self];
		
		UINavigationController * nvc = [[UINavigationController alloc] initWithRootViewController:vc];
		[nvc setNavigationBarHidden:YES];
		[self.navigationController presentViewController:nvc animated:YES completion:nil];
	}
}

#pragma mark - RECEIPT CREATOR DELEGATE

-(void)creatorViewController:(CreateTimesheetVC *)viewController createdTimesheet:(TimeSheetOBJ *)timesheet
{
	if (index_of_timesheet == -1)
	{
		if ([[timesheet number] isEqual:@"TS00001"])
		{
			int number = (int)[CustomDefaults customIntegerForKey:kNumberOfTimesheetKeyForNSUserDefaults];
			
			NSString * valueSTR = [timesheet number];
			
			if ([valueSTR isEqual:@"TS00001"])
			{
				if (number < 10)
				{
					valueSTR = [NSString stringWithFormat:@"TS0000%d", number];
				}
				else if (number < 100)
				{
					valueSTR = [NSString stringWithFormat:@"TS000%d", number];
				}
				else if (number < 1000)
				{
					valueSTR = [NSString stringWithFormat:@"TS00%d", number];
				}
				else if (number < 10000)
				{
					valueSTR = [NSString stringWithFormat:@"TS0%d", number];
				}
				else
				{
					valueSTR = [NSString stringWithFormat:@"TS%d", number];
				}
			}
			
			[timesheet setNumber:valueSTR];
			number++;
			
			[CustomDefaults setCustomInteger:number forKey:kNumberOfTimesheetKeyForNSUserDefaults];
		}
		
		[DELEGATE incrementDocumentsCount];
		
		[sync_manager updateCloud:[timesheet dictionaryRepresentation] andPurposeForDelete:1];
		
		[array_with_timesheets insertObject:timesheet atIndex:0];
		
		[self createArrays];
	}
	else
	{
		[sync_manager updateCloud:[timesheet dictionaryRepresentation] andPurposeForDelete:0];
		
		switch (selected_section)
		{
			case kSectionWeek:
			{
				[weekTimesheets replaceObjectAtIndex:index_of_timesheet withObject:timesheet];
				
				break;
			}
				
			case kSectionMonth:
			{
				[monthTimesheets replaceObjectAtIndex:index_of_timesheet withObject:timesheet];
				
				break;
			}
				
			case kSectionYear:
			{
				[yearTimesheets replaceObjectAtIndex:index_of_timesheet withObject:timesheet];
				
				break;
			}
				
			default:
				break;
		}
		
		[array_with_timesheets removeAllObjects];
				
		[array_with_timesheets addObjectsFromArray:weekTimesheets];
		[array_with_timesheets addObjectsFromArray:monthTimesheets];
		[array_with_timesheets addObjectsFromArray:yearTimesheets];
	}

	[data_manager saveTimesheetArrayToUserDefaults:array_with_timesheets forKey:kTimeSheetKeyForNSUserDefaults];
	
	[timesheetTableView reloadData];
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
	
	[timesheetTableView reloadData];
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

-(void)createTimesheet:(UIButton *)sender
{
	if ([DELEGATE documentsLimitReached])
		return;
	
	index_of_timesheet = -1;
	
	CreateTimesheetVC *vc = [[CreateTimesheetVC alloc] initForCreationWithDelegate:self];

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
		case kApplicationVersionTimesheets:
		{			
			[array_with_timesheets removeAllObjects];
			[array_with_timesheets addObjectsFromArray:[data_manager loadTimesheetsArrayFromUserDefaultsAtKey:kTimeSheetKeyForNSUserDefaults]];
			
			break;
		}
			
		default:
			break;
	}

	[self createArrays];
	
	[timesheetTableView reloadData];
}

-(void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
}

-(void)dealloc
{
	[timesheetTableView setEditing:NO];
	[timesheetTableView setDelegate:nil];
}

@end
