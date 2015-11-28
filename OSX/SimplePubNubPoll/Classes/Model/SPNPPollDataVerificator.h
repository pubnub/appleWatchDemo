#import <Foundation/Foundation.h>


/**
 @brief      Class describes verification model used during new poll creation.
 @discussion This verificator used by interface elements to change their state basing on whether 
             valid data has been passed for new poll or not.
 
 @author Sergey Mamontov
 @copyright © 2009-2015 PubNub, Inc.
 */
@interface SPNPPollDataVerificator : NSObject


///------------------------------------------------
/// @name Information
///------------------------------------------------

/**
 @brief  Stores information on whether valid information has been passed by user for polling or not.
 */
@property (nonatomic, readonly, assign, getter = isValid) BOOL valid;


///------------------------------------------------
/// @name State management
///------------------------------------------------

/**
 @brief  Reset verificator cached state.
 */
- (void)reset;

#pragma mark -


@end
