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
	//save to preferences
	[KeyboardListUtility saveToPrefs:keyboardList];
	//save to disk for system start
	[self writeUserSettings];
	//activate settings for the current session
	[self activateCurrentSettings];
	//make the new settings the settings to revert to.
	[self copyNewSettingsToOld];
}

//  --------------------------------------------------------------------------------------
//	clear all prefs
//
- (IBAction)clearPrefsPressed:(id)sender {
	[KeyboardListUtility clearAllPrefs];
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
		[mKeyboardTable reloadData];
	}
}
//  --------------------------------------------------------------------------------------
//	copy each value from the key newConfigID to configID to make a new revert point.
//
- (void)copyNewSettingsToOld {
	int i, count = [keyboardList count];
	
	for(i = 0; i < count; i++){
		NSMutableDictionary* keyboard = [keyboardList objectAtIndex:i];
		unsigned int newConfig = [[keyboard objectForKey:@"newConfigID"] unsignedIntValue];
		[keyboard setObject:[NSNumber numberWithUnsignedInt:newConfig] forKey:@"configID"];
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
	//update the config so it will save correctly.
	[self saveCheckboxSelectionToCurrentConfig];
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
	
	// the other prefs will be fetched in didSelect in a tick :)
	
	//load the keyboards from the prefs file and the io registry.
	keyboardList = [[KeyboardListUtility keyboards] retain];
	[mKeyboardTable reloadData];
}


//  --------------------------------------------------------------------------------------
//  every time the prefs gets selected
//
- (void) didSelect {
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
//  write User Prefs to Disk and preferences. 
//
- (BOOL) writeUserSettings
{
	int i;
    BOOL ret = NO;

	NSDictionary* currentKbd = [keyboardList objectAtIndex:0];
	NSNumber* globalConfigID = [currentKbd objectForKey:@"configID"];
	NSMutableString * thePrefs = [NSMutableString stringWithFormat: @"dc.config=%d", [globalConfigID intValue]];
	
	for (i = 1; i <= MAX_NUM_KEYBOARDS && i < [keyboardList count] ; i++) {
		NSDictionary* currentKbd = [keyboardList objectAtIndex:i];
		
		if ([[currentKbd objectForKey:@"deleted"] intValue] == 0) {
			int kbdID = [[currentKbd objectForKey:@"keyboardID"] intValue];
			int configID = [[currentKbd objectForKey:@"configID"] intValue];
			
			[thePrefs appendFormat:@" dc.config%d=%d dc.keyboard%d=%d", i, configID, i, kbdID];			
		}
	}
	ret = [thePrefs writeToFile:mUserPrefPath atomically:YES encoding:NSUTF8StringEncoding error:NULL];
    return ret;
}

-(BOOL) activateCurrentSettings{
	int i=0, count = [keyboardList count];
	BOOL ret = NO;
	for(i = 0; i <= MAX_NUM_KEYBOARDS && i < count; i++){
		NSDictionary* curKbd = [keyboardList objectAtIndex:i];
		unsigned int keyID  = [[curKbd objectForKey:@"keyboardID"] unsignedIntValue];
		unsigned int confID = [[curKbd objectForKey:@"newConfigID"] unsignedIntValue];

		if(i==0){			
			ret = [self writeValue:confID forSysCtl:@"dc.config"];
			if (ret == -1) { break; }
		}else{
			ret = [self writeValue:keyID forSysCtl:[NSString stringWithFormat:@"dc.keyboard%d",i]];
			if (ret == -1) { break; }
			ret = [self writeValue:confID forSysCtl:[NSString stringWithFormat:@"dc.config%d",i]];
			if (ret == -1) { break; }
		}
	}
	return ret;
}

//  --------------------------------------------------------------------------------------
//  write a setting to sysctl
//
- (OSStatus) writeValue:(unsigned int)configID forSysCtl:(NSString*)sysctlName {
//	if( errCode==-1 ) NSLog(@"Error writing sysctl:%@ with value %d. Error Code: %d configIDlength: %d", sysctlName, configID, errCode, sizeof(configID));
	NSLog(@"writing %d for value: %@", configID, sysctlName);
    OSStatus errCode = 0;    
    u_int len = sizeof(configID);
	const char * name = [sysctlName UTF8String];
	
	errCode = sysctlbyname(name, NULL, 0, &configID, len);
	
	if( errCode == -1 ) {
		perror("sysctl");
		NSLog(@"Error writing sysctl:%@ with value %d. Error Code: %d", sysctlName, configID, errCode);
	}
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
