#import "SPNPSerializable.h"


/**
 @brief      Describes model which store information about single response on poll.
 @discussion This model used by host to describe single response on upcoming poll and used by 
             attendees to submit their response.
 
 @author Sergey Mamontov
 @copyright © 2009-2015 PubNub, Inc.
 */
@interface SPNPPollResponse : SPNPSerializable


///------------------------------------------------
/// @name Information
///------------------------------------------------

/**
 @brief  Stores reference on identifier of the poll for which response object will be created.
 */
@property (nonatomic, readonly, copy) NSString *pollIdentifier;

/**
 @brief Stores reference on response \c body which will be shown in user interface of host and 
        attendees.
 */
@property (nonatomic, readonly, copy) NSString *response;

/**
 @brief  Stores reference on sorting order index and at the same time unique question identifier 
         used during response submission.
 */
@property (nonatomic, readonly, assign) NSNumber *order;


///------------------------------------------------
/// @name Initialization and Configuration
///------------------------------------------------

/**
 @brief  Create and configure poll response model with predefined name and order index.
 
 @param pollIdentifier Identifier of the poll for which response object will be created.
 @param response       Response \c body which will be shown in user interface of host and attendees.
 @param order          Sorting order index and at the same time unique question identifier used 
                       during response submission.
 
 @return Configured and ready to use poll response instance.
 */
+ (instancetype)pollResponseFor:(NSString *)pollIdentifier withValue:(NSString *)response
                    orderNumber:(NSNumber *)order;

#pragma mark -


@end
