#import "DeNadolleDoubleCommandPrefsPane.h" 
#import <Security/AuthorizationTags.h>
// #import <sys/param.h>
#import <sys/sysctl.h>
#import <CoreFoundation/CFPreferences.h>
#import "KeyboardListUtility.h"


@implementation DeNadolleDoubleCommandPrefsPane


#pragma mark -
#pragma mark Button Handlers
//  --------------------------------------------------------------------------------------
//	Save the settings to disk and preferences.
//
- (IBAction)saveSettingsPressed:(id)sender {
	[KeyboardListUtility saveToPrefs:keyboardList];
}

//  --------------------------------------------------------------------------------------
//	Revert the current keyboard setting to the orignal settings before last save.
//
- (IBAction)revertSettingsPressed:(id)sender {
	int currentRow = [mKeyboardTable selectedRow];
	if (currentRow >= 0){
		//get the old config and save it in the dictionary
		NSMutableDictionary* kbdObj = [keyboardList objectAtIndex:currentRow];
		int originalConfig = [[kbdObj objectForKey:@"configID"] intValue];
		[kbdObj setObject:[NSNumber numberWithInt:originalConfig] forKey:@"newConfigID"];

		//apply the new settings
		mEditVal = originalConfig;
		[self refreshCheckBoxes];
		//if we add the column for current config in the tableview this will be handy to refresh the data
		//[mKeyboardTable reloadData];
	}
}

//  --------------------------------------------------------------------------------------
//  all checkboxes off, please
//
- (IBAction)allOffPressed:(id)sender {
	if (mEditVal != 0) {
		mEditVal = 0;
		int i;
		for (i = 0; i <= DCP_lastusedbit; i++) {
			id theCell = [checkBoxes cellWithTag: i];
			[theCell setState: FALSE];
		}
	}
	[editVal setStringValue: [NSString stringWithFormat:@"%d", mEditVal]];
}



