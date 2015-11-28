#import <UIKit/UIKit.h>


#pragma mark Class forward

@class SPNPPollManager;


/**
 @brief      View controller which is used as 'waiting room'.
 @discussion Polling manager need some time to pull out information about active poll and statistic.
             Also this view used when there is no active polling and user just have to wait new to
             vote.
 
 @author Sergey Mamontov
 @copyright © 2009-2015 PubNub, Inc.
 */
@interface SPNPWaitingViewController : UIViewController


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

