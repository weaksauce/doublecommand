//
//  KeyboardListUtility.m
//  DoubleCommandPrefPane
//
//  Created by Patrick Murtha on 7/20/10. opensourcepatrick@gmail.com
//
#import <Cocoa/Cocoa.h>
#import "KeyboardListUtility.h"

#define MAX_NUM_KEYBOARDS 4

@implementation KeyboardListUtility

+ (NSMutableArray*) keyboards{
	/* overview
	 get the list of keyboards from preferences
	 get the currently attached keyboards
	 go through them one by one to see if one is not in the current keyboard list.
	 if it is then do nothing
	 if it is not then add it to the return value.
	 */
	KeyboardListUtility* keyboardPrefManager = [[KeyboardListUtility alloc] init];
	
	NSMutableArray* returnValue = [keyboardPrefManager keyboardListFromPrefs];
	NSArray* listOfKeyboardIDs = [keyboardPrefManager keyboardIDsFromArray:returnValue];
	NSMutableArray* currentlyAttached = [keyboardPrefManager allKeyboardsCurrentlyAttached];
	
	int i, count = [currentlyAttached count];
	for (i = 0; i < count; i++) {
		NSDictionary * obj = [currentlyAttached objectAtIndex:i];
		NSNumber* hidInt = [obj objectForKey:@"keyboardID"];
		if ( hidInt != nil) {
			if (![listOfKeyboardIDs containsObject:hidInt]) {
				//add object into the array and continue.
				[returnValue addObject:obj];
			}
		}
	}
	
	[keyboardPrefManager release];
	
	return returnValue;
}

- (NSMutableArray*) allKeyboardsCurrentlyAttached{
	NSMutableArray* keyboardsFound = [[NSMutableArray alloc] init];
	//these are used to stuff the keyboard information into the dictionary. 
	int hidsubsystemID = 0;
	NSString* strProduct;
	
	//	these variables are used to go through the IO Registry and return the keyboards attached to the system.
	CFMutableDictionaryRef mykeyboards; 
	io_iterator_t iterator;
	io_object_t myKeyboardObject; 
	io_name_t devName;
	CFTypeRef deviceProperty, deviceProduct;
	
	//Get a matching dictionary that only matches keyboard objects.
	mykeyboards = IOServiceMatching("IOHIDKeyboard");
	
	IOServiceGetMatchingServices(kIOMasterPortDefault, mykeyboards, &iterator);
	
	myKeyboardObject = IOIteratorNext(iterator);
	
	while (myKeyboardObject != 0) {
		IORegistryEntryGetName(myKeyboardObject, devName);
		deviceProperty  = IORegistryEntryCreateCFProperty(myKeyboardObject, CFSTR("HIDSubinterfaceID"), kCFAllocatorDefault, 0);
		deviceProduct = IORegistryEntryCreateCFProperty(myKeyboardObject, CFSTR("Product"), kCFAllocatorDefault, 0);
		hidsubsystemID = 0;
		
		//if they both return correctly then we want to extract the correct data and stuff it into the return dictionary.
		if(deviceProperty && deviceProduct){	
			CFNumberGetValue(deviceProperty, CFNumberGetType(deviceProperty), &hidsubsystemID);
			strProduct =  (NSString*) deviceProduct;
		}else {
			printf("error with current Keyboard\n");
			continue;
		}
		NSMutableDictionary* currentKeyboard = [[NSMutableDictionary alloc] init];
		[currentKeyboard setObject:strProduct forKey:@"description"];
		[currentKeyboard setObject:[NSNumber numberWithInt:hidsubsystemID] forKey:@"keyboardID"];
		//populate the current keyboard with default values
		[currentKeyboard setObject:strProduct forKey:@"descriptionUserSet"];		
		[currentKeyboard setObject:[NSNumber numberWithInt:0] forKey:@"configID"];
		[currentKeyboard setObject:[NSNumber numberWithInt:0] forKey:@"newConfigID"];		
		[currentKeyboard setObject:[NSNumber numberWithBool:NO] forKey:@"active"]; 
		[currentKeyboard setObject:[NSNumber numberWithBool:NO] forKey:@"deleted"];
		
		//add the current keyboard object to the array to return it. 
		[keyboardsFound addObject:currentKeyboard];
		
		CFRelease(deviceProduct);
		CFRelease(deviceProperty);
		myKeyboardObject = IOIteratorNext(iterator);		
	}
	
	IOObjectRelease(iterator);
	IOObjectRelease(myKeyboardObject);
	
	return keyboardsFound;
}

