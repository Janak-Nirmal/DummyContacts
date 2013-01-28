//
//  ViewController.h
//  DummyContacts
//
//  Created by Jennis on 23/01/13.
//  Copyright (c) 2013 MFMA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <UIAlertViewDelegate>
{
    
    IBOutlet UILabel *lblStatus;
}

- (IBAction)btnAddContactsTapped:(id)sender;
- (IBAction)btnRemoveContactsTapped:(id)sender;

@end
