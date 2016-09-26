//
//  PhotoLogoCell.m
//  Invoice
//
//  Created by Dmytro Nosulich on 5/8/15.
//  Copyright (c) 2015 XGRoup. All rights reserved.
//

#import "PhotoLogoCell.h"

#import "Defines.h"

#define LOGO_SIZE 40.f
#define LOGO_X_OFFSET 5.f

@implementation PhotoLogoCell

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString*)reuseIdentifier {
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  
  if (self) {
    [self.layer setMasksToBounds:YES];
    
    [self setBackgroundColor:[UIColor clearColor]];
    
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, dvc_width, dvc_height)];
    [bgView setBackgroundColor:[UIColor clearColor]];
    [self setBackgroundView:bgView];
    
    [self.contentView.layer setMasksToBounds:YES];
    
    bg = [[UIImageView alloc] initWithFrame:CGRectMake(10, 0, dvc_width - 20, 42)];
    [bg setTag:1];
    bg.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    [self.contentView addSubview:bg];
    
    bgSelected = [[UIImageView alloc] initWithFrame:CGRectMake(10, 0, dvc_width - 20, 42)];
    [bgSelected setTag:2];
    [bgSelected setAlpha:0.0];
    [self.contentView addSubview:bgSelected];
    
    arrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cellArrow.png"]];
    arrow.frame = CGRectMake(arrow.frame.origin.x, arrow.frame.origin.y, 20,20);
    [arrow setCenter:CGPointMake(self.contentView.frame.size.width - 30, 21)];
    arrow.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
    [self.contentView addSubview:arrow];
    
    logo = [[UIImageView alloc] init];
    logo.frame = CGRectMake(logo.frame.origin.x, logo.frame.origin.y, LOGO_SIZE,LOGO_SIZE);
    [logo setCenter:CGPointMake(arrow.frame.origin.x - LOGO_SIZE / 2.f - LOGO_X_OFFSET, 21)];
    logo.contentMode = UIViewContentModeScaleAspectFit;
    logo.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
    [self.contentView addSubview:logo];
    
    titleTextField = [[UITextField alloc] initWithFrame:CGRectMake(20, 0, (dvc_width - 40) * 0.6, 42)];
    [titleTextField setTextAlignment:NSTextAlignmentLeft];
    [titleTextField setTextColor:[UIColor grayColor]];
    [titleTextField setFont:HelveticaNeue(16)];
    [titleTextField setBackgroundColor:[UIColor clearColor]];
    [titleTextField setTag:10];
    [titleTextField setEnabled:NO];
    [self.contentView addSubview:titleTextField];
    
    titleLabelSelected = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, (dvc_width - 40) * 0.6, 42)];
    [titleLabelSelected setTextAlignment:NSTextAlignmentLeft];
    [titleLabelSelected setTextColor:app_tab_selected_color];
    [titleLabelSelected setFont:HelveticaNeue(16)];
    [titleLabelSelected setBackgroundColor:[UIColor clearColor]];
    [titleLabelSelected setTag:20];
    [titleLabelSelected setAlpha:0.0];
    [self.contentView addSubview:titleLabelSelected];
  }
  
  return self;
}

-(void)prepareForReuse {
  [super prepareForReuse];
  
  [bg setImage:nil];
  [titleTextField setText:@""];
  [titleLabelSelected setText:@""];
  [logo setImage:nil];
  accessoryButton = nil;
}

-(void)setSelected:(BOOL)selected animated:(BOOL)animated {
  [super setSelected:selected animated:animated];
}

