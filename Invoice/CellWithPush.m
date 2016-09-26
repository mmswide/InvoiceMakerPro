//
//  CellWithPush.m
//  Invoice
//
//  Created by XGRoup5 on 8/15/13.
//  Copyright (c) 2013 XGRoup. All rights reserved.
//

#import "CellWithPush.h"

#import "Defines.h"

@implementation CellWithPush

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier width:(CGFloat)width {
  cellWidth = width;
  
  return [self initWithStyle:style reuseIdentifier:reuseIdentifier];
}

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString*)reuseIdentifier {
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	
	if (self) {
    if(cellWidth == 0) {
      cellWidth = dvc_width;
    }
    
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
		
		arrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cellArrow.png"]];
    arrow.frame = CGRectMake(arrow.frame.origin.x, arrow.frame.origin.y, 20,20);
		[arrow setCenter:CGPointMake(self.contentView.frame.size.width - 30, 21)];
    arrow.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
		[bgView addSubview:arrow];
		
		titleTextField = [[UITextField alloc] initWithFrame:CGRectMake(20, 0, (cellWidth - 40) * 0.6, 42)];
		[titleTextField setTextAlignment:NSTextAlignmentLeft];
		[titleTextField setTextColor:[UIColor grayColor]];
		[titleTextField setFont:HelveticaNeue(16)];
		[titleTextField setBackgroundColor:[UIColor clearColor]];
		[titleTextField setTag:10];
    [titleTextField setEnabled:NO];
		[bgView addSubview:titleTextField];
		
		titleLabelSelected = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, (cellWidth - 40) * 0.6, 42)];
		[titleLabelSelected setTextAlignment:NSTextAlignmentLeft];
		[titleLabelSelected setTextColor:app_tab_selected_color];
		[titleLabelSelected setFont:HelveticaNeue(16)];
		[titleLabelSelected setBackgroundColor:[UIColor clearColor]];
		[titleLabelSelected setTag:20];
		[titleLabelSelected setAlpha:0.0];
		[bgView addSubview:titleLabelSelected];
		
    valueTextField = [[UITextField alloc] initWithFrame:CGRectMake(self.contentView.frame.size.width / 2.f + EDGE_OFFSET / 2.f,
                                                                   0,
                                                                   cellWidth / 2.f - EDGE_OFFSET * 2 - 20,
                                                                   42)];
		[valueTextField setTextAlignment:NSTextAlignmentRight];
		[valueTextField setTextColor:[UIColor darkGrayColor]];
		[valueTextField setFont:HelveticaNeue(16)];
		[valueTextField setBackgroundColor:[UIColor clearColor]];
    [valueTextField setEnabled:NO];
    valueTextField.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
		[bgView addSubview:valueTextField];
	}
	
	return self;
}

