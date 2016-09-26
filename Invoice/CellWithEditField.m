//
//  CellWithEditField.m
//  Invoice
//
//  Created by Dmytro Nosulich on 3/13/15.
//  Copyright (c) 2015 XGRoup. All rights reserved.
//

#import "CellWithEditField.h"
#import <QuartzCore/QuartzCore.h>
#import "Defines.h"

#define ACCESSORY_SIZE 30.f

@implementation CellWithEditField

@synthesize titleTextField;


-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier width:(CGFloat)width {
  cellWidth = width;
  
  return [self initWithStyle:style reuseIdentifier:reuseIdentifier];
}

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString*)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self)
    {
      if(cellWidth == 0) {
        cellWidth = dvc_width;
      }
      
      [self.layer setMasksToBounds:YES];
      
      [self setBackgroundColor:[UIColor clearColor]];
      
      [self setSelectionStyle:UITableViewCellSelectionStyleNone];
      
      bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.contentView.frame.size.width, self.contentView.frame.size.height)];
      bgView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
      [bgView setBackgroundColor:[UIColor clearColor]];
      [self.contentView addSubview:bgView];
      
      [self.contentView.layer setMasksToBounds:YES];
      
      bg = [[UIImageView alloc] initWithFrame:CGRectMake(10, 0, cellWidth - EDGE_OFFSET, 42)];
      [bg setTag:1];
      bg.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
      [bgView addSubview:bg];
      
      bgSelected = [[UIImageView alloc] initWithFrame:CGRectMake(10, 0, cellWidth - EDGE_OFFSET, 42)];
      [bgSelected setTag:2];
      [bgSelected setAlpha:0.0];
      [bgView addSubview:bgSelected];
      
      titleTextField = [[UITextField alloc] initWithFrame:CGRectMake(EDGE_OFFSET, self.frame.size.height - 42 - 2, cellWidth - EDGE_OFFSET * 2, 42)];
      [titleTextField setTextColor:[UIColor grayColor]];
      [titleTextField setFont:HelveticaNeue(16)];
      [titleTextField setBackgroundColor:[UIColor clearColor]];
      [titleTextField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
      [titleTextField setReturnKeyType:UIReturnKeyDone];
      [titleTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
      if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
          titleTextField.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
      }
      [bgView addSubview:titleTextField];
      
      valueTextField = [[UITextField alloc] initWithFrame:CGRectMake(self.contentView.frame.size.width / 2.f + EDGE_OFFSET / 2.f, self.frame.size.height - 42 - 2, cellWidth / 2.f - EDGE_OFFSET * 1.5, 42)];
      [valueTextField setTextColor:[UIColor darkGrayColor]];
      [valueTextField setTextAlignment:NSTextAlignmentRight];
      [valueTextField setFont:HelveticaNeue(16)];
      [valueTextField setBackgroundColor:[UIColor clearColor]];
      [valueTextField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
      [valueTextField setReturnKeyType:UIReturnKeyDone];
      [valueTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
      valueTextField.hidden = YES;
      valueTextField.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
      [bgView addSubview:valueTextField];
  }
  
  return self;
}

-(void)prepareForReuse
{
    [super prepareForReuse];
    
    [bg setImage:nil];
    [titleTextField setText:@""];
    [titleTextField setPlaceholder:@""];
    [valueTextField setText:@""];
    [valueTextField setPlaceholder:@""];
    accessoryButton = nil;
}

-(void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

-(void)animateSelection {
  [UIView animateWithDuration:0.15 animations:^{
      [bg setAlpha:0.0];
      [bgSelected setAlpha:1.0];
  } completion:^(BOOL finished) {
      [UIView animateWithDuration:0.15 animations:^{
          [bg setAlpha:1.0];
          [bgSelected setAlpha:0.0];
      }];
  }];
}

-(void)loadTitle:(NSString*)value tag:(int)tag textFieldDelegate:(id<UITextFieldDelegate>)delegate cellType:(kCellType)type andKeyboardType:(UIKeyboardType)keyboardType {
    [titleTextField setFont:HelveticaNeue(16)];
    [titleTextField setUserInteractionEnabled:YES];
    
    [titleTextField setPlaceholder:value];
    
    [self setCellType:type];
  
    if(!isEditingMode) {
      bg.frame = CGRectMake(10, 0, self.contentView.frame.size.width - 20, 42);
      [valueTextField setFrame:CGRectMake(self.contentView.frame.size.width / 2.f + EDGE_OFFSET / 2.f,
                                          self.frame.size.height - 42 - 2,
                                          cellWidth / 2.f - EDGE_OFFSET * 1.5,
                                          42)];
    }
    [titleTextField setTag:tag];
    [titleTextField setKeyboardType:keyboardType];
    [titleTextField setText:value];
    [titleTextField setDelegate:delegate];
    
    [valueTextField setDelegate:delegate];
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

-(void)setReturnkeyType:(UIReturnKeyType)type {
    [titleTextField setReturnKeyType:type];
}

-(void)setAutoCorrectionType:(UITextAutocorrectionType)type {
    [titleTextField setAutocorrectionType:type];
}

-(void)setAutoCapitalizationType:(UITextAutocapitalizationType)type {
    [titleTextField setAutocapitalizationType:type];
}

-(void)resize:(CGFloat)height {
  if(!isEditingMode) {
    [bg setFrame:CGRectMake(10, height - 42, cellWidth - EDGE_OFFSET, 42)];
  }
  [bgSelected setFrame:CGRectMake(10, height - 42, cellWidth - EDGE_OFFSET, 42)];
  
  [titleTextField setFrame:CGRectMake(EDGE_OFFSET,
                                      height - 42 - 2,
                                      valueTextField.hidden?cellWidth - EDGE_OFFSET * 2.:cellWidth / 2.f - EDGE_OFFSET * 1.5,
                                      42)];
  if(!isEditingMode) {
    [valueTextField setFrame:CGRectMake(cellWidth / 2.f + EDGE_OFFSET / 2.f,
                                        height - 42 - 2,
                                        cellWidth / 2.f - EDGE_OFFSET * 1.5,
                                        42)];
  }
}

-(void)setTextFieldEditable:(BOOL)sender {
    [titleTextField setUserInteractionEnabled:sender];
}

-(void)changeFontTo:(UIFont*)sender {
    [titleTextField setFont:sender];
}

- (void)addAccessoryTarget:(id)target action:(SEL)action {
    accessoryButton = [[UIButton alloc] initWithFrame:CGRectMake(cellWidth - ACCESSORY_SIZE * 1.5, (42 - ACCESSORY_SIZE) / 2, ACCESSORY_SIZE, ACCESSORY_SIZE)];
    [accessoryButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    [accessoryButton setImage:[UIImage imageNamed:@"plus.png"] forState:UIControlStateNormal];
    accessoryButton.imageEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);
    [self addSubview:accessoryButton];
    
    CGRect frame = titleTextField.frame;
    frame.origin.x = (40 + (cellWidth - 40) * 0.6) - ACCESSORY_SIZE;
    titleTextField.frame = frame;
}

- (void)setCanEditvalueField:(BOOL)canEditvalueField {
    super.canEditvalueField = canEditvalueField;
    valueTextField.enabled = canEditvalueField;
}

- (void)setIsTitleEditable:(BOOL)isTitleEditable {
    super.isTitleEditable = isTitleEditable;
    titleTextField.enabled = isTitleEditable;
}

- (void)setAutolayoutForValueField {
  valueTextField.autoresizingMask =  UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin;
  if(!isEditingMode) {
    valueTextField.frame = CGRectMake(self.contentView.frame.size.width / 2.f + EDGE_OFFSET / 2.f, self.frame.size.height - 42 - 2, cellWidth / 2.f - EDGE_OFFSET * 1.5, 42);
  }
}

- (void)setValueField:(NSString *)value tag:(NSInteger)tag {
    valueTextField.hidden = NO;
    valueTextField.text = value?:@"";
    valueTextField.placeholder = valueTextField.text;
    [valueTextField setTag:tag];
    
    [titleTextField setFrame:CGRectMake(EDGE_OFFSET,
                                        self.frame.size.height - 42 - 2,
                                        cellWidth / 2.f - EDGE_OFFSET * 1.5,
                                        42)];
  if(!isEditingMode) {
    [valueTextField setFrame:CGRectMake(self.contentView.frame.size.width / 2.f + EDGE_OFFSET / 2.f,
                                        self.frame.size.height - 42 - 2,
                                        cellWidth / 2.f - EDGE_OFFSET * 1.5,
                                        42)];
  }
}

- (void)setCellWidth:(CGFloat)pCellWidth {
  cellWidth = pCellWidth;
  
  [self resize:self.contentView.frame.size.height];
}

@end
