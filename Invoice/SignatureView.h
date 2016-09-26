//
//  SignatureView.h
//  Work.
//
//  Created by Paul on 19/11/13.
//  Copyright (c) 2013 XGRoup. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SignatureView : UIView

{
	UIColor * brushColor;
	UIImage * signature;
	BOOL startedWithImage;
	BOOL isEmpty;
}

-(id)init;
-(id)initWithFrame:(CGRect)frame;
-(id)initWithFrame:(CGRect)frame signature:(UIImage*)sender andSignatureFrame:(CGRect)sFrame;

-(void)setColor:(UIColor*)color;
-(void)clear;
-(UIImage*)theSignature;
-(void)createBoundariesForPoint:(CGPoint)sender;

@property (strong) UIBezierPath * signaturePath;
@property CGPoint topLeftPoint;
@property CGPoint bottomRightPoint;


@end