//
//  ClientsVC.m
//  Invoice
//
//  Created by XGRoup5 on 8/13/13.
//  Copyright (c) 2013 XGRoup. All rights reserved.
//

#import "ClientsVC.h"

#import "Defines.h"
#import "CreateOrEditClientVC.h"
#import "ClientDetailsVC.h"

@interface ClientsVC () <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, ClientCreatorDelegate, AlertViewDelegate, ABPeoplePickerNavigationControllerDelegate> {
  BOOL shouldClearArrays;
}

@end

@implementation ClientsVC

-(id)initWithInvoice:(InvoiceOBJ*)sender {
  self = [super init];
  
  if (self) {
    theInvoice = sender;
    [self mainInit];
  }
  
  return self;
}

-(id)initWithEstimate:(EstimateOBJ*)sender {
  self = [super init];
  
  if (self) {
    theEstimate = sender;
    [self mainInit];
  }
  
  return self;
}

-(id)initWithQuote:(QuoteOBJ*)sender {
  self = [super init];
  
  if (self) {
    theQuote = sender;
    [self mainInit];
  }
  
  return self;
}

-(id)initWithPO:(PurchaseOrderOBJ*)sender {
  self = [super init];
  
  if (self) {
    thePurchareOrder = sender;
    [self mainInit];
  }
  
  return self;
}

-(id)initWithProject:(ProjectOBJ*)sender {
  self = [super init];
  
  if(self) {
    theProject = sender;
    [self mainInit];
  }
  
  return self;
}

-(id)initWithReceipt:(ReceiptOBJ*)sender {
  self = [super init];
  
  if(self) {
    theReceipt = sender;
    [self mainInit];
  }
  
  return self;
}

-(id)initWithTimesheet:(TimeSheetOBJ *)sender {
  self = [super init];
  
  if(self) {
    theTimesheet = sender;
    [self mainInit];
  }
  
  return self;
}


-(id)init {
	self = [super init];
	
	if (self) {
    [self mainInit];
	}
	
	return self;
}

- (void)mainInit {
  array_with_clients = [[NSMutableArray alloc] initWithArray:[data_manager loadClientsArrayFromUserDefaultsAtKey:kClientsKeyForNSUserDefaults]];
  sectionSortingDict = [NSMutableDictionary new];
}

#pragma mark - VIEW DID LOAD

