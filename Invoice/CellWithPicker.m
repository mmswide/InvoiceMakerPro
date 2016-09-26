//
//  CellWithPicker.m
//  Invoice
//
//  Created by XGRoup5 on 8/15/13.
//  Copyright (c) 2013 XGRoup. All rights reserved.
//

#import "CellWithPicker.h"

#import "Defines.h"

@implementation CellWithPicker

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
		
		titleTextField = [[UITextField alloc] initWithFrame:CGRectMake(20, 0, (cellWidth - 40) * 0.6, 42)];
		[titleTextField setTextAlignment:NSTextAlignmentLeft];
		[titleTextField setTextColor:[UIColor grayColor]];
		[titleTextField setFont:HelveticaNeue(16)];
		[titleTextField setBackgroundColor:[UIColor clearColor]];
		[titleTextField setTag:10];
        titleTextField.enabled = NO;
		[bgView addSubview:titleTextField];
		
		titleLabelSelected = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, (cellWidth - 40) * 0.6, 42)];
		[titleLabelSelected setTextAlignment:NSTextAlignmentLeft];
		[titleLabelSelected setTextColor:app_tab_selected_color];
		[titleLabelSelected setFont:HelveticaNeue(16)];
		[titleLabelSelected setBackgroundColor:[UIColor clearColor]];
		[titleLabelSelected setTag:20];
		[titleLabelSelected setAlpha:0.0];
		[bgView addSubview:titleLabelSelected];
		
		valueLabel = [[UILabel alloc] initWithFrame:CGRectMake(cellWidth / 2.f + EDGE_OFFSET / 2.f, self.frame.size.height - 42 + 1, cellWidth / 2.f - 30, 42)];
		[valueLabel setTextAlignment:NSTextAlignmentRight];
		[valueLabel setTextColor:[UIColor darkGrayColor]];
		[valueLabel setFont:HelveticaNeue(16)];
		[valueLabel setBackgroundColor:[UIColor clearColor]];
    valueLabel.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
		[bgView addSubview:valueLabel];
	}
	
	return self;
}

-(void)prepareForReuse {
	[super prepareForReuse];
	
	[bg setImage:nil];
	[bgSelected setImage:nil];
	[titleTextField setText:@""];
	[titleLabelSelected setText:@""];
	[valueLabel setText:@""];
}

-(void)setSelected:(BOOL)selected animated:(BOOL)animated {
	[super setSelected:selected animated:animated];
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

-(void)loadTitle:(NSString*)title andValue:(NSString*)value cellType:(kCellType)type {
  [self setCellType:type];
	
	[titleTextField setText:title];
  [titleTextField setPlaceholder:title];
	[titleLabelSelected setText:title];
	
  if(!isEditingMode) {
    bg.frame = CGRectMake(10, 0, self.contentView.frame.size.width - 20, 42);
    [valueLabel setFrame:CGRectMake(cellWidth / 2.f + EDGE_OFFSET / 2.f, self.frame.size.height - 42 + 1, cellWidth / 2.f - 30, 42)];
  }
	[valueLabel setText:value];
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

-(void)resize {
  if(!isEditingMode) {
    [bg setFrame:CGRectMake(10, self.frame.size.height - 42, cellWidth - 20, 42)];
  }
	[bgSelected setFrame:CGRectMake(10, self.frame.size.height - 42, cellWidth - 20, 42)];
	[titleTextField setFrame:CGRectMake(20, self.frame.size.height - 42, (cellWidth - 40) * 0.6, 42)];
	[titleLabelSelected setFrame:CGRectMake(20, self.frame.size.height - 42, (cellWidth - 40) * 0.6, 42)];
  if(!isEditingMode) {
    [valueLabel setFrame:CGRectMake(self.contentView.frame.size.width / 2.f + EDGE_OFFSET / 2.f - valueOffset,
                                        self.frame.size.height - 42 - 2,
                                        cellWidth / 2.f - EDGE_OFFSET * 1.5 + valueOffset,
                                        42)];
  }
  
  if(self.isTitleEditable) {
      [self setTitleEditableLayout];
  }
}

- (void)setAutolayoutForValueField {
  valueLabel.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin;

  if(!isEditingMode) {
    valueLabel.frame = CGRectMake(self.contentView.frame.size.width / 2.f + EDGE_OFFSET / 2.f - valueOffset,
                                      self.frame.size.height - 42 - 2,
                                      cellWidth / 2.f - EDGE_OFFSET * 1.5 + valueOffset,
                                      42);
  }
}

- (void)setCanEditvalueField:(BOOL)canEditvalueField {
    super.canEditvalueField = canEditvalueField;   
    titleTextField.enabled = canEditvalueField;
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
    [valueLabel setFrame:CGRectMake(cellWidth / 2.f + EDGE_OFFSET / 2.f, self.frame.size.height - 42 + 1, cellWidth / 2.f - 30, 42)];
  }
}

- (void)setCellWidth:(CGFloat)pCellWidth {
  cellWidth = pCellWidth;
  
  [self resize];
}

@end
