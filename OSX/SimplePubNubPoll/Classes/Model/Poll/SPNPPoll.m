/**
 @author Sergey Mamontov
 @copyright © 2009-2015 PubNub, Inc.
 */
#import "SPNPPoll.h"
#import "SPNPPollResponse.h"


#pragma mark Private interface declaration

@interface SPNPPoll ()


#pragma mark - Properties

@property (nonatomic, copy) NSString *identifier;
@property (nonatomic, assign, getter = isActive) BOOL active;
@property (nonatomic, copy) NSString *question;
@property (nonatomic, copy) NSArray *responses;


#pragma mark - Initialization and Configuration

/**
 @brief  Initialize polling model for concrete question and response variants.
 
 @param question         Question on which attendees should respond.
 @param responseVariants List of response variants from which user should choose.
 
 @return Initialized and ready to use polling model.
 */
- (instancetype)initWithQuestion:(NSString *)question responses:(NSArray *)responseVariants;


#pragma mark - Misc

/**
 @brief  Convert response variant strings/dictionary representation into \b SPNPPollResponse 
         objects.
 
 @param variants List of question response variant strings.
 
 @return List of \b SPNPPollResponse objects.
 */
- (NSArray *)responsesFromList:(NSArray *)variants;

#pragma mark -


@end


#pragma mark - Interface implementation

@implementation SPNPPoll


#pragma mark - Initialization and Configuration

+ (instancetype)pollWithQuestion:(NSString *)question responses:(NSArray *)responseVariants {
    
    return [[self alloc] initWithQuestion:question responses:responseVariants];
}

- (instancetype)initWithQuestion:(NSString *)question responses:(NSArray *)responseVariants {
    
    // Check whether initialization was successful or not.
    if ((self = [super init])) {
        
        _identifier = [NSUUID UUID].UUIDString;
        _active = YES;
        _question = [question copy];
        _responses = [self responsesFromList:responseVariants];
    }
    
    return self;
}

- (instancetype)completedPoll {
    
    NSMutableDictionary *pollData = [[self dictionaryRepresentation] mutableCopy];
    pollData[@"active"] = @NO;
    
    return [self.class objectFromDictionaryRepresentation:pollData];
}

- (void)setResponses:(NSArray *)responses {
    
    [self willChangeValueForKey:@"responses"];
    NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"order" ascending:YES];
    _responses = [responses sortedArrayUsingDescriptors:@[descriptor]];
    [self didChangeValueForKey:@"responses"];
}


#pragma mark - Misc

- (NSArray *)responsesFromList:(NSArray *)variants {
    
    NSMutableArray *responses = (variants.count ? [NSMutableArray new] : nil);
    for (NSUInteger variantIdx = 0; variantIdx < variants.count; variantIdx++) {

        [responses addObject:[SPNPPollResponse pollResponseFor:_identifier withValue:variants[variantIdx]
                                                   orderNumber:@(variantIdx)]];
    }
    
    return [responses copy];
}

#pragma mark -


@end
