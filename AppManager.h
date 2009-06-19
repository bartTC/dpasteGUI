#import <Cocoa/Cocoa.h>

@interface AppManager: NSObject {
    IBOutlet NSProgressIndicator* progressDings;
    IBOutlet NSTextField* urlLabel;
    IBOutlet NSTextView* textField;
    IBOutlet NSButton* clickOpenButton;
    IBOutlet NSWindow* window;
}
- (IBAction)sendText:(NSButton*)sender;
- (IBAction)clickOpen:(NSButton*)sender;
- (IBAction)openDocument:(id)sender;
@end
