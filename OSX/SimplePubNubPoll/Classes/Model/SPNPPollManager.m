/**
 @author Sergey Mamontov
 @copyright © 2009-2015 PubNub, Inc.
 */
#import "SPNPPollManager.h"
#import "SPNPPollResponseStatistic.h"
#import "SPNPPollStatistic.h"
#import "SPNPPollResponse.h"
#import <PubNub/PubNub.h>
#import "SPNPPoll.h"


#pragma mark Static

/**
 @brief  Stores reference on key which is required by \b PubNub client to give ability to retrieve
         real-time updates.
 */
static NSString * const kSPNPPubNubSubscribeKey = @"demo-36";

/**
 @brief  Stores reference on key which is required by \b PubNub client to give ability to push data
         to data channels.
 */
static NSString * const kSPNPPubNubPublishKey = @"demo-36";

/**
 @brief  Stores value which is used by statistic update timer if new data available.
 */
static NSTimeInterval const kSPNPStatisticRefreshInterval = 0.5f;


#pragma mark - Private interface declaration

@interface SPNPPollManager () <PNObjectEventListener>


#pragma mark - Properties

/**
 @brief  Stores reference on \b PubNub client which is used for real-time communication with 
         attendees to send them updates and accept data.
 */
@property (nonatomic) PubNub *client;

/**
 @brief  Stores reference on unique host identifier which is used to build data channel names for
         subscription and data publish.
 */
@property (nonatomic, copy) NSString *identifier;

/**
 @brief  Stores whether instance has been created for polls host or not.
 */
@property (nonatomic, assign, getter = isHost) BOOL host;

@property (nonatomic, strong) SPNPPoll *activePoll;
@property (nonatomic, assign) BOOL restoredSession;
@property (nonatomic, strong) NSNumber *attendeesCount;
@property (nonatomic, copy) NSString *attendeesCountString;
@property (nonatomic, assign, getter = isConnected) BOOL connected;
@property (nonatomic, assign, getter = isInitiallyConnected) BOOL initiallyConnected;

/**
 @brief  Stores reference on timer which is used to publish poll statistic for attendees.
 */
@property (nonatomic) NSTimer *statisticUpdateTimer;

/**
 @brief  Stores whether manager store some polling statistic which wasn't published yet.
 */
@property (nonatomic, assign) BOOL hasUnupblishedStatistic;

/**
 @Brief  Stores reference on block which will be called by manager every time when commectivity 
         status will changed.
 */
@property (nonatomic, copy) void(^statusHandleBlock)(BOOL connected, NSString *errorMessage);


#pragma mark - Initialization and Configuration

/**
 @brief  Initialize poll manager using host identifier.
 
 @param isHost     Whether manager created for host or attendees.
 @param identifier Reference on unique host identifier which should be used by attendees to join to
 polls announced by host.
 
 @return Initialized and ready to use poll manager instance.
 */
- (instancetype)initHost:(BOOL)isHost withHostIdentifier:(NSString *)identifier;

/**
 @brief  Complete \b PunNub client configuraion.
 */
- (void)initializePubNubClient;


#pragma mark - Restore

/**
 @brief  Try to restore polling host state basing on previously active polling sessions and stats
         channels.
 
 @param completionBlock Reference on block which should be called at the end of recovery process.
                        Block pass only one argument - error message in case if restore process 
                        failed.
 */
- (void)restoreHostStateWith:(void(^)(NSString *errorMessage))completionBlock;

/**
 @brief  Try to find for previously started and not completed polling sessions.
 
 @param block Reference on block which should be called at the end of search process. Block is able 
              to pass two arguments: \c poll - reference on previously started poll instance or 
              \c nil in case if there was no active polls; \c errorMessage - in case of any error
              will contain error message description.
 */
- (void)searchForPreviousPollSessionWith:(void(^)(SPNPPoll *poll, NSString *errorMessage))block;

/**
 @brief  Try to restore latest statistic for passed poll instance.
 
 @param poll  Reference on active poll for which manager should try to restore stats.
 @param block Reference on block which should be called at the end of restore process. Block pass
              only one argument - error message in case if restore process failed.
 */
- (void)restoreStatisticInformationFor:(SPNPPoll *)poll
                             withBlock:(void(^)(NSString *errorMessage))block;


#pragma mark - Statistic

/**
 @brief  Use host provided statistic information to update local cache.
 
 @param statistics Reference on list of statistic instances objects.
 */
- (void)updateStatisticFromHost:(NSArray *)statistics;

/**
 @brief  Use passed response instance to increase counter for passed response option.
 
 @param response Reference on response instance for which used gave his voice.
 */
