#import <Foundation/Foundation.h>


#pragma mark Class forward

@class SPNPPollResponse, SPNPPoll;


/**
 @brief  Manager is intermediate layer between \b PubNub real-time service and user interface which
         implement polling functionality.
 
 @author Sergey Mamontov
 @copyright © 2009-2015 PubNub, Inc.
 */
@interface SPNPPollManager : NSObject


///------------------------------------------------
/// @name Information
///------------------------------------------------

/**
 @brief  Stores reference on currently active poll.
 */
@property (nonatomic, readonly, strong) SPNPPoll *activePoll;

/**
 @brief  Stores list of dynamically updated statistic instances for further representation.
 */
@property (nonatomic, readonly, strong) NSMutableArray *statistics;

/**
 @brief  Stores how many active attendees on current host session.
 */
@property (nonatomic, readonly, strong) NSNumber *attendeesCount;

/**
 @brief  Stores stringified attendees count which can be used to display in user interface.
 */
@property (nonatomic, readonly, copy) NSString *attendeesCountString;

/**
 @brief  Stores whether \b PubNub client has active connection or there was unexpected 
         disconnection.
 */
@property (nonatomic, readonly, assign, getter = isConnected) BOOL connected;

/**
 @brief  Stores whether \b PubNub client was able to restore polling session from history or not.
 */
@property (nonatomic, readonly, assign) BOOL restoredSession;

/**
 @brief  Stores whether \b PubNub client has been connected initially or not.
 */
@property (nonatomic, readonly, assign, getter = isInitiallyConnected) BOOL initiallyConnected;

/**
 @brief  Retrieve active poll question.
 
 @return Active poll question.
 */
- (NSString *)pollQuestion;

/**
 @brief  Retrieve active poll response variants.
 
 @return Active poll response variants.
 */
- (NSArray *)pollResponseVariants;


///------------------------------------------------
/// @name Initialization and Configuration
///------------------------------------------------

/**
 @brief  Create and configure poll manager using host identifier.
 
 @param isHost     Whether manager created for host or attendees.
 @param identifier Reference on unique host identifier which should be used by attendees to join to
                   polls announced by host.
 
 @return Configured and ready to use poll manager instance.
 */
+ (instancetype)pollManagerHost:(BOOL)isHost withHostIdentifier:(NSString *)identifier;

/**
 @brief  Use provided device push token to register it with set of required channels.
 
 @param token Reference on binary data token which should be used to register for push 
              notifications.
 */
- (void)registerDevicePushToken:(NSData *)token;


///------------------------------------------------
/// @name Operation manipulaion
///------------------------------------------------

/**
 @brief  Start poll manager communication using \b PubNub service.
 
 @param statusHandleBlock Reference on block which will be called by manager every time when
                          commectivity status will changed.  Block pass two arguments: 
                          \c connected - whether manager connected to real-time communication 
                          network or not; \c errorMessage - information about error because of which
                          manager was disconnected or was unable to connect.
 */
- (void)startWithStatusBlock:(void(^)(BOOL connected, NSString *errorMessage))statusHandleBlock;

/**
 @brief  Announce new polling and invite attendees.
 
 @param question Reference on question which should be suggested for attendees to response.
 @param variants List of responses from which used should choose.
 @param block    Reference on block which will be called at the end of announcement process. Block
                 pass two arguments: \c announced - whether new poll successfully announced or not;
                 \c errorMessage - information about error because of which announcement failed.
 */
- (void)announcePoll:(NSString *)question withResponse:(NSArray *)variants
     completionBlock:(void(^)(BOOL announced, NSString *errorMessage))block;

/**
 @brief  Inform attendees about poll completion.
 
 @param block Reference on block which should be called at the end of announcement. Block pass only
              one argument - announcement error message in case of failure.
 */
- (void)announcePollCompletionWithBlock:(void(^)(NSString *errorMessage))block;

/**
 @brief  Submit attendees response to the polling host.
 
 @param response Reference on response instance which represent user choice.
 @param block    Reference on block which should be called at the end of submittion process. Block
                 pass only one argument - submittion error description.
 */
- (void)submitResponse:(SPNPPollResponse *)response
   withCompletionBlock:(void(^)(NSString *errorMessage))block;

#pragma mark -


@end
