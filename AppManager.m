#import "AppManager.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"

@implementation AppManager

-(void)awakeFromNib{

    [window center];
    [window setReleasedWhenClosed:NO];
        
    // Set Monaco font
    [textField setTypingAttributes: 
    	[NSDictionary dictionaryWithObject:
        	[NSFont fontWithName:@"Monaco" size:11.0] forKey:NSFontAttributeName
     	]
    ];
}

// Redisplay the window after close and click on the dock icon
- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication hasVisibleWindows:(BOOL)flag
{
    [window makeKeyAndOrderFront: (id) theApplication];
    return flag;
}

// Do something if the app becomes active
- (void) applicationWillBecomeActive:(NSNotification *)note{
 	//NSBeep();   
}

// Open file dialog and load the text into the select box
- (IBAction)openDocument:(id)sender{
    int i; // Loop counter.
    
    // Create the File Open Dialog class.
    NSOpenPanel* openDlg = [NSOpenPanel openPanel];
    
    // Enable the selection of files in the dialog.
    [openDlg setCanChooseFiles:YES];
    
    // Enable the selection of directories in the dialog.
    [openDlg setCanChooseDirectories:NO];
    
    // Display the dialog.  If the OK button was pressed,
    // process the files.
    if ( [openDlg runModalForDirectory:nil file:nil] == NSOKButton )
    {
        // Get an array containing the full filenames of all
        // files and directories selected.
        NSArray* files = [openDlg filenames];
        
        // Loop through all the files and process them.
        for( i = 0; i < [files count]; i++ )
        {
            NSString* fileName = [files objectAtIndex:i];
            NSString* content = [[NSString alloc] initWithContentsOfFile:fileName];
            [textField setString:content];
            [content release];
        }
    }
}

- (IBAction)clickOpen:(NSButton*)sender {
    // Öffnet den Webbrowser mit der URL aus dem Textfeld
    NSURL* url = [NSURL URLWithString: [urlLabel stringValue]];
    [[NSWorkspace sharedWorkspace] openURL: url];
}


- (IBAction)sendText:(NSButton*)sender {
    // Show indicator
    [progressDings setHidden: (BOOL) NO];
    [progressDings startAnimation: (NSButton*) sender];
    
    // Wenn das Textfeld nicht leer ist
    if([[textField string] length] > 0){
        
        // API Basepoint
        NSURL *url = [NSURL URLWithString:@"https://dpaste.de/api/"];
                
        // Request aufbauen und senden
        ASIFormDataRequest *request = [[[ASIFormDataRequest alloc] initWithURL:url] autorelease];
        [request addRequestHeader:@"User-Agent" value:@"dpasteGUI"];
        [request addRequestHeader:@"Content-Type" value:@"application/json"];
        [request setAllowCompressedResponse: (BOOL) YES];        
        [request setPostValue:[textField string] forKey:@"content"];
        [request startSynchronous];
                
        if (![request error]) {
            // Url aus dem response auslesen und Anführungszeichen entfernen (piston bug?)
            NSString *response = [[request responseString] stringByReplacingOccurrencesOfString:@"\"" withString:@""];
            
            if(response) {
                [urlLabel setStringValue:response];
                [urlLabel selectText: (id) sender];
                [clickOpenButton setEnabled: (BOOL) YES];
            } else {
                [urlLabel setStringValue: @"Response Error of the API"];
            }
            
        }else{
            [urlLabel setStringValue: @"Request/Response Error of the API"];
        }
        
	}else{
        // Kein Text im Feld
	    NSBeep();
    }
    
    // Hide indicator
    [progressDings stopAnimation: (NSButton*) sender];
    [progressDings setHidden: (BOOL) YES];        
}
@end
