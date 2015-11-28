/**
 @author Sergey Mamontov
 @copyright © 2009-2015 PubNub, Inc.
 */
#import "SPNPPollSessionRestoreViewController.h"


#pragma mark Private interface declaration

@interface SPNPPollSessionRestoreViewController ()

/**
 @brief  Stores reference on spinner which is shown to the user during session restore process.
 */
@property (nonatomic, weak) IBOutlet NSProgressIndicator *spinner;

#pragma mark -


@end


#pragma mark - Interface implementation

@implementation SPNPPollSessionRestoreViewController


#pragma mark - Controller life-cycle

- (void)viewDidLoad {
    
    // Forward method call to the super class.
    [super viewDidLoad];
    
    self.spinner.usesThreadedAnimation = YES;
    [self.spinner startAnimation:self];
}

- (void)viewDidDisappear {
    
    // Forward method call to the super class.
    [super viewDidDisappear];
    
    [self.spinner stopAnimation:self];
}

#pragma mark -


@end