-(void)viewDidLoad {
	[super viewDidLoad];
	
  shouldClearArrays = YES;
  
	theSelfView = [[UIView alloc] initWithFrame:CGRectMake(0, statusBarHeight, dvc_width, dvc_height)];
	[theSelfView setBackgroundColor:[UIColor clearColor]];
	[self.view addSubview:theSelfView];
		
	[self.view setBackgroundColor:app_background_color];
	
	topBarView = [[TopBar alloc] initWithFrame:CGRectMake(0, 0, dvc_width, 42 + statusBarHeight) andTitle:@"Contacts"];
	[topBarView setBackgroundColor:app_bar_update_color];
	
  if([self isSelecting]) {
    BackButton * backButton = [[BackButton alloc] initWithFrame:CGRectMake(0, 42 + statusBarHeight - 40, 70, 40) andTitle:@"Back"];
    [backButton addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    [topBarView addSubview:backButton];
  }
  
	UIButton * addClient = [[UIButton alloc] initWithFrame:CGRectMake(dvc_width - 40, 42 + statusBarHeight - 40, 40, 40)];
	[addClient setTitle:@"+" forState:UIControlStateNormal];
	[addClient setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[addClient setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
	[addClient.titleLabel setFont:HelveticaNeueBold(33)];
	[addClient setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 10, 0)];
	[addClient addTarget:self action:@selector(createClient:) forControlEvents:UIControlEventTouchUpInside];
	[topBarView addSubview:addClient];
	
  NSInteger offset = [self isSelecting]?42:87;
	clientsTableView = [[TableWithShadow alloc] initWithFrame:CGRectMake(0, 42, dvc_width, dvc_height - offset) style:UITableViewStyleGrouped];
	[clientsTableView setDelegate:self];
	clientsTableView.backgroundColor = [UIColor clearColor];
	[clientsTableView setDataSource:self];
	[clientsTableView setSeparatorColor:[UIColor clearColor]];
  [clientsTableView setBackgroundView:nil];
  [clientsTableView setTableHeaderView:[[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)]];
	[theSelfView addSubview:clientsTableView];
  
  clientsTableView.sectionIndexBackgroundColor = [UIColor clearColor];
  clientsTableView.sectionIndexMinimumDisplayRowCount = 2;
  clientsTableView.sectionIndexTrackingBackgroundColor = [UIColor colorWithWhite:0.5 alpha:0.2];
	
	[self.view addSubview:topBarView];
}

#pragma mark - ALERTVIEW DELEGATE

-(void)alertView:(AlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 1) {
    shouldClearArrays = NO;
		CreateOrEditClientVC * vc = [[CreateOrEditClientVC alloc] initWithClient:nil delegate:self];
		UINavigationController * nvc = [[UINavigationController alloc] initWithRootViewController:vc];
		[nvc setNavigationBarHidden:YES];
		[self.navigationController presentViewController:nvc animated:YES completion:nil];
	} else if (buttonIndex == 2) {
    shouldClearArrays = NO;
		ABPeoplePickerNavigationController * picker = [[ABPeoplePickerNavigationController alloc] init];
		[picker setPeoplePickerDelegate:self];
		[self.navigationController presentViewController:picker animated:YES completion:nil];
	}
}

#pragma mark - PEOPLE PICKER DELEGATE

- (void)peoplePickerNavigationController:(ABPeoplePickerNavigationController*)peoplePicker didSelectPerson:(ABRecordRef)person; {
    [self addPerson:person andPicker:peoplePicker];    
}

-(void)addPerson:(ABRecordRef)person andPicker:(ABPeoplePickerNavigationController*)peoplePicker {
    ClientOBJ * client = [[ClientOBJ alloc] init];
    
    AddressOBJ * address = [[AddressOBJ alloc] init];
    
    id value = (__bridge id)(ABRecordCopyValue(person, kABPersonFirstNameProperty));
    [client setFirstName:value];
    
    value = (__bridge id)(ABRecordCopyValue(person, kABPersonLastNameProperty));
    [client setLastName:value];
    
    ABMultiValueRef ref = ABRecordCopyValue(person, kABPersonAddressProperty);
    
    if (ABMultiValueGetCount(ref) > 0) {
        CFStringRef valueRef = ABMultiValueCopyValueAtIndex(ref, 0);
        NSDictionary * tempValue = (__bridge NSDictionary *) valueRef;
        
        NSArray * array = [[tempValue objectForKey:@"Street"] componentsSeparatedByString:@"\n"];
        
        [address setAddressLine1:[array objectAtIndex:0]];
        
        if (array.count > 1) {
            [address setAddressLine2:[array objectAtIndex:1]];
        }
        
        if (array.count > 2) {
            [address setAddressLine3:[array objectAtIndex:2]];
        }
        
        [address setCity:[tempValue objectForKey:@"City"]];
        [address setCountry:[tempValue objectForKey:@"Country"]];
        [address setZIP:[tempValue objectForKey:@"ZIP"]];
        [address setState:[tempValue objectForKey:@"State"]];
    }
    
    ref = ABRecordCopyValue(person, kABPersonPhoneProperty);
    
    if (ABMultiValueGetCount(ref) > 0) {
        CFStringRef valueRef = ABMultiValueCopyValueAtIndex(ref, 0);
        NSString * tempValue = (__bridge NSString *) valueRef;
        tempValue = [tempValue stringByReplacingOccurrencesOfString:@"(" withString:@""];
        tempValue = [tempValue stringByReplacingOccurrencesOfString:@")" withString:@""];
        tempValue = [tempValue stringByReplacingOccurrencesOfString:@" " withString:@""];
        tempValue = [tempValue stringByReplacingOccurrencesOfString:@"-" withString:@""];
        [client setMobile:tempValue];
    }
    
    [client setBillingAddress:[address contentsDictionary]];
    [client setShippingAddress:[address contentsDictionary]];
    
    [peoplePicker dismissViewControllerAnimated:NO completion:nil];
  
  shouldClearArrays = NO;
    CreateOrEditClientVC * vc = [[CreateOrEditClientVC alloc] initWithClient:client delegate:self];
    UINavigationController * nvc = [[UINavigationController alloc] initWithRootViewController:vc];
    [nvc setNavigationBarHidden:YES];
    [self.navigationController presentViewController:nvc animated:YES completion:nil];
  shouldClearArrays = NO;
}

-(void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController*)peoplePicker {
	[peoplePicker dismissViewControllerAnimated:YES completion:nil];
}

-(BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController*)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person {
    [self addPerson:person andPicker:peoplePicker];
    
	return NO;
}

-(BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController*)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier {
	return NO;
}

#pragma mark - FUNCTIONS

-(void)createClient:(UIButton*)sender {
	[[[AlertView alloc] initWithButtons:self cancelButtonTitle:@"Cancel" otherButtonTitles:[NSArray arrayWithObjects:@"Create Contact", @"Contacts", nil]] showInWindow];
}

-(kClientCellType)clientTypeForIndexPath:(NSIndexPath *)indexPath {
  NSArray *productArray = [self clientsInSection:indexPath.section];
	if (indexPath.row == 0) {
		if (productArray.count == 1) {
			return kClientCellTypeSingle;
		} else {
			return kClientCellTypeTop;
		}
	} else {
		if (indexPath.row == productArray.count - 1) {
			return kClientCellTypeBottom;
		} else {
			return kClientCellTypeMiddle;
		}
	}
}

-(void)back:(UIButton*)sender {
  [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)isSelecting {
  return theInvoice || theQuote || theEstimate || thePurchareOrder || theProject || theReceipt || theTimesheet;
}

#pragma mark - CLIENT CREATOR DELEGATE

-(void)creatorViewController:(CreateOrEditClientVC*)viewController createdClient:(ClientOBJ*)client {
	[sync_manager updateCloud:[client contentsDictionary] andPurposeForDelete:1];
	
	[array_with_clients addObject:client];
	[self sortClients];
	[data_manager saveClientsArrayToUserDefaults:array_with_clients forKey:kClientsKeyForNSUserDefaults];
  
  [self setupSectionsDict];
  
	[clientsTableView reloadData];
}

#pragma mark - SCROLLVIEW DELEGATE

-(void)scrollViewDidScroll:(UIScrollView*)scrollView {
	if (clientsTableView && [clientsTableView respondsToSelector:@selector(didScroll)])
		[clientsTableView didScroll];
}

#pragma mark - TABLEVIEW DATASOURCE

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
  return [self sections];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView*)tableView {
  return [[sectionSortingDict allKeys] count];
}

-(NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section {
	return [[self clientsInSection:section] count];
}

-(UIView*)tableView:(UITableView*)tableView viewForHeaderInSection:(NSInteger)section {
  UIView * view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, dvc_width, 20)];
  [view setBackgroundColor:[UIColor clearColor]];
  
  UILabel * title = [[UILabel alloc] initWithFrame:CGRectMake(22, 0, dvc_width - 44, 20)];
  [title setTextAlignment:NSTextAlignmentLeft];
  [title setTextColor:app_title_color];
  [title setFont:HelveticaNeueMedium(15)];
  [title setBackgroundColor:[UIColor clearColor]];
  [view addSubview:title];
  
  title.text = [self sections][section];
  
  return view;
}

