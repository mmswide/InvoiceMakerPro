//
//  PlaceHolderTextView.h
//  Invoice
//
//  Created by Dmytro Nosulich on 4/24/15.
//  Copyright (c) 2015 XGRoup. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlaceHolderTextView : UITextView

@property (nonatomic, retain) NSString *placeholder;
@property (nonatomic, retain) UIColor *placeholderColor;

-(void)textChanged:(NSNotification*)notification;

@end
