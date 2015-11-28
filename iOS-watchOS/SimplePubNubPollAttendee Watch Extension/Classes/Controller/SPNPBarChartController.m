/**
 @author Sergey Mamontov
 @copyright © 2009-2015 PubNub, Inc.
 */
#import "SPNPBarChartController.h"
#import "SPNPPollResponseStatistic.h"
#import "SPNPBarChartLegendCell.h"
#import "SPNPPollResponse.h"
#import "SPNPChartBarView.h"
#import "SPNPPollManager.h"
#import "SPNPPoll.h"


#pragma mark Static

/**
 @brief  Stores maximum number of bars which can be displayed on the screen at the same time.
 */
static NSUInteger const kWKNumberOfChartBars = 5;

/**
 @brief  Stores chart change animation duration.
 */
static CGFloat const kWKChartUpdateAnimationDuration = 0.3f;

/**
 @brief  Stores name of the cell which should be used for bar chart legend representation.
 */
static NSString * const kSPNPBarChartLegendCell = @"SPNPBarChartLegendCell";


#pragma mark - Private interface declaration

@interface SPNPBarChartController ()


#pragma mark - Properties

/**
 @brief  Stores reference on label which is used for poll question output.
 */
@property (nonatomic, weak) IBOutlet WKInterfaceLabel *pollQuestion;

/**
 @brief  Stores reference on table which is used for chart legend layout.
 */
@property (nonatomic, weak) IBOutlet WKInterfaceTable *legendTable;

/**
 @brief  References on bar chart components
 */
@property (nonatomic) IBOutlet WKInterfaceGroup *barHolder1;
@property (nonatomic) IBOutlet WKInterfaceGroup *barHolder2;
@property (nonatomic) IBOutlet WKInterfaceGroup *barHolder3;
@property (nonatomic) IBOutlet WKInterfaceGroup *barHolder4;
@property (nonatomic) IBOutlet WKInterfaceGroup *barHolder5;

@property (nonatomic) IBOutlet WKInterfaceLabel *barValue1;
@property (nonatomic) IBOutlet WKInterfaceLabel *barValue2;
@property (nonatomic) IBOutlet WKInterfaceLabel *barValue3;
@property (nonatomic) IBOutlet WKInterfaceLabel *barValue4;
@property (nonatomic) IBOutlet WKInterfaceLabel *barValue5;

@property (nonatomic) IBOutlet WKInterfaceGroup *bar1;
@property (nonatomic) IBOutlet WKInterfaceGroup *bar2;
@property (nonatomic) IBOutlet WKInterfaceGroup *bar3;
@property (nonatomic) IBOutlet WKInterfaceGroup *bar4;
@property (nonatomic) IBOutlet WKInterfaceGroup *bar5;

/**
 @brief  Stores reference on list of chart bars with which it should work.
 */
@property (nonatomic) NSMutableArray *bars;

/**
 @brief  Stores position dependant list of bar colors.
 */
@property (nonatomic) NSArray *barsColor;

/**
 @brief  Stores reference on manager which should be used for further attendees application
         working flow.
 */
@property (nonatomic) SPNPPollManager *manager;

/**
 @brief  Stores number of charts which is displayed on screen at this moment.
 */
@property (nonatomic, assign) NSUInteger entriesCount;


#pragma mark - Interface

/**
 @brief  Perform initial interface preparation.
 */
- (void)prepareInterface;

/**
 @brief  Provide chart legend table with data to show up.
 */
- (void)updateChartLegend;

/**
 @brief  Try to pass cached statistics information to build graphs.
 */
- (void)updateStatistics;

/**
 @brief  Update displayed chart information with user provided data.
 
 @param statistics Reference on list of response statistics entries.
 @param animated   Whether update should be animated or not.
 */
- (void)updateStatistics:(NSArray *)statistics animated:(BOOL)animated;


#pragma mark - Misc

/**
 @brief  Gather all outlets and wrap them into classes which is easier to use.
 */
- (void)prepareChartBars;

/**
 @brief  Subscribe to all required manager state updates to represent them in time to the user.
 */
- (void)subscribeOnUpdates;

/**
 @brief  Unsubscribe from all previously tracked manager state.
 */
- (void)unsubscribeFromUpdates;


#pragma mark -


@end


#pragma mark - Interface implementation

@implementation SPNPBarChartController


#pragma mark - Controller life-cycle

- (void)awakeWithContext:(id)context {
    
    // Forward method call to the super class.
    [super awakeWithContext:context];
    
    [self prepareChartBars];
    self.manager = context;
    [self prepareInterface];
    [self subscribeOnUpdates];
}


#pragma mark - Interface

- (void)prepareInterface {
    
    [self.pollQuestion setText:self.manager.activePoll.question];
    [self updateChartLegend];
    [self updateStatistics];
}

