//
//  CreateOrEditProjectVC.m
//  Invoice
//
//  Created by Paul on 17/06/14.
//  Copyright (c) 2014 XGRoup. All rights reserved.
//

#import "CreateOrEditProjectVC.h"

#import "CellWithText.h"
#import "CellWithPush.h"
#import "CellWithCheck.h"

#import "ClientsVC.h"

@interface CreateOrEditProjectVC () <UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate,UITextFieldDelegate>

@end

@implementation CreateOrEditProjectVC

@synthesize delegate;

-(id)initWithProject:(ProjectOBJ*)sender delegate:(id<ProjectCreatorDelegate>)del
{
	self = [super init];
	
	if(self)
	{
		editState = (sender == nil) ? 0 : 1;
		delegate = del;
		
		theProject = [[ProjectOBJ alloc] initWithProject:sender];
		firstTime = YES;
	}
	
	return self;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	theSelfView = [[UIView alloc] initWithFrame:CGRectMake(0, statusBarHeight, dvc_width, dvc_height)];
	[theSelfView setBackgroundColor:[UIColor clearColor]];
	[self.view addSubview:theSelfView];
		
	[self.view setBackgroundColor:app_background_color];
	
	NSString *topBarString = (editState == 0) ? @"Create Project" : @"Edit Project";
	
	topBarView = [[TopBar alloc] initWithFrame:CGRectMake(0, 0, dvc_width, 42 + statusBarHeight) andTitle:topBarString];
	[topBarView setBackgroundColor:app_bar_update_color];

	UIButton * cancel = [[UIButton alloc] initWithFrame:CGRectMake(0, 42 + statusBarHeight - 40, 80, 40)];
	[cancel setTitle:@"Cancel" forState:UIControlStateNormal];
	[cancel setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[cancel setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
	[cancel.titleLabel setFont:HelveticaNeueLight(17)];
	[cancel addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
	[topBarView addSubview:cancel];
	
	UIButton * done = [[UIButton alloc] initWithFrame:CGRectMake(dvc_width - 60, 42 + statusBarHeight - 40, 60, 40)];
	[done setTitle:@"Done" forState:UIControlStateNormal];
	[done setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[done setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
	[done.titleLabel setFont:HelveticaNeueLight(17)];
	[done addTarget:self action:@selector(done:) forControlEvents:UIControlEventTouchUpInside];
	[topBarView addSubview:done];
	
	mainScrollView = [[ScrollWithShadow alloc] initWithFrame:CGRectMake(0, 42, dvc_width, dvc_height - 42)];
	[mainScrollView setBackgroundColor:[UIColor clearColor]];
	[mainScrollView setDelegate:self];
	[theSelfView addSubview:mainScrollView];
	
	myTableView = [[TableWithShadow alloc] initWithFrame:CGRectMake(0, 0, dvc_width, dvc_height - 42) style:UITableViewStyleGrouped];
	[myTableView setDataSource:self];
	[myTableView setDelegate:self];
	myTableView.scrollEnabled = NO;
	[myTableView setBackgroundColor:[UIColor clearColor]];
	[myTableView setSeparatorColor:[UIColor clearColor]];
	[myTableView layoutIfNeeded];
	
	if (sys_version >= 7)
	{
		[myTableView setContentInset:UIEdgeInsetsZero];
		[mainScrollView setContentInset:UIEdgeInsetsMake(-20, 0, 0, 0)];
	}
	
	[mainScrollView setContentSize:myTableView.contentSize];
	[myTableView setFrame:CGRectMake(0, 0, mainScrollView.contentSize.width, mainScrollView.contentSize.height)];
	
	[mainScrollView addSubview:myTableView];
	
	theToolbar = [[ToolBarView alloc] initWithFrame:CGRectMake(0, dvc_height, dvc_width, 40)];
	[theToolbar.prevButton addTarget:self action:@selector(prev:) forControlEvents:UIControlEventTouchUpInside];
	[theToolbar.nextButton addTarget:self action:@selector(next:) forControlEvents:UIControlEventTouchUpInside];
	[theToolbar.doneButton addTarget:self action:@selector(close:) forControlEvents:UIControlEventTouchUpInside];
	
	[theSelfView addSubview:theToolbar];
	
	[self.view addSubview:topBarView];
}

-(void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	if(firstTime == NO)
	{
		[myTableView reloadData];
	}
	
	firstTime = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardFrameChanged:) name:UIKeyboardDidChangeFrameNotification object:nil];
}

#pragma mark - TABLE VIEW DATASOURCE

-(NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
	return 6;
}

-(UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
	return [self projectCell:(int)indexPath.row];
}

#pragma mark - TABLE VIEW DELEGATE

-(CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
	return 42.0f;
}

-(void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
	UITableViewCell *theCell = [tableView cellForRowAtIndexPath:indexPath];
		
	if ([theCell isKindOfClass:[CellWithPush class]])
	{
		[(CellWithPush*)theCell animateSelection];
	}
	else
	if ([theCell isKindOfClass:[CellWithCheck class]])
	{
		[(CellWithCheck*)theCell animateSelection];
	}
	
	[self selectCellAtRow:indexPath.row];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
  if([cell respondsToSelector:@selector(setCellWidth:)])
    [(BaseTableCell *)cell setCellWidth:tableView.frame.size.width];
}

-(UITableViewCell*)projectCell:(int)row
{
	UITableViewCell * theCell;
	
	switch (row)
	{
		case 0:
		{
			theCell = [myTableView dequeueReusableCellWithIdentifier:@"tableCellText"];
			
			if (!theCell)
			{
				theCell = [[CellWithText alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"tableCellText"];
			}
			
			[(CellWithText*)theCell loadTitle:@"Name" andValue:[theProject projectName] tag:111 textFieldDelegate:self cellType:kCellTypeTop andKeyboardType:UIKeyboardTypeDefault];
			[(CellWithText*)theCell setReturnkeyType:UIReturnKeyNext];
			[(CellWithText*)theCell setAutoCorrectionType:UITextAutocorrectionTypeDefault];
			[(CellWithText*)theCell setAutoCapitalizationType:UITextAutocapitalizationTypeWords];
			
			break;
		}
			
		case 1:
		{
			theCell = [myTableView dequeueReusableCellWithIdentifier:@"tableCellText"];
			
			if (!theCell)
			{
				theCell = [[CellWithText alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"tableCellText"];
			}
			
			[(CellWithText*)theCell loadTitle:@"Project Number" andValue:[theProject projectNumber] tag:222 textFieldDelegate:self cellType:kCellTypeMiddle andKeyboardType:UIKeyboardTypeDefault];
			[(CellWithText*)theCell setReturnkeyType:UIReturnKeyNext];
			[(CellWithText*)theCell setAutoCorrectionType:UITextAutocorrectionTypeNo];
			[(CellWithText*)theCell setAutoCapitalizationType:UITextAutocapitalizationTypeSentences];
			
			break;
		}
			
		case 2:
		{
			theCell = [myTableView dequeueReusableCellWithIdentifier:@"tableCellPush"];
			
			if (!theCell)
			{
				theCell = [[CellWithPush alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"tableCellPush"];
			}
			
			ClientOBJ * theClient = [theProject client];
			
			NSString * name = [theClient company];
			
			if (name.length == 0)
			{
				name = [NSString stringWithFormat:@"%@ %@", [theClient firstName], [theClient lastName]];
			}
			
			[(CellWithPush*)theCell loadTitle:@"Client" andValue:name cellType:kCellTypeMiddle andSize:20.0];
			[theCell setUserInteractionEnabled:YES];
			
			break;
		}
			
		case 3:
		{
			theCell = [myTableView dequeueReusableCellWithIdentifier:@"tableCellText"];
						
			if (!theCell)
			{
				theCell = [[CellWithText alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"tableCellText"];
			}
			
			[(CellWithText*)theCell loadTitle:@"Location" andValue:[theProject location] tag:333 textFieldDelegate:self cellType:kCellTypeMiddle andKeyboardType:UIKeyboardTypeDefault];
			[(CellWithText*)theCell setReturnkeyType:UIReturnKeyNext];
			[(CellWithText*)theCell setAutoCorrectionType:UITextAutocorrectionTypeDefault];
			[(CellWithText*)theCell setAutoCapitalizationType:UITextAutocapitalizationTypeSentences];
			
			break;
		}
			
		case 4:
		{
			theCell = [myTableView dequeueReusableCellWithIdentifier:@"tableCellCheck"];
			
			if (!theCell)
			{
				theCell = [[CellWithCheck alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"tableCellCheck"];
			}
							
			[(CellWithCheck*)theCell loadTitle:@"Paid" andValue:[theProject paid] cellType:kProjectCellTypeMiddle];
					
			break;
		}
			
		case 5:
		{
			theCell = [myTableView dequeueReusableCellWithIdentifier:@"tableCellCheck"];
			
			if(!theCell)
			{
				theCell = [[CellWithCheck alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"tableCellCheck"];
			}
			
			[(CellWithCheck*)theCell loadTitle:@"Completed" andValue:[theProject completed] cellType:kProjectCellTypeBottom];
			
			break;
		}
			
		default:
			break;
	}
	
	return theCell;
}

#pragma mark - CELL SELECTION

-(void)selectCellAtRow:(NSInteger)row
{
	switch (row)
	{
		case 0:
		{
			[(UITextField*)[self.view viewWithTag:111] becomeFirstResponder];
			break;
		}
			
		case 1:
		{
			[(UITextField*)[self.view viewWithTag:222] becomeFirstResponder];
			break;
		}
		case 2:
		{
			ClientsVC *vc = [[ClientsVC alloc] initWithProject:theProject];
			[self.navigationController pushViewController:vc animated:YES];

			break;
		}
		case 3:
		{
			[(UITextField*)[self.view viewWithTag:333] becomeFirstResponder];
			break;
		}
			
		case 4:
		{
			int paidValue = [[theProject paid] intValue];
			
			if(paidValue == 1)
				[theProject setPaid:@"0"];
			else
				[theProject setPaid:@"1"];
			
			[myTableView reloadData];
			
			break;
		}
			
		case 5:
		{
			int completedValue = [[theProject completed] intValue];
			
			if(completedValue == 1)
				[theProject setCompleted:@"0"];
			else
				[theProject setCompleted:@"1"];
			
			[myTableView reloadData];
			
			break;
		}
			
		default:
			break;
	}
}

#pragma mark - TEXT FIELD DELEGATE

-(void)textFieldDidBeginEditing:(UITextField*)textField
{
	[theToolbar.prevButton setAlpha:1.0];
	[theToolbar.prevButton setUserInteractionEnabled:YES];
	
	[theToolbar.nextButton setAlpha:1.0];
	[theToolbar.nextButton setUserInteractionEnabled:YES];
	
	switch (textField.tag)
	{
		case 111:
		{
			active_field = kActiveFieldProjectName;
			[theToolbar.prevButton setAlpha:0.5];
			[theToolbar.prevButton setUserInteractionEnabled:NO];
			break;
		}
			
		case 222:
		{
			active_field = kActiveFieldProjectNumber;
			break;
		}
			
		case 333:
		{
			[theToolbar.nextButton setAlpha:0.5];
			[theToolbar.nextButton setUserInteractionEnabled:NO];
			
			active_field = kActiveFieldLocation;
			break;
		}
			
		default:
			break;
	}
}

-(BOOL)textFieldShouldBeginEditing:(UITextField*)textField
{
	another_textfield_takes_over = YES;
	
	[[self.navigationController.view viewWithTag:101010] removeFromSuperview];
	
	[UIView animateWithDuration:0.25 animations:^{
		
		[theToolbar setFrame:CGRectMake(0, dvc_height - keyboard_height - 40, dvc_width, 40)];
        
		[mainScrollView setFrame:CGRectMake(mainScrollView.frame.origin.x, mainScrollView.frame.origin.y, dvc_width, dvc_height - 82 - keyboard_height)];
		if (mainScrollView && [mainScrollView respondsToSelector:@selector(didScroll)])
			[mainScrollView didScroll];
		
	} completion:^(BOOL finished) {
		
		CGRect frame = textField.superview.frame;
		
		if (sys_version >= 7)
        {
			frame = textField.superview.superview.frame;
        }
        
        if(sys_version >= 8)
        {
            frame = textField.superview.frame;
        }
		
		[mainScrollView scrollRectToVisible:frame animated:YES];
		
	}];
	
	return YES;
}

-(BOOL)textFieldShouldEndEditing:(UITextField*)textField
{
	if (!another_textfield_takes_over)
	{
		[[self.navigationController.view viewWithTag:101010] removeFromSuperview];
		
		[UIView animateWithDuration:0.25 animations:^{
			
			[mainScrollView setFrame:CGRectMake(mainScrollView.frame.origin.x, mainScrollView.frame.origin.y, dvc_width, dvc_height - 87)];
			if (mainScrollView && [mainScrollView respondsToSelector:@selector(didScroll)])
				[mainScrollView didScroll];
			
		}];
	}
	
	another_textfield_takes_over = NO;
	
	switch (textField.tag)
	{
		case 111:
		{
			[theProject setProjectName:textField.text];
			break;
		}
			
		case 222:
		{
			[theProject setProjectNumber:textField.text];
			break;
		}
			
		case 333:
		{
			[theProject setLocation:textField.text];
			break;
		}
						
		default:
			break;
	}
	
	return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField*)textField
{
	if (textField.tag < 333)
	{
		[(UITextField*)[self.view viewWithTag:textField.tag + 111] becomeFirstResponder];
	}

	[textField resignFirstResponder];
	return YES;
}

#pragma mark - SCROLL VIEW DELEGATE

-(void)scrollViewDidScroll:(UIScrollView*)scrollView
{
	if (mainScrollView && [mainScrollView respondsToSelector:@selector(didScroll)])
		[mainScrollView didScroll];
}

#pragma mark - ACTIONS

-(void)next:(UIButton*)sender
{
    switch (active_field)
    {
        case kActiveFieldProjectName:
        {
            [(UITextField*)[self.view viewWithTag:222] becomeFirstResponder];
            break;
        }
            
        case kActiveFieldProjectNumber:
        {
            [(UITextField*)[self.view viewWithTag:333] becomeFirstResponder];
            break;
        }
            
        case kActiveFieldLocation:
        {
            break;
        }
            
        default:
            break;
    }
}

-(void)prev:(UIButton*)sender
{
    switch (active_field)
    {
        case kActiveFieldProjectName:
        {
            break;
        }
            
        case kActiveFieldProjectNumber:
        {
            [(UITextField*)[self.view viewWithTag:111] becomeFirstResponder];
            break;
        }
            
        case kActiveFieldLocation:
        {
            [(UITextField*)[self.view viewWithTag:222] becomeFirstResponder];
            break;
        }
            
        default:
            break;
    }
}

-(void)close:(UIButton*)sender
{
    [(UITextField*)[self.view viewWithTag:111] resignFirstResponder];
    [(UITextField*)[self.view viewWithTag:222] resignFirstResponder];
    [(UITextField*)[self.view viewWithTag:333] resignFirstResponder];
    
    [UIView animateWithDuration:0.25 animations:^{
        [theToolbar setFrame:CGRectMake(0, dvc_height, dvc_width, 40)];
        [mainScrollView setFrame:CGRectMake(mainScrollView.frame.origin.x, mainScrollView.frame.origin.y, dvc_width, dvc_height - 42)];
        
        if (mainScrollView && [mainScrollView respondsToSelector:@selector(didScroll)])
            [mainScrollView didScroll];
        
    } completion:^(BOOL finished) {
    }];
}

-(void)cancel:(UIButton*)sender
{
	[self dismissViewControllerAnimated:YES completion:nil];
}

-(void)done:(UIButton*)sender
{
	if([[theProject projectName] isEqual:@""])
	{
		[[[AlertView alloc] initWithTitle:@"" message:@"The project must have a name" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] showInWindow];
		return;
	}
	
	if([[theProject projectNumber] isEqual:@""])
	{
		[[[AlertView alloc] initWithTitle:@"" message:@"The project must have a number" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] showInWindow];
		return;
	}
	
	if([delegate respondsToSelector:@selector(creatorViewController:createdProject:)])
	{
		[delegate creatorViewController:self createdProject:theProject];
	}
	
	[self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - NSNotificationCenter

-(void)keyboardFrameChanged:(NSNotification*)notification
{
    NSDictionary* info = [notification userInfo];
    
    CGPoint to = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].origin;
    
    if(to.y == dvc_height + 20)
    {
        return;
    }
    
    [UIView animateWithDuration:0.25 animations:^{
        
        theToolbar.frame = CGRectMake(theToolbar.frame.origin.x, to.y - theToolbar.frame.size.height - 20, theToolbar.frame.size.width, theToolbar.frame.size.height);
        
    }];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
