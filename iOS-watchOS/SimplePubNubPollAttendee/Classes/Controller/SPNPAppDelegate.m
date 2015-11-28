/**
 @author Sergey Mamontov
 @copyright © 2009-2015 PubNub, Inc.
 */
#import "SPNPAppDelegate.h"
#import "SPNPWaitingViewController.h"
#import "SPNPPollManager.h"


#pragma mark Private interface declaration

@interface SPNPAppDelegate ()


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
 @brief  Allow to complete application window customization.
 */
- (void)configureWindow;

#pragma mark -


@end


#pragma mark - Interface implementation

@implementation SPNPAppDelegate


#pragma mark - UIApplication delegate metfhods

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [self prepareDataSource];
    [self configureWindow];
    
    // Registering for push notifications.
    UIUserNotificationType types = (UIUserNotificationTypeAlert | UIUserNotificationTypeBadge |
                                    UIUserNotificationTypeSound);
    UIUserNotificationSettings* notificationSettings = [UIUserNotificationSettings settingsForTypes:types
                                                                                         categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:notificationSettings];
    [[UIApplication sharedApplication] registerForRemoteNotifications];
    
    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    [self.manager registerDevicePushToken:deviceToken];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    
    NSLog(@"Unable to receive device push token: %@", error);
}


#pragma mark - Data source

- (void)prepareDataSource {
    
    self.manager = [SPNPPollManager pollManagerHost:NO withHostIdentifier:@"com.pubnub.poll-demo"];
}


#pragma mark - Interface customization

- (void)configureWindow {
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    SPNPWaitingViewController *controller = [storyboard instantiateInitialViewController];
    [controller setupWithManager:self.manager];
    
    // Present user with initial interface.
    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    self.window.rootViewController = controller;
    [self.window makeKeyAndVisible];
}

#pragma mark -


@end
