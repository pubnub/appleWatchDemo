/**
 @author Sergey Mamontov
 @copyright © 2009-2015 PubNub, Inc.
 */
#import "SPNPPollStatistic.h"
#import "SPNPPoll.h"


#pragma mark Private interface declaration

@interface SPNPPollStatistic ()


#pragma mark - Properties

@property (nonatomic, copy) NSString *pollIdentifier;
@property (nonatomic, strong) NSArray *responses;


#pragma mark - Initialization and Configuration

/**
 @brief  Initialize poll statistic information instance.
 
 @param poll             Reference on poll for which statistic information should be aggregated and
                         published.
 @param responseVariants List of response statistic instances.
 
 @return Initialized and ready to use poll statistic instance.
 */
- (instancetype)initForPoll:(SPNPPoll *)poll withResponses:(NSArray *)responseVariants;

#pragma mark -


@end


#pragma mark - Interface implementation

@implementation SPNPPollStatistic


#pragma mark - Initialization and Configuration

+ (instancetype)statisticForPoll:(SPNPPoll *)poll withResponses:(NSArray *)responseVariants {
    
    return [[self alloc] initForPoll:poll withResponses:responseVariants];
}

- (instancetype)initForPoll:(SPNPPoll *)poll withResponses:(NSArray *)responseVariants {
    
    // Check whether initialization was successful or not.
    if ((self = [super init])) {
        
        _pollIdentifier = [poll.identifier copy];
        _responses = responseVariants;
    }
    
    return self;
}

#pragma mark -


@end