- (void)updateStatisticInformationForResponse:(SPNPPollResponse *)response;

/**
 @brief  Launch timer which is responsible for statistic updated.
 */
- (void)startStatisticPublising;

/**
 @brief  Stop timer which is responsible for statistic publish triggering.
 */
- (void)stopStatisticPublishing;

/**
 @brief  Publish aggrgated statistic to the stats channel used by attendees to get results in
         real-time.
 */
- (void)publishStatistic;


#pragma mark - Misc

/**
 @brief  Fill up statistic instance with initial statistic information for just started test.
 
 @param statistics Reference on list of response statistic instances.
 */
- (void)setInitialStatisticStateWith:(NSArray *)statistics;

/**
 @brief  Retrieve reference on list of channel names on which \b PubNub client should subscribe.
 
 @return List of channel names.
 */
- (NSArray *)channelsForSubscription;

/**
 @brief  Channel name construction helpers.
 */
- (NSString *)pollChannelName;
- (NSString *)pollStatisticsChannelName;
- (NSString *)answersChannelName;

#pragma mark -


@end


#pragma mark - Interface implementation

@implementation SPNPPollManager


#pragma mark - Initialization and Configuration


+ (instancetype)pollManagerHost:(BOOL)isHost withHostIdentifier:(NSString *)identifier {
    
    return [[self alloc] initHost:isHost withHostIdentifier:identifier];
}

- (instancetype)initHost:(BOOL)isHost withHostIdentifier:(NSString *)identifier {
    
    // Check whether initialization was successful or not.
    if ((self = [super init])) {
        
        _host = isHost;
        _identifier = [identifier copy];
        _statistics = [NSMutableArray new];
        [self initializePubNubClient];
    }
    
    return self;
}

- (void)initializePubNubClient {
    
    [PNLog enabled:YES];
    PNConfiguration *configuration = [PNConfiguration configurationWithPublishKey:kSPNPPubNubPublishKey
                                                                     subscribeKey:kSPNPPubNubSubscribeKey];
    if (_host) { configuration.uuid = _identifier; }
    _client = [PubNub clientWithConfiguration:configuration];
    [_client addListener:self];
}

- (void)registerDevicePushToken:(NSData *)token {
    
    [self.client addPushNotificationsOnChannels:@[[self pollChannelName]] withDevicePushToken:token
                                  andCompletion:nil];
}


#pragma mark - Information

- (NSString *)pollQuestion {
    
    return (self.activePoll.question?: @"");
}

- (NSArray *)pollResponseVariants {
    
    return ([self.activePoll.responses valueForKey:@"response"]?: @[]);
}


#pragma mark - Operation manipulaion

- (void)startWithStatusBlock:(void(^)(BOOL connected, NSString *errorMessage))statusHandleBlock {
    
    self.statusHandleBlock = statusHandleBlock;
    __weak __typeof(self) weakSelf = self;
    [self restoreHostStateWith:^(NSString *errorMessage){
        
        __strong __typeof(self) strongSelf = weakSelf;
        if (!errorMessage) {
            
            [strongSelf.client subscribeToChannels:[strongSelf channelsForSubscription]
                                      withPresence:NO];
        }
        else if (strongSelf.statusHandleBlock) { strongSelf.statusHandleBlock(NO, errorMessage); }
    }];
}

- (void)announcePoll:(NSString *)question withResponse:(NSArray *)variants
     completionBlock:(void(^)(BOOL announced, NSString *errorMessage))block {
    
    if (!self.activePoll) {
        
        SPNPPoll *poll = [SPNPPoll pollWithQuestion:question responses:variants];
        NSDictionary *aps = @{@"aps": @{@"alert": @"New poll announced!"}};
        __weak __typeof(self) weakSelf = self;
        [self.client publish:[poll dictionaryRepresentation] toChannel:[self pollChannelName]
           mobilePushPayload:aps compressed:YES withCompletion:^(PNPublishStatus *status) {
                  
            __strong __typeof(self) strongSelf = weakSelf;
            NSString *publishErrorMessage = nil;
            if (status.isError) { publishErrorMessage = status.errorData.information; }
            if (!status.isError) {
                
                strongSelf.activePoll = poll;
                [strongSelf setInitialStatisticStateWith:nil];
                [strongSelf startStatisticPublising];
            }
            block(!status.isError, publishErrorMessage);
        }];
    }
    else { block(YES, nil); }
}

