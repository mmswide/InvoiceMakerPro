//
//  HomeVC.m
//  Invoice
//
//  Created by XGRoup5 on 8/13/13.
//  Copyright (c) 2013 XGRoup. All rights reserved.
//

#import "HomeVC.h"

#import "Defines.h"

#import "InvoicesVC.h"
#import "EstimatesVC.h"
#import "PurchaseOrdersVC.h"
#import "EstimatesVC_Q.h"
#import "ExportVC.h"
#import "MenuV.h"
#import "ReceiptsVC.h"
#import "TimesheetVC.h"

@interface HomeVC ()

@end

@implementation HomeVC

-(id)init
{
	self = [super init];
	
	if (self)
	{
		
	}
	
	return self;
}

#pragma mark - VIEW DID LOAD

-(void)viewDidLoad
{
	[super viewDidLoad];
			
	menuView = [[MenuV alloc] initWithFrame:CGRectMake(0, 20 - statusBarHeight, 200, dvc_height + statusBarHeight)];
	menuView.backgroundColor = app_bar_update_color;
    menuView.alpha = 0.0f;
	[DELEGATE.window addSubview:menuView];
    
    [DELEGATE.window sendSubviewToBack:menuView];
    [DELEGATE.window bringSubviewToFront:self.view];
	
	theSelfView = [[UIView alloc] initWithFrame:CGRectMake(0, statusBarHeight, dvc_width, dvc_height)];
	[theSelfView setBackgroundColor:[UIColor clearColor]];
	[self.view addSubview:theSelfView];
	
	[self.view setBackgroundColor:app_background_color];
	
	if(dvc_width <= 320)
		[self createIphoneContent];
	else
		[self createIpadContent];
	
	topBarView = [[TopBar alloc] initWithFrame:CGRectMake(0, 0, dvc_width, 42 + statusBarHeight) andTitle:@"invoice."];
	[topBarView setBackgroundColor:app_bar_update_color];
	[self.view addSubview:topBarView];

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

-(void)createIphoneContent
{
	// Invoices
	{
		UIView *invoicesView = [[UIView alloc] initWithFrame:CGRectMake(0, 60, 140, 80)];
		invoicesView.backgroundColor = [UIColor clearColor];
		[theSelfView addSubview:invoicesView];
		
		UIImageView *invoicesImage = [[UIImageView alloc] initWithFrame:CGRectMake(42, 0, 56, 50)];
		invoicesImage.image = [[UIImage imageNamed:@"fileIcon.png"] stretchableImageWithLeftCapWidth:15 topCapHeight:15];
		[invoicesView addSubview:invoicesImage];
		
		UILabel *invoicesLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 50, 140, 30)];
		invoicesLabel.backgroundColor = [UIColor clearColor];
		invoicesLabel.font = HelveticaNeueMedium(15);
		invoicesLabel.textAlignment = NSTextAlignmentCenter;
		invoicesLabel.textColor = [UIColor colorWithRed:(float)122/255 green:(float)180/255 blue:(float)233/255 alpha:1.0];
		invoicesLabel.text = @"Invoices";
		[invoicesView addSubview:invoicesLabel];
		
		UIButton * invoicesBTN = [[UIButton alloc] initWithFrame:CGRectMake(0, 0 , 140, 80)];
		[invoicesBTN addTarget:self action:@selector(openInvoices:) forControlEvents:UIControlEventTouchUpInside];
		[invoicesView addSubview:invoicesBTN];
		
		[invoicesView setCenter:CGPointMake(dvc_width / 2 - 70, dvc_height / 2 - (80 + 30))];
	}
	
	// Quotes
	{
		UIView *quotesView = [[UIView alloc] initWithFrame:CGRectMake(0, 60, 140, 80)];
		quotesView.backgroundColor = [UIColor clearColor];
		[theSelfView addSubview:quotesView];
		
		UIImageView *quotesImage = [[UIImageView alloc] initWithFrame:CGRectMake(42, 0, 56, 50)];
		quotesImage.image = [[UIImage imageNamed:@"fileIcon"] stretchableImageWithLeftCapWidth:15 topCapHeight:15];
		[quotesView addSubview:quotesImage];
		
		UILabel *quotesLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 50, 140, 30)];
		quotesLabel.backgroundColor = [UIColor clearColor];
		quotesLabel.font = HelveticaNeueMedium(15);
		quotesLabel.textAlignment = NSTextAlignmentCenter;
		quotesLabel.textColor = [UIColor colorWithRed:(float)122/255 green:(float)180/255 blue:(float)233/255 alpha:1.0];
		quotesLabel.text = @"Quotes";
		[quotesView addSubview:quotesLabel];
		
		UIButton *quotesBTN = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 140, 80)];
		[quotesBTN addTarget:self action:@selector(openQuotes:) forControlEvents:UIControlEventTouchUpInside];
		[quotesView addSubview:quotesBTN];
		
		[quotesView setCenter:CGPointMake(dvc_width / 2 + 70,dvc_height / 2 - (80 + 30))];
	}
	
	// Estimates
	{
		UIView *estimatesView = [[UIView alloc] initWithFrame:CGRectMake(0, 60, 140, 80)];
		estimatesView.backgroundColor = [UIColor clearColor];
		[theSelfView addSubview:estimatesView];
		
		UIImageView *estimatesImage = [[UIImageView alloc] initWithFrame:CGRectMake(42, 0, 56, 50)];
		estimatesImage.image = [[UIImage imageNamed:@"fileIcon"] stretchableImageWithLeftCapWidth:15 topCapHeight:15];
		[estimatesView addSubview:estimatesImage];
		
		UILabel *estimatesLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 50, 140, 30)];
		estimatesLabel.backgroundColor = [UIColor clearColor];
		estimatesLabel.font = HelveticaNeueMedium(15);
		estimatesLabel.textAlignment = NSTextAlignmentCenter;
		estimatesLabel.textColor = [UIColor colorWithRed:(float)122/255 green:(float)180/255 blue:(float)233/255 alpha:1.0];
		estimatesLabel.text = @"Estimates";
		[estimatesView addSubview:estimatesLabel];
		
		UIButton *estimatesBTN = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 140, 80)];
		[estimatesBTN addTarget:self action:@selector(openEstimates:) forControlEvents:UIControlEventTouchUpInside];
		[estimatesView addSubview:estimatesBTN];
		
		[estimatesView setCenter:CGPointMake(dvc_width / 2 - 70,dvc_height / 2)];
		
	}
	
	// Purchase Orders
	{
		UIView *purchaseView = [[UIView alloc] initWithFrame:CGRectMake(0, 60, 140, 80)];
		purchaseView.backgroundColor = [UIColor clearColor];
		[theSelfView addSubview:purchaseView];
		
		UIImageView *purchaseImage = [[UIImageView alloc] initWithFrame:CGRectMake(42, 0, 56, 50)];
		purchaseImage.image = [[UIImage imageNamed:@"fileIcon"] stretchableImageWithLeftCapWidth:15 topCapHeight:15];
		[purchaseView addSubview:purchaseImage];
		
		UILabel *purchaseLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 50, 140, 30)];
		purchaseLabel.backgroundColor = [UIColor clearColor];
		purchaseLabel.font = HelveticaNeueMedium(15);
		purchaseLabel.textAlignment = NSTextAlignmentCenter;
		purchaseLabel.textColor = [UIColor colorWithRed:(float)122/255 green:(float)180/255 blue:(float)233/255 alpha:1.0];
		purchaseLabel.text = @"Purchase Orders";
		[purchaseView addSubview:purchaseLabel];
		
		UIButton *purchaseBTN = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 140, 80)];
		[purchaseBTN addTarget:self action:@selector(openPurchaseOrders:) forControlEvents:UIControlEventTouchUpInside];
		[purchaseView addSubview:purchaseBTN];
		
		[purchaseView setCenter:CGPointMake(dvc_width / 2 + 70,dvc_height / 2)];
	}
	
	// Receipts
	{
		UIView *receiptsView = [[UIView alloc] initWithFrame:CGRectMake(0, 60, 140, 80)];
		receiptsView.backgroundColor = [UIColor clearColor];
		[theSelfView addSubview:receiptsView];
		
		UIImageView *receiptImage = [[UIImageView alloc] initWithFrame:CGRectMake(42, 0, 56, 50)];
		receiptImage.image = [[UIImage imageNamed:@"fileIcon"] stretchableImageWithLeftCapWidth:15 topCapHeight:15];
		[receiptsView addSubview:receiptImage];
		
		UILabel *receiptLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 50, 140, 30)];
		receiptLabel.backgroundColor = [UIColor clearColor];
		receiptLabel.font = HelveticaNeueMedium(15);
		receiptLabel.textAlignment = NSTextAlignmentCenter;
		receiptLabel.textColor = [UIColor colorWithRed:(float)122/255 green:(float)180/255 blue:(float)233/255 alpha:1.0];
		receiptLabel.text = @"Receipts";
		[receiptsView addSubview:receiptLabel];
		
		UIButton *receiptBTN = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 140, 80)];
		[receiptBTN addTarget:self action:@selector(openReceipts:) forControlEvents:UIControlEventTouchUpInside];
		[receiptsView addSubview:receiptBTN];
		
		[receiptsView setCenter:CGPointMake(dvc_width / 2 - 70,dvc_height / 2 + 80 + 30)];
	}
	
	// Timesheets
	{
		UIView *timeView = [[UIView alloc] initWithFrame:CGRectMake(0, 60, 140, 80)];
		timeView.backgroundColor = [UIColor clearColor];
		[theSelfView addSubview:timeView];
		
		UIImageView *timeImage = [[UIImageView alloc] initWithFrame:CGRectMake(42, 0, 56, 50)];
		timeImage.image = [[UIImage imageNamed:@"fileIcon"] stretchableImageWithLeftCapWidth:15 topCapHeight:15];
		[timeView addSubview:timeImage];
		
		UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 50, 140, 30)];
		timeLabel.backgroundColor = [UIColor clearColor];
		timeLabel.font = HelveticaNeueMedium(15);
		timeLabel.textAlignment = NSTextAlignmentCenter;
		timeLabel.textColor = [UIColor colorWithRed:(float)122/255 green:(float)180/255 blue:(float)233/255 alpha:1.0];
		timeLabel.text = @"Timesheets";
		[timeView addSubview:timeLabel];
		
		UIButton *timeBTN = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 140, 80)];
		[timeBTN addTarget:self action:@selector(openTimesheets:) forControlEvents:UIControlEventTouchUpInside];
		[timeView addSubview:timeBTN];
		
		[timeView setCenter:CGPointMake(dvc_width / 2 + 70,dvc_height / 2 + 80 + 30)];
	}
}