-(CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section {
  return 20.0f;
}

-(UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath {
	CellWithClient * theCell = [tableView dequeueReusableCellWithIdentifier:@"clientCell"];
	
	if (!theCell) {
		theCell = [[CellWithClient alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"clientCell"];
	}
	
	[theCell loadClient:[self clientAtIndexPath:indexPath] withType:[self clientTypeForIndexPath:indexPath]];
	
	if ([tableView isKindOfClass:[TableWithShadow class]]) {
		[(TableWithShadow*)tableView didScroll];
	}
	
	return theCell;
}

-(void)tableView:(UITableView*)tableView willDisplayCell:(UITableViewCell*)cell forRowAtIndexPath:(NSIndexPath*)indexPath {
	if (indexPath.row == 0) {
		if ([cell respondsToSelector:@selector(resize)]) {
			[(CellWithClient*)cell resize];
		}
	}
}

#pragma mark - TABLEVIEW DELEGATE

-(CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath {
//	if (indexPath.row == 0) {
//		return 62.0f;
//	} else {
		return 52.0f;
//	}
}

-(void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath {
  if([self isSelecting]) {
    ClientOBJ *selectedClient = [self clientAtIndexPath:indexPath];
    
    [theInvoice setClient:[selectedClient contentsDictionary]];
    [theInvoice setClientBillingTitleforKey:kInvoiceBillingAddressTitleKeyForNSUserDefaults
                                shippingKey:kInvoiceShippingAddressTitleKeyForNSUserDefaults];
    
    [theEstimate setClient:[selectedClient contentsDictionary]];
    [theEstimate setClientBillingTitleforKey:kEstimateBillingAddressTitleKeyForNSUserDefaults
                                 shippingKey:kEstimateShippingAddressTitleKeyForNSUserDefaults];
    
    [theQuote setClient:[selectedClient contentsDictionary]];
    [theQuote setClientBillingTitleforKey:kQuoteBillingAddressTitleKeyForNSUserDefaults
                              shippingKey:kQuoteShippingAddressTitleKeyForNSUserDefaults];
    
    [thePurchareOrder setClient:[selectedClient contentsDictionary]];
    [thePurchareOrder setClientBillingTitleforKey:kPurchaseBillingAddressTitleKeyForNSUserDefaults
                                      shippingKey:kPurchaseShippingAddressTitleKeyForNSUserDefaults];
    
    [theProject setClient:[selectedClient contentsDictionary]];
    [theReceipt setClient:selectedClient];
    [theTimesheet setClient:selectedClient];
    
    [self back:nil];
  } else {
    ClientDetailsVC * vc = [[ClientDetailsVC alloc] initWithClient:[self clientAtIndexPath:indexPath] atIndex:(int)[self indexOfObjectAtIndexPath:indexPath]];
    [self.navigationController pushViewController:vc animated:YES];
  }
}

-(BOOL)tableView:(UITableView*)tableView canEditRowAtIndexPath:(NSIndexPath*)indexPath {
	return YES;
}

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"Delete"  handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
      [sync_manager updateCloud:[[self clientAtIndexPath:indexPath] contentsDictionary] andPurposeForDelete:-1];
      
      [array_with_clients removeObjectAtIndex:[self indexOfObjectAtIndexPath:indexPath]];
    
      [self removeClientFromSectionsDictAtIndexPath:indexPath];
    
      [clientsTableView reloadData];
      
      [data_manager saveClientsArrayToUserDefaults:array_with_clients forKey:kClientsKeyForNSUserDefaults];
    }];
    
    return @[deleteAction];
}

-(void)tableView:(UITableView*)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath*)indexPath {
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		[sync_manager updateCloud:[[self clientAtIndexPath:indexPath] contentsDictionary] andPurposeForDelete:-1];
		
		[array_with_clients removeObjectAtIndex:[self indexOfObjectAtIndexPath:indexPath]];
    
    [self removeClientFromSectionsDictAtIndexPath:indexPath];
    
		[clientsTableView reloadData];
		
		[data_manager saveClientsArrayToUserDefaults:array_with_clients forKey:kClientsKeyForNSUserDefaults];
	}
}

