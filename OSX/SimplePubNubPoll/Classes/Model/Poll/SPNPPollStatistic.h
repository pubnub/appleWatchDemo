#import <Foundation/Foundation.h>
#import "SPNPSerializable.h"


#pragma mark Class forward

@class SPNPPoll;


/**
 @brief      Describes model which is used to describe poll response statistic.
 @discussion Object stores information about overall poll response options and how many votes they 
             have. This object posted by polling host on regular basis to eas catch-up process for
             attendees.
 
 @author Sergey Mamontov
 @copyright © 2009-2015 PubNub, Inc.
 */
@interface SPNPPollStatistic : SPNPSerializable


///------------------------------------------------
/// @name Information
///------------------------------------------------

/**
 @brief  Stores reference on target poll identifier.
 */
@property (nonatomic, readonly, copy) NSString *pollIdentifier;

/**
 @brief  Stores reference on list of response statistic objects.
 */
@property (nonatomic, readonly, strong) NSArray *responses;


///------------------------------------------------
/// @name Initialization and Configuration
///------------------------------------------------

/**
 @brief  Create and configure poll statistic information instance.
 
 @param poll             Reference on poll for which statistic information should be aggregated and
                         published.
 @param responseVariants List of response statistic instances.
 
 @return Configured and ready to use poll statistic instance.
 */
+ (instancetype)statisticForPoll:(SPNPPoll *)poll withResponses:(NSArray *)responseVariants;

#pragma mark -


@end