#pragma mark helper methods
-(NSMutableArray*) keyboardIDsFromArray:(NSArray*)inputArray {
	NSMutableArray* keyboardIDs = [[NSMutableArray alloc] init];
	
	int i, count = [inputArray count];
	for (i = 0; i < count; i++) {
		NSDictionary * obj = [inputArray objectAtIndex:i];
		NSNumber * myval = [obj objectForKey:@"keyboardID"];	
		if (myval) {
			[keyboardIDs addObject:myval];
		}
	}
	[keyboardIDs autorelease];
	return keyboardIDs;
}

- (NSMutableArray*) keyboardListFromPrefs{
	NSUserDefaults* systemSettings = [NSUserDefaults standardUserDefaults];
	NSMutableArray* keyboardsFound = [[NSMutableArray alloc] init];
	NSString * GlobalConfigName = @"Global Settings";
	int i;
	

	//exit if we do not have a keyboard
	if(![systemSettings stringForKey:@"dc.description"]){
		//Fill global keyboard with defaults and add it to the return list

		NSMutableDictionary* currentKeyboard = [[NSMutableDictionary alloc] init];
		[currentKeyboard setObject:GlobalConfigName forKey:@"description"];
		[currentKeyboard setObject:GlobalConfigName forKey:@"descriptionUserSet"];		
		[currentKeyboard setObject:[NSNumber numberWithInt:0] forKey:@"keyboardID"];
		[currentKeyboard setObject:[NSNumber numberWithInt:0] forKey:@"configID"];
		[currentKeyboard setObject:[NSNumber numberWithInt:0] forKey:@"newConfigID"];
		[currentKeyboard setObject:[NSNumber numberWithBool:YES] forKey:@"active"];		
		[currentKeyboard setObject:[NSNumber numberWithBool:NO] forKey:@"deleted"];
		
		[keyboardsFound addObject:currentKeyboard];
	}else {
		//fill up the global keyboard config with the saved preferences. 
		NSMutableDictionary* currentKeyboard = [[NSMutableDictionary alloc] init];
		[currentKeyboard setObject:GlobalConfigName forKey:@"description"];
		[currentKeyboard setObject:GlobalConfigName forKey:@"descriptionUserSet"];		
		[currentKeyboard setObject:[NSNumber numberWithInt:[systemSettings integerForKey:@"dc.keyboardid"]] forKey:@"keyboardID"];
		[currentKeyboard setObject:[NSNumber numberWithInt:[systemSettings integerForKey:@"dc.configid"]] forKey:@"configID"];
		[currentKeyboard setObject:[NSNumber numberWithInt:[systemSettings integerForKey:@"dc.configid"]] forKey:@"newConfigID"];
		[currentKeyboard setObject:[NSNumber numberWithBool:[systemSettings boolForKey:@"dc.active"]] forKey:@"active"];		
		[currentKeyboard setObject:[NSNumber numberWithBool:[systemSettings boolForKey:@"dc.deleted"]] forKey:@"deleted"];
		
		[keyboardsFound addObject:currentKeyboard];
	}
	
	//Get the Saved keyboards from the preferences. 
	for (i = 1; i <= MAX_NUM_KEYBOARDS; i++) {
		
		//exit if we do not have a keyboard
		if(![systemSettings stringForKey:[NSString stringWithFormat:@"dc.description%d", i]]) break;
		
		//allocate some memory for the current keyboard object and populate all the required dictionary fields if there is no problem with the guard above. 
		NSMutableDictionary* currentKeyboard = [[NSMutableDictionary alloc] init];
		[currentKeyboard setObject:[systemSettings stringForKey:[NSString stringWithFormat:@"dc.description%d", i]] forKey:@"description"];
		[currentKeyboard setObject:[systemSettings stringForKey:[NSString stringWithFormat:@"dc.descriptionUserSet%d", i]] forKey:@"descriptionUserSet"];		
		[currentKeyboard setObject:[NSNumber numberWithInt:[systemSettings integerForKey:[NSString stringWithFormat:@"dc.keyboardid%d", i]]] forKey:@"keyboardID"];
		[currentKeyboard setObject:[NSNumber numberWithInt:[systemSettings integerForKey:[NSString stringWithFormat:@"dc.configid%d", i]]] forKey:@"configID"];
		[currentKeyboard setObject:[NSNumber numberWithInt:[systemSettings integerForKey:[NSString stringWithFormat:@"dc.configid%d", i]]] forKey:@"newConfigID"];
		[currentKeyboard setObject:[NSNumber numberWithBool:[systemSettings boolForKey:[NSString stringWithFormat:@"dc.active%d", i]]] forKey:@"active"];		
		[currentKeyboard setObject:[NSNumber numberWithBool:[systemSettings boolForKey:[NSString stringWithFormat:@"dc.deleted%d", i]]] forKey:@"deleted"];
		
		[keyboardsFound addObject:currentKeyboard];
	}
	
	
	[keyboardsFound autorelease];
	
	return keyboardsFound;
}

