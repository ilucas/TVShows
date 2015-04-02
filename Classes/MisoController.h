/*
 *  This file is part of the TVShows 2 ("Phoenix") source code.
 *  http://github.com/victorpimentel/TVShows/
 *
 *  TVShows is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with TVShows. If not, see <http://www.gnu.org/licenses/>.
 *
 */

#import <Cocoa/Cocoa.h>
#import "SubscriptionsDelegate.h"
#import "Miso.h"

@interface MisoController : NSWindowController <MisoDelegate>
{
    BOOL signInProgress;
    BOOL manually;
    Miso *misoBackend;
    
    IBOutlet SubscriptionsDelegate *subscriptionsDelegate;
    
    IBOutlet NSTextField *misoText;
    IBOutlet NSTextField *existingUserText;
    IBOutlet NSTextField *whyText;
    IBOutlet NSTextField *becauseText;
    IBOutlet NSButton *loginButton;
    IBOutlet NSButton *signUpButton;
    IBOutlet NSProgressIndicator *loading;
    IBOutlet NSTextField *nameTitle;
    IBOutlet NSTextField *passwordTitle;
    IBOutlet NSTextField *nameField;
    IBOutlet NSSecureTextField *passwordField;
    IBOutlet NSButton *syncCheck;
    IBOutlet NSTextField *syncText;
    IBOutlet NSButton *checkinCheck;
    IBOutlet NSTextField *checkinText;
    IBOutlet NSButton *logOutButton;
    IBOutlet NSButton *visitButton;
    IBOutlet NSTabView *tabView;
    
    IBOutlet NSArrayController *PTArrayController;
    IBOutlet NSArrayController *SBArrayController;
}

- (IBAction)signIn:(id)sender;
- (IBAction)createAccount:(id)sender;
- (IBAction)syncButtonDidChange:(id)sender;
- (IBAction)checkinCheckDidChange:(id)sender;
- (IBAction)logOut:(id)sender;

- (void)syncShows;

@end
