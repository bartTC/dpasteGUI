#import "AppManager.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"

@implementation AppManager

-(void)awakeFromNib{
    // Set Monaco font
    [textField setTypingAttributes: 
    	[NSDictionary dictionaryWithObject:
        	[NSFont fontWithName:@"Monaco" size:11.0] forKey:NSFontAttributeName
     	]
    ];
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
        NSURL *url = [NSURL URLWithString:@"http://dpaste.de/api/"];

        // POST-Content urlencoden
        // @see http://simonwoodside.com/weblog/2009/4/22/how_to_really_url_encode/
        NSString* encodedString = (NSString * )CFURLCreateStringByAddingPercentEscapes(
            NULL,
            (CFStringRef) [textField string],
            NULL,
            (CFStringRef) @"!*'();:@&=+$,/?%#[]",
            kCFStringEncodingUTF8
    	);
                                                                                    
        // Post content aufbauen
        NSString* postContent = @"content=";
        postContent = [postContent stringByAppendingString: encodedString];
                
        // Request aufbauen und senden
        ASIFormDataRequest *request = [[[ASIFormDataRequest alloc] initWithURL:url] autorelease];
        [request addRequestHeader:@"User-Agent" value:@"dpasteGUI"];
        [request setAllowCompressedResponse: (BOOL) YES];        
        [request setPostBody: [postContent dataUsingEncoding:NSUTF8StringEncoding]];
        [request start];
                
        // Response
        NSError *error = [request error];        
        if (!error) {
            // Url aus dem response auslesen und Anführungszeichen entfernen (piston bug?)
            NSString *response = [[request responseString] stringByReplacingOccurrencesOfString:@"\"" withString:@""];            
            [urlLabel setStringValue:response];
            [urlLabel selectText: (id) sender];
            
            // Open Button aktivieren
            [clickOpenButton setEnabled: (BOOL) YES];
        }else{
            [urlLabel setStringValue: @"Request/Response Error with the API"];
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
