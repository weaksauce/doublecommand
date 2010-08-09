//
//  KeyboardListUtility.h
//  DoubleCommandPrefPane
//
//  Created by Patrick Murtha on 7/20/10. opensourcepatrick@gmail.com


#import <Cocoa/Cocoa.h>
#import <IOKit/IOKitLib.h>
#import <CoreFoundation/CoreFoundation.h>
#import <CoreFoundation/CFPreferences.h>

@interface KeyboardListUtility : NSObject {
	
}

+ (NSMutableArray*) keyboards;
- (NSMutableArray*) allKeyboardsCurrentlyAttached;
- (NSMutableArray*) keyboardListFromPrefs;
- (NSMutableArray*)	keyboardIDsFromArray:(NSArray*)inputArray;
+ (void) saveToPrefs:(NSArray *)keyboards;
+ (void) clearAllPrefs;
+ (void) delete:(int)hidID fromList:(NSMutableArray*)keyboards;
@end

