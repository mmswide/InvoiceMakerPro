//
//  EstimatesVC.m
//  Invoice
//
//  Created by XGRoup5 on 8/13/13.
//  Copyright (c) 2013 XGRoup. All rights reserved.
//

#import "EstimatesVC.h"

#import "Defines.h"
#import "CreateEstimateVC.h"
#import "ESTCell.h"
#import "ExportVC.h"

@interface EstimatesVC () <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, EstimateCreatorDelegate, MFMailComposeViewControllerDelegate, AlertViewDelegate>

@end

@implementation EstimatesVC

-(id)init
{
	self = [super init];
	
	if (self)
	{
		
	}
	
	return self;
}

-(id)initWithEstimates:(NSArray*)sender
{
	self = [super init];
	
	if (self)
	{
		array_with_estimates = [[NSMutableArray alloc] initWithArray:sender];
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
	
	topBarView = [[TopBar alloc] initWithFrame:CGRectMake(0, 0, dvc_width, 42 + statusBarHeight) andTitle:@"Estimates"];
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
	
	if (!array_with_estimates)
	{
		array_with_estimates = [[NSMutableArray alloc] initWithArray:[data_manager loadEstimatesArrayFromUserDefaultsAtKey:kEstimatesKeyForNSUserDefaults]];
		
		UIButton * addEstimate = [[UIButton alloc] initWithFrame:CGRectMake(dvc_width - 40, 42 + statusBarHeight - 40, 40, 40)];
		[addEstimate setTitle:@"+" forState:UIControlStateNormal];
		[addEstimate setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		[addEstimate setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
		[addEstimate.titleLabel setFont:HelveticaNeueBold(33)];
		[addEstimate setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 10, 0)];
		[addEstimate addTarget:self action:@selector(createEstimate:) forControlEvents:UIControlEventTouchUpInside];
		[topBarView addSubview:addEstimate];
	}
	
	estimatesTableView = [[TableWithShadow alloc] initWithFrame:CGRectMake(0, 42, dvc_width, dvc_height - 87) style:UITableViewStylePlain];
	[estimatesTableView setDelegate:self];
	[estimatesTableView setDataSource:self];
	[estimatesTableView setSeparatorColor:[UIColor clearColor]];
	estimatesTableView.backgroundColor = [UIColor clearColor];
	[theSelfView addSubview:estimatesTableView];
	
	[self.view addSubview:topBarView];
}

#pragma mark - FUNCTIONS

-(void)back:(UIButton*)sender
{
	[self.navigationController popViewControllerAnimated:YES];
}

-(void)createEstimate:(UIButton*)sender
{
	if ([DELEGATE documentsLimitReached])
		return;
	
	index_of_estimate = -1;
	
	CreateEstimateVC * vc = [[CreateEstimateVC alloc] initForCreationWithDelegate:self];
	UINavigationController * nvc = [[UINavigationController alloc] initWithRootViewController:vc];
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

#pragma mark - ESTIMATE CREATOR DELEGATE

-(void)creatorViewController:(CreateEstimateVC*)viewController createdEstimate:(EstimateOBJ*)estimate
{
	if (index_of_estimate == -1)
	{	
		[DELEGATE incrementDocumentsCount];
		
		[sync_manager updateCloud:[estimate contentsDictionary] andPurposeForDelete:1];
		[array_with_estimates insertObject:estimate atIndex:0];
	}
	else
	{
		[sync_manager updateCloud:[estimate contentsDictionary] andPurposeForDelete:0];
		[array_with_estimates replaceObjectAtIndex:index_of_estimate withObject:estimate];
	}
	
	[data_manager saveEstimatesArrayToUserDefaults:array_with_estimates forKey:kEstimatesKeyForNSUserDefaults];
	[estimatesTableView reloadData];
}

#pragma mark - TABLE VIEW DATASOURCE

-(NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
	return array_with_estimates.count;
}

-(UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
	ESTCell * theCell = [tableView dequeueReusableCellWithIdentifier:nil];
	
	if (!theCell)
	{
		theCell = [[ESTCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
	}
	
	kEstimateCellType type = kEstimateCellTypeMiddle;
	
	if (indexPath.row == 0)
	{
		if (array_with_estimates.count == 1)
		{
			type = kEstimateCellTypeSingle;
		}
		else
		{
			type = kEstimateCellTypeTop;
		}
	}
	else if (indexPath.row == array_with_estimates.count - 1)
	{
		type = kEstimateCellTypeBottom;
	}
	
	[theCell loadEstimate:[array_with_estimates objectAtIndex:indexPath.row] withCellType:type];
	
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
			[(ESTCell*)cell resize];
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
        [sync_manager updateCloud:[(EstimateOBJ*)[array_with_estimates objectAtIndex:indexPath.row] contentsDictionary] andPurposeForDelete:-1];
        
        [array_with_estimates removeObjectAtIndex:indexPath.row];
        [estimatesTableView reloadData];
        
        [data_manager saveEstimatesArrayToUserDefaults:array_with_estimates forKey:kEstimatesKeyForNSUserDefaults];
    }];
    
    return @[deleteAction];
}

-(void)tableView:(UITableView*)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath*)indexPath
{
	if (editingStyle == UITableViewCellEditingStyleDelete)
	{
		[sync_manager updateCloud:[(EstimateOBJ*)[array_with_estimates objectAtIndex:indexPath.row] contentsDictionary] andPurposeForDelete:-1];
		
		[array_with_estimates removeObjectAtIndex:indexPath.row];
		[estimatesTableView reloadData];
		
		[data_manager saveEstimatesArrayToUserDefaults:array_with_estimates forKey:kEstimatesKeyForNSUserDefaults];
	}
}

-(void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
	index_of_estimate = (int)indexPath.row;
	
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
		
		NSData * pdfData = [PDFCreator PDFDataFromUIView:[PDFCreator PDFViewFromEstimate:[array_with_estimates objectAtIndex:index_of_estimate]]];
		
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
			NSString * fileName = [NSString stringWithFormat:@"%@.pdf", [(EstimateOBJ*)[array_with_estimates objectAtIndex:index_of_estimate] number]];
			
			MFMailComposeViewController * vc = [[MFMailComposeViewController alloc] init];
			[vc setSubject:[NSString stringWithFormat:@"%@", [(EstimateOBJ*)[array_with_estimates objectAtIndex:index_of_estimate] number]]];
			[vc setToRecipients:[NSArray arrayWithObject:[[(EstimateOBJ*)[array_with_estimates objectAtIndex:index_of_estimate] client] email]]];
			[vc setMailComposeDelegate:self];
			[vc addAttachmentData:[PDFCreator PDFDataFromUIView:[PDFCreator PDFViewFromEstimate:[array_with_estimates objectAtIndex:index_of_estimate]]] mimeType:@"application/pdf" fileName:fileName];
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
		
		NSData * temp = [PDFCreator PDFDataFromUIView:[PDFCreator PDFViewFromEstimate:[array_with_estimates objectAtIndex:index_of_estimate]]];
		
		if (pic && [UIPrintInteractionController canPrintData:temp])
		{
			UIPrintInfo * printInfo = [UIPrintInfo printInfo];
			[printInfo setOutputType:UIPrintInfoOutputGeneral];
			[printInfo setJobName:@"Print Estimate"];
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
		CreateEstimateVC * vc = [[CreateEstimateVC alloc] initWithEstimate:[array_with_estimates objectAtIndex:index_of_estimate] delegate:self];
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

#pragma mark - VIEW CONTROLLER FUNCTIONS

-(void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];

	kApplicationVersion version = app_version;
	
	switch (version)
	{
		case kApplicationVersionEstimate:
		{
			[array_with_estimates removeAllObjects];
			[array_with_estimates addObjectsFromArray:[data_manager loadEstimatesArrayFromUserDefaultsAtKey:kEstimatesKeyForNSUserDefaults]];
			
			break;
		}
			
		default:
			break;
	}
	
	[estimatesTableView reloadData];
}

-(void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
}

-(void)dealloc
{
	[estimatesTableView setEditing:NO];
	[estimatesTableView setDelegate:nil];
  
  [array_with_estimates removeAllObjects];
  array_with_estimates = nil;
}

@end