#pragma mark - VIEW CONTROLLER FUNCTIONS

- (void)viewDidDisappear:(BOOL)animated {
  [super viewDidDisappear:animated];
  
  if(shouldClearArrays) {
    [self clearArrays];
  }
  shouldClearArrays = YES;
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  [array_with_clients removeAllObjects];
  array_with_clients = [NSMutableArray new];
  [array_with_clients addObjectsFromArray:[data_manager loadClientsArrayFromUserDefaultsAtKey:kClientsKeyForNSUserDefaults]];
  [self sortClients];
  
  [self setupSectionsDict];
  
  [clientsTableView reloadData];
}

-(void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	[clientsTableView reloadData];
}

-(void)sortClients {
	NSComparisonResult (^myComparator)(id, id) = ^NSComparisonResult(ClientOBJ * obj1, ClientOBJ * obj2) {
		return [[[obj1 firstName] uppercaseString] compare:[[obj2 firstName] uppercaseString]];
	};
	
	[array_with_clients sortUsingComparator:myComparator];
}

#pragma mark - Section Sorting methods

- (void)setupSectionsDict {
  [sectionSortingDict removeAllObjects];
  sectionSortingDict = [NSMutableDictionary new];
  
  __weak NSArray *clients = array_with_clients;
  
  if([clients count] == 0) return;
  
  for(ClientOBJ *client in clients) {
    NSString *title = [[[client firstName] substringToIndex:1] uppercaseString];
    if(!sectionSortingDict[title]) {
      NSMutableArray *sectionClients = [NSMutableArray arrayWithObject:client];
      [sectionSortingDict setObject:sectionClients forKey:title];
    } else {
      NSMutableArray *sectionClients = sectionSortingDict[title];
      [sectionClients addObject:client];
      [sectionSortingDict setObject:sectionClients forKey:title];
    }
  }
}

