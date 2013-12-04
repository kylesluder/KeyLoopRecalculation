KeyLoopRecalculation
===

A demo project that shows off some unexpected behavior with key view loops.

According to the documentation for -[NSWindow recalculateKeyViewLoop]:, "When it is first loaded, NSWindow calls this method automatically if your window does not have a key view loop already established." I've built a demo project and confirmed that -recalculateKeyViewLoop does not get called if you set up the window's initialFirstResponder in nib. So as long as your window has a valid key view loop in nib, you should be okay.

As far as the tab view goes, the tab view mucks with the key view loop of the to-be-selected item's view whenever its current tab item changes. If the initial first responder is set then it works as you expect, *except* that the last view in the loop has its nextKeyView set to the tab view itself. This normally has no visible effect, since the tab view returns NO from -acceptsFirstResponder and returns the correct value from -nextKeyView such that -nextValidKeyView remains a loop.

I presume NSTabView insists on inserting itself into the key view loop in order to ensure that a user who is using Full Keyboard Access is able to navigate to the tab view and from there to its peers, rather than being trapped inside the tab view's content area (which is a failure mode I have experienced when using VoiceOver on iOS).

Sadly, there is apparently no way for a tab view whose initial item is selected in nib but whose view is swapped in from elsewhere to use a custom tab order. (More generally, it's not possible to use a custom tab order when swapping out the view of the selected tab view item; the fact that it's selected in nib is just a particular example.) If you try to set the initial first responder of a tab view item to something that's not a descendant of the view, it throws an exception. And as soon as you set the view of the selected tab view item, it sees that its initialFirstResponder is nil, determines you don't have a valid key loop, and tramples everything.

One possible solution (untested) would be to, immediately after assigning the view to the tab view item, delay-perform a message that first sets the tab view item's initial first responder and then rebuilds its key view loop:

// note: untested
@property IBOutlet NSView *viewToSwapIn;
@property IBOutlet NSView *swappedInSubviewA, *swappedInSubviewB;

- (void)windowDidLoad {
  _tabViewItem.view = _viewToSwapIn;
  [self performSelector:@selector(_rebuildKeyViewLoopForTabItem:) withObject:_firstTabItem afterDelay:0];
}

- (void)_rebuildKeyViewLoopForTabItem:(NSTabViewItem *)item
{
  _swappedInSubviewA.nextKeyView = _swappedInSubviewB;

  if (item == _tabView.selectedTabViewItem) {
    _swappedInSubviewB.nextKeyView = _tabView;
    _tabView.nextKeyView = _swappedInSubviewA;
  } else {
    _swappedInSubviewB.nextKeyView = _swappedInSubviewA;
  }

  item.initialFirstResponder = _swappedInSubviewA;
}
//end
