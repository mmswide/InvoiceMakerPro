//
//  CellWithText.m
//  Invoice
//
//  Created by XGRoup5 on 8/15/13.
//  Copyright (c) 2013 XGRoup. All rights reserved.
//

#import "CellWithText.h"
#import <QuartzCore/QuartzCore.h>
#import "Defines.h"

#define ACCESSORY_SIZE 30.f

@implementation CellWithText

@synthesize valueTextField;

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier width:(CGFloat)width {
  cellWidth = width;
  
  return [self initWithStyle:style reuseIdentifier:reuseIdentifier];
}

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString*)reuseIdentifier {
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	
  if(cellWidth <= 0) {
    cellWidth = dvc_width;
  }
  
	if (self) {
		[self.layer setMasksToBounds:YES];
		
		[self setBackgroundColor:[UIColor clearColor]];
		
		[self setSelectionStyle:UITableViewCellSelectionStyleNone];
		
		bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.contentView.frame.size.width, self.contentView.frame.size.height)];
		[bgView setBackgroundColor:[UIColor clearColor]];
    bgView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.contentView addSubview:bgView];
    
    [self.contentView.layer setMasksToBounds:YES];
		
		bg = [[UIImageView alloc] initWithFrame:CGRectMake(10, 0, cellWidth - 20, 42)];
		[bg setTag:1];
    bg.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;

		[bgView addSubview:bg];
		
		bgSelected = [[UIImageView alloc] initWithFrame:CGRectMake(10, 0, cellWidth - 20, 42)];
		[bgSelected setTag:2];
		[bgSelected setAlpha:0.0];
		[bgView addSubview:bgSelected];
		
		titleTextField = [[UITextField alloc] initWithFrame:CGRectMake(20, 0, cellWidth / 2.f - EDGE_OFFSET * 1.5, 42)];
		[titleTextField setTextAlignment:NSTextAlignmentLeft];
		[titleTextField setTextColor:[UIColor grayColor]];
		[titleTextField setFont:HelveticaNeue(16)];
		[titleTextField setBackgroundColor:[UIColor clearColor]];
		[titleTextField setTag:10];
    titleTextField.enabled = NO;
    titleTextField.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
		[bgView addSubview:titleTextField];
		
		titleLabelSelected = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, (cellWidth - 40) * 0.6, 42)];
		[titleLabelSelected setTextAlignment:NSTextAlignmentLeft];
		[titleLabelSelected setTextColor:app_tab_selected_color];
		[titleLabelSelected setFont:HelveticaNeue(16)];
		[titleLabelSelected setBackgroundColor:[UIColor clearColor]];
		[titleLabelSelected setTag:20];
		[titleLabelSelected setAlpha:0.0];
		[titleLabelSelected setNumberOfLines:2];
		[bgView addSubview:titleLabelSelected];
		
		valueTextField = [[UITextField alloc] initWithFrame:CGRectMake(self.contentView.frame.size.width / 2.f + EDGE_OFFSET / 2.f, self.frame.size.height - 42 - 2, cellWidth / 2.f - EDGE_OFFSET * 1.5, 42)];
		[valueTextField setTextAlignment:NSTextAlignmentRight];
		[valueTextField setTextColor:[UIColor darkGrayColor]];
		[valueTextField setFont:HelveticaNeue(16)];
		[valueTextField setBackgroundColor:[UIColor clearColor]];
		[valueTextField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
		[valueTextField setReturnKeyType:UIReturnKeyDone];
		[valueTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
		[valueTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
    valueTextField.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
		[bgView addSubview:valueTextField];
	}
	
	return self;
}

- (void)willTransitionToState:(UITableViewCellStateMask)state {
    [super willTransitionToState:state];
}

-(void)prepareForReuse {
	[super prepareForReuse];
	
	[bg setImage:nil];
	[titleTextField setText:@""];
  [self setIsTitleEditable:NO];
	[titleLabelSelected setText:@""];
	[valueTextField setText:@""];
  accessoryButton = nil;
  _activeValueOnSelection = NO;
}

-(void)setSelected:(BOOL)selected animated:(BOOL)animated {
	[super setSelected:selected animated:animated];
  if(selected && _activeValueOnSelection) {
    [valueTextField becomeFirstResponder];
  }
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

-(void)loadTitle:(NSString*)title andValue:(NSString*)value tag:(int)tag textFieldDelegate:(id<UITextFieldDelegate>)delegate cellType:(kCellType)type andKeyboardType:(UIKeyboardType)keyboardType {
	[valueTextField setFont:HelveticaNeue(16)];
	[valueTextField setUserInteractionEnabled:YES];

    [self setCellType:type];
	
	[titleTextField setText:title];
  [titleTextField setPlaceholder:title];
	[titleLabelSelected setText:title];

  if(!isEditingMode) {
      valueTextField.frame = CGRectMake(self.contentView.frame.size.width / 2.f + EDGE_OFFSET / 2.f - valueOffset,
                                        self.frame.size.height - 42 - 2,
                                        cellWidth / 2.f - EDGE_OFFSET * 1.5 + valueOffset,
                                        42);
      bg.frame = CGRectMake(10, 0, self.contentView.frame.size.width - 20, 42);
  }
  [self setTitleBiggerFrame];
	[valueTextField setTag:tag];
	[valueTextField setKeyboardType:keyboardType];
	[valueTextField setText:value];
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
	[valueTextField setReturnKeyType:type];
}

-(void)setAutoCorrectionType:(UITextAutocorrectionType)type {
	[valueTextField setAutocorrectionType:type];
}

-(void)setAutoCapitalizationType:(UITextAutocapitalizationType)type {
	[valueTextField setAutocapitalizationType:type];
}

-(void)resize:(CGFloat)height {
  if(!isEditingMode) {
      [bg setFrame:CGRectMake(10, height - 42, cellWidth - 20, 42)];
  }
	[bgSelected setFrame:CGRectMake(10, height - 42, cellWidth - 20, 42)];
	[titleTextField setFrame:CGRectMake(20, height - 42, cellWidth / 2.f - EDGE_OFFSET * 1.5, 42)];
	[titleLabelSelected setFrame:CGRectMake(20, height - 42, (cellWidth - 40) * 0.6, 42)];
		
  if(!isEditingMode) {
    [valueTextField setFrame:CGRectMake(self.contentView.frame.size.width / 2.f + EDGE_OFFSET / 2.f - valueOffset,
                                        self.frame.size.height - 42 - 2,
                                        cellWidth / 2.f - EDGE_OFFSET * 1.5 + valueOffset,
                                        42)];
  }
	[titleTextField setFrame:CGRectMake(20, height - 42 - 2, cellWidth - 20 - valueTextField.frame.size.width - 30, 42)];
	[titleLabelSelected setFrame:titleTextField.frame];
  if(isTitleBigger) {
    [self makeTitleBigger:isTitleBigger];
  }
    
  if(self.isTitleEditable) {
      [self setTitleEditableLayout];
  }
}

-(void)setTextFieldEditable:(BOOL)sender {
	[valueTextField setUserInteractionEnabled:sender];
}

-(void)changeFontTo:(UIFont*)sender {
	[valueTextField setFont:sender];	
}

- (void)addAccessoryTarget:(id)target action:(SEL)action {
    accessoryButton = [[UIButton alloc] initWithFrame:CGRectMake(cellWidth - ACCESSORY_SIZE * 1.5, (42 - ACCESSORY_SIZE) / 2, ACCESSORY_SIZE, ACCESSORY_SIZE)];
    [accessoryButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    [accessoryButton setImage:[UIImage imageNamed:@"plus.png"] forState:UIControlStateNormal];
    accessoryButton.imageEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);
    [self addSubview:accessoryButton];
    
    CGRect frame = valueTextField.frame;
    frame.origin.x = self.contentView.frame.size.width / 2.f + EDGE_OFFSET / 2.f - ACCESSORY_SIZE;
    valueTextField.frame = frame;
}

- (void)setCanEditvalueField:(BOOL)canEditvalueField {
  if(isEditingMode) {
    canEditvalueField = NO;
  }
  super.canEditvalueField = canEditvalueField;
  valueTextField.enabled = canEditvalueField;
}

- (void)setIsTitleEditable:(BOOL)isTitleEditable {
    super.isTitleEditable = isTitleEditable;
    titleTextField.enabled = isTitleEditable;
}

- (void)setAutolayoutForValueField {
  valueTextField.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin;
  if(!isEditingMode) {
      valueTextField.frame = CGRectMake(self.contentView.frame.size.width / 2.f + EDGE_OFFSET / 2.f - valueOffset,
                                        self.frame.size.height - 42 - 2,
                                        cellWidth / 2.f - EDGE_OFFSET * 1.5 + valueOffset,
                                        42);
  }
  [self setTitleBiggerFrame];
  [self makeValueBigger:valueOffset > 0];
}

- (void)setIsTitleEditable:(BOOL)isTitleEditable delegate:(id<UITextFieldDelegate>)delegate tag:(NSInteger)tag {
  if(!isEditingMode) {
    super.isTitleEditable = isTitleEditable;
    
    titleTextField.enabled = isTitleEditable;
    if(isTitleEditable) {
        titleTextField.delegate = delegate;
        titleTextField.tag = tag;
        [self setTitleEditableLayout];
    }
  }
}

- (void)setTitleEditableLayout {
  if(!isEditingMode) {
    [titleTextField setFrame:CGRectMake(20,
                                        self.frame.size.height - 42 - 2,
                                        cellWidth / 2.f - EDGE_OFFSET * 1.5,
                                        42)];
    [titleLabelSelected setFrame:titleTextField.frame];
    [valueTextField setFrame:CGRectMake(self.contentView.frame.size.width / 2.f + EDGE_OFFSET / 2.f - valueOffset,
                                        self.frame.size.height - 42 - 2,
                                        cellWidth / 2.f - EDGE_OFFSET * 1.5 + valueOffset,
                                        42)];
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

- (void)makeValueBigger:(BOOL)isBigger {
  valueOffset = isBigger?cellWidth / 4.:0.f;
  if(isBigger) {
    valueTextField.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
  }
}

- (void)setTitleBiggerFrame {
  if(isTitleBigger && !isEditingMode) {
    [titleTextField setFrame:CGRectMake(20, self.frame.size.height - 42 - 2, (cellWidth / 3.f) * 2.f - EDGE_OFFSET * 1.5, 42)];
    [titleLabelSelected setFrame:titleTextField.frame];
    [valueTextField setFrame:CGRectMake((self.contentView.frame.size.width / 3.f) * 2.f + EDGE_OFFSET / 2.f, self.frame.size.height - 42 - 2, cellWidth / 3.f - EDGE_OFFSET * 1.5, 42)];
  }
}

- (void)setCellWidth:(CGFloat)pCellWidth {
  cellWidth = pCellWidth;
  
  
  [self resize:self.contentView.frame.size.height];
}

@end
