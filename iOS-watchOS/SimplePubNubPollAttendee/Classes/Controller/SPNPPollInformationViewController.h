#import <UIKit/UIKit.h>


#pragma mark Class forward

@class SPNPPollManager;


/**
 @brief  View controller used to show user voting options and voting stats in real-time.
 
 @author Sergey Mamontov
 @copyright © 2009-2015 PubNub, Inc.
 */
@interface SPNPPollInformationViewController : UIViewController


///------------------------------------------------
/// @name Configuration
///------------------------------------------------

/**
 @brief  Configure controller to work with polling manager.
 
 @param manager Reference on initialized polling manager.
 */
- (void)setupWithManager:(SPNPPollManager *)manager;

#pragma mark -


@end