- (NSArray *)clientsInSection:(NSInteger)section {
  NSString *title = [[sectionSortingDict allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)][section];
  return sectionSortingDict[title];
}

- (ClientOBJ *)clientAtIndexPath:(NSIndexPath *)indexPath {
  NSString *title = [[sectionSortingDict allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)][indexPath.section];
  return [sectionSortingDict[title] objectAtIndex:indexPath.row];
}

- (void)removeClientFromSectionsDictAtIndexPath:(NSIndexPath *)indexPath {
  NSString *title = [[sectionSortingDict allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)][indexPath.section];
  NSMutableArray *sectionClients = sectionSortingDict[title];
  [sectionClients removeObjectAtIndex:indexPath.row];
  if([sectionClients count] == 0) {
    [sectionSortingDict removeObjectForKey:title];
  } else {
    [sectionSortingDict setObject:sectionClients forKey:title];
  }
}

- (NSArray *)sections {
  return [[sectionSortingDict allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
}

- (NSInteger)indexOfObjectAtIndexPath:(NSIndexPath *)indexPath {
  NSInteger index = 0;
  NSArray *sections = [self sections];
  for(int i = 0; i < indexPath.section; i++) {
    index += [sectionSortingDict[sections[i]] count];
  }
  index += indexPath.row;
  
  return index;
}

#pragma mark - Other methods

-(void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

-(void)dealloc {
	[clientsTableView setDelegate:nil];
  
  [self clearArrays];
}

- (void)clearArrays {
  [array_with_clients removeAllObjects];
  array_with_clients = nil;
  [sectionSortingDict removeAllObjects];
  sectionSortingDict = nil;
}

@end