+ (void) saveToPrefs:(NSArray*)keyboards{
	NSUserDefaults* systemSettings = [NSUserDefaults standardUserDefaults];
	int counter, count = [keyboards count];
	
	for (counter = 0; counter < count; counter++) {
		NSDictionary * obj = [keyboards objectAtIndex:counter];
		if (counter == 0) {
			//save global settings
			[systemSettings setObject:[obj objectForKey:@"description"] forKey:@"dc.description"];
			[systemSettings setObject:[obj objectForKey:@"descriptionUserSet"] forKey:@"dc.descriptionUserSet"];
			[systemSettings setObject:[obj objectForKey:@"keyboardID"] forKey:@"dc.keyboardid"];
			[systemSettings setObject:[obj objectForKey:@"newConfigID"] forKey:@"dc.configid"];
			[systemSettings setObject:[obj objectForKey:@"active"] forKey:@"dc.active"];
			[systemSettings setObject:[obj objectForKey:@"deleted"] forKey:@"dc.deleted"];
		}else {
			[systemSettings setObject:[obj objectForKey:@"description"] forKey:[NSString stringWithFormat:@"dc.description%d", counter]];
			[systemSettings setObject:[obj objectForKey:@"descriptionUserSet"] forKey:[NSString stringWithFormat:@"dc.descriptionUserSet%d", counter]];
			[systemSettings setObject:[obj objectForKey:@"keyboardID"] forKey:[NSString stringWithFormat:@"dc.keyboardid%d", counter]];
			[systemSettings setObject:[obj objectForKey:@"newConfigID"] forKey:[NSString stringWithFormat:@"dc.configid%d", counter]];
			[systemSettings setObject:[obj objectForKey:@"active"] forKey:[NSString stringWithFormat:@"dc.active%d", counter]];
			[systemSettings setObject:[obj objectForKey:@"deleted"] forKey:[NSString stringWithFormat:@"dc.deleted%d", counter]];			
		}
	}
}

+ (void) clearAllPrefs{
	NSUserDefaults* systemSettings = [NSUserDefaults standardUserDefaults];
	int i;
	i = 0;

	if ([systemSettings stringForKey:@"dc.description"]) {
		[systemSettings removeObjectForKey:@"dc.description"];
		[systemSettings removeObjectForKey:@"dc.descriptionUserSet"];
		[systemSettings removeObjectForKey:@"dc.keyboardid"];
		[systemSettings removeObjectForKey:@"dc.configid"];
		[systemSettings removeObjectForKey:@"dc.active"];
		[systemSettings removeObjectForKey:@"dc.deleted"];
	}
	
	while ( i == 0 || ([systemSettings stringForKey:[NSString stringWithFormat:@"dc.description%d", i]] && i <= MAX_NUM_KEYBOARDS)) {
		[systemSettings removeObjectForKey:[NSString stringWithFormat:@"dc.description%d", i]];
		[systemSettings removeObjectForKey:[NSString stringWithFormat:@"dc.descriptionUserSet%d", i]];
		[systemSettings removeObjectForKey:[NSString stringWithFormat:@"dc.keyboardid%d", i]];
		[systemSettings removeObjectForKey:[NSString stringWithFormat:@"dc.configid%d", i]];
		[systemSettings removeObjectForKey:[NSString stringWithFormat:@"dc.active%d", i]];
		[systemSettings removeObjectForKey:[NSString stringWithFormat:@"dc.deleted%d", i]];
		
		i++;
	}
}

+ (void) delete:(int)hidID fromList:(NSMutableArray*)keyboards{
	if(hidID < 0) return;
	
	int i, count = [keyboards count];
	for (i = 0; i < count; i++) {
		NSMutableDictionary * curKbd = [keyboards objectAtIndex:i];
		NSNumber* kID = [curKbd objectForKey:@"keyboardid"];
		int currentHID = [kID intValue]; 
		if (currentHID == hidID) {
			[curKbd setObject:[NSNumber numberWithBool:YES] forKey:@"deleted"];
			return;
		}
	}
}

@end

















