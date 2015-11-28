#import <UIKit/UIKit.h>


/**
 @brief  View designed to show used color based legend to statistics graph.
 
 @author Sergey Mamontov
 @copyright © 2009-2015 PubNub, Inc.
 */
@interface SPNPStatisticsLegendView : UIView


///------------------------------------------------
/// @name Configuration
///------------------------------------------------

/**
 @brief  Configure grapth to show list in legend.
 
 @param pollResponses List of response instance which should be used to configure graph legend.
 */
- (void)setupWithResponses:(NSArray *)pollResponses;

#pragma mark -


@end
