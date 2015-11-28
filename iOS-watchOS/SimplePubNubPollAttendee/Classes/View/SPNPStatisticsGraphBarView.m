/**
 @author Sergey Mamontov
 @copyright © 2009-2015 PubNub, Inc.
 */
#import "SPNPStatisticsGraphBarView.h"


#pragma mark Private interface declaration

@interface SPNPStatisticsGraphBarView ()


#pragma mark - Properties

/**
 @brief  Stores reference on width constraint which describe equal bar width.
 */
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *widthConstraint;

/**
 @brief  Stores referebce on bar height constraint which can be used during height adjustments.
 */
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *heightConstraint;

/**
 @brief  Stores reference on label which is used for textual value presentation to the user.
 */
@property (nonatomic, weak) IBOutlet UILabel *value;

/**
 @brief  Stores reference on color bar which should change height according to shown values.
 */
@property (nonatomic, weak) IBOutlet UIView *bar;

#pragma mark -


@end


#pragma mark - Interface implementation

@implementation SPNPStatisticsGraphBarView

#pragma mark - Representation

- (void)hide {

    [self.superview removeConstraint:self.widthConstraint];
    NSDictionary *bindingViews = NSDictionaryOfVariableBindings(self);
    NSDictionary *metrics = @{@"width": @(0)};
    
    [self addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"H:[self(==width)]"
                           options:0 metrics:metrics views:bindingViews]];
}

- (void)showValue:(NSUInteger)value scale:(NSUInteger)maxValue {
    
    CGFloat fullHeight = self.superview.frame.size.height;
    CGFloat multiplier = (maxValue > 0 ? (1.0f - ((CGFloat)value) / ((CGFloat)maxValue)) : 1);
    self.heightConstraint.constant = - MIN((fullHeight * multiplier + 21), fullHeight);
    self.value.text = [NSString stringWithFormat:@"%lu", (unsigned long)value];
}

#pragma mark -


@end
