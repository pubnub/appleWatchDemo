/**
 @author Sergey Mamontov
 @copyright © 2009-2015 PubNub, Inc.
 */
#import "SPNPExtensionDelegate.h"
#import "SPNPPollManager.h"


#pragma mark Static 

/**
 @brief  Store name of controller which should be shown initially to the user.
 */
static NSString * const kSPNPPollWaitingScreenIdentifier = @"SPNPPollWaitingScreen";


#pragma mark - Private interface declaration

@interface SPNPExtensionDelegate ()


#pragma mark - Properties

/**
 @brief  Stores reference on poll manager instance.
 */
@property (nonatomic) SPNPPollManager *manager;


#pragma mark - Data source

/**
 @brief  Initialize all data models which is required for interface elements layout.
 */
- (void)prepareDataSource;


#pragma mark - Interface customization

/**
 @brief  Allow to complete controllers initialization.
 */
- (void)configureControllers;

#pragma mark - 


@end


#pragma mark - Interface implementation

@implementation SPNPExtensionDelegate

- (void)applicationDidFinishLaunching {
    
    [self prepareDataSource];
    [self configureControllers];
}


#pragma mark - Data source

- (void)prepareDataSource {
    
    self.manager = [SPNPPollManager pollManagerHost:NO withHostIdentifier:@"com.pubnub.poll-demo"];
}


#pragma mark - Interface customization

- (void)configureControllers {
    
    [WKInterfaceController reloadRootControllersWithNames:@[kSPNPPollWaitingScreenIdentifier]
                                                 contexts:@[self.manager]];
}

@end
