//
//  DropboxBackupVC.m
//  Invoice
//
//  Created by Dmytro Nosulich on 6/17/15.
//  Copyright (c) 2015 XGRoup. All rights reserved.
//

#import "DropboxBackupVC.h"
#import "Defines.h"
#import "DropboxManager.h"

@interface DropboxBackupVC () {
  UISwitch *backupSwitch;
  BOOL wasUnlinked;
}

@end

@implementation DropboxBackupVC

- (void)viewDidLoad {
  [super viewDidLoad];
  
  wasUnlinked = [DropboxManager isLinked];
  
  theSelfView = [[UIView alloc] initWithFrame:CGRectMake(0, statusBarHeight, dvc_width, dvc_height)];
  [theSelfView setBackgroundColor:[UIColor clearColor]];
  [self.view addSubview:theSelfView];
  [self.view setBackgroundColor:app_background_color];
  
  [self.view setBackgroundColor:app_background_color];
  
  topBarView = [[TopBar alloc] initWithFrame:CGRectMake(0, 0, dvc_width, 42 + statusBarHeight) andTitle:@"Dropbox backup"];
  [topBarView setBackgroundColor:app_bar_update_color];
  
  UIButton * cancel = [[UIButton alloc] initWithFrame:CGRectMake(0, 42 + statusBarHeight - 40, 80, 40)];
  [cancel setTitle:@"Cancel" forState:UIControlStateNormal];
  [cancel setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
  [cancel setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
  [cancel.titleLabel setFont:HelveticaNeueLight(17)];
  [cancel addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
  [topBarView addSubview:cancel];
  
  [self.view addSubview:topBarView];
  
  //title
  UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.f, 62.f, dvc_width - 20.f, 50)];
  titleLabel.text = @"Back up all the files in PDF into your Dropbox account";
  titleLabel.font = [UIFont systemFontOfSize:20.f];
  titleLabel.textColor = [UIColor grayColor];
  titleLabel.numberOfLines = 0;
  titleLabel.backgroundColor = [UIColor clearColor];
  [theSelfView addSubview:titleLabel];
  
  //Dropbox backup
  {
    UIView *switchView = [[UIView alloc] initWithFrame:CGRectMake(10,
                                                                  CGRectGetMaxY(titleLabel.frame) + 20,
                                                                  dvc_width - 20,
                                                                  40)];
    [switchView setBackgroundColor:[UIColor clearColor]];
    [theSelfView addSubview:switchView];
    
    UIImageView * bgForText = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, dvc_width - 20, 40)];
    [bgForText setImage:[[UIImage imageNamed:@"tableSingleCellWhite.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10]];
    [switchView addSubview:bgForText];
    
    UILabel * titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, dvc_width - 20, 20)];
    [titleLabel setText:@"Dropbox backup"];
    titleLabel.font = HelveticaNeue(20);
    titleLabel.textColor = [UIColor grayColor];
    [titleLabel setTextAlignment:NSTextAlignmentLeft];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [switchView addSubview:titleLabel];
    
    backupSwitch = [[UISwitch alloc] init];
    backupSwitch.frame = CGRectMake(switchView.frame.size.width - backupSwitch.frame.size.width - 10,
                                    (40 - backupSwitch.frame.size.height) / 2,
                                    10, 10);
    backupSwitch.on = isDropboxBackupOn;
    [backupSwitch addTarget:self action:@selector(backupSwitchChanged:) forControlEvents:UIControlEventValueChanged];
    [switchView addSubview:backupSwitch];
  }
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveDropboxBackupPayment:) name:DROPBOX_BACKUP_DID_PURCHASE_NOTIFICATION object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didLoginIntoDropbox:) name:DROPBOX_DID_LOGIN_NOTIFICATION object:nil];
  
  if([DropboxManager isLinked] && !wasUnlinked) {
    [[NSNotificationCenter defaultCenter] postNotificationName:DROPBOX_DID_LOGIN_NOTIFICATION object:nil];
  }
}

- (void)viewDidDisappear:(BOOL)animated {
  [super viewDidDisappear:animated];
  
  wasUnlinked = [DropboxManager isLinked];
  
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Private methods

-(void)cancel:(UIButton*)sender {
  [UIView animateWithDuration:0.3 animations:^{
    [self.navigationController.view setFrame:CGRectMake(-dvc_width, 0, self.view.frame.size.width, self.navigationController.view.frame.size.height)];
  } completion:^(BOOL finished) {
    [self.navigationController.view removeFromSuperview];
  }];
}

- (void)backupSwitchChanged:(UISwitch *)sender {
  if(isFullDROPBOX_BU) {
    [self setEnableDropboxBackup:sender.on];
  } else {
    if(sender.on) {
      sender.on = NO;
      [DELEGATE checkDropboxBackupEnable];
//      [[NSNotificationCenter defaultCenter] postNotificationName:DROPBOX_BACKUP_DID_PURCHASE_NOTIFICATION object:nil];
    }
  }
}

- (void)setEnableDropboxBackup:(BOOL)enable {
  [CustomDefaults setCustomBool:enable forKey:DO_DROPBOX_BACKUP_KEY];
}

#pragma mark - Notifications

- (void)didReceiveDropboxBackupPayment:(NSNotification *)notification {
  if(![DropboxManager isLinked]) {
    [DropboxManager linkFromController:self];
  } else {
    [self setEnableDropboxBackup:YES];
    backupSwitch.on = YES;
  }
}

- (void)didLoginIntoDropbox:(NSNotification *)notification {
  [self setEnableDropboxBackup:YES];
  backupSwitch.on = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
