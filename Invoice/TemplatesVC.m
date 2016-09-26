//
//  TemplatesVC.m
//  Invoice
//
//  Created by XGRoup5 on 9/5/13.
//  Copyright (c) 2013 XGRoup. All rights reserved.
//

#import "TemplatesVC.h"

#import "Defines.h"

@interface TemplatesVC () <UIScrollViewDelegate>

@end

@implementation TemplatesVC

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
	
	theSelfView = [[UIView alloc] initWithFrame:CGRectMake(0, statusBarHeight, dvc_width, dvc_height)];
	[theSelfView setBackgroundColor:[UIColor clearColor]];
	[self.view addSubview:theSelfView];
		
	ScrollWithShadow * scrollView = [[ScrollWithShadow alloc] initWithFrame:CGRectMake(0, 42, dvc_width + 20, dvc_height - 87)];
	[scrollView setDelegate:self];
	[scrollView setPagingEnabled:YES];
	[scrollView setBackgroundColor:[UIColor darkGrayColor]];
	[theSelfView addSubview:scrollView];
	
	if (sys_version >= 7)
		[scrollView setContentInset:UIEdgeInsetsMake(-20, 0, 0, 0)];
	
	CGFloat width = paper_size.width;
	CGFloat height = paper_size.height;
	changePaperSize(((scrollView.frame.size.width - 20) * 2), ((scrollView.frame.size.width - 20) * 2) * height / width);
	
	kTemplate selectedTemplate = [data_manager selectedTemplate];
	
	for (int i = 0; i < 5; i++)
	{
		[data_manager setTemplate:i];
		
		NSData * pdfData = [PDFCreator PDFDataFromUIView:[PDFCreator PDFViewFromInvoice:[[InvoiceOBJ alloc] initForTemplate]]];
		
		UIWebView * webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, scrollView.frame.size.width - 20, scrollView.frame.size.height)];
		[webView loadData:pdfData MIMEType:@"application/pdf" textEncodingName:@"" baseURL:nil];
		[webView setTag:666];
		[scrollView addSubview:webView];
		
		[webView setCenter:CGPointMake(((scrollView.frame.size.width - 20) / 2) + (i * scrollView.frame.size.width), scrollView.frame.size.height / 2)];
	}
	
	[scrollView setContentSize:CGSizeMake((dvc_width + 20) * 5, dvc_height - 87)];
	[scrollView setContentOffset:CGPointMake(selectedTemplate * scrollView.frame.size.width, 0) animated:NO];
	
	if (sys_version >= 7)
		[scrollView setContentOffset:CGPointMake(selectedTemplate * scrollView.frame.size.width, 20) animated:YES];
	
	[data_manager setTemplate:selectedTemplate];
	
	topBarView = [[TopBar alloc] initWithFrame:CGRectMake(0, 0, dvc_width, 42 + statusBarHeight) andTitle:@"Templates"];
	[topBarView setBackgroundColor:app_bar_update_color];
	[self.view addSubview:topBarView];
	
	BackButton * backButton = [[BackButton alloc] initWithFrame:CGRectMake(0, 42 + statusBarHeight - 40, 70, 40) andTitle:@"Back"];
	[backButton addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
	[topBarView addSubview:backButton];
	
	UIButton * done = [[UIButton alloc] initWithFrame:CGRectMake(dvc_width - 60, 42 + statusBarHeight - 40, 60, 40)];
	[done setTitle:@"Done" forState:UIControlStateNormal];
	[done setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[done setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
	[done.titleLabel setFont:HelveticaNeueLight(17)];
	[done addTarget:self action:@selector(done:) forControlEvents:UIControlEventTouchUpInside];
	[topBarView addSubview:done];
}

#pragma mark - FUNCTIONS

-(void)back:(UIButton*)sender
{
	[self.navigationController popViewControllerAnimated:YES];
}

-(void)done:(UIButton*)sender
{
	[data_manager setTemplate:current_template];
	
	[self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - SCROLLVIEW DELEGATE

-(void)scrollViewDidEndDecelerating:(UIScrollView*)scrollView
{
	current_template = (int)(floor(scrollView.contentOffset.x / scrollView.frame.size.width));
}

-(void)scrollViewDidEndDragging:(UIScrollView*)scrollView willDecelerate:(BOOL)decelerate
{
	if (!decelerate)
	{
		current_template = (int)(floor(scrollView.contentOffset.x / scrollView.frame.size.width));
	}
}

#pragma mark - VIEW CONTROLLER FUNCTIONS

-(void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
}

@end