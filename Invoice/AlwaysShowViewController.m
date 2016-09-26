//
//  AlwaysShowViewController.m
//  Invoice
//
//  Created by Dmytro Nosulich on 6/12/15.
//  Copyright (c) 2015 XGRoup. All rights reserved.
//

#import "AlwaysShowViewController.h"
#import "Defines.h"

@interface AlwaysShowViewController ()

@end

@implementation AlwaysShowViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  
  alwaysShowType = -1;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)addAlwaysShowSwitchAfterY:(CGFloat)y {
  if (theTimesheet == nil) {
    oAlwaysView = [[UIView alloc] initWithFrame:CGRectMake(10, y + 10, dvc_width - 20, 40)];
    [oAlwaysView setBackgroundColor:[UIColor clearColor]];
    [theSelfView addSubview:oAlwaysView];
    
    UIImageView * bgForText = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, dvc_width - 20, 40)];
    [bgForText setImage:[[UIImage imageNamed:@"tableSingleCellWhite.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10]];
    [oAlwaysView addSubview:bgForText];
    
    UILabel * titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, dvc_width - 20, 20)];
    [titleLabel setText:@"Always show"];
    [titleLabel setTextAlignment:NSTextAlignmentLeft];
    [titleLabel setTextColor:app_title_color];
    [titleLabel setFont:HelveticaNeueMedium(14)];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [oAlwaysView addSubview:titleLabel];
    
    UISwitch *alwaysShowSwitch = [[UISwitch alloc] init];
    alwaysShowSwitch.frame = CGRectMake(oAlwaysView.frame.size.width - alwaysShowSwitch.frame.size.width - 10, (40 - alwaysShowSwitch.frame.size.height) / 2, 10, 10);
    [alwaysShowSwitch addTarget:self action:@selector(alwaysShowChanged:) forControlEvents:UIControlEventValueChanged];
    
    alwaysShowSwitch.on = [self switchValue];
    
    [oAlwaysView addSubview:alwaysShowSwitch];
    
    return YES;
  }
  return NO;
}

- (void)alwaysShowChanged:(UISwitch *)alwaysShow {
  [self setChangedValue:alwaysShow.on];
}

- (BOOL)switchValue {
  switch (alwaysShowType) {
    case AlwaysShowTypeSignatyreLeft:
      return [[self baseObject] alwaysShowSignatureLeft];
      break;
      
    case AlwaysShowTypeSignatyreRight:
      return [[self baseObject] alwaysShowSignatureRight];
      break;
      
    case AlwaysShowTypeNote:
      return [[self baseObject] alwaysShowNote];
      break;
      
    case AlwaysShowTypeOtherComment:
      return [[self baseObject] alwaysShowOtherComments];
      break;
      
    default:
      break;
  }
  
  return NO;
}

- (void)setChangedValue:(BOOL)value {
  switch (alwaysShowType) {
    case AlwaysShowTypeSignatyreLeft:
      [[self baseObject] setAlwaysShowSignatureLeft:value];
      break;
      
    case AlwaysShowTypeSignatyreRight:
      [[self baseObject] setAlwaysShowSignatureRight:value];
      break;
      
    case AlwaysShowTypeNote:
      [[self baseObject] setAlwaysShowNote:value];
      break;
      
    case AlwaysShowTypeOtherComment:
      [[self baseObject] setAlwaysShowOtherComments:value];
      break;
      
    default:
      break;
  }
}

- (BaseOBJ *)baseObject {
  if (theInvoice)
    return theInvoice;
  else if (theQuote)
    return theQuote;
  else if (theEstimate)
    return theEstimate;
  else if (thePurchaseOrder)
    return thePurchaseOrder;
  else
    return nil;
}

@end