//  --------------------------------------------------------------------------------------
//  somebody clicked on a checkbox
//
- (IBAction)checkBoxClicked:(id)sender {
	id cell = [sender selectedCell];
	int bit = [cell tag];
	BOOL setOn = ([cell state] == NSOnState);
	
	
	if ([self isBitSet:bit] != setOn) {
		int val = 1 << bit;
		int remove;
		if (setOn) {
		
		
			//Added by Sastira - sastira@gmail.com
			//This code will automatically deselect conflicting options in the preference pane.
			//Please note: I learned Objective-C yesterday, so there may be a much better way of doing this.
			switch(bit)
			{
				case CAPSLOCK_TO_CONTROL:
				case CAPSLOCK_TO_DELETE:
				case CAPSLOCK_TO_FORWARD_DELETE:
				case DISABLE_CAPSLOCK:
				{
					if (bit != CAPSLOCK_TO_CONTROL && [[checkBoxes cellWithTag:CAPSLOCK_TO_CONTROL] state] == NSOnState) 
					{
						remove = 1 << CAPSLOCK_TO_CONTROL;
						mEditVal &= (~remove);
						[[checkBoxes cellWithTag:CAPSLOCK_TO_CONTROL] setState: FALSE];				
					}
					if (bit != CAPSLOCK_TO_DELETE && [[checkBoxes cellWithTag:CAPSLOCK_TO_DELETE] state] == NSOnState)
					{
						remove = 1 << CAPSLOCK_TO_DELETE;
						mEditVal &= (~remove);
						[[checkBoxes cellWithTag:CAPSLOCK_TO_DELETE] setState: FALSE];	
					}
					if (bit != CAPSLOCK_TO_FORWARD_DELETE && [[checkBoxes cellWithTag:CAPSLOCK_TO_FORWARD_DELETE] state] == NSOnState) 
					{
						remove = 1 << CAPSLOCK_TO_FORWARD_DELETE;
						mEditVal &= (~remove);
						[[checkBoxes cellWithTag:CAPSLOCK_TO_FORWARD_DELETE] setState: FALSE];					
					}
					if (bit != DISABLE_CAPSLOCK && [[checkBoxes cellWithTag:DISABLE_CAPSLOCK] state] == NSOnState) 
					{
						remove = 1 << DISABLE_CAPSLOCK;
						mEditVal &= (~remove);
						[[checkBoxes cellWithTag:DISABLE_CAPSLOCK] setState: FALSE];					
					}					
				}
				break;
					
				case OPTION_R_TO_CONTROL:
				case OPTION_R_TO_FORWARD_DELETE:
				case OPTION_R_TO_ENTER:
				case DISABLE_COMMAND_AND_OPTION:
				{
					if (bit != OPTION_R_TO_CONTROL && [[checkBoxes cellWithTag:OPTION_R_TO_CONTROL] state] == NSOnState) 
					{
						remove = 1 << OPTION_R_TO_CONTROL;
						mEditVal &= (~remove);
						[[checkBoxes cellWithTag:OPTION_R_TO_CONTROL] setState: FALSE];					
					}
					if (bit != OPTION_R_TO_FORWARD_DELETE && [[checkBoxes cellWithTag:OPTION_R_TO_FORWARD_DELETE] state] == NSOnState) 
					{
						remove = 1 << OPTION_R_TO_FORWARD_DELETE;
						mEditVal &= (~remove);
						[[checkBoxes cellWithTag:OPTION_R_TO_FORWARD_DELETE] setState: FALSE];					
					}
					if (bit != DISABLE_COMMAND_AND_OPTION && [[checkBoxes cellWithTag:DISABLE_COMMAND_AND_OPTION] state] == NSOnState) 
					{
						remove = 1 << DISABLE_COMMAND_AND_OPTION;
						mEditVal &= (~remove);
						[[checkBoxes cellWithTag:DISABLE_COMMAND_AND_OPTION] setState: FALSE];					
					}					
					if (bit != OPTION_R_TO_ENTER && [[checkBoxes cellWithTag:OPTION_R_TO_ENTER] state] == NSOnState) 
					{
						remove = 1 << OPTION_R_TO_ENTER;
						mEditVal &= (~remove);
						[[checkBoxes cellWithTag:OPTION_R_TO_ENTER] setState: FALSE];					
					}					
				}
				break;
			
			case ENTER_TO_COMMAND:		
			case ENTER_TO_CONTROL:			
			case ENTER_TO_OPTION:				
			case ENTER_TO_FUNCTION:			
			case ENTER_TO_FORWARD_DELETE:
				{
					if (bit != ENTER_TO_COMMAND && [[checkBoxes cellAtRow:0 column:0] state] == NSOnState) 
					{
						remove = 1 << ENTER_TO_COMMAND;
						mEditVal &= (~remove);
						[[checkBoxes cellAtRow:0 column:0] setState: FALSE];					
					}
					if (bit != ENTER_TO_CONTROL && [[checkBoxes cellWithTag:ENTER_TO_CONTROL] state] == NSOnState) 
					{
						remove = 1 << ENTER_TO_CONTROL;
						mEditVal &= (~remove);
						[[checkBoxes cellWithTag:ENTER_TO_CONTROL] setState: FALSE];					
					}
					if (bit != ENTER_TO_OPTION && [[checkBoxes cellWithTag:ENTER_TO_OPTION] state] == NSOnState) 
					{
						remove = 1 << ENTER_TO_OPTION;
						mEditVal &= (~remove);
						[[checkBoxes cellWithTag:ENTER_TO_OPTION] setState: FALSE];					
					}
					if (bit != ENTER_TO_FUNCTION && [[checkBoxes cellWithTag:ENTER_TO_FUNCTION] state] == NSOnState) 
					{
						remove = 1 << ENTER_TO_FUNCTION;
						mEditVal &= (~remove);
						[[checkBoxes cellWithTag:ENTER_TO_FUNCTION] setState: FALSE];					
					}
					if (bit != ENTER_TO_FORWARD_DELETE && [[checkBoxes cellWithTag:ENTER_TO_FORWARD_DELETE] state] == NSOnState) 
					{
						remove = 1 << ENTER_TO_FORWARD_DELETE;
						mEditVal &= (~remove);
						[[checkBoxes cellWithTag:ENTER_TO_FORWARD_DELETE] setState: FALSE];					
					}
				}
				break;
				
				case COMMAND_TO_OPTION:
				case COMMAND_TO_CONTROL:
				{
					if (bit != COMMAND_TO_OPTION && [[checkBoxes cellWithTag:COMMAND_TO_OPTION] state] == NSOnState) 
					{
						remove = 1 << COMMAND_TO_OPTION;
						mEditVal &= (~remove);
						[[checkBoxes cellWithTag:COMMAND_TO_OPTION] setState: FALSE];					
					}					
					if (bit != COMMAND_TO_CONTROL && [[checkBoxes cellWithTag:COMMAND_TO_CONTROL] state] == NSOnState) 
					{
						remove = 1 << COMMAND_TO_CONTROL;
						mEditVal &= (~remove);
						[[checkBoxes cellWithTag:COMMAND_TO_CONTROL] setState: FALSE];					
					}
				}
				
				case SHIFT_DELETE_TO_FORWARD_DELETE:
				case SWAP_DELETE_AND_FORWARD_DELETE:
				{		
					if (bit != SHIFT_DELETE_TO_FORWARD_DELETE && [[checkBoxes cellWithTag:SHIFT_DELETE_TO_FORWARD_DELETE] state] == NSOnState) 
					{
						remove = 1 << SHIFT_DELETE_TO_FORWARD_DELETE;
						mEditVal &= (~remove);
						[[checkBoxes cellWithTag:SHIFT_DELETE_TO_FORWARD_DELETE] setState: FALSE];					
					}
					if (bit != SWAP_DELETE_AND_FORWARD_DELETE && [[checkBoxes cellWithTag:SWAP_DELETE_AND_FORWARD_DELETE] state] == NSOnState) 
					{
						remove = 1 << SWAP_DELETE_AND_FORWARD_DELETE;
						mEditVal &= (~remove);
						[[checkBoxes cellWithTag:SWAP_DELETE_AND_FORWARD_DELETE] setState: FALSE];					
					}					
				}
				break;
			}
			//End addition by Sastira
			
			mEditVal |= val;
		} else {
			mEditVal &= (~val);
		}
	}
	[editVal setStringValue: [NSString stringWithFormat:@"%d", mEditVal]];
	[self saveCheckboxSelectionToCurrentConfig];
}