- (void)announcePollCompletionWithBlock:(void(^)(NSString *errorMessage))block {
    
    [self publishStatistic];
    __weak __typeof(self) weakSelf = self;
    NSDictionary *aps = @{@"aps": @{@"alert": @"Poll has been completed!"}};
    [self.client publish:[[self.activePoll completedPoll] dictionaryRepresentation]
               toChannel:[self pollChannelName] mobilePushPayload:aps compressed:YES
          withCompletion:^(PNPublishStatus *status) {
              
        __strong __typeof(self) strongSelf = weakSelf;
        if (!status.isError) {
            
            strongSelf.activePoll = nil;
            [strongSelf.statistics removeAllObjects];
            [strongSelf stopStatisticPublishing];
        }
        block(status.isError ? status.errorData.information : nil);
    }];
}

- (void)submitResponse:(SPNPPollResponse *)response
   withCompletionBlock:(void(^)(NSString *errorMessage))block {
    
    [self.client publish:[response dictionaryRepresentation] toChannel:[self answersChannelName]
              compressed:YES withCompletion:^(PNPublishStatus *status) {
              
        block(status.isError ? status.errorData.information : nil);
    }];
}


#pragma mark - Restore

- (void)restoreHostStateWith:(void(^)(NSString *errorMessage))completionBlock {
    
    __weak __typeof(self) weakSelf = self;
    [self searchForPreviousPollSessionWith:^(SPNPPoll *poll, NSString *searchErrorMessage) {
        
        __strong __typeof(self) strongSelf = weakSelf;
        strongSelf.activePoll = poll;
        strongSelf.restoredSession = (poll != nil);
        if (strongSelf.restoredSession) {
            
            [strongSelf restoreStatisticInformationFor:strongSelf.activePoll
                                             withBlock:^(NSString *errorMessage) {
                
                completionBlock(errorMessage);
                [strongSelf startStatisticPublising];
            }];
        }
        else { completionBlock(searchErrorMessage); }
    }];
}

- (void)searchForPreviousPollSessionWith:(void(^)(SPNPPoll *poll, NSString *errorMessage))block {
    
    [self.client historyForChannel:[self pollChannelName] start:nil end:nil limit:1
                    withCompletion:^(PNHistoryResult *result, PNErrorStatus *status) {

        SPNPPoll *poll = [SPNPPoll objectFromDictionaryRepresentation:result.data.messages.lastObject];
        block((poll.isActive ? poll : nil), (status.isError ? status.errorData.information : nil));
    }];
}

- (void)restoreStatisticInformationFor:(SPNPPoll *)poll
                             withBlock:(void(^)(NSString *errorMessage))block {
    
    __weak __typeof(self) weakSelf = self;
    [self.client historyForChannel:[self pollStatisticsChannelName] start:nil end:nil limit:1
                    withCompletion:^(PNHistoryResult *result, PNErrorStatus *status) {
        
        __strong __typeof(self) strongSelf = weakSelf;
        NSDictionary *object = result.data.messages.lastObject;
        SPNPPollStatistic *statistic = [SPNPPollStatistic objectFromDictionaryRepresentation:object];
        if (statistic && [statistic.pollIdentifier isEqualToString:strongSelf.activePoll.identifier]) {
            
            [strongSelf setInitialStatisticStateWith:statistic.responses];
        }
        else { [strongSelf setInitialStatisticStateWith:nil]; }
        block(status.isError ? status.errorData.information : nil);
    }];
}


#pragma mark - Statistic

- (void)updateStatisticFromHost:(NSArray *)statistics {
    
    [self willChangeValueForKey:@"statistics"];
    NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"order" ascending:YES];
    NSArray *sortedStatistics = [statistics sortedArrayUsingDescriptors:@[descriptor]];
    [_statistics removeAllObjects];
    [_statistics addObjectsFromArray:sortedStatistics];
    [self didChangeValueForKey:@"statistics"];
}

- (void)updateStatisticInformationForResponse:(SPNPPollResponse *)response {
    
    [self willChangeValueForKey:@"statistics"];
    SPNPPollResponseStatistic *responseStatistic = self.statistics[response.order.unsignedIntegerValue];
    [responseStatistic registerVoice];
    [self didChangeValueForKey:@"statistics"];
}

- (void)startStatisticPublising {
    
    [self stopStatisticPublishing];
    self.statisticUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:kSPNPStatisticRefreshInterval
                                 target:self selector:@selector(publishStatistic) userInfo:nil
                                                                repeats:YES];
}

- (void)stopStatisticPublishing {
    
    if (self.statisticUpdateTimer.isValid) {
        
        [self.statisticUpdateTimer invalidate];
        self.statisticUpdateTimer = nil;
    }
}