- (void)setCellType:(kCellType)type {
  switch (type) {
    case kCellTypeTop: {
      [bg setImage:[[UIImage imageNamed:@"tableTopCellWhite.png"] stretchableImageWithLeftCapWidth:20 topCapHeight:15]];
      [bgSelected setImage:[[UIImage imageNamed:@"selectedTopCell.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10]];
      
      break;
    }
      
    case kCellTypeMiddle: {
      [bg setImage:[[UIImage imageNamed:@"tableMiddleCellWhite.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10]];
      [bgSelected setImage:[[UIImage imageNamed:@"selectedMiddleCell.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10]];
      
      break;
    }
      
    case kCellTypeBottom: {
      [bg setImage:[[UIImage imageNamed:@"tableBottomCellWhite.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10]];
      [bgSelected setImage:[[UIImage imageNamed:@"selectedBottomCell.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10]];
      
      break;
    }
      
    case kCellTypeSingle: {
      [bg setImage:[[UIImage imageNamed:@"tableSingleCellWhite.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10]];
      [bgSelected setImage:[[UIImage imageNamed:@"selectedSingleCell.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10]];
      
      break;
    }
      
    default:
      break;
  }
}

-(void)loadTitle:(NSString*)title andValue:(UIImage*)value cellType:(kCellType)type andSize:(int)size {
  [self setCellType:type];
  
  isArrowType = size == 0;
  
  int difference = 0;
  
  if(size == 0.0) {
    UIImage *cellImage = [UIImage imageNamed:@"cellArrow.png"];
    
    arrow.image = cellImage;
    arrow.frame = CGRectMake(arrow.frame.origin.x, arrow.frame.origin.y, cellImage.size.width, (self.contentView.frame.size.height - cellImage.size.height) / 2.f);
    
    [arrow setCenter:CGPointMake(arrow.center.x, 21)];
    
    difference = 20;
  } else {
    UIImage *cellImage = [UIImage imageNamed:@"plus.png"];
    
    arrow.image = cellImage;
    arrow.frame = CGRectMake(arrow.frame.origin.x, arrow.frame.origin.y, 20,20);
    difference = 20;
  }
  
  [titleTextField setText:title];
  [titleTextField setPlaceholder:title];
  [titleLabelSelected setText:title];
  
  NSInteger offset = isEditingMode?40:0;
  [logo setFrame:CGRectMake(arrow.frame.origin.x - LOGO_SIZE - LOGO_X_OFFSET - offset,
                                      1,
                                      LOGO_SIZE,
                                      LOGO_SIZE)];
  if(!isEditingMode) {
    bg.frame = CGRectMake(10, 0, self.contentView.frame.size.width - 20, 42);
  }
  
  [self setTitleBiggerFrame];
  [logo setImage:value];
}

- (void)addAccessoryTarget:(id)target action:(SEL)action {
  CGRect buttonFrame = CGRectInset(arrow.frame, -(isArrowType?15:20), -20);
  buttonFrame.origin.x += 5;
  accessoryButton = [[UIButton alloc] initWithFrame:buttonFrame];
  [accessoryButton setBackgroundColor:[UIColor clearColor]];
  [accessoryButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
  [self addSubview:accessoryButton];
}

-(void)animateSelection {
  [UIView animateWithDuration:0.15 animations:^{
    [bg setAlpha:0.0];
    [bgSelected setAlpha:1.0];
    [titleTextField setAlpha:0.0];
    [titleLabelSelected setAlpha:1.0];
  } completion:^(BOOL finished) {
    [UIView animateWithDuration:0.15 animations:^{
      [bg setAlpha:1.0];
      [bgSelected setAlpha:0.0];
      [titleTextField setAlpha:1.0];
      [titleLabelSelected setAlpha:0.0];
      
    }];
  }];
}

-(void)colorOn {
  [bg setAlpha:0.0];
  [bgSelected setAlpha:1.0];
  [titleTextField setAlpha:0.0];
  [titleLabelSelected setAlpha:1.0];
}

-(void)colorOff {
  [bg setAlpha:1.0];
  [bgSelected setAlpha:0.0];
  [titleTextField setAlpha:1.0];
  [titleLabelSelected setAlpha:0.0];
}

-(void)resize {
  [bg setFrame:CGRectMake(10, self.frame.size.height - 42, dvc_width - 20, 42)];
  [bgSelected setFrame:CGRectMake(10, self.frame.size.height - 42, dvc_width - 20, 42)];
  [titleTextField setFrame:CGRectMake(20, self.frame.size.height - 42, (dvc_width - 40) * 0.6, 42)];
  [titleLabelSelected setFrame:CGRectMake(20, self.frame.size.height - 42, (dvc_width - 40) * 0.6, 42)];
  [logo setFrame:CGRectMake(arrow.frame.origin.x - LOGO_SIZE - LOGO_X_OFFSET,
                                      1,
                                      LOGO_SIZE,
                                      LOGO_SIZE)];
}

- (void)setAutolayoutForValueField {
  NSInteger offset = isEditingMode?40:0;
  logo.frame = CGRectMake(arrow.frame.origin.x - LOGO_SIZE - LOGO_X_OFFSET - offset,
                                    1,
                                    LOGO_SIZE,
                                    LOGO_SIZE);
  [self setTitleBiggerFrame];
}

- (void)setIsTitleEditable:(BOOL)isTitleEditable {
  super.isTitleEditable = isTitleEditable;
  titleTextField.enabled = isTitleEditable;
}

- (void)setIsTitleEditable:(BOOL)isTitleEditable delegate:(id<UITextFieldDelegate>)delegate tag:(NSInteger)tag {
  super.isTitleEditable = isTitleEditable;
  
  titleTextField.enabled = isTitleEditable;
  if(isTitleEditable) {
    titleTextField.delegate = delegate;
    titleTextField.tag = tag;
    [self setTitleEditableLayout];
  }
}

- (void)setTitleEditableLayout {
  if(!isEditingMode) {
    [titleTextField setFrame:CGRectMake(20, self.frame.size.height - 42 - 2, dvc_width / 2.f - 30, 42)];
    [logo setFrame:CGRectMake(arrow.frame.origin.x - LOGO_SIZE - LOGO_X_OFFSET,
                                        1,
                                        LOGO_SIZE,
                                        LOGO_SIZE)];
  }
}

- (void)makeTitleBigger:(BOOL)isbigger {
  isTitleBigger = isbigger;
  if(isbigger) {
    [self setTitleBiggerFrame];
  } else {
    [self setTitleEditableLayout];
  }
}

- (void)setTitleBiggerFrame {
  if(isTitleBigger) {
    [titleTextField setFrame:CGRectMake(20, self.frame.size.height - 42 - 2, (dvc_width / 3.f) * 2.f - EDGE_OFFSET * 1.5, 42)];
  }
}

@end
