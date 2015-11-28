/**
 @author Sergey Mamontov
 @copyright © 2009-2015 PubNub, Inc.
 */
#import "SPNPStatisticsGraphView.h"
#import "SPNPStatisticsGraphBarView.h"
#import "SPNPPollResponseStatistic.h"
#import "SPNPPollStatistic.h"


#pragma mark Private interface declaration

@interface SPNPStatisticsGraphView ()


#pragma mark - Properties

/**
 @brief  Properties stores reference on bar view which is used to represent single value.
 */
@property (nonatomic, weak) IBOutlet SPNPStatisticsGraphBarView *bar1View;
@property (nonatomic, weak) IBOutlet SPNPStatisticsGraphBarView *bar2View;
@property (nonatomic, weak) IBOutlet SPNPStatisticsGraphBarView *bar3View;
@property (nonatomic, weak) IBOutlet SPNPStatisticsGraphBarView *bar4View;
@property (nonatomic, weak) IBOutlet SPNPStatisticsGraphBarView *bar5View;

/**
 @brief  Stores whether graph view shown at least one portion of data or not.
 */
@property (nonatomic, assign) BOOL presentedData;

/**
 @brief  Stores reference on list of bars for which data available.
 */
@property (nonatomic) NSArray *activeBars;

#pragma mark -


@end


#pragma mark - Interface implementation

@implementation SPNPStatisticsGraphView


#pragma mark - Configuration

- (void)setupWithResponses:(NSArray *)pollResponses {
    
    NSArray *barsList = @[self.bar1View, self.bar2View, self.bar3View, self.bar4View, self.bar5View];
    if (pollResponses.count < barsList.count) {
        
        NSUInteger unusedBarsCount = (barsList.count - pollResponses.count);
        NSRange subarrayRange = NSMakeRange(pollResponses.count, unusedBarsCount);
        [[barsList subarrayWithRange:subarrayRange] makeObjectsPerformSelector:@selector(hide)];
        self.activeBars = [barsList subarrayWithRange:NSMakeRange(0, pollResponses.count)];
    }
    else { self.activeBars = barsList; }
}


#pragma mark - Data representation

- (void)updateStatistics:(NSArray *)pollStatistics {
    
    NSArray *values = [pollStatistics valueForKey:@"votesCount"];
    NSUInteger maximumValue = ((NSNumber *)[values valueForKeyPath:@"@max.self"]).unsignedIntegerValue;
    dispatch_block_t barsUpdateBlock = ^{
        
        [values enumerateObjectsUsingBlock:^(NSNumber *votesCount, NSUInteger responsIdx,
                                             BOOL *responsesStatisticEnumerationStop) {
            
            SPNPStatisticsGraphBarView *barView = self.activeBars[responsIdx];
            [barView showValue:votesCount.unsignedIntegerValue scale:maximumValue];
            [barView setNeedsDisplay];
        }];
        [self layoutIfNeeded];
        self.presentedData = YES;
    };
    if (!self.presentedData) {
        
        barsUpdateBlock();
    }
    else {
        
        [self needsUpdateConstraints];
        [UIView animateWithDuration:0.5f delay:0.0f usingSpringWithDamping:0.55f initialSpringVelocity:0.45f
                            options:UIViewAnimationOptionBeginFromCurrentState animations:barsUpdateBlock
                         completion:NULL];
    }
}

#pragma mark -


@end
