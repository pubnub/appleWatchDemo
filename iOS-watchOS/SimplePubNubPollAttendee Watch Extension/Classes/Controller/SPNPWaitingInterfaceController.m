/**
 @author Sergey Mamontov
 @copyright © 2009-2015 PubNub, Inc.
 */
#import "SPNPWaitingInterfaceController.h"
#import "SPNPPollManager.h"


#pragma mark Static

/**
 @brief  Stores reference on
 */
static NSString * const kSPNPChartsInterfaceController = @"SPNPPollStatisticsScreen";

#pragma mark - Private interface declaration

@interface SPNPWaitingInterfaceController()


#pragma mark - Properties

/**
 @brief  Reference on polls readines status label.
 */
@property (nonatomic) IBOutlet WKInterfaceLabel *status;

/**
 @brief  Reference on polls readines status label.
 */
@property (nonatomic) IBOutlet WKInterfaceButton *backToPollButton;

/**
 @brief  Stores whether controller already subscribed on manager events or not.
 */
@property (nonatomic, assign) BOOL subscribedOnUpdates;

/**
 @brief  Stores reference on manager which should be used for further attendees application
         working flow.
 */
@property (nonatomic) SPNPPollManager *manager;


#pragma mark - Interface

/**
 @brief  Update user interface basing on latest manager state.
 */
- (void)updateInterface;

/**
 @brief  Navigate attendee to the screen where he will be able to vote and watch poll stats in
 real-time.
 */
- (void)showPollInformation;


#pragma mark - Handlers

/**
 @brief  Handler user tap on \c back button.
 
 @param button Reference on button on which user tapped.
 */
- (IBAction)handleBackButtonTap:(WKInterfaceButton *)button;


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

@implementation SPNPWaitingInterfaceController


#pragma mark - Controller life-cycle

- (void)awakeWithContext:(id)context {
    
    // Forward method call to the super class.
    [super awakeWithContext:context];

    self.manager = context;
    
    __weak __typeof(self) weakSelf = self;
    [self.manager startWithStatusBlock:^(BOOL connected, NSString *errorMessage) {
        
        __strong __typeof(self) strongSelf = weakSelf;
        if (connected) {
            
            [strongSelf updateInterface];
            if (strongSelf.manager.activePoll) { [strongSelf showPollInformation]; }
            else { [self subscribeOnUpdates]; }
        }
        else { [strongSelf showError:errorMessage forOperation:@"Connection"]; }
    }];
}

- (void)willActivate {
    
    // Forward method call to the super class.
    [super willActivate];
    
    [self updateInterface];
}

#pragma mark - Interface

- (void)updateInterface {
    
    [self.backToPollButton setHidden:(self.manager.activePoll == nil)];
    if (self.manager.activePoll) {
        [self.status setText:@"Poll information\nreceived"];
    }
    else {
        [self.status setText:@"Waiting for\npoll data."];
    }
}

- (void)showPollInformation {
    
    [self presentControllerWithName:kSPNPChartsInterfaceController context:self.manager];
}


#pragma mark - Handlers

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                        change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    
    // Looks like active poll information has been changed.
    if ([keyPath isEqualToString:@"activePoll"]) {
        
        [self updateInterface];
        id activePoll = change[NSKeyValueChangeNewKey];
        if ([activePoll isEqual:[NSNull null]]) { activePoll = nil; }
        if (activePoll) { [self showPollInformation]; }
    }
}

- (IBAction)handleBackButtonTap:(WKInterfaceButton *)button {
    
    [self showPollInformation];
}


#pragma mark - Misc

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

- (void)showError:(NSString *)errorMessage forOperation:(NSString *)operation {
    
    NSString *title = [operation stringByAppendingString:@" Error!"];
    NSString *message = [NSString stringWithFormat:@"%@ failed: %@", operation, errorMessage];
    WKAlertAction *ok = [WKAlertAction actionWithTitle:@"OK" style:WKAlertActionStyleDestructive
                                               handler:^{ [self dismissController]; }];
    [self presentAlertControllerWithTitle:title message:message preferredStyle:WKAlertControllerStyleAlert
                                  actions:@[ok]];
}

- (void)dealloc {
    
    [self unsubscribeFromUpdates];
}

@end



