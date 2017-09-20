//
//  ViewController.m
//  DummyContacts
//
//  Created by Jennis on 23/01/13.
//  Copyright (c) 2013 MFMA. All rights reserved.
//

#import "ViewController.h"
#import <AddressBook/AddressBook.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnAddContactsTapped:(id)sender
{
    lblStatus.text =  @"Adding contacts, please wait...";
    [self performSelector:@selector(addContacts) withObject:nil afterDelay:0.1];
}

- (IBAction)btnRemoveContactsTapped:(id)sender
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"Are you sure you want to remove all records from addressbook ?" delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
    alertView.tag = 2;
    [alertView show];
    [alertView release];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex==1 && alertView.tag == 2)
    {
        lblStatus.text =  @"Removing contacts, please wait...";
        [self performSelector:@selector(removeContacts) withObject:nil afterDelay:0.1];
    }
}

-(void)addContacts
{
    ABAddressBookRef addressBook = ABAddressBookCreate();
    __block BOOL accessGranted = NO;
    
    if (ABAddressBookRequestAccessWithCompletion != NULL) { // we're on iOS 6
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            accessGranted = granted;
            dispatch_semaphore_signal(sema);
        });
        
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
        dispatch_release(sema);
    }
    else { // we're on iOS 5 or older
        accessGranted = YES;
    }
    
    long countAdded = 0;
    if(accessGranted)
    {
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"DummyVCard" ofType:@"vcf"];
        NSData *myData = [NSData dataWithContentsOfFile:filePath];
        CFDataRef vCardData = (CFDataRef)myData;
        
        ABAddressBookRef book = ABAddressBookCreate();
        ABRecordRef defaultSource = ABAddressBookCopyDefaultSource(book);
        CFArrayRef vCardPeople = ABPersonCreatePeopleInSourceWithVCardRepresentation(defaultSource, vCardData);
        for (CFIndex index = 0; index < CFArrayGetCount(vCardPeople); index++)
        {
            ABRecordRef person = CFArrayGetValueAtIndex(vCardPeople, index);
            NSString *strRandomname = [NSString stringWithFormat:@"%d.jpg",(arc4random() % 10) + 1];
            ABPersonSetImageData(person, (CFDataRef) (UIImageJPEGRepresentation([UIImage imageNamed:strRandomname], 1.0f)), nil);
            ABAddressBookAddRecord(book, person, NULL);
            ABAddressBookSave(book, nil);
            CFRelease(person);
        }
        
        countAdded += CFArrayGetCount(vCardPeople);
        CFRelease(vCardPeople);
        CFRelease(defaultSource);
    }
    
    NSString *msg = [NSString stringWithFormat:@"%ld contacts added successfully.", countAdded];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:msg delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    [alertView show];
    [alertView release];
    
    lblStatus.text =  @"Idle";
}

-(void)removeContacts
{
    ABAddressBookRef addressBook = ABAddressBookCreate();
    __block BOOL accessGranted = NO;
    
    if (ABAddressBookRequestAccessWithCompletion != NULL) { // we're on iOS 6
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            accessGranted = granted;
            dispatch_semaphore_signal(sema);
        });
        
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
        dispatch_release(sema);
    }
    else { // we're on iOS 5 or older
        accessGranted = YES;
    }
    
    if(accessGranted)
    {
        CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople( addressBook );
        CFIndex nPeople = ABAddressBookGetPersonCount( addressBook );
        
        for ( int i = 0; i < nPeople; i++ )
        {
            ABRecordRef ref = CFArrayGetValueAtIndex(allPeople, i);
            ABAddressBookRemoveRecord(addressBook, ref, nil);
            ABAddressBookSave(addressBook,nil);
        }
    }
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"All contacts removed successfully." delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    [alertView show];
    [alertView release];
    
    lblStatus.text =  @"Idle";
}


- (void)dealloc {
    [lblStatus release];
    [super dealloc];
}
- (void)viewDidUnload {
    [lblStatus release];
    lblStatus = nil;
    [super viewDidUnload];
}
@end