- (void)updateChartLegend {
    
    NSArray *responses = self.manager.activePoll.responses;
    [self.legendTable setNumberOfRows:responses.count withRowType:kSPNPBarChartLegendCell];
    [responses enumerateObjectsUsingBlock:^(SPNPPollResponse *response, NSUInteger responseIdx,
                                            BOOL *responsesEnumeratorStop) {
        
        SPNPBarChartLegendCell *cell = [self.legendTable rowControllerAtIndex:responseIdx];
        [cell updateWithTitle:response.response color:self.barsColor[responseIdx]];
    }];
}

- (void)updateStatistics {
    
    [self updateStatistics:self.manager.statistics animated:(self.entriesCount != 0)];
    self.entriesCount = self.manager.statistics.count;
}

- (void)updateStatistics:(NSArray *)statistics animated:(BOOL)animated {
    
    if (animated) {
        
        [self animateWithDuration:kWKChartUpdateAnimationDuration animations:^{
        
            [self updateStatistics:statistics animated:NO];
        }];
    }
    else {
        
        NSArray *values = [statistics valueForKey:@"votesCount"];
        NSUInteger maximumValue = ((NSNumber *)[values valueForKeyPath:@"@max.self"]).unsignedIntegerValue;
        CGFloat screenWidth = [WKInterfaceDevice currentDevice].screenBounds.size.width;
        [statistics enumerateObjectsUsingBlock:^(SPNPPollResponseStatistic *statistic,
                                                NSUInteger statisticIdx,
                                                BOOL *statisticsEnumeratorStop) {
            
            SPNPChartBarView *bar = self.bars[statisticIdx];
            
            if (self.entriesCount == 0) { [bar setWidth:(screenWidth / statistics.count)]; }
            [bar showValue:statistic.votesCount withTitle:statistic.response
                   percent:(statistic.votesCount.floatValue / MAX(maximumValue, 0.001f))];
        }];
    }
}


#pragma mark - Handlers

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                        change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    
    // Looks like active poll information has been changed.
    if ([keyPath isEqualToString:@"activePoll"]) {
        
        id previousPoll = change[NSKeyValueChangeOldKey];
        id activePoll = change[NSKeyValueChangeNewKey];
        if ([previousPoll isEqual:[NSNull null]]) { previousPoll = nil; }
        if ([activePoll isEqual:[NSNull null]]) { activePoll = nil; }
        if (previousPoll && !activePoll) { [self dismissController]; }
    }
    else if ([keyPath isEqualToString:@"statistics"]) {
        
        [self updateStatistics];
    }
}


#pragma mark - Misc

- (void)subscribeOnUpdates {
    
    NSKeyValueObservingOptions options = (NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld);
    [_manager addObserver:self forKeyPath:@"statistics" options:options context:nil];
    [_manager addObserver:self forKeyPath:@"activePoll" options:options context:nil];
}

- (void)unsubscribeFromUpdates {
    
    [_manager removeObserver:self forKeyPath:@"statistics" context:nil];
    [_manager removeObserver:self forKeyPath:@"activePoll" context:nil];
}

- (void)prepareChartBars {
    
    _barsColor = @[[UIColor colorWithRed:(38.0/255.0) green:(120.0/255.0) blue:(178.0/255.0) alpha:1.0],
                   [UIColor colorWithRed:(253.0/255.0) green:(127.0/255.0) blue:(40.0/255.0) alpha:1.0],
                   [UIColor colorWithRed:(51.0/255.0) green:(159.0/255.0) blue:(52.0/255.0) alpha:1.0],
                   [UIColor colorWithRed:(212.0/255.0) green:(42.0/255.0) blue:(47.0/255.0) alpha:1.0],
                   [UIColor colorWithRed:(58.0/255.0) green:(148.0/255.0) blue:(90.0/255.0) alpha:1.0]];
    _bars = [NSMutableArray new];
    for (NSUInteger barIdx = 1; barIdx <= kWKNumberOfChartBars; barIdx++) {
        
        WKInterfaceGroup *holder = [self valueForKey:[NSString stringWithFormat:@"barHolder%d", barIdx]];
        WKInterfaceLabel *value = [self valueForKey:[NSString stringWithFormat:@"barValue%d", barIdx]];
        WKInterfaceGroup *bar = [self valueForKey:[NSString stringWithFormat:@"bar%d", barIdx]];
        SPNPChartBarView *chartBar = [SPNPChartBarView barWithHolder:holder value:value bar:bar];
        [chartBar setColor:_barsColor[barIdx - 1]];
        [chartBar setWidth:0.0f];
        [_bars addObject:chartBar];
    }
}

- (void)dealloc {
    
    [self unsubscribeFromUpdates];
}

#pragma mark -


@end
