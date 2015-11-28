/**
 @author Sergey Mamontov
 @copyright © 2009-2015 PubNub, Inc.
 */
#import "SPNPStatisticsLegendCell.h"


#pragma mark Private interface declaration

@interface SPNPStatisticsLegendCell ()


#pragma mark - Properties

/**
 @brief  Stores reference on view which is used to specify color label on legend entry.
 */
@property (nonatomic, weak) IBOutlet UIView *dotView;

/**
 @brief  Stores reference on label which is used to show legend entry title.
 */
@property (nonatomic, weak) IBOutlet UILabel *legendTitle;

#pragma mark -


@end


#pragma mark - Interface implementation

@implementation SPNPStatisticsLegendCell


#pragma mark - Data presentation

- (void)updateWithTitle:(NSString *)title color:(UIColor *)color {
    
    self.legendTitle.text = title;
    self.dotView.backgroundColor = color;
}

#pragma mark -


@end
