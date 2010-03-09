//
//  AutoCompleteViewController.m
//  SpokesCore_iPhone
//
//  Created by Matthew Arturi on 1/30/10.
//  Copyright 2010 8B Studio, Inc. All rights reserved.
//

#import "AutoCompleteViewController.h"
#import "Person.h"

@interface AutoCompleteViewController()

- (void) didReceiveItems:(NSArray*)items;

@end


@implementation AutoCompleteViewController

@synthesize autocompleteThreshold;

- (id)init {
	if (self = [super init]) {
		self.autocompleteThreshold = 1;
	}
	return self;
}

- (void)loadView {
	self.view = [[[UITableView alloc] initWithFrame:CGRectMake(0, 123, 320, 121) style:UITableViewStylePlain] autorelease];
    ((UITableView*)self.view).delegate = self;
    ((UITableView*)self.view).dataSource = self;
    ((UITableView*)self.view).scrollEnabled = YES;
    self.view.hidden = YES;
	autocompleteEntriesLoading = [[NSMutableArray alloc] init];
	[autocompleteEntriesLoading removeAllObjects];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)searchAutocompleteEntriesWithSubstring:(NSString*)substring {
	if ([substring length] >= autocompleteThreshold) {
		[self searchSavedAddressesWithSubstring:substring];
	} else {
		self.view.hidden = YES;
	}
}

- (void) searchSavedAddressesWithSubstring:(NSString*)substring {
	NSMutableArray *list = [[NSMutableArray alloc] init];
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSMutableArray *addresses = [NSMutableArray arrayWithArray:[defaults arrayForKey:@"addresses"]];
	[addresses addObject:@"Current Location|"];
	for(NSString *address in addresses) {
		NSArray *listItems = [address componentsSeparatedByString:@"|"];
		int cnt = [listItems count];
		if(cnt > 0) {
			if([[listItems objectAtIndex:0] rangeOfString:substring options:NSCaseInsensitiveSearch].location == 0) {
				Person *pers = [[Person alloc] init];
				pers.name = [listItems objectAtIndex:0];
				if(cnt == 3) {
					CLLocationCoordinate2D coord = {[[listItems objectAtIndex:1] doubleValue], [[listItems objectAtIndex:2] doubleValue]};
					pers.coord = coord;
				}
				[list addObject:pers];
				[pers release];
			}
		}
	}
	[self didReceiveItems:list];
	[list release];
}

- (void) didReceiveItems:(NSArray*)items {
    [autocompleteEntriesLoading addObjectsFromArray:items];
	[autocompleteEntries release];
	autocompleteEntries = [[NSMutableArray alloc] initWithArray:autocompleteEntriesLoading];
	[autocompleteEntries sortUsingSelector:@selector(compareEntry:)];
        
	if ([autocompleteEntries count]) {
		self.view.hidden = NO;
	} else {
		self.view.hidden = YES;
	}
	[((UITableView*)self.view) reloadData];
}

// Text field delegate stuff
- (BOOL)textFieldShouldBeginEditing:(UITextField*)textField {
	[autocompleteEntriesLoading removeAllObjects];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField*)textField {
    [((UITableView*)self.view) reloadData];
}

- (void)textFieldDidEndEditing:(UITextField*)textField {
    self.view.hidden = YES;
}

- (BOOL)textField:(UITextField*)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString*)string {
    NSString *substring = [NSString stringWithString:textField.text];
    substring = [substring stringByReplacingCharactersInRange:range withString:string];
	[self searchAutocompleteEntriesWithSubstring:substring];
	[((UITableView*)self.view) reloadData];
	[autocompleteEntriesLoading removeAllObjects];
    return YES;
}

# pragma mark Table View Delegation and dataSource

- (UITableViewCell*)tableView:(UITableView*)newTableView cellForRowAtIndexPath:(NSIndexPath*)indexPath {
    AutocompleteEntry *currentEntry = [[autocompleteEntries objectAtIndex:indexPath.row] retain];
	
	UITableViewCell *cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero] autorelease];
	
	[cell setSelectionStyle:UITableViewCellSelectionStyleGray];
	UILabel *mainLabel = [[[UILabel alloc] initWithFrame:CGRectMake(40, 4, 250, 15)] autorelease];
	UILabel *auxLabel = [[[UILabel alloc] initWithFrame:CGRectMake(40, 21, 50, 15)] autorelease];
    UILabel *auxValue = [[[UILabel alloc] initWithFrame:CGRectMake(90, 21, 200, 15)] autorelease];
	mainLabel.text = currentEntry.name;
	mainLabel.font = [UIFont boldSystemFontOfSize:14];
	auxLabel.text = currentEntry.auxlabel;
	auxLabel.font = [UIFont boldSystemFontOfSize:12];
	auxLabel.textColor = [UIColor grayColor];
    auxValue.text = currentEntry.aux;
    auxValue.font = [UIFont systemFontOfSize:12];
    auxValue.textColor = [UIColor grayColor];
	[cell addSubview:mainLabel];
	[cell addSubview:auxLabel];
    [cell addSubview:auxValue];
    
    [currentEntry release];
    
    return cell;
}

- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40;
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath {
	Person *currentEntry = [autocompleteEntries objectAtIndex:indexPath.row];
	NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObject:currentEntry forKey:@"selectedAddress"];
	NSNotification *notification = [NSNotification notificationWithName:@"AutocompleteSelected" object:nil userInfo:params];
	[[NSNotificationCenter defaultCenter] postNotification:notification];
	[autocompleteEntries removeAllObjects];
	[((UITableView*)self.view) reloadData];
    ((UITableView*)self.view).hidden = YES;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section {
    return autocompleteEntries.count;
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
	[autocompleteEntriesLoading release];
	autocompleteEntriesLoading = nil;
	[autocompleteEntries release];
	autocompleteEntries = nil;
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[autocompleteEntriesLoading release];
	[autocompleteEntries release];
    [super dealloc];
}


@end
