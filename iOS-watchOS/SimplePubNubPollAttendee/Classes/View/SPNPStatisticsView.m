/**
 @author Sergey Mamontov
 @copyright © 2009-2015 PubNub, Inc.
 */
#import "SPNPStatisticsView.h"
#import "SPNPStatisticsLegendView.h"
#import "SPNPStatisticsGraphView.h"
#import "SPNPPoll.h"


#pragma mark Private interface declaration

@interface SPNPStatisticsView ()


#pragma mark - Properties

/**
 @brief  Stores reference on view which is responsible for data representation to the user.
 */
@property (nonatomic, weak) IBOutlet SPNPStatisticsGraphView *graphView;

/**
 @brief  Stores reference on view which is used to show legend information to the user.
 */
@property (nonatomic, weak) IBOutlet SPNPStatisticsLegendView *legendView;

#pragma mark -


@end


#pragma mark - Interface implementation

@implementation SPNPStatisticsView


#pragma mark - Configuration

- (void)setupForPoll:(SPNPPoll *)poll {
    
    [self.legendView setupWithResponses:poll.responses];
    [self.graphView setupWithResponses:poll.responses];
}


#pragma mark - Data representation

- (void)updateStatistics:(NSArray *)pollStatistics {
    
    [self.graphView updateStatistics:pollStatistics];
}

#pragma mark -


@end
