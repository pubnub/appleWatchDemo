/**
 @author Sergey Mamontov
 @copyright © 2009-2015 PubNub, Inc.
 */
#import "SPNPWaitingViewController.h"
#import "SPNPPollInformationViewController.h"
#import "SPNPPollManager.h"


#pragma mark Static

/**
 @brief  Stores name of the segue which should be performed as soon as new poll will be announced or
         manager will be able to catch up on previously active session.
 */
static NSString * const kSPNPShowPollViewControllerSegueIdentifier = @"SPNPShowPollViewControllerSegue";


#pragma mark - Private interface declaration

@interface SPNPWaitingViewController ()


#pragma mark - Properties

/**
 @brief  Stores reference on activity indicator which will be shown while waiting for data from 
         manager.
 */
@property (nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;

/**
 @brief  Stores whether controller already subscribed on manager events or not.
 */
@property (nonatomic, assign) BOOL subscribedOnUpdates;

/**
 @brief  Stores reference on manager which should be used for further attendees application
         working flow.
 */
@property (nonatomic) SPNPPollManager *manager;


#pragma mark - Flow

/**
 @brief  Navigate attendee to the screen where he will be able to vote and watch poll stats in
         real-time.
 */
- (void)showPollInformation;


#pragma mark - Misc

/**
 @brief  Subscribe to all required manager state updates to represent them in time to the user.
 */
- (void)subscribeOnUpdates;

/**
 @brief  Unsubscribe from all previously tracked manager state.
 */
- (void)unsubscribeFromUpdates;

/**
 @brief  Present user with error alert for passed error message and operation.
 
 @param errorMessage Reference on message which should be shown in alert view.
 @param operation    Reference on name of operation which failed.
 */
- (void)showError:(NSString *)errorMessage forOperation:(NSString *)operation;

#pragma mark -


@end


#pragma mark - Interface implementation

@implementation SPNPWaitingViewController


#pragma mark - Controller life-cycle

- (void)viewWillAppear:(BOOL)animated {
    
    // Forward method call to the super class.
    [super viewWillAppear:animated];
    
    [self.activityIndicatorView startAnimating];
}

- (void)viewDidAppear:(BOOL)animated {
    
    // Forward method call to the super class.
    [super viewDidAppear:animated];
    
    __weak __typeof(self) weakSelf = self;
    [self.manager startWithStatusBlock:^(BOOL connected, NSString *errorMessage) {
        
        __strong __typeof(self) strongSelf = weakSelf;
        if (connected) {
            
            if (strongSelf.manager.activePoll) { [strongSelf showPollInformation]; }
            else { [self subscribeOnUpdates]; }
        }
        else { [strongSelf showError:errorMessage forOperation:@"Connection"]; }
    }];
}

- (void)viewDidDisappear:(BOOL)animated {
    
    // Forward method call to the super class.
    [super viewDidDisappear:animated];
    
    [self.activityIndicatorView stopAnimating];
    [self unsubscribeFromUpdates];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    SPNPPollInformationViewController *controller = segue.destinationViewController;
    [controller setupWithManager:self.manager];
}


#pragma mark - Configuration

- (void)setupWithManager:(SPNPPollManager *)manager {
    
    self.manager = manager;
}


#pragma mark - Flow

- (void)showPollInformation {
    
    [self performSegueWithIdentifier:kSPNPShowPollViewControllerSegueIdentifier sender:self];
}


#pragma mark - Handlers

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                        change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    
    // Looks like active poll information has been changed.
    if ([keyPath isEqualToString:@"activePoll"] && !self.presentedViewController) {
        
        id activePoll = change[NSKeyValueChangeNewKey];
        if ([activePoll isEqual:[NSNull null]]) { activePoll = nil; }
        if (activePoll) { [self showPollInformation]; }
    }
}


#pragma mark - Misc

- (void)showError:(NSString *)errorMessage forOperation:(NSString *)operation {

    NSString *title = [operation stringByAppendingString:@" Error!"];
    NSString *message = [NSString stringWithFormat:@"%@ failed: %@", operation, errorMessage];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDestructive
                                               handler:^(UIAlertAction *action){

        [alert dismissViewControllerAnimated:YES completion:nil];
    }];
    [alert addAction:ok];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)subscribeOnUpdates {
    
    if (!self.subscribedOnUpdates) {
        
        self.subscribedOnUpdates = YES;
        [_manager addObserver:self forKeyPath:@"activePoll" options:NSKeyValueObservingOptionNew
                      context:nil];
    }
}

- (void)unsubscribeFromUpdates {
    
    if (self.subscribedOnUpdates) {
        
        self.subscribedOnUpdates = NO;
        [_manager removeObserver:self forKeyPath:@"activePoll" context:nil];
    }
}

- (void)dealloc {
    
    [self unsubscribeFromUpdates];
}

#pragma mark -


@end
