#import <UIKit/UIKit.h>


/**
 @brief  Vote application delegate to handle application state change and transitions.
 
 @author Sergey Mamontov
 @copyright © 2009-2015 PubNub, Inc.
 */
@interface SPNPAppDelegate : UIResponder <UIApplicationDelegate>


///------------------------------------------------
/// @name Information
///------------------------------------------------

/**
 @brief  Stores reference on main window in which interface should be presented to the user.
 */
@property (strong, nonatomic) UIWindow *window;

#pragma mark -


@end