-(void)createIpadContent
{
	// Invoices
	{
		UIView *invoicesView = [[UIView alloc] initWithFrame:CGRectMake(0, 60, 280, 160)];
		invoicesView.backgroundColor = [UIColor clearColor];
		[theSelfView addSubview:invoicesView];
		
		UIImageView *invoicesImage = [[UIImageView alloc] initWithFrame:CGRectMake(84, 0, 112, 100)];
		invoicesImage.image = [UIImage imageNamed:@"fileIcon.png"];
		[invoicesView addSubview:invoicesImage];
		
		UILabel *invoicesLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 100, 280, 60)];
		invoicesLabel.backgroundColor = [UIColor clearColor];
		invoicesLabel.font = HelveticaNeueMedium(20);
		invoicesLabel.textAlignment = NSTextAlignmentCenter;
		invoicesLabel.textColor = [UIColor colorWithRed:(float)122/255 green:(float)180/255 blue:(float)233/255 alpha:1.0];
		invoicesLabel.text = @"Invoices";
		[invoicesView addSubview:invoicesLabel];
		
		UIButton * invoicesBTN = [[UIButton alloc] initWithFrame:CGRectMake(0, 0 , 280, 160)];
		[invoicesBTN addTarget:self action:@selector(openInvoices:) forControlEvents:UIControlEventTouchUpInside];
		[invoicesView addSubview:invoicesBTN];
		
		[invoicesView setCenter:CGPointMake(dvc_width / 2 - 140, dvc_height / 2 - (120 + 80))];
	}
	
	// Quotes
	{
		UIView *quotesView = [[UIView alloc] initWithFrame:CGRectMake(0, 120, 280, 160)];
		quotesView.backgroundColor = [UIColor clearColor];
		[theSelfView addSubview:quotesView];
		
		UIImageView *quotesImage = [[UIImageView alloc] initWithFrame:CGRectMake(84, 0, 112, 100)];
		quotesImage.image = [UIImage imageNamed:@"fileIcon"];
		[quotesView addSubview:quotesImage];
		
		UILabel *quotesLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 100, 280, 60)];
		quotesLabel.backgroundColor = [UIColor clearColor];
		quotesLabel.font = HelveticaNeueMedium(20);
		quotesLabel.textAlignment = NSTextAlignmentCenter;
		quotesLabel.textColor = [UIColor colorWithRed:(float)122/255 green:(float)180/255 blue:(float)233/255 alpha:1.0];
		quotesLabel.text = @"Quotes";
		[quotesView addSubview:quotesLabel];
		
		UIButton *quotesBTN = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 280, 160)];
		[quotesBTN addTarget:self action:@selector(openQuotes:) forControlEvents:UIControlEventTouchUpInside];
		[quotesView addSubview:quotesBTN];
		
		[quotesView setCenter:CGPointMake(dvc_width / 2 + 140,dvc_height / 2 - (120 + 80))];
	}
	
	// Estimates
	{
		UIView *estimatesView = [[UIView alloc] initWithFrame:CGRectMake(0, 120, 280, 160)];
		estimatesView.backgroundColor = [UIColor clearColor];
		[theSelfView addSubview:estimatesView];
		
		UIImageView *estimatesImage = [[UIImageView alloc] initWithFrame:CGRectMake(84, 0, 112, 100)];
		estimatesImage.image = [UIImage imageNamed:@"fileIcon.png"];
		[estimatesView addSubview:estimatesImage];
		
		UILabel *estimatesLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 100, 280, 60)];
		estimatesLabel.backgroundColor = [UIColor clearColor];
		estimatesLabel.font = HelveticaNeueMedium(20);
		estimatesLabel.textAlignment = NSTextAlignmentCenter;
		estimatesLabel.textColor = [UIColor colorWithRed:(float)122/255 green:(float)180/255 blue:(float)233/255 alpha:1.0];
		estimatesLabel.text = @"Estimates";
		[estimatesView addSubview:estimatesLabel];
		
		UIButton *estimatesBTN = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 280, 160)];
		[estimatesBTN addTarget:self action:@selector(openEstimates:) forControlEvents:UIControlEventTouchUpInside];
		[estimatesView addSubview:estimatesBTN];
		
		[estimatesView setCenter:CGPointMake(dvc_width / 2 - 140,dvc_height / 2)];
		
	}
	
	// Purchase Orders
	{
		UIView *purchaseView = [[UIView alloc] initWithFrame:CGRectMake(0, 120, 280, 160)];
		purchaseView.backgroundColor = [UIColor clearColor];
		[theSelfView addSubview:purchaseView];
		
		UIImageView *purchaseImage = [[UIImageView alloc] initWithFrame:CGRectMake(84, 0, 112, 100)];
		purchaseImage.image = [UIImage imageNamed:@"fileIcon.png"];
		[purchaseView addSubview:purchaseImage];
		
		UILabel *purchaseLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 100, 280, 60)];
		purchaseLabel.backgroundColor = [UIColor clearColor];
		purchaseLabel.font = HelveticaNeueMedium(20);
		purchaseLabel.textAlignment = NSTextAlignmentCenter;
		purchaseLabel.textColor = [UIColor colorWithRed:(float)122/255 green:(float)180/255 blue:(float)233/255 alpha:1.0];
		purchaseLabel.text = @"Purchase Orders";
		[purchaseView addSubview:purchaseLabel];
		
		UIButton *purchaseBTN = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 280, 160)];
		[purchaseBTN addTarget:self action:@selector(openPurchaseOrders:) forControlEvents:UIControlEventTouchUpInside];
		[purchaseView addSubview:purchaseBTN];
		
		[purchaseView setCenter:CGPointMake(dvc_width / 2 + 140,dvc_height / 2)];
	}
	
	// Receipts
	{
		UIView *receiptsView = [[UIView alloc] initWithFrame:CGRectMake(0, 120, 280, 160)];
		receiptsView.backgroundColor = [UIColor clearColor];
		[theSelfView addSubview:receiptsView];
		
		UIImageView *receiptImage = [[UIImageView alloc] initWithFrame:CGRectMake(84, 0, 112, 100)];
		receiptImage.image = [UIImage imageNamed:@"fileIcon.png"];
		[receiptsView addSubview:receiptImage];
		
		UILabel *receiptLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 100, 280, 60)];
		receiptLabel.backgroundColor = [UIColor clearColor];
		receiptLabel.font = HelveticaNeueMedium(20);
		receiptLabel.textAlignment = NSTextAlignmentCenter;
		receiptLabel.textColor = [UIColor colorWithRed:(float)122/255 green:(float)180/255 blue:(float)233/255 alpha:1.0];
		receiptLabel.text = @"Receipts";
		[receiptsView addSubview:receiptLabel];
		
		UIButton *receiptBTN = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 280, 160)];
		[receiptBTN addTarget:self action:@selector(openReceipts:) forControlEvents:UIControlEventTouchUpInside];
		[receiptsView addSubview:receiptBTN];
		
		[receiptsView setCenter:CGPointMake(dvc_width / 2 - 140,dvc_height / 2 + 120 + 80)];
	}
	
	// Timesheets
	{
		UIView *timeView = [[UIView alloc] initWithFrame:CGRectMake(0, 120, 280, 160)];
		timeView.backgroundColor = [UIColor clearColor];
		[theSelfView addSubview:timeView];
		
		UIImageView *timeImage = [[UIImageView alloc] initWithFrame:CGRectMake(84, 0, 112, 100)];
		timeImage.image = [UIImage imageNamed:@"fileIcon.png"];
		[timeView addSubview:timeImage];
		
		UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 100, 280, 60)];
		timeLabel.backgroundColor = [UIColor clearColor];
		timeLabel.font = HelveticaNeueMedium(20);
		timeLabel.textAlignment = NSTextAlignmentCenter;
		timeLabel.textColor = [UIColor colorWithRed:(float)122/255 green:(float)180/255 blue:(float)233/255 alpha:1.0];
		timeLabel.text = @"Timesheets";
		[timeView addSubview:timeLabel];
		
		UIButton *timeBTN = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 280, 160)];
		[timeBTN addTarget:self action:@selector(openTimesheets:) forControlEvents:UIControlEventTouchUpInside];
		[timeView addSubview:timeBTN];
		
		[timeView setCenter:CGPointMake(dvc_width / 2 + 140,dvc_height / 2 + 120 + 80)];
	}

}

