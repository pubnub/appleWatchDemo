/**
 @author Sergey Mamontov
 @copyright © 2009-2015 PubNub, Inc.
 */
#import "SPNPMainViewController.h"
#import "SPNPPollDataVerificator.h"
#import "SPNPPollManager.h"


#pragma mark Static

/**
 @brief  Stores name of the segue which should be shown during host session restore process.
 */
static NSString * const kSPNPShowSessionRestoreSegueIdentifier = @"SPNPShowSessionRestoreSegue";


#pragma mark - Private interface declaration

@interface SPNPMainViewController () <NSTabViewDelegate, NSTableViewDataSource>


#pragma mark - Properties

/**
 @brief  Stores reference on text field which can be used by user to specify question.
 */
@property (nonatomic, weak) IBOutlet NSTextField *questionField;

/**
 @brief  Stores reference on text field which can be used by user to specify possible variants to
         answer on question.
 */
@property (nonatomic, weak) IBOutlet NSTextField *variantsField;

/**
 @brief  Stores reference on buttons which allow to start/stop poll.
 */
@property (nonatomic, weak) IBOutlet NSButton *startPollButton;
@property (nonatomic, weak) IBOutlet NSButton *stopPollButton;

/**
 @brief  Stores reference on poll form verificator.
 */
@property (nonatomic, strong) IBOutlet SPNPPollDataVerificator *verificator;

/**
 @brief  Stores reference on array controller which is used to present user voting statistic 
         information.
 */
@property (nonatomic, strong) IBOutlet NSArrayController *statistics;

/**
 @brief  Stores reference on poll manager instance.
 */
@property (nonatomic) SPNPPollManager *manager;

/**
 @Brief  Stores reference on block which will be called by manager every time when commectivity 
         status will changed.
 */
@property (nonatomic, copy) void(^statusHandleBlock)(BOOL connected, NSString *errorMessage);


#pragma mark - Interface customization

/**
 @brief  Complete user interface configuration.
 */
- (void)completeInterfaceSetup;

/**
 @brief  Update interface basing on current controller state.
 */
- (void)updateElementsState;


#pragma mark - Data source

/**
 @brief  Initialize all data models which is required for interface elements layout.
 */
- (void)prepareDataSource;

/**
 @brief  Publish all required data about started poll.
 */
- (void)publishPollInformation;


#pragma mark - Handlers

/**
 @brief  Handle user tap on 'poll start' button to start new poll and send required information to
         attendees.
 */
- (IBAction)handlePollStartButtonClick:(NSButton *)button;

/**
 @brief  Handle user tap on 'poll stop' button to stop active poll and inform all attendees what 
         it is over.
 */
- (IBAction)handlePollStopButtonClick:(NSButton *)button;

#pragma mark -


@end


#pragma mark - Interface implementation

@implementation SPNPMainViewController


#pragma mark - Controller life-cycle

- (void)viewDidLoad {
    
    // Forward method call to the super class.
    [super viewDidLoad];
    
    [self prepareDataSource];
    [self completeInterfaceSetup];
}


#pragma mark - Interface customization

- (void)completeInterfaceSetup {
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [self performSegueWithIdentifier:kSPNPShowSessionRestoreSegueIdentifier sender:self];
        [self.manager startWithStatusBlock:self.statusHandleBlock];
    });
}

- (void)updateElementsState {
    
    self.questionField.stringValue = [self.manager pollQuestion];
    self.variantsField.stringValue = [[self.manager pollResponseVariants] componentsJoinedByString:@", "];
    [self.statistics rearrangeObjects];
}


#pragma mark - Data source

- (void)prepareDataSource {
    
    self.manager = [SPNPPollManager pollManagerHost:YES withHostIdentifier:@"com.pubnub.poll-demo"];
    self.statistics.content = self.manager.statistics;
    
    __weak __typeof(self) weakSelf = self;
    self.statusHandleBlock = ^(BOOL connected, NSString *errorMessage) {
        
        __strong __typeof(self) strongSelf = weakSelf;
        if (strongSelf.presentedViewControllers.count) {
            
            [strongSelf.presentedViewControllers makeObjectsPerformSelector:@selector(dismissController:)
                                                                 withObject:strongSelf];
        }
        
        if (connected) {
            
            if (strongSelf.manager.restoredSession) { [strongSelf updateElementsState]; }
            else { [strongSelf publishPollInformation]; }
        }
        else if (errorMessage) {
            
            NSAlert *alert = [NSAlert alertWithMessageText:@"Connection Error!" defaultButton:@"OK"
                                           alternateButton:nil otherButton:nil
                                 informativeTextWithFormat:@"Connection issues: %@", errorMessage];
            [alert beginSheetModalForWindow:strongSelf.view.window completionHandler:nil];
        }
    };
}

- (void)publishPollInformation {
    
    if (self.verificator.isValid) {
        
        __weak __typeof(self) weakSelf = self;
        NSArray *responseVariants = [self.variantsField.stringValue componentsSeparatedByString:@","];
        [self.manager announcePoll:self.questionField.stringValue withResponse:responseVariants
                   completionBlock:^(BOOL announced, NSString *errorMessage) {

            __strong __typeof(self) strongSelf = weakSelf;
            if (!announced) {

                NSAlert *alert = [NSAlert alertWithMessageText:@"Poll Announcement Failed!"
                                                 defaultButton:@"OK" alternateButton:nil otherButton:nil
                                     informativeTextWithFormat:@"Poll announcement issues: %@",
                                                               errorMessage];
                [alert beginSheetModalForWindow:strongSelf.view.window completionHandler:nil];
            }
            else {
                
                [strongSelf.statistics rearrangeObjects];
            }
        }];
    }
}


#pragma mark - Handlers

- (IBAction)handlePollStartButtonClick:(NSButton *)button {
    
    [self.view.window makeFirstResponder:nil];
    button.enabled = NO;
    
    if (!self.manager.isInitiallyConnected) {
        
        [self.manager startWithStatusBlock:self.statusHandleBlock];
    }
    else { [self publishPollInformation]; }
}

- (IBAction)handlePollStopButtonClick:(NSButton *)button {
    
    __weak __typeof(self) weakSelf = self;
    [self.manager announcePollCompletionWithBlock:^(NSString *errorMessage) {
        
        __strong __typeof(self) strongSelf = weakSelf;
        if (!errorMessage) {
            
            [strongSelf updateElementsState];
            [strongSelf.verificator reset];
        }
        else {
            
            NSAlert *alert = [NSAlert alertWithMessageText:@"Poll Completion Announcement Failed!"
                              defaultButton:@"OK" alternateButton:nil otherButton:nil
                              informativeTextWithFormat:@"Poll completion announcement issues: %@",
                               errorMessage];
            [alert beginSheetModalForWindow:strongSelf.view.window completionHandler:nil];
            
            
        }
    }];
}

#pragma mark -


@end
