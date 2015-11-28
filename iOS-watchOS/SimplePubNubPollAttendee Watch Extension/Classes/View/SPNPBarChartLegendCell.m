/**
 @author Sergey Mamontov
 @copyright © 2009-2015 PubNub, Inc.
 */
#import "SPNPBarChartLegendCell.h"
#import <WatchKit/WatchKit.h>


#pragma mark Private interface declaration

@interface SPNPBarChartLegendCell ()


#pragma mark - Properties

/**
 @brief Stores reference on group which has been created to show user color marker which correspond
        to bar in chart.
 */
@property (nonatomic, weak) IBOutlet WKInterfaceGroup *colorMarker;

/**
 @brief  Stores reference on label to show textual legend table entry valur.
 */
@property (nonatomic, weak) IBOutlet WKInterfaceLabel *entryTitle;

#pragma mark - 


@end


#pragma mark - Interface implementation

@implementation SPNPBarChartLegendCell


#pragma mark - Data presentation

- (void)updateWithTitle:(NSString *)title color:(UIColor *)color {
    
    [self.entryTitle setText:title];
    [self.colorMarker setBackgroundColor:color];
}

#pragma mark -


@end
