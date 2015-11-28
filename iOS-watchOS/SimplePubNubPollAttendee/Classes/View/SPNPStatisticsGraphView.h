#import <UIKit/UIKit.h>


#pragma mark Class forward

@class SPNPPollStatistic;


/**
 @brief  View designed to show colored graph bars as statistic representation.
 
 @author Sergey Mamontov
 @copyright © 2009-2015 PubNub, Inc.
 */
@interface SPNPStatisticsGraphView : UIView


///------------------------------------------------
/// @name Configuration
///------------------------------------------------

/**
 @brief  Configure grapth bars holder view.
 
 @param pollResponses List of response instance which should be used to configure graphic.
 */
- (void)setupWithResponses:(NSArray *)pollResponses;


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
