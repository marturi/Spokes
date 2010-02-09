//
//  AutoCompleteViewController.h
//  SpokesCore_iPhone
//
//  Created by Matthew Arturi on 1/30/10.
//  Copyright 2010 8B Studio, Inc. All rights reserved.
//

#import <AddressBook/AddressBook.h>

@interface AutoCompleteViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
	NSMutableArray *autocompleteEntries;
	NSMutableArray *autocompleteEntriesLoading;
	
	ABAddressBookRef addressBook;
	NSInteger autocompleteThreshold;
}

@property (readwrite) NSInteger autocompleteThreshold;

- (void) searchAutocompleteEntriesWithSubstring:(NSString*)substring;
- (void) searchContactsWithSubstring:(NSString*)substring;
- (void) searchSavedAddressesWithSubstring:(NSString*)substring;
- (BOOL) textFieldShouldBeginEditing:(UITextField*)textField;
- (void) textFieldDidBeginEditing:(UITextField*)textField;
- (void) textFieldDidEndEditing:(UITextField*)textField;
- (BOOL) textField:(UITextField*)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString*)string;

@end
