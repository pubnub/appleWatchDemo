#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


/**
 @brief  Class describe table view cell to display bar chart legend.

 @author Sergey Mamontov
 @copyright © 2009-2015 PubNub, Inc.
 */
@interface SPNPBarChartLegendCell : NSObject


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