//  --------------------------------------------------------------------------------------
//  User wants to save user prefs
//
- (IBAction)setUserPressed:(id)sender {
	//mUserVal = mEditVal;
	return;
	if (! [self writeUserSettings]) {
		NSRunAlertPanel(@"DoubleCommand Prefs",
			@"Could not write your user prefs. Sorry.",
			@"Oh dear", nil,  nil);
	}
	[self readUserSettings];
}

//  --------------------------------------------------------------------------------------
//  User wants to save system prefs
//
- (IBAction)setSystemPressed:(id)sender {
	return;
	mSystemVal = mEditVal;
	OSStatus err = [self writeSystemSettings];
	if ( (err != 0) && (err != errAuthorizationCanceled)) {
		NSString * errStr = [NSString stringWithFormat: @"Could not write system prefs, error: %d", err];
		NSRunAlertPanel(@"DoubleCommand Prefs",
			errStr,
			@"Oh dear", nil,  nil);
	}
	
	// read again
	// but it seems that we need to wait a litte 
	// or else we would read the old value again before the new one was saved.

	NSTimeInterval waitingTime = 0.1;                      // half a second
	NSDate *recoverDate = [[NSDate date] addTimeInterval:waitingTime + [[NSDate date] timeIntervalSinceNow]];
	[NSThread sleepUntilDate: recoverDate];                 // Blocks the current thread 	
	
	[self readSystemSettings];
	
	
}

		

//  --------------------------------------------------------------------------------------
//  User wants to activate active prefs
//
- (IBAction)setActivePressed:(id)sender {
	return;
	mActiveVal = mEditVal;
	OSStatus err = [self writeActiveSettings];
	if (err) {
		NSString * errStr = [NSString stringWithFormat: @"Could not activate settings, error: %d", err];
		NSRunAlertPanel(@"DoubleCommand Prefs",
			errStr,
			@"Oh dear", nil,  nil);
	}
	[self readActiveSettings];
}

#pragma mark -
#pragma mark Main
//  --------------------------------------------------------------------------------------
//  we were just loaded 
//
- (void)mainViewDidLoad {
	mAuthRef = nil;
	mUserPrefPath = NSHomeDirectory();
	mUserPrefPath = [mUserPrefPath stringByAppendingPathComponent: userPrefsRelPath];
	[mUserPrefPath retain];
	
	if (! [self readActiveSettings]) {
		NSRunAlertPanel(@"DoubleCommand Prefs",
			@"DoubleCommand seems not to be running at the moment.\nYou can save prefs but can't activate settings.\nMaybe you need to reinstall...",
			@"Oh dear", nil,  nil);
	}
	// the other prefs will be fetched in didSelect in a tick :)
	
	//load the keyboards from the prefs file and the io registry.
	keyboardList = [[KeyboardListUtility keyboards] retain];
	[mKeyboardTable reloadData];
}


//  --------------------------------------------------------------------------------------
//  every time the prefs gets selected
//
- (void) didSelect {
	[self readSystemSettings];
	[self readUserSettings];
	[self readActiveSettings];
	mEditVal = mActiveVal;
	[self refreshCheckBoxes];
}


