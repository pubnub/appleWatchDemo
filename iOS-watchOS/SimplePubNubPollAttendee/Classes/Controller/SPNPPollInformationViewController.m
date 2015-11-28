/**
 @author Sergey Mamontov
 @copyright © 2009-2015 PubNub, Inc.
 */
#import "SPNPPollInformationViewController.h"
#import "SPNPPollResponseStatistic.h"
#import "SPNPStatisticsView.h"
#import "SPNPPollStatistic.h"
#import "SPNPPollResponse.h"
#import "SPNPPollManager.h"
#import "SPNPPoll.h"


#pragma mark Private interface declaration

@interface SPNPPollInformationViewController () <UITableViewDelegate, UITableViewDataSource>


#pragma mark - Properties

@property (nonatomic) IBOutlet NSLayoutConstraint *constraint;

/**
 @brief  Stores reference on table which can be used by user to vote for one of poll variants.
 */
@property (nonatomic, weak) IBOutlet UITableView *pollResponsesTable;

/**
 @brief  Stores reference on label which is used to print out current poll title.
 */
@property (nonatomic, weak) IBOutlet UILabel *pollQuestionLabel;

/**
 @brief  Stores reference on action 'Submit' button.
 */
@property (nonatomic, weak) IBOutlet UIButton *submitButton;

/**
 @brief  Stores reference on the view which is reponsible for statistics information representation
         in real-time.
 */
@property (nonatomic, weak) IBOutlet SPNPStatisticsView *statisticsView;

/**
 @brief  Stores reference on previously selected response variant index path.
 */
@property (nonatomic) NSIndexPath *selectedResponseIndexPath;

/**
 @brief  Stores reference on manager which should be used for further attendees application
         working flow.
 */
@property (nonatomic) SPNPPollManager *manager;


#pragma mark - Interface customization

/**
 @brief  Complete initial user interface configuration using controller's state.
 */
- (void)prepareInterface;


#pragma mark - Flow



#pragma mark - Handlers

/**
 @brief  Handle user tap on 'Submit' button to process his voice.
 
 @param submitButton Reference on button on which user tapped.
 */
- (IBAction)handleSubmitButtonTap:(UIButton *)submitButton;


#pragma mark - Misc

/**
 @brief  Present to the user polling statistics.
 */
- (void)showPollStatistics;

/**
 @brief  Subscribe to all required manager state updates to represent them in time to the user.
 */
- (void)subscribeOnUpdates;

/**
 @brief  Unsubscribe from all previously tracked manager state.
 */
- (void)unsubscribeFromUpdates;

#pragma mark -


@end


#pragma mark - Interface implementation

@implementation SPNPPollInformationViewController


#pragma mark - Controller life-cycle

- (void)viewWillAppear:(BOOL)animated {
    
    // Forward method class to the super class.
    [super viewWillAppear:animated];
    
    [self prepareInterface];
}


#pragma mark - Configuration

- (void)setupWithManager:(SPNPPollManager *)manager {
    
    self.manager = manager;
    [self subscribeOnUpdates];
}


#pragma mark - Interface customization

- (void)prepareInterface {
    
    self.pollQuestionLabel.text = self.manager.activePoll.question;
    [self.statisticsView setupForPoll:self.manager.activePoll];
}

- (void)showPollStatistics {
    
    [self.statisticsView updateStatistics:self.manager.statistics];
    
    CGFloat value = self.constraint.constant;
    if (self.constraint.firstAttribute == NSLayoutAttributeTop) {
        
        value += ((UIView *)self.constraint.firstItem).frame.size.height;
    }
    else {
        value += ((UIView *)self.constraint.secondItem).frame.size.height;
    }
    self.constraint.constant = value;
}


#pragma mark - Handlers

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                        change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    
    // Looks like active poll information has been changed.
    if ([keyPath isEqualToString:@"activePoll"]) {
        
        id previousPoll = change[NSKeyValueChangeOldKey];
        id activePoll = change[NSKeyValueChangeNewKey];
        if ([previousPoll isEqual:[NSNull null]]) { previousPoll = nil; }
        if ([activePoll isEqual:[NSNull null]]) { activePoll = nil; }
        if (previousPoll && !activePoll) {
            
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
    else if ([keyPath isEqualToString:@"statistics"]) {
        
        [self.statisticsView updateStatistics:self.manager.statistics];
    }
}

- (IBAction)handleSubmitButtonTap:(UIButton *)submitButton {
    
    SPNPPollResponse *responseVariant = self.manager.activePoll.responses[self.selectedResponseIndexPath.row];
    __weak __typeof(self) weakSelf = self;
    [self.manager submitResponse:responseVariant withCompletionBlock:^(NSString *errorMessage) {
        
        __strong __typeof(self) strongSelf = weakSelf;
        if (!errorMessage) { [strongSelf showPollStatistics]; }
        else {
            
            NSString *message = [@"Response submission failed: " stringByAppendingString:errorMessage];
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Submit Error!"
                                        message:message preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDestructive
                                                       handler:^(UIAlertAction * _Nonnull action) {
                                                           
                [alert dismissViewControllerAnimated:YES completion:nil];
            }];
            [alert addAction:ok];
            [strongSelf presentViewController:alert animated:YES completion:nil];
        }
    }];
    submitButton.enabled = NO;
}


#pragma mark - UITableView delegate methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.manager.activePoll.responses.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return [tableView dequeueReusableCellWithIdentifier:@"SPNPPollResponseCell"];
}

- (void)  tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell
  forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    SPNPPollResponse *responseVariant = self.manager.activePoll.responses[indexPath.row];
    cell.textLabel.text = responseVariant.response;
    cell.layoutMargins = UIEdgeInsetsZero;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [tableView cellForRowAtIndexPath:self.selectedResponseIndexPath].accessoryType = UITableViewCellAccessoryNone;
    
    if ([indexPath isEqual:self.selectedResponseIndexPath]) { self.selectedResponseIndexPath = nil; }
    else { self.selectedResponseIndexPath = indexPath; }
    UITableViewCellAccessoryType type = (self.selectedResponseIndexPath ? UITableViewCellAccessoryCheckmark :
                                         UITableViewCellAccessoryNone);
    [tableView cellForRowAtIndexPath:indexPath].accessoryType = type;
    self.submitButton.enabled = (self.selectedResponseIndexPath != nil);
}


#pragma mark - Misc

- (void)subscribeOnUpdates {
    
    NSKeyValueObservingOptions options = (NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld);
    [_manager addObserver:self forKeyPath:@"statistics" options:options context:nil];
    [_manager addObserver:self forKeyPath:@"activePoll" options:options context:nil];
}

- (void)unsubscribeFromUpdates {
    
    [_manager removeObserver:self forKeyPath:@"statistics" context:nil];
    [_manager removeObserver:self forKeyPath:@"activePoll" context:nil];
}

- (void)dealloc {
    
    [self unsubscribeFromUpdates];
}

#pragma mark -

@end