#pragma mark - FUNCTIONS

-(void)openInvoices:(UIButton*)sender
{
	InvoicesVC * vc = [[InvoicesVC alloc] init];
	[self.navigationController pushViewController:vc animated:YES];
}

-(void)openQuotes:(UIButton *)sender
{
	EstimatesVC_Q * vc = [[EstimatesVC_Q alloc] init];
	[self.navigationController pushViewController:vc animated:YES];
}

-(void)openEstimates:(UIButton*)sender
{
	EstimatesVC * vc = [[EstimatesVC alloc] init];
	[self.navigationController pushViewController:vc animated:YES];
}

-(void)openPurchaseOrders:(UIButton*)sender
{
	PurchaseOrdersVC * vc = [[PurchaseOrdersVC alloc] init];
	[self.navigationController pushViewController:vc animated:YES];
}

-(void)openReceipts:(UIButton*)button
{
	ReceiptsVC *vc = [[ReceiptsVC alloc] init];
	[self.navigationController pushViewController:vc animated:YES];
}

-(void)openTimesheets:(UIButton*)button
{	
	TimesheetVC *vc = [[TimesheetVC alloc] init];
	[self.navigationController pushViewController:vc animated:YES];
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

#pragma mark - VIEW CONTROLLER FUNCTIONS

-(void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
}

@end