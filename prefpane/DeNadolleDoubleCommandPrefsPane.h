/* DeNadolleDoubleCommandPrefsPane */

#import <Cocoa/Cocoa.h>
#import <PreferencePanes/NSPreferencePane.h>
#import <CoreFoundation/CoreFoundation.h> 
#import <Security/Authorization.h>
#import "KeyboardListUtility.h"

#define DCP_lastusedbit  30

#define CAPSLOCK_TO_CONTROL							11
#define CAPSLOCK_TO_DELETE							25
#define CAPSLOCK_TO_FORWARD_DELETE			27

#define OPTION_R_TO_FORWARD_DELETE			26
#define OPTION_R_TO_CONTROL							28
#define OPTION_R_TO_ENTER								29

#define DISABLE_COMMAND_AND_OPTION			15
#define DISABLE_CAPSLOCK								19

#define ENTER_TO_COMMAND								0
#define ENTER_TO_CONTROL								1
#define ENTER_TO_OPTION									2
#define ENTER_TO_FUNCTION								3
#define ENTER_TO_FORWARD_DELETE					20

#define COMMAND_TO_OPTION								4
#define COMMAND_TO_CONTROL							5

#define SHIFT_DELETE_TO_FORWARD_DELETE	14
#define SWAP_DELETE_AND_FORWARD_DELETE	30

#define MAX_NUM_KEYBOARDS 4

NSString * systemPrefsPath = @"/Library/StartupItems/DoubleCommand/DoubleCommand.pref";
NSString * userPrefsRelPath = @"Library/Preferences/DoubleCommand.pref";
NSString * sysPrefsWriteTool = @"/Library/PreferencePanes/DoubleCommandPreferences.prefPane/Contents/Resources/prefWriter";

@protocol NSTableViewDelegate;

@interface DeNadolleDoubleCommandPrefsPane : NSPreferencePane //<NSTableViewDelegate>
{
    IBOutlet id allOffButton;
    IBOutlet id checkBoxes; // NSMatrix containig all the NSButton-Checkboxes
    IBOutlet id editVal;
	
    IBOutlet id showUserButton;
    IBOutlet id showSystemButton;
    IBOutlet id showActiveButton;
	
    IBOutlet id setUserButton;
    IBOutlet id setSystemButton;
    IBOutlet id setActiveButton;

    IBOutlet id userVal;
    IBOutlet id systemVal;
    IBOutlet id activeVal;
	
	AuthorizationRef mAuthRef;
	
	unsigned int mUserVal;
	unsigned int mSystemVal;
	unsigned int mActiveVal;
	unsigned int mEditVal;
	
	IBOutlet id keyboardConfigCurrent;
	
	NSString * mUserPrefPath;
	
	IBOutlet NSTableView * mKeyboardTable;
	
	NSMutableArray* keyboardList;
}

/*
	all checkboxes off
*/
- (IBAction)allOffPressed:(id)sender;

- (IBAction)checkBoxClicked:(id)sender;

- (IBAction)setUserPressed:(id)sender;
- (IBAction)setSystemPressed:(id)sender;
- (IBAction)setActivePressed:(id)sender;

- (IBAction)saveSettingsPressed:(id)sender;
- (IBAction)revertSettingsPressed:(id)sender;
- (IBAction)clearPrefsPressed:(id)sender;

/* will be called from the App */
- (void) mainViewDidLoad;
- (void) didSelect;

/* internal tools */
- (BOOL) isBitSet:(int)bit;
- (OSStatus) tryAuthorization;
- (void) destroyAuthorization;
- (BOOL) readSystemSettings;
- (OSStatus) writeSystemSettings;
- (BOOL) readUserSettings;
- (BOOL) writeUserSettings;
- (BOOL) readActiveSettings;
- (OSStatus) writeActiveSettings;
- (void) refreshCheckBoxes;
- (void) saveCheckboxSelectionToCurrentConfig;

//table view delegate methods.
- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex;
- (void)tableView:(NSTableView *)aTableView setObjectValue:anObject forTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex;
- (int)numberOfRowsInTableView:(NSTableView *)aTableView;
- (void)tableViewSelectionDidChange:(NSNotification *)aNotification;

@end
