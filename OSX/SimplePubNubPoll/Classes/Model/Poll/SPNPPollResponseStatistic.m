/**
 @author Sergey Mamontov
 @copyright © 2009-2015 PubNub, Inc.
 */
#import "SPNPPollResponseStatistic.h"
#import "SPNPPollResponse.h"


#pragma mark Private interface declaration

@interface SPNPPollResponseStatistic () <NSCopying>


#pragma mark - Properties

@property (nonatomic, copy) NSString *response;
@property (nonatomic, strong) NSNumber *order;
@property (nonatomic, strong) NSNumber *votesCount;


#pragma mark - Initialization and Configuration

/**
 @brief  Initialize statistic object for concrete response variant.
 
 @param response Reference on response for which stats will be gathered.
 
 @return Initialized and ready to use statistic instance.
 */
- (instancetype)initWithResponse:(SPNPPollResponse *)response;

#pragma mark -


@end


#pragma mark - Interface implementation

@implementation SPNPPollResponseStatistic


#pragma mark - Initialization and Configuration

+ (instancetype)statisticForResponse:(SPNPPollResponse *)response {
    
    return [[self alloc] initWithResponse:response];
}

- (instancetype)initWithResponse:(SPNPPollResponse *)response {
    
    // Check whether initialization was successful or not.
    if ((self = [super init])) {
        
        _response = response.response;
        _order = response.order;
        _votesCount = @0;
    }
    
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    
    return self;
}


#pragma mark - Statistic

- (void)registerVoice {
    
    self.votesCount = @(self.votesCount.unsignedLongLongValue + 1);
}

#pragma mark -


@end
