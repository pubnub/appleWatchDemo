/**
 @author Sergey Mamontov
 @copyright © 2009-2015 PubNub, Inc.
 */
#import "SPNPPollResponse.h"


#pragma mark Private interface declaration

@interface SPNPPollResponse ()


#pragma mark - Properties

@property (nonatomic, copy) NSString *pollIdentifier;
@property (nonatomic, copy) NSString *response;
@property (nonatomic, assign) NSNumber *order;


#pragma mark - Initialization and Configuration

/**
 @brief  Initialize poll response model with predefined name and order index.
 
 @param pollIdentifier Identifier of the poll for which response object will be created.
 @param response       Response \c body which will be shown in user interface of host and attendees.
 @param order          Sorting order index and at the same time unique question identifier used 
                       during response submission.
 
 @return Initialized and ready to use poll response instance.
 */
- (instancetype)initFor:(NSString *)pollIdentifier withValue:(NSString *)response
            orderNumber:(NSNumber *)order;

#pragma mark -


@end


#pragma mark - Interface implementation

@implementation SPNPPollResponse


#pragma mark - Initialization and Configuration

+ (instancetype)pollResponseFor:(NSString *)pollIdentifier withValue:(NSString *)response
                    orderNumber:(NSNumber *)order {
    
    return [[self alloc] initFor:pollIdentifier withValue:response orderNumber:order];
}

- (instancetype)initFor:(NSString *)pollIdentifier withValue:(NSString *)response
            orderNumber:(NSNumber *)order {
    
    // Check whether initialization was successful or not.
    if ((self = [super init])) {
        
        _pollIdentifier = [pollIdentifier copy];
        _response = [response stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        _order = order;
    }
    
    return self;
}

#pragma mark - 


@end