//  --------------------------------------------------------------------------------------
//  check a bit in mEditValue
//
- (BOOL)isBitSet:(int)bit {
	return ((mEditVal & (1 << bit)) != 0);
}

#pragma mark -
#pragma mark Settings IO
//  --------------------------------------------------------------------------------------
//  read System Prefs from the preferences
//
- (BOOL) readSystemSettings {
	return YES;
	NSFileManager *manager = [NSFileManager defaultManager];
	BOOL hasSettings = YES;
	if ([manager fileExistsAtPath: systemPrefsPath]) {
		NSString *thePrefsStr = [ NSString stringWithContentsOfFile:systemPrefsPath encoding:NSUTF8StringEncoding error:NULL];
		mSystemVal = [thePrefsStr intValue];
		[systemVal setStringValue: [NSString stringWithFormat:@"%d", mSystemVal]];
	} else {
		mSystemVal = 0;
		[systemVal setStringValue:@"n/a"];
		hasSettings = NO;
	}
	[showSystemButton setEnabled:hasSettings];
	return hasSettings;
}

//  --------------------------------------------------------------------------------------
//  write System prefs to Disk and preferences 
//
- (OSStatus) writeSystemSettings {
	return 0;
	OSStatus err = 0;
	
	if (mAuthRef == nil) {
		err = [self tryAuthorization];
	}
	if (! err) {
		const char * const args[] = { [[NSString stringWithFormat:@"dc.config=%d", mSystemVal] UTF8String], NULL };
		err = AuthorizationExecuteWithPrivileges (mAuthRef, [sysPrefsWriteTool UTF8String], 
										kAuthorizationFlagDefaults, (char * const *) args, nil);
	}
	return err;
}


//  --------------------------------------------------------------------------------------
//  read User Prefs from preferences
//
- (BOOL) readUserSettings {
	return YES;
	NSFileManager *manager = [NSFileManager defaultManager];
	BOOL hasSettings = YES;
	if ([manager fileExistsAtPath: mUserPrefPath]) {
		NSString *thePrefsStr = [ NSString stringWithContentsOfFile:mUserPrefPath encoding:NSUTF8StringEncoding error:NULL];
		mUserVal = [thePrefsStr intValue];
		[userVal setStringValue: [NSString stringWithFormat:@"%d", mUserVal]];
	} else {
		mUserVal = 0;
		[userVal setStringValue:@"n/a"];
		hasSettings = NO;
	}
	[showUserButton setEnabled:hasSettings];
	return hasSettings;
}


//  --------------------------------------------------------------------------------------
//  write User Prefs to Disk and preferences. 
//
- (BOOL) writeUserSettings
{
	int i;
    BOOL ret = NO;

	NSDictionary* currentKbd = [keyboardList objectAtIndex:0];
	NSNumber* globalConfigID = [currentKbd objectForKey:@"dc.configID"];
	NSMutableString * thePrefs = [NSMutableString stringWithFormat: @"dc.config=%d", [globalConfigID intValue]];
	
	for (i = 1; i <= MAX_NUM_KEYBOARDS && i < [keyboardList count] ; i++) {
		NSDictionary* currentKbd = [keyboardList objectAtIndex:i];
		if (![[currentKbd objectForKey:@"deleted"] boolValue]) {
			
			NSNumber * kbdID = [currentKbd objectForKey:@"dc.keyboardID"];
			NSNumber * configID = [currentKbd objectForKey:@"dc.configID"];
			
			[thePrefs stringByAppendingFormat:@" dc.config%d=%d dc.keyboardid%d=%d", i, [configID intValue], i, [kbdID intValue]];			
		}
	}
	ret = [thePrefs writeToFile:mUserPrefPath atomically:YES encoding:NSUTF8StringEncoding error:NULL];
    return ret;
}


//  --------------------------------------------------------------------------------------
//  read Active Settings from sysctl
//
- (BOOL) readActiveSettings {
	BOOL hasSettings = YES;
	return YES;
	char *name = "dc.config";
	size_t len = 4;
	int errCode = 0;
	int val = 0;

    errCode = sysctlbyname(name, &val, &len, NULL, 0);

    if(errCode == 0)  {
		mActiveVal = (unsigned int)val;
		[activeVal setStringValue: [NSString stringWithFormat:@"%d", mActiveVal]];
	} else {
		mActiveVal = 0;
		hasSettings = NO;
		[activeVal setStringValue:@"n/a"];
	}

	[showActiveButton setEnabled:hasSettings];
	[setActiveButton setEnabled:hasSettings];
	return hasSettings;
}


