//
//  ProductsVC.m
//  Invoice
//
//  Created by XGRoup5 on 8/13/13.
//  Copyright (c) 2013 XGRoup. All rights reserved.
//

#import "ProductsVC.h"

#import "Defines.h"
#import "CreateOrEditProductVC.h"
#import "ProductDetailsVC.h"
#import "CreateOrEditServiceVC.h"
#import "ServiceDetailsVC.h"
#import "ProductBaseOBJ.h"

@interface ProductsVC () <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, ProductCreatorDelegate, ServiceCreatorDelegate, AlertViewDelegate,CategorySelectDelegate> {
  BOOL shouldClearArrays;
}

@end

@implementation ProductsVC

-(id)init
{
	self = [super init];
	
	if (self)
	{
		categorySelected = 1;
		
		array_with_products = [[NSMutableArray alloc] init];
		array_with_services = [[NSMutableArray alloc] init];
    sectionSortingDict = [NSMutableDictionary new];
	}
	
	return self;
}

#pragma mark - VIEW DID LOAD

-(void)viewDidLoad {
	[super viewDidLoad];
	
  shouldClearArrays = YES;
  
	theSelfView = [[UIView alloc] initWithFrame:CGRectMake(0, statusBarHeight, dvc_width, dvc_height)];
	[theSelfView setBackgroundColor:[UIColor clearColor]];
	[self.view addSubview:theSelfView];
		
	[self.view setBackgroundColor:app_background_color];
	
	topBarView = [[TopBar alloc] initWithFrame:CGRectMake(0, 0, dvc_width, 42 + statusBarHeight) andTitle:@"Products and Services"];
	[topBarView setBackgroundColor:app_bar_update_color];
	
	UIButton * addProduct = [[UIButton alloc] initWithFrame:CGRectMake(dvc_width - 40, 42 + statusBarHeight - 40, 40, 40)];
	[addProduct setTitle:@"+" forState:UIControlStateNormal];
	[addProduct setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[addProduct setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
	[addProduct.titleLabel setFont:HelveticaNeueBold(33)];
	[addProduct setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 10, 0)];
	[addProduct addTarget:self action:@selector(createProduct:) forControlEvents:UIControlEventTouchUpInside];
	[topBarView addSubview:addProduct];
  
  if(_delegate) {
    BackButton * backButton = [[BackButton alloc] initWithFrame:CGRectMake(0, 42 + statusBarHeight - 40, 70, 40) andTitle:@"Back"];
    [backButton addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    [topBarView addSubview:backButton];
  }
	
	productsAndServicesTableView = [[TableWithShadow alloc] initWithFrame:CGRectMake(0, 42 + 40, dvc_width, dvc_height - 87 - 40) style:UITableViewStyleGrouped];
	[productsAndServicesTableView setDelegate:self];
	[productsAndServicesTableView setDataSource:self];
	[productsAndServicesTableView setSeparatorColor:[UIColor clearColor]];
	[productsAndServicesTableView setBackgroundColor:[UIColor clearColor]];
	[productsAndServicesTableView setBackgroundView:nil];
	[productsAndServicesTableView setTableHeaderView:[[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)]];
	[theSelfView addSubview:productsAndServicesTableView];
	
	[self.view addSubview:topBarView];
	
	categoryBar = [[CategorySelectV alloc] initWithFrame:CGRectMake(0, theSelfView.frame.origin.y + 52 - statusBarHeight, dvc_width, 30) andType:kProductAndServiceSelect andDelegate:self];
	categoryBar.backgroundColor = [UIColor clearColor];
	[theSelfView addSubview:categoryBar];
  
  productsAndServicesTableView.sectionIndexBackgroundColor = [UIColor clearColor];
  productsAndServicesTableView.sectionIndexMinimumDisplayRowCount = 2;
  productsAndServicesTableView.sectionIndexTrackingBackgroundColor = [UIColor colorWithWhite:0.5 alpha:0.2];
}

#pragma mark - ALERTVIEW DELEGATE

-(void)alertView:(AlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 1) {
    shouldClearArrays = NO;
		CreateOrEditProductVC * vc = [[CreateOrEditProductVC alloc] initWithProduct:nil index:0 delegate:self];
		UINavigationController * nvc = [[UINavigationController alloc] initWithRootViewController:vc];
		[nvc setNavigationBarHidden:YES];
		[self.navigationController presentViewController:nvc animated:YES completion:nil];
	} else if (buttonIndex == 2) {
    shouldClearArrays = NO;
		CreateOrEditServiceVC * vc = [[CreateOrEditServiceVC alloc] initWithService:nil index:0 delegate:self];
		UINavigationController * nvc = [[UINavigationController alloc] initWithRootViewController:vc];
		[nvc setNavigationBarHidden:YES];
		[self.navigationController presentViewController:nvc animated:YES completion:nil];
	}
}

#pragma mark - FUNCTIONS

-(void)createProduct:(UIButton*)sender
{
	[[[AlertView alloc] initWithTitle:@"New" message:@"What would you like to create?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:[NSArray arrayWithObjects:@"Product", @"Service", nil]] showInWindow];
}

-(kProductCellType)productTypeForIndexPath:(NSIndexPath *)index {
  NSArray *productArray = [self productsInSection:index.section];
	if (index.row == 0) {
		if (productArray.count == 1) {
			return kProductCellTypeSingle;
		} else {
			return kProductCellTypeTop;
		}
	} else {
		if (index.row == productArray.count - 1) {
			return kProductCellTypeBottom;
		} else {
			return kProductCellTypeMiddle;
		}
	}
}

-(kServiceCellType)serviceTypeForIndexPath:(NSIndexPath *)index {
  NSArray *productArray = [self productsInSection:index.section];
	if (index.row == 0) {
		if (productArray.count == 1) {
			return kServiceCellTypeSingle;
		} else {
			return kServiceCellTypeTop;
		}
	} else {
		if (index.row == productArray.count - 1) {
			return kServiceCellTypeBottom;
		} else {
			return kServiceCellTypeMiddle;
		}
	}
}

-(void)back:(UIButton*)sender {
  [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - PRODUCT CREATOR DELEGATE

-(void)creatorViewController:(CreateOrEditProductVC*)viewController createdObject:(ProductOBJ*)product {
	[sync_manager updateCloud:[product contentsDictionary] andPurposeForDelete:1];
	
	[array_with_products addObject:product];
	[self sortProducts];
	
	NSMutableArray * array = [[NSMutableArray alloc] init];
	[array addObjectsFromArray:array_with_products];
	[array addObjectsFromArray:array_with_services];
	
	[data_manager saveProductsArrayToUserDefaults:array forKey:kProductsKeyForNSUserDefaults];
  
  [self setupSectionsDict];
  
	[productsAndServicesTableView reloadData];
}

-(void)editorViewController:(CreateOrEditProductVC*)viewController editedObject:(ProductOBJ*)product atIndex:(NSInteger)index {
	[sync_manager updateCloud:[product contentsDictionary] andPurposeForDelete:0];
	
	[array_with_products replaceObjectAtIndex:index withObject:product];
	[self sortProducts];
	
	NSMutableArray * array = [[NSMutableArray alloc] init];
	[array addObjectsFromArray:array_with_products];
	[array addObjectsFromArray:array_with_services];
	
	[data_manager saveProductsArrayToUserDefaults:array forKey:kProductsKeyForNSUserDefaults];
  
  [self setupSectionsDict];
  
	[productsAndServicesTableView reloadData];
}

#pragma mark - SERVICE CREATOR DELEGATE

-(void)creatorViewController:(CreateOrEditServiceVC*)viewController createdService:(ServiceOBJ*)service {
	[sync_manager updateCloud:[service contentsDictionary] andPurposeForDelete:1];
	
	[array_with_services addObject:service];
	[self sortServices];
	
	NSMutableArray * array = [[NSMutableArray alloc] init];
	[array addObjectsFromArray:array_with_products];
	[array addObjectsFromArray:array_with_services];
	
	[data_manager saveProductsArrayToUserDefaults:array forKey:kProductsKeyForNSUserDefaults];
  
  [self setupSectionsDict];
  
	[productsAndServicesTableView reloadData];
}

-(void)editorViewController:(CreateOrEditServiceVC*)viewController editedService:(ServiceOBJ*)service atIndex:(NSInteger)index {
	[sync_manager updateCloud:[service contentsDictionary] andPurposeForDelete:0];
	
	[array_with_services replaceObjectAtIndex:index withObject:service];
	[self sortServices];
	
	NSMutableArray * array = [[NSMutableArray alloc] init];
	[array addObjectsFromArray:array_with_products];
	[array addObjectsFromArray:array_with_services];
	
	[data_manager saveProductsArrayToUserDefaults:array forKey:kProductsKeyForNSUserDefaults];
  
  [self setupSectionsDict];
  
	[productsAndServicesTableView reloadData];
}

#pragma mark - SCROLLVIEW DELEGATE

-(void)scrollViewDidScroll:(UIScrollView*)scrollView {
	if (productsAndServicesTableView && [productsAndServicesTableView respondsToSelector:@selector(didScroll)])
		[productsAndServicesTableView didScroll];
}

#pragma mark - TABLEVIEW DATASOURCE

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
  return [self sections];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView*)tableView {
	return [[sectionSortingDict allKeys] count];
}

-(NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section {
  return [[self productsInSection:section] count];
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
	if(categorySelected == 1) {
		CellWithProduct * theCell = [tableView dequeueReusableCellWithIdentifier:@"productCell"];
		
		if (!theCell) {
			theCell = [[CellWithProduct alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"productCell"];
		}
		
		[theCell loadProduct:(ProductOBJ*)[self productAtIndexPath:indexPath] withType:[self productTypeForIndexPath:indexPath]];
		
		if ([tableView isKindOfClass:[TableWithShadow class]]) {
			[(TableWithShadow*)tableView didScroll];
		}
		
		return theCell;
	}
	
	CellWithService * theCell = [tableView dequeueReusableCellWithIdentifier:@"serviceCell"];
	
	if (!theCell) {
		theCell = [[CellWithService alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"serviceCell"];
	}
	
	[theCell loadService:(ServiceOBJ*)[self productAtIndexPath:indexPath] withType:[self serviceTypeForIndexPath:indexPath]];
	
	if ([tableView isKindOfClass:[TableWithShadow class]]) {
		[(TableWithShadow*)tableView didScroll];
	}
	
	return theCell;
}

-(void)tableView:(UITableView*)tableView willDisplayCell:(UITableViewCell*)cell forRowAtIndexPath:(NSIndexPath*)indexPath {
	if (indexPath.row == 0) {
		if ([cell respondsToSelector:@selector(resize)]) {
			if ([cell isKindOfClass:[CellWithProduct class]])
				[(CellWithProduct*)cell resize];
			
			if ([cell isKindOfClass:[CellWithService class]])
				[(CellWithService*)cell resize];
		}
	}
}

#pragma mark - TABLEVIEW DELEGATE

-(CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath {
//	if (indexPath.row == 0) {
//		return 52.0f;
//	} else {
		return 42.0f;
//	}
}

-(void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath {
	if(categorySelected == 1) {
    if(_delegate) {
      ProductOBJ *selectedProduct = (ProductOBJ *)[self productAtIndexPath:indexPath];
      selectedProduct.indexInCollection = [self indexOfObjectAtIndexPath:indexPath];
      [_delegate viewController:self selectedProduct:selectedProduct];
      [self back:nil];
    } else {
      ProductDetailsVC * vc = [[ProductDetailsVC alloc] initWithProduct:(ProductOBJ*)[self productAtIndexPath:indexPath] atIndex:(int)[self indexOfObjectAtIndexPath:indexPath]];
      [self.navigationController pushViewController:vc animated:YES];
    }
	} else {
    if(_delegate) {
      ServiceOBJ *selectedService = (ServiceOBJ *)[self productAtIndexPath:indexPath];
      selectedService.indexInCollection = [self indexOfObjectAtIndexPath:indexPath];
      [_delegate viewController:self selectedService:selectedService];
      [self back:nil];
    } else {
      ServiceDetailsVC * vc = [[ServiceDetailsVC alloc] initWithService:(ServiceOBJ*)[self productAtIndexPath:indexPath] atIndex:(int)[self indexOfObjectAtIndexPath:indexPath]];
      [self.navigationController pushViewController:vc animated:YES];
    }
	}
}

-(BOOL)tableView:(UITableView*)tableView canEditRowAtIndexPath:(NSIndexPath*)indexPath {
	return YES;
}

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"Delete"  handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
      if(categorySelected == 1) {
          [sync_manager updateCloud:[[self productAtIndexPath:indexPath] contentsDictionary] andPurposeForDelete:-1];
          [array_with_products removeObjectAtIndex:[self indexOfObjectAtIndexPath:indexPath]];
      } else {
          [sync_manager updateCloud:[[self productAtIndexPath:indexPath] contentsDictionary] andPurposeForDelete:-1];
          [array_with_services removeObjectAtIndex:[self indexOfObjectAtIndexPath:indexPath]];
      }
      
      NSMutableArray * array = [[NSMutableArray alloc] init];
      [array addObjectsFromArray:array_with_products];
      [array addObjectsFromArray:array_with_services];
      
      [data_manager saveProductsArrayToUserDefaults:array forKey:kProductsKeyForNSUserDefaults];
    
      [self removeProductFromSectionsDictAtIndexPath:indexPath];
      
      [productsAndServicesTableView reloadData];
    }];
    
    return @[deleteAction];
}

-(void)tableView:(UITableView*)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath*)indexPath {
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		if(categorySelected == 1) {
			[sync_manager updateCloud:[[self productAtIndexPath:indexPath] contentsDictionary] andPurposeForDelete:-1];
			[array_with_products removeObjectAtIndex:[self indexOfObjectAtIndexPath:indexPath]];
		} else {
			[sync_manager updateCloud:[[self productAtIndexPath:indexPath] contentsDictionary] andPurposeForDelete:-1];
			[array_with_services removeObjectAtIndex:[self indexOfObjectAtIndexPath:indexPath]];
		}
				
		NSMutableArray * array = [[NSMutableArray alloc] init];
		[array addObjectsFromArray:array_with_products];
		[array addObjectsFromArray:array_with_services];
		
		[data_manager saveProductsArrayToUserDefaults:array forKey:kProductsKeyForNSUserDefaults];
    
    [self removeProductFromSectionsDictAtIndexPath:indexPath];
        
    [productsAndServicesTableView reloadData];
	}
}

#pragma mark - CATEGORY BAR DELEGATE

-(void)categorySelectDelegate:(CategorySelectV *)view selectedCategory:(int)category {
	categorySelected = category;
	
	[self createArrays];
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
  
  [self createArrays];
}

-(void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
//	[self createArrays];
  [productsAndServicesTableView reloadData];
}

-(void)createArrays {
	[array_with_products removeAllObjects];
  array_with_products = [NSMutableArray new];
	[array_with_services removeAllObjects];
  array_with_services = [NSMutableArray new];
  [sectionSortingDict removeAllObjects];
  sectionSortingDict = [NSMutableDictionary new];
	
	NSArray * array = [data_manager loadProductsArrayFromUserDefaultsAtKey:kProductsKeyForNSUserDefaults];
	
	for (NSObject * temp in array) {
		if ([temp isKindOfClass:[ProductOBJ class]]) {
			[array_with_products addObject:temp];
			[self sortProducts];
		} else if ([temp isKindOfClass:[ServiceOBJ class]]) {
			[array_with_services addObject:temp];
			[self sortServices];
		}
	}
  
  [self setupSectionsDict];
  
  [self indexOfObjectAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
	
	[productsAndServicesTableView reloadData];
}

-(void)sortProducts {
	NSComparisonResult (^myComparator)(id, id) = ^NSComparisonResult(ProductOBJ * obj1, ProductOBJ * obj2) {
		return [[[obj1 name] uppercaseString] compare:[[obj2 name] uppercaseString]];
	};
	
	[array_with_products sortUsingComparator:myComparator];
}

-(void)sortServices {
	NSComparisonResult (^myComparator)(id, id) = ^NSComparisonResult(ServiceOBJ * obj1, ServiceOBJ * obj2) {
		return [[[obj1 name] uppercaseString] compare:[[obj2 name] uppercaseString]];
	};
	
	[array_with_services sortUsingComparator:myComparator];
}

#pragma mark - Section Sorting methods

- (void)setupSectionsDict {
  [sectionSortingDict removeAllObjects];
  
  __weak NSArray *products = categorySelected == 1?array_with_products:array_with_services;
  
  if([products count] == 0) return;
  
  for(ProductBaseOBJ *product in products) {
    NSString *prodName = [[product name] length] > 0?[product name]:@"a";
    
    NSString *title = [[prodName substringToIndex:1] uppercaseString];
    if(!sectionSortingDict[title]) {
      NSMutableArray *sectionProducts = [NSMutableArray arrayWithObject:product];
      [sectionSortingDict setObject:sectionProducts forKey:title];
    } else {
      NSMutableArray *sectionProducts = sectionSortingDict[title];
      [sectionProducts addObject:product];
      [sectionSortingDict setObject:sectionProducts forKey:title];
    }
  }
}

- (NSArray *)productsInSection:(NSInteger)section {
  NSString *title = [[sectionSortingDict allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)][section];
  return sectionSortingDict[title];
}

- (ProductBaseOBJ *)productAtIndexPath:(NSIndexPath *)indexPath {
  NSString *title = [[sectionSortingDict allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)][indexPath.section];
  return [sectionSortingDict[title] objectAtIndex:indexPath.row];
}

- (void)removeProductFromSectionsDictAtIndexPath:(NSIndexPath *)indexPath {
  NSString *title = [[sectionSortingDict allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)][indexPath.section];
  NSMutableArray *sectionProducts = sectionSortingDict[title];
  [sectionProducts removeObjectAtIndex:indexPath.row];
  if([sectionProducts count] == 0) {
    [sectionSortingDict removeObjectForKey:title];
  } else {
    [sectionSortingDict setObject:sectionProducts forKey:title];
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
	[productsAndServicesTableView setDelegate:nil];
  
}

- (void)clearArrays {
  [array_with_products removeAllObjects];
  array_with_products = nil;
  [array_with_services removeAllObjects];
  array_with_services = nil;
  [sectionSortingDict removeAllObjects];
  sectionSortingDict = nil;
}

@end