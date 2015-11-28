#import <Foundation/Foundation.h>
#import "SPNPSerializable.h"


/**
 @brief      Describes model which store all polling required information.
 @discussion This model used by host to announce new polling and by attendees to extract polling 
             information.
 
 @author Sergey Mamontov
 @copyright © 2009-2015 PubNub, Inc.
 */
@interface SPNPPoll : SPNPSerializable


///------------------------------------------------
/// @name Information
///------------------------------------------------

/**
 @brief  Stores unique poll identifier which is used during responses.
 */
@property (nonatomic, readonly, copy) NSString *identifier;

/**
 @brief  Stores whether poll is active or not.
 */
@property (nonatomic, readonly, assign, getter = isActive) BOOL active;

/**
 @brief  Stores reference on question on which attendees should respond.
 */
@property (nonatomic, readonly, copy) NSString *question;

/**
 @brief      Stores reference on list of response variants from which user should choose.
 @discussion \b SPNPPollResponse instances stored inside to provide poll serialization ability and 
             ease resopnses handling.
 */
@property (nonatomic, readonly, copy) NSArray *responses;


///------------------------------------------------
/// @name Initialization and Configuration
///------------------------------------------------

/**
 @brief  Create and configure polling model for concrete question and response variants.
 
 @param question         Question on which attendees should respond.
 @param responseVariants List of response variants from which user should choose.
 
 @return Configured and ready to use polling model.
 */
+ (instancetype)pollWithQuestion:(NSString *)question responses:(NSArray *)responseVariants;

/**
 @brief  Construct from existing poll instance the same but in inactive state.
 
 @return Reference on poll instance which has inactive state.
 */
- (instancetype)completedPoll;

#pragma mark - 


@end
