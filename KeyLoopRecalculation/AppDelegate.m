//
//  AppDelegate.m
//  KeyLoopRecalculation
//
//  Created by Kyle Sluder on 12/3/13.
//  Copyright (c) 2013 Kyle Sluder. All rights reserved.
//

#import "AppDelegate.h"

///////

#define SET_INITIAL_FIRST_RESPONDERS 1

///////

static NSString *describeResponder(NSResponder *responder)
{
    if ([responder conformsToProtocol:@protocol(NSUserInterfaceItemIdentification)]) {
        NSString *identifier = ((NSResponder <NSUserInterfaceItemIdentification> *)responder).identifier;
        if (identifier.length > 0 && !([identifier hasPrefix:@"_NS"]))
            return identifier;
    }
    
    return [NSString stringWithFormat:@"<%@:%p>", responder.class, responder];
}

@interface MyWindow : NSWindow
@end

@implementation MyWindow

- (void)recalculateKeyViewLoop;
{
    NSLog(@"=== WINDOW RECALCULATING LOOP");
    [super recalculateKeyViewLoop];
}

@end

@interface MyTextField : NSTextField
@end

@implementation MyTextField
{
    BOOL _didAwake;
}

- (void)awakeFromNib;
{
    _didAwake = YES;
    [super awakeFromNib];
}

- (void)setNextKeyView:(NSView *)next;
{
    if (self.window != nil)
        NSLog(@"=== TEXT FIELD %@ SETTING NEXT KEY VIEW TO %@", self.identifier, describeResponder(next));
    
    [super setNextKeyView:next];
}

@end

@implementation AppDelegate

static void *FirstResponderObservationContext = &FirstResponderObservationContext;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
#if SET_INITIAL_FIRST_RESPONDERS
    _window.initialFirstResponder = _fieldA;
#endif
    
    NSTabViewItem *tabViewItem = ((NSTabViewItem *)_tabView.tabViewItems[0]);
    tabViewItem.view = _tabContentView;
    
#if SET_INITIAL_FIRST_RESPONDERS
    tabViewItem.initialFirstResponder = _field1;
#endif

    [_window addObserver:self forKeyPath:@"firstResponder" options:NSKeyValueObservingOptionInitial context:FirstResponderObservationContext];
}

- (void)_updateFirstResponderLabel:(id)unused;
{
    NSResponder *firstResponder = _window.firstResponder;
    if ([firstResponder isKindOfClass:[NSTextView class]] && ((NSTextView *)firstResponder).isFieldEditor) {
        NSTextView *fieldEditor = (NSTextView *)firstResponder;
        _firstResponderLabel.stringValue = [NSString stringWithFormat:@"firstResponder = (field editor); delegate = %@ ; delegate.nextKeyView = %@ ; delegate.nextValidKeyView = %@", describeResponder((NSView *)fieldEditor.delegate), describeResponder(((NSView *)fieldEditor.delegate).nextKeyView), describeResponder(((NSView *)fieldEditor.delegate).nextValidKeyView)];
    } else if ([firstResponder isKindOfClass:[NSView class]]) {
        _firstResponderLabel.stringValue = [NSString stringWithFormat:@"firstResponder = %@ ; nextKeyView = %@ ; nextValidKeyView = %@", describeResponder(firstResponder), describeResponder(((NSView *)firstResponder).nextKeyView), describeResponder(((NSView *)firstResponder).nextValidKeyView)];
    } else {
        _firstResponderLabel.stringValue = @"firstResponder = %@";
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context;
{
    if (context == FirstResponderObservationContext) {
        [self performSelector:@selector(_updateFirstResponderLabel:) withObject:nil afterDelay:0];
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender;
{
    return YES;
}

@end
