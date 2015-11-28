#import <WatchKit/WatchKit.h>


/**
 @brief  Class which describe bar based chart single bar item.

 @author Sergey Mamontov
 @copyright © 2009-2015 PubNub, Inc.
 */
@interface SPNPChartBarView : NSObject


///------------------------------------------------
/// @name Initialization and Configuration
///------------------------------------------------

/**
 @brief  Construct and configure bar based chart unit using specified values.
 
 @param holder Refeence on group which hold components of single bar (label and bar itself).
 @param value  Reference on label instance which will display bar value.
 @param bar    Reference on grop which is used to display color bar inside of holder below value.
 
 @return Configured and ready to use bar component.
 */
+ (instancetype)barWithHolder:(WKInterfaceGroup *)holder value:(WKInterfaceLabel *)value
                          bar:(WKInterfaceGroup *)bar;

/**
 @brief  Update bar width to conform to passed data or device.
 */
- (void)setWidth:(CGFloat)barWidth;

/**
 @brief  Update background bar color.
 */
- (void)setColor:(UIColor *)barColor;

/**
 @brief  Clean up generated image cache for field titles.
 */
+ (void)clearImageCache;


///------------------------------------------------
/// @name Presentation
///------------------------------------------------

/**
 @brief  Update bar component layout using specified information.
 
 @param value   Value which should be shown to the user and used during bar height caluclations.
 @param title   Title of parameter which should be printed at the back of bar component.
 @param percent Relation of bar height in percents to highest bar.
 */
- (void)showValue:(NSNumber *)value withTitle:(NSString *)title percent:(CGFloat)percent;

#pragma mark -


@end
