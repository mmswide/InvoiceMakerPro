//
//  MenuV.m
//  Invoice
//
//  Created by XGRoup on 7/10/14.
//  Copyright (c) 2014 XGRoup. All rights reserved.
//

#import "MenuV.h"

#import "Defines.h"
#import "ExportVC.h"
#import "DropboxBackupVC.h"
#import "MKStoreManager.h"

@implementation MenuV

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self)
	{
    UIView *theSelfView = [[UIView alloc] initWithFrame:CGRectMake(0, statusBarHeight + 42, frame.size.width, dvc_height)];
    theSelfView.backgroundColor = [UIColor clearColor];
    [self addSubview:theSelfView];
    
    UILabel *options = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 180, 40)];
    options.backgroundColor = [UIColor clearColor];
    options.font = HelveticaNeueMedium(20);
    options.text = @"Options";
    options.textColor = [UIColor whiteColor];
    [theSelfView addSubview:options];
    
    UIView *whiteLine = [[UIView alloc] initWithFrame:CGRectMake(20, 40, 180, 1)];
    whiteLine.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.7];
    [theSelfView addSubview:whiteLine];
    
    NSString *dotString = @"●";
    
    //DropBox backup
    {
      UIButton * dropBoxBTN = [[UIButton alloc] initWithFrame:CGRectMake(20, 40, 180, 50)];
      [dropBoxBTN setTitle:[NSString stringWithFormat:@"%@ Dropbox backup",[dotString lowercaseString]] forState:UIControlStateNormal];
      [dropBoxBTN setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
      [dropBoxBTN setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
      [dropBoxBTN.titleLabel setFont:HelveticaNeueLight(18)];
      [dropBoxBTN addTarget:self action:@selector(openDropBox:) forControlEvents:UIControlEventTouchUpInside];
      [theSelfView addSubview:dropBoxBTN];
    }
    
    //export CSV
    {
      UIButton * quotesBTN = [[UIButton alloc] initWithFrame:CGRectMake(20, 90, 140, 50)];
      [quotesBTN setTitle:[NSString stringWithFormat:@"%@ Export CSV",[dotString lowercaseString]] forState:UIControlStateNormal];
      [quotesBTN setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
      [quotesBTN setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
      [quotesBTN.titleLabel setFont:HelveticaNeueLight(18)];
      [quotesBTN addTarget:self action:@selector(openExport:) forControlEvents:UIControlEventTouchUpInside];
      [theSelfView addSubview:quotesBTN];
    }
		
		/*if(app_version == 4 || app_version == 5 || YES)
		{
			UILabel *inapp = [[UILabel alloc] initWithFrame:CGRectMake(20, 100, 180, 40)];
			inapp.backgroundColor = [UIColor clearColor];
			inapp.font = HelveticaNeueMedium(20);
			inapp.text = @"In-app Purchases";
			inapp.textColor = [UIColor whiteColor];
			[theSelfView addSubview:inapp];
			
			whiteLine = [[UIView alloc] initWithFrame:CGRectMake(20, 140, 180, 1)];
			whiteLine.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.7];
			[theSelfView addSubview:whiteLine];
			
			UIButton *purchaseButton = [[UIButton alloc] initWithFrame:CGRectMake(20, 140, 140, 50)];
			[purchaseButton setTitle:[NSString stringWithFormat:@"%@ Export CSV",[dotString lowercaseString]] forState:UIControlStateNormal];
			[purchaseButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
			[purchaseButton.titleLabel setFont:HelveticaNeueLight(18)];
			[purchaseButton addTarget:self action:@selector(openPurchase:) forControlEvents:UIControlEventTouchUpInside];
			[theSelfView addSubview:purchaseButton];
			
			UILabel *purchaseLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 180, 140, 40)];
			purchaseLabel.textAlignment = NSTextAlignmentRight;
			[purchaseLabel setTextColor:[UIColor whiteColor]];
			[purchaseLabel setFont:HelveticaNeueLight(18)];
			[theSelfView addSubview:purchaseLabel];
		} */
	}
	
	return self;
}

#pragma mark
#pragma mark Actions
-(void)openExport:(UIButton*)button {
	_exportView = [[ExportVC alloc] init];
	
	_controller = [[UINavigationController alloc] initWithRootViewController:_exportView];
	[_controller setNavigationBarHidden:YES];
	
	[DELEGATE.window addSubview:_controller.view];

	_controller.view.backgroundColor = [UIColor whiteColor];
	[_controller.view setFrame:CGRectMake(-dvc_width, 0, _controller.view.frame.size.width, _controller.view.frame.size.height)];
	
	[UIView animateWithDuration:0.3 animations:^{
		[_controller.view setFrame:CGRectMake(0, 0, _controller.view.frame.size.width, _controller.view.frame.size.height)];
	}];
}

- (void)openDropBox:(UIButton *)sender {
  DropboxBackupVC *vc = [[DropboxBackupVC alloc] init];
  
  _controller = [[UINavigationController alloc] initWithRootViewController:vc];
  [_controller setNavigationBarHidden:YES];
  
  [DELEGATE.window addSubview:_controller.view];
  
  _controller.view.backgroundColor = [UIColor whiteColor];
  [_controller.view setFrame:CGRectMake(-dvc_width, 0, _controller.view.frame.size.width, _controller.view.frame.size.height)];
  
  [UIView animateWithDuration:0.3 animations:^{
    [_controller.view setFrame:CGRectMake(0, 0, _controller.view.frame.size.width, _controller.view.frame.size.height)];
  }];
}

-(void)openPurchase:(UIButton*)button
{
	
}

@end