//  --------------------------------------------------------------------------------------
//  write Active Settings to sysctl
//
- (OSStatus) writeActiveSettings {
	return 0;
    char *name = "dc.config";
    u_int len = 4;
    OSStatus errCode = 0;

    errCode = sysctlbyname(name, NULL, 0, &mActiveVal, len);
    return (errCode);
}


//  --------------------------------------------------------------------------------------
//  helper method called everytime a checkbox is selected to save the current changes into
//  the tableview's newConfigID column. 
//
- (void) saveCheckboxSelectionToCurrentConfig {
	int currentRow = [mKeyboardTable selectedRow];
	if(currentRow >= 0){
		//If the row is valid save the current configuration into the newConfigid field of the data structure. 
		NSMutableDictionary* theRecord = [keyboardList objectAtIndex:currentRow];
		[theRecord setObject:[NSNumber numberWithInt:mEditVal] forKey:@"newConfigID"];
		[self refreshCheckBoxes];
	}
}


#pragma mark -
#pragma mark TableView datasource methods
- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex {
    id theRecord, theValue;
	
    NSParameterAssert(rowIndex >= 0 && rowIndex < [keyboardList count]);
    theRecord = [keyboardList objectAtIndex:rowIndex];
	
    theValue = [theRecord objectForKey:[aTableColumn identifier]];
	
    return theValue;
}

- (void)tableView:(NSTableView *)aTableView setObjectValue:anObject forTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex{
    id theRecord;
    NSParameterAssert(rowIndex >= 0 && rowIndex < [keyboardList count]);
    theRecord = [keyboardList objectAtIndex:rowIndex];
    [theRecord setObject:anObject forKey:[aTableColumn identifier]];
}

- (int)numberOfRowsInTableView:(NSTableView *)aTableView {
	return [keyboardList count];
}

#pragma mark -
#pragma mark TableView delegate methods
- (void)tableViewSelectionDidChange:(NSNotification *)aNotification{
	if(([mKeyboardTable selectedRow] >= 0)){
		int index = [mKeyboardTable selectedRow];
		NSDictionary* obj = [keyboardList objectAtIndex:index];
		mEditVal = [[obj objectForKey:@"newConfigID"] intValue];
		[self refreshCheckBoxes];
	}else {
		//clear the checkboxes if the selection is invalid
		[self allOffPressed:self];
	}

}


#pragma mark -
#pragma mark Auth methods and deallocation
//  --------------------------------------------------------------------------------------
//  try to get the root authorization to save global prefs
//  might return errAuthorizationCanceled, which is not an error but still failed
//
- (OSStatus) tryAuthorization {
	OSStatus err = 0;
	
	// check if the tool is there and some other things:
	NSFileManager *manager = [NSFileManager defaultManager];
	if (! ([manager fileExistsAtPath: sysPrefsWriteTool])) {
		err = -43;
	}
	
	if (!err) {
		// get the root auth
		AuthorizationItem theAItem;
		theAItem.name = kAuthorizationRightExecute;
		theAItem.flags = 0;
		theAItem.value = (void *)[sysPrefsWriteTool UTF8String];
		theAItem.valueLength = [sysPrefsWriteTool length];
		
		AuthorizationItemSet theASet;
		theASet.count = 1;
		theASet.items = &theAItem;
		
		UInt32 aFlags =  kAuthorizationFlagExtendRights | kAuthorizationFlagInteractionAllowed | kAuthorizationFlagPreAuthorize;
						
		err = AuthorizationCreate(&theASet, kAuthorizationEmptyEnvironment, aFlags, &mAuthRef);
	}
	return err;
}

//  --------------------------------------------------------------------------------------
//  unauthorizise
//
- (void) destroyAuthorization {
	if (mAuthRef) {
		AuthorizationFree (mAuthRef, kAuthorizationFlagDestroyRights);
		mAuthRef = 0;
	}
	[keyboardList release];
}

//  --------------------------------------------------------------------------------------
//  clean up before dying
//
- (void) dealloc {
	[self destroyAuthorization];
	[mUserPrefPath retain];
	[super dealloc];
}


//  --------------------------------------------------------------------------------------
//  some Value was set mEditVal and we should set the checkboxes to match
//
- (void) refreshCheckBoxes {
	int i;
	for (i = 0; i <= DCP_lastusedbit; i++) {
		id theCell = [checkBoxes cellWithTag: i];
		if (theCell) [theCell setState: [self isBitSet:i]];
	}
	[editVal setStringValue: [NSString stringWithFormat:@"%d", mEditVal]];
}

@end