-(void)prepareForReuse {
	[super prepareForReuse];
	
	[bg setImage:nil];
	[titleTextField setText:@""];
	[titleLabelSelected setText:@""];
	[valueTextField setText:@""];
  [valueTextField setPlaceholder:@""];
  [self removeAccessoryTarget];
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

-(void)loadTitle:(NSString*)title andValue:(NSString*)value cellType:(kCellType)type andSize:(int)size {
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
  if(!isEditingMode) {
    bg.frame = CGRectMake(10, 0, self.contentView.frame.size.width - 20, 42);
    [valueTextField setFrame:CGRectMake(self.contentView.frame.size.width / 2.f + EDGE_OFFSET / 2.f - offset - valueOffset,
                                        0,
                                        cellWidth / 2.f - EDGE_OFFSET * 2 - difference + valueOffset,
                                        42)];
  }
  
  [self setTitleBiggerFrame];
	[valueTextField setText:value];
}

- (void)addAccessoryTarget:(id)target action:(SEL)action {
  CGRect buttonFrame = CGRectInset(arrow.frame, -(isArrowType?15:20), -20);
  buttonFrame.origin.x += 5;
  accessoryButton = [[UIButton alloc] initWithFrame:buttonFrame];
  [accessoryButton setBackgroundColor:[UIColor clearColor]];
  [accessoryButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
  [self addSubview:accessoryButton];
}

- (void)removeAccessoryTarget {
  [accessoryButton removeFromSuperview];
  accessoryButton = nil;
}

- (void)removeValueField {
    [valueTextField removeFromSuperview];
    valueTextField = nil;
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
  if(!isEditingMode) {
    [bg setFrame:CGRectMake(10, self.frame.size.height - 42, cellWidth - 20, 42)];
  }
	[bgSelected setFrame:CGRectMake(10, self.frame.size.height - 42, cellWidth - 20, 42)];
	[titleTextField setFrame:CGRectMake(20, self.frame.size.height - 42, (cellWidth - 40) * 0.6, 42)];
	[titleLabelSelected setFrame:CGRectMake(20, self.frame.size.height - 42, (cellWidth - 40) * 0.6, 42)];
  if(!isEditingMode) {
    [valueTextField setFrame:CGRectMake(self.contentView.frame.size.width / 2.f + EDGE_OFFSET / 2.f - valueOffset,
                                          0,
                                          cellWidth / 2.f - EDGE_OFFSET * 2 - 20 + valueOffset,
                                          42)];
  }
}

-(void)setAutoCapitalizationType:(UITextAutocapitalizationType)type {
  [valueTextField setAutocapitalizationType:type];
}

- (void)setAutolayoutForValueField {
  valueTextField.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin;
  
  if(!isEditingMode) {
    NSInteger offset = isEditingMode?40:0;
    valueTextField.frame = CGRectMake(self.contentView.frame.size.width / 2.f + EDGE_OFFSET / 2.f - offset - valueOffset,
                                      0,
                                      cellWidth / 2.f - EDGE_OFFSET * 2 - 20 + valueOffset,
                                      42);
  }
  [self setTitleBiggerFrame];
}

- (void)setCanEditvalueField:(BOOL)canEditvalueField {
    super.canEditvalueField = canEditvalueField;
    valueTextField.enabled = canEditvalueField;
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
        [titleTextField setFrame:CGRectMake(20, self.frame.size.height - 42 - 2, cellWidth / 2.f - 30, 42)];
        [valueTextField setFrame:CGRectMake(self.contentView.frame.size.width / 2.f + EDGE_OFFSET / 2.f - valueOffset,
                                            0,
                                            cellWidth / 2.f - EDGE_OFFSET * 2 - 20 + valueOffset,
                                            42)];
    }
}

- (void)setValueTextfieldDelegate:(id<UITextFieldDelegate>)valueTextfieldDelegate tag:(NSInteger)tag; {
    valueTextField.delegate = valueTextfieldDelegate;
    valueTextField.tag = tag;
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
        [titleTextField setFrame:CGRectMake(20, self.frame.size.height - 42 - 2, (cellWidth / 3.f) * 2.f - EDGE_OFFSET * 1.5, 42)];
        [valueTextField setFrame:CGRectMake((self.contentView.frame.size.width / 3.f) * 2.f + EDGE_OFFSET / 2.f, self.frame.size.height - 42 - 2, cellWidth / 3.f - EDGE_OFFSET * 2 - 20, 42)];
    }
}

- (void)setValueEditable:(BOOL)editable {
  [valueTextField setEnabled:editable];
}

- (void)makeValueBigger:(BOOL)isBigger {
  valueOffset = isBigger?cellWidth / 3.5f:0.f;
}

- (void)setValueDelegate:(id<UITextFieldDelegate>)delegate tag:(NSInteger)tag keyboardType:(UIKeyboardType)keyboardType {
  valueTextField.delegate = delegate;
  valueTextField.tag = tag;
  valueTextField.keyboardType = keyboardType;
}

- (void)setValuePlaceholder:(NSString *)placeholder {
  valueTextField.placeholder = placeholder;
}

- (void)setCellWidth:(CGFloat)pCellWidth {
  cellWidth = pCellWidth;
  
  [self resize];
}

@end