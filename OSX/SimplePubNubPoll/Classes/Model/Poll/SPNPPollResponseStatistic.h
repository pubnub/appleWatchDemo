#import <Foundation/Foundation.h>
#import "SPNPSerializable.h"


#pragma mark Class forward

@class SPNPPollResponse;


/**
 @brief      Describes model which is used to describe response stats.
 @discussion Object stores information about poll response option and how many votes it got.
 
 @author Sergey Mamontov
 @copyright © 2009-2015 PubNub, Inc.
 */
@interface SPNPPollResponseStatistic : SPNPSerializable


///------------------------------------------------
/// @name Information
///------------------------------------------------

/**
 @brief  Stores reference on response title.
 */
@property (nonatomic, readonly, copy) NSString *response;

/**
 @brief  Stores response order # in responses list. This number is also response item identifier.
 */
@property (nonatomic, readonly, strong) NSNumber *order;

/**
 @brief  Stores how many votes have been given to response.
 */
@property (nonatomic, readonly, strong) NSNumber *votesCount;


///------------------------------------------------
/// @name Initialization and Configuration
///------------------------------------------------

/**
 @brief  Create and configure statistic object for concrete response variant.
 
 @param response Reference on response for which stats will be gathered.
 
 @return Configured and ready to use statistic instance.
 */
+ (instancetype)statisticForResponse:(SPNPPollResponse *)response;


///------------------------------------------------
/// @name Statistic
///------------------------------------------------

/**
 @brief  Register voice for managed response.
 */
- (void)registerVoice;

#pragma mark -


@end
