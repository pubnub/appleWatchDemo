#import <UIKit/UIKit.h>


/**
 @brief  Cell used to present user one of graph legend entries.
 
 @author Sergey Mamontov
 @copyright © 2009-2015 PubNub, Inc.
 */
@interface SPNPStatisticsLegendCell : UITableViewCell


///------------------------------------------------
/// @name Data presentation
///------------------------------------------------

/**
 @brief  Update legend entry with specified title and color.
 
 @param title Reference on title which should be displayed on legend entry.
 @param color Reference on marker color which should be set to the legend entry.
 */
- (void)updateWithTitle:(NSString *)title color:(UIColor *)color;

#pragma mark -


@end
