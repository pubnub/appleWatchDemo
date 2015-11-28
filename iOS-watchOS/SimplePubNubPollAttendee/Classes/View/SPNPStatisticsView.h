#import <UIKit/UIKit.h>


#pragma mark Class forward

@class SPNPPollStatistic, SPNPPoll;


/**
 @brief  View designed to show used real-time information about polling progress.
 
 @author Sergey Mamontov
 @copyright © 2009-2015 PubNub, Inc.
 */
@interface SPNPStatisticsView : UIView


///------------------------------------------------
/// @name Configuration
///------------------------------------------------

/**
 @brief  Complete view setup for concrete polling object.
 
 @param poll Reference on poll description instance which has information for statistics to show.
 */
- (void)setupForPoll:(SPNPPoll *)poll;


///------------------------------------------------
/// @name Data representation
///------------------------------------------------

/**
 @brief  Update presented data according to received stats.
 
 @param pollStatistics Reference on list of response statistics entries.
 */
- (void)updateStatistics:(NSArray *)pollStatistics;

#pragma mark -


@end
