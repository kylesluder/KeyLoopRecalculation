//
//  AppDelegate.h
//  KeyLoopRecalculation
//
//  Created by Kyle Sluder on 12/3/13.
//  Copyright (c) 2013 Kyle Sluder. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSTabView *tabView;
@property (retain) IBOutlet NSView *tabContentView;

@property (assign) IBOutlet NSTextField *fieldA;
@property (assign) IBOutlet NSTextField *field1;

@property (assign) IBOutlet NSTextField *firstResponderLabel;

@end
