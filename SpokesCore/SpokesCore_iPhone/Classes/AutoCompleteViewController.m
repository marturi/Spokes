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
		autocompleteEntriesLoading = [[NSMutableArray alloc] init];
		[autocompleteEntriesLoading removeAllObjects];

		addressBook = ABAddressBookCreate();
	}
	return self;
}

- (void) loadAddressBook {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	addressBook = ABAddressBookCreate();
	[pool drain];
}

- (void)loadView {
	self.view = [[[UITableView alloc] initWithFrame:CGRectMake(0, 123, 320, 121) style:UITableViewStylePlain] autorelease];
    ((UITableView*)self.view).delegate = self;
    ((UITableView*)self.view).dataSource = self;
    ((UITableView*)self.view).scrollEnabled = YES;
    self.view.hidden = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)searchAutocompleteEntriesWithSubstring:(NSString*)substring {
	if ([substring length] >= autocompleteThreshold) {
		[self searchSavedAddressesWithSubstring:substring];
		[self searchContactsWithSubstring:substring];
	} else {
		self.view.hidden = YES;
	}
}

- (void)searchContactsWithSubstring:(NSString*)substring {
	NSMutableArray *list = [[NSMutableArray alloc] init];
	NSArray *addresses = (NSArray*)ABAddressBookCopyPeopleWithName(addressBook, (CFStringRef)substring);
	NSInteger addressesCount = [addresses count];
	
	for (CFIndex i = 0; i < addressesCount; i++) {
		ABRecordRef record = [[addresses objectAtIndex:i] retain];
		ABMultiValueRef streets = ABRecordCopyValue(record, kABPersonAddressProperty);
		if(ABMultiValueGetCount(streets) > 0) {
			NSMutableString *str = [[NSMutableString alloc] init];
			for (CFIndex j = 0; j < ABMultiValueGetCount(streets); j++) {
				CFDictionaryRef dict = ABMultiValueCopyValueAtIndex(streets, j);
				NSString *street = [(NSString*)CFDictionaryGetValue(dict, kABPersonAddressStreetKey) copy];
				if(street) {
					NSString *fName = (NSString*)ABRecordCopyValue(record, kABPersonFirstNameProperty);
					NSString *lName = (NSString*)ABRecordCopyValue(record, kABPersonLastNameProperty);
					NSString *city = [(NSString*)CFDictionaryGetValue(dict, kABPersonAddressCityKey) copy];
					Person *pers = [[Person alloc] init];
					if(fName) {
						[str setString:fName];
					}
					if(fName && lName) {
						[str appendString:@" "];
					}
					if(lName) {
						[str appendString:lName];
					}
					pers.name = str;
					[str setString:street];
					if(city) {
						[str appendString:[NSString stringWithFormat:@", %@", city]];
					}
					pers.address = str;
					CFStringRef typeTmp = ABMultiValueCopyLabelAtIndex(streets, j);
					pers.type = (NSString*)ABAddressBookCopyLocalizedLabel(typeTmp);
					CFRelease(typeTmp);
					[list addObject:pers];
					[pers release];
					[city release];
					[fName release];
					[lName release];
				}
				CFRelease(dict);
				[street release];
			}
			[str release];
		}
		CFRelease(streets);
		CFRelease(record);
	}
	[addresses release];
    [self didReceiveItems:list];
	[list release];
}

- (void) searchSavedAddressesWithSubstring:(NSString*)substring {
	NSMutableArray *list = [[NSMutableArray alloc] init];
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSMutableArray *addresses = [NSMutableArray arrayWithArray:[defaults arrayForKey:@"addresses"]];
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
	[autocompleteEntriesLoading removeAllObjects];
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
	CFRelease(addressBook);
	[autocompleteEntriesLoading release];
	autocompleteEntriesLoading = nil;
	[autocompleteEntries release];
	autocompleteEntries = nil;
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	CFRelease(addressBook);
	[autocompleteEntriesLoading release];
	[autocompleteEntries release];
    [super dealloc];
}


@end
