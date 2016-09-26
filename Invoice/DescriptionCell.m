//
//  DescriptionCell.m
//  Invoice
//
//  Created by Dmytro Nosulich on 4/1/15.
//  Copyright (c) 2015 XGRoup. All rights reserved.
//

#import "DescriptionCell.h"
#import <QuartzCore/QuartzCore.h>
#import "Defines.h"
#import "PlaceHolderTextView.h"

#define ACCESSORY_SIZE 30.f
#define TITLE_FIELD_HEIGHT 42.f

@implementation DescriptionCell

@synthesize valueTextView;

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
        
        bg = [[UIImageView alloc] initWithFrame:CGRectMake(10, 0, dvc_width - 20, DESCRIPTION_VIEW_HEIGHT)];
        [bg setTag:1];
//        if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            bg.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
//        }
        [self.contentView addSubview:bg];
        
        bgSelected = [[UIImageView alloc] initWithFrame:CGRectMake(10, 0, dvc_width - 20, DESCRIPTION_VIEW_HEIGHT)];
        [bgSelected setTag:2];
        [bgSelected setAlpha:0.0];
        [self.contentView addSubview:bgSelected];
        
        titleTextField = [[UITextField alloc] initWithFrame:CGRectMake(20, 0, dvc_width - 40, TITLE_FIELD_HEIGHT)];
        [titleTextField setTextAlignment:NSTextAlignmentLeft];
        [titleTextField setTextColor:[UIColor grayColor]];
        [titleTextField setFont:HelveticaNeue(16)];
        [titleTextField setBackgroundColor:[UIColor clearColor]];
        [titleTextField setTag:10];
        titleTextField.enabled = NO;
        //		[titleLabel setNumberOfLines:2];
        [self.contentView addSubview:titleTextField];
        
        titleLabelSelected = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, (dvc_width - 40) * 0.6, TITLE_FIELD_HEIGHT)];
        [titleLabelSelected setTextAlignment:NSTextAlignmentLeft];
        [titleLabelSelected setTextColor:app_tab_selected_color];
        [titleLabelSelected setFont:HelveticaNeue(16)];
        [titleLabelSelected setBackgroundColor:[UIColor clearColor]];
        [titleLabelSelected setTag:20];
        [titleLabelSelected setAlpha:0.0];
        [titleLabelSelected setNumberOfLines:2];
        [self.contentView addSubview:titleLabelSelected];
        
        valueTextView = [[PlaceHolderTextView alloc] initWithFrame:CGRectMake(20, TITLE_FIELD_HEIGHT, self.contentView.frame.size.width - 40, DESCRIPTION_VIEW_HEIGHT - TITLE_FIELD_HEIGHT)];
        [valueTextView setPlaceholder:@"Write down item description"];
        [valueTextView setTextColor:[UIColor darkGrayColor]];
        [valueTextView setFont:HelveticaNeue(16)];
        [valueTextView setBackgroundColor:[UIColor clearColor]];
        [valueTextView setReturnKeyType:UIReturnKeyDone];
        [valueTextView setAutocorrectionType:UITextAutocorrectionTypeYes];
        if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            valueTextView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        }
        [self.contentView addSubview:valueTextView];
    }
    
    return self;
}

-(void)prepareForReuse {
    [super prepareForReuse];
    
    [bg setImage:nil];
    [titleTextField setText:@""];
    [titleLabelSelected setText:@""];
    [valueTextView setText:@""];
    accessoryButton = nil;
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

-(void)loadTitle:(NSString*)title andValue:(NSString*)value tag:(int)tag textFieldDelegate:(id<UITextViewDelegate>)delegate cellType:(kCellType)type andKeyboardType:(UIKeyboardType)keyboardType {
    
    [self setCellType:type];
    
    [titleTextField setText:title];
    [titleTextField setPlaceholder:title];
    [titleLabelSelected setText:title];
    
    [valueTextView setFrame:CGRectMake(valueTextView.frame.origin.x, TITLE_FIELD_HEIGHT + 1, valueTextView.frame.size.width, DESCRIPTION_VIEW_HEIGHT - TITLE_FIELD_HEIGHT)];
    [valueTextView setTag:tag];
    [valueTextView setKeyboardType:keyboardType];
    [valueTextView setText:value];
    [valueTextView setDelegate:delegate];
    [valueTextView setFont:HelveticaNeue(16)];
    [valueTextView setUserInteractionEnabled:YES];
    
    if(!isEditingMode) {
        bg.frame = CGRectMake(10, 0, self.contentView.frame.size.width - 20, DESCRIPTION_VIEW_HEIGHT);
    }
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
    [valueTextView setReturnKeyType:type];
}

-(void)setAutoCorrectionType:(UITextAutocorrectionType)type {
    [valueTextView setAutocorrectionType:type];
}

-(void)setAutoCapitalizationType:(UITextAutocapitalizationType)type {
    [valueTextView setAutocapitalizationType:type];
}

-(void)resize:(CGFloat)height {
    [bg setFrame:CGRectMake(10, height - DESCRIPTION_VIEW_HEIGHT, dvc_width - 20, DESCRIPTION_VIEW_HEIGHT)];
    [bgSelected setFrame:CGRectMake(10, height - DESCRIPTION_VIEW_HEIGHT, dvc_width - 20, DESCRIPTION_VIEW_HEIGHT)];
    [titleTextField setFrame:CGRectMake(20, 0, dvc_width - 40, TITLE_FIELD_HEIGHT)];
    [titleLabelSelected setFrame:CGRectMake(20, 0, dvc_width - 40, TITLE_FIELD_HEIGHT)];
    
    [valueTextView setFrame:CGRectMake(valueTextView.frame.origin.x, TITLE_FIELD_HEIGHT + 1, valueTextView.frame.size.width, DESCRIPTION_VIEW_HEIGHT - TITLE_FIELD_HEIGHT)];
}

-(void)setTextFieldEditable:(BOOL)sender {
    [valueTextView setUserInteractionEnabled:sender];
}

-(void)changeFontTo:(UIFont*)sender {
    [valueTextView setFont:sender];
}

- (void)setCanEditvalueField:(BOOL)canEditvalueField {
    super.canEditvalueField = canEditvalueField;
    valueTextView.editable = canEditvalueField;
}

- (void)setIsTitleEditable:(BOOL)isTitleEditable {
    super.isTitleEditable = isTitleEditable;
    titleTextField.enabled = isTitleEditable;
}

- (void)setAutolayoutForValueField {
    valueTextView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
}

- (void)setIsTitleEditable:(BOOL)isTitleEditable delegate:(id<UITextFieldDelegate>)delegate tag:(NSInteger)tag {
    super.isTitleEditable = isTitleEditable;
    
    titleTextField.enabled = isTitleEditable;
    if(isTitleEditable) {
        titleTextField.delegate = delegate;
        titleTextField.tag = tag;
    }
}

@end

