#import <UIKit/UIKit.h>


/**
 @brief  Single bar representation view.
 
 @author Sergey Mamontov
 @copyright © 2009-2015 PubNub, Inc.
 */
@interface SPNPStatisticsGraphBarView : UIView


///------------------------------------------------
/// @name Representation
///------------------------------------------------

/**
 @brief  Hide receiver from graph.
 */
- (void)hide;

/**
 @brief  Update shown value with \c value.
 
 @param value Value which should be displayed by bar view.
 @param maxValue Maximum value which should be shown in graph and should be used to calculate height
                 ratio.
 */
- (void)showValue:(NSUInteger)value scale:(NSUInteger)maxValue;

#pragma mark -


@end