- (void)publishStatistic {
    
    if (self.hasUnupblishedStatistic && self.activePoll) {
        
        self.hasUnupblishedStatistic = NO;
        SPNPPollStatistic *statistics = [SPNPPollStatistic statisticForPoll:self.activePoll
                                                              withResponses:self.statistics];
        __weak __typeof(self) weakSelf = self;
        [self.client publish:[statistics dictionaryRepresentation]
                   toChannel:[self pollStatisticsChannelName] compressed:YES
              withCompletion:^(PNPublishStatus *status) {
            
            __strong __typeof(self) strongSelf = weakSelf;
            if (status.isError) { strongSelf.hasUnupblishedStatistic = YES; }
        }];
    }
}


#pragma mark - PubNub event listener

- (void)client:(PubNub *)client didReceiveStatus:(PNStatus *)status {
    
    if (status.operation == PNSubscribeOperation) {
        
        __block NSString *errorMessage = nil;
        if (status.category == PNUnexpectedDisconnectCategory) {
            
            errorMessage = ((PNErrorStatus *)status).errorData.information;
        }
        self.connected = (errorMessage == nil);
        if (!self.isInitiallyConnected && self.isConnected) {
            
            self.initiallyConnected = YES;
        }
        if (self.statusHandleBlock) { self.statusHandleBlock(errorMessage == nil, errorMessage); }
    }
    else if (status.operation == PNUnsubscribeOperation && self.statusHandleBlock) {
        
        self.statusHandleBlock(NO, nil);
    }
}

- (void)client:(PubNub *)client didReceivePresenceEvent:(PNPresenceEventResult *)event {
    
    if ([event.data.subscribedChannel isEqualToString:self.identifier]) {
        
        self.attendeesCount = @(event.data.presence.occupancy.unsignedLongLongValue - 1);
        self.attendeesCountString = [NSString stringWithFormat:@"%@",
                                     (self.attendeesCount.unsignedLongLongValue == 0) ?
                                     @"--" : self.attendeesCount];
    }
}

- (void)client:(PubNub *)client didReceiveMessage:(PNMessageResult *)message {
    
    NSString *channelName = message.data.subscribedChannel;
    NSDictionary *data = message.data.message;
    
    // Handle responses from poll attendees.
    if ([channelName isEqualToString:[self answersChannelName]]) {
        
        self.hasUnupblishedStatistic = YES;
        SPNPPollResponse *response = [SPNPPollResponse objectFromDictionaryRepresentation:data];
        [self updateStatisticInformationForResponse:response];
    }
    // Handle stats from host.
    else if ([channelName isEqualToString:[self pollStatisticsChannelName]]) {
        
        SPNPPollStatistic *statistics = [SPNPPollStatistic objectFromDictionaryRepresentation:data];
        [self updateStatisticFromHost:statistics.responses];
    }
    // Handle polls announcements from host.
    else if ([channelName isEqualToString:[self pollChannelName]]) {
        
        SPNPPoll *poll = [SPNPPoll objectFromDictionaryRepresentation:data];
        self.activePoll = (poll.isActive ? poll : nil);
        if (self.activePoll) { [self setInitialStatisticStateWith:nil]; }
        else { [self.statistics removeAllObjects]; }
    }
}


#pragma mark - Misc

- (void)setInitialStatisticStateWith:(NSArray *)statistics {
    
    NSMutableArray *responseStatistics = nil;
    NSArray *pollResponses = self.activePoll.responses;
    NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"order" ascending:YES];
    NSArray *sortedResponses = [(statistics?: pollResponses) sortedArrayUsingDescriptors:@[descriptor]];
    if (!statistics) {
        
        responseStatistics = [NSMutableArray new];
        [sortedResponses enumerateObjectsUsingBlock:^(SPNPPollResponse *response, NSUInteger responseIdx,
                                                      BOOL *responsesEnumeratorStop) {
            
            [responseStatistics addObject:[SPNPPollResponseStatistic statisticForResponse:response]];
        }];
    }
    [self.statistics addObjectsFromArray:(responseStatistics?: sortedResponses)];
}

- (NSArray *)channelsForSubscription {
    
    NSMutableArray *channels = [@[self.identifier] mutableCopy];
    [channels addObject:[self.identifier stringByAppendingString:@"-pnpres"]];
    if (self.isHost) {
        
        [channels addObjectsFromArray:@[[self answersChannelName]]];
    }
    else {
        
        [channels addObjectsFromArray:@[[self pollChannelName], [self pollStatisticsChannelName]]];
    }
    
    return [channels copy];
}

- (NSString *)pollChannelName {
    
    return [self.identifier stringByAppendingString:@"-poll"];
}

- (NSString *)pollStatisticsChannelName {
    
    return [self.identifier stringByAppendingString:@"-stat"];
}

- (NSString *)answersChannelName {
    
    return [self.identifier stringByAppendingString:@"-res"];
}

#pragma mark -


@end
