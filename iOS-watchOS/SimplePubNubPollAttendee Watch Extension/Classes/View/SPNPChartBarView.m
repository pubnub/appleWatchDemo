/**
 @author Sergey Mamontov
 @copyright © 2009-2015 PubNub, Inc.
 */
#import "SPNPChartBarView.h"
#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIKit.h>


#pragma mark Static

/**
 @brief  Stores maximum bar value label height.
 */
static CGFloat const kWKBarValueLabelHeight = 14.0f;

/**
 @brief  Stores value used for spacing between elements of holding group.
 */
static CGFloat const kWKBarElementsSpacing = 4.0f;


#pragma mark - Private interface declaration

@interface SPNPChartBarView ()


#pragma mark - Properties

/**
 @brief  Stores reference on group which hold bar components.
 */
@property (nonatomic, weak) WKInterfaceGroup *holder;

/**
 @brief  Stores reference on instance used for bar value specification.
 */
@property (nonatomic, weak) WKInterfaceLabel *value;

/**
 @brief  Stores reference on instance used to display bar.
 */
@property (nonatomic, weak) WKInterfaceGroup *bar;

/**
 @brief  Stores original bar size.
 */
@property (nonatomic, assign) CGSize orignalBarSize;

/**
 @brief  Stores name of the field which currently shown in bar.
 */
@property (nonatomic, copy) NSString *currentFieldName;


#pragma mark - Initialization and Configuration

/**
 @brief  Initialize bar based chart unit using specified values.
 
 @param holder Refeence on group which hold components of single bar (label and bar itself).
 @param value  Reference on label instance which will display bar value.
 @param bar    Reference on grop which is used to display color bar inside of holder below value.
 
 @return Initialized and ready to use bar component.
 */
- (instancetype)initWithHolder:(WKInterfaceGroup *)holder value:(WKInterfaceLabel *)value
                           bar:(WKInterfaceGroup *)bar;


#pragma mark - Misc

/**
 @brief  Stores reference on images generated to be shown as field name.
 */
+ (NSMutableDictionary *)imageCache;

/**
 @brief  Retrieve image which should be shown at the back of the bar to clarify for which field data
         is shown.
 
 @param fieldName Name of the fields for which image should be retrieved from cache or generated.
 
 @return Generated \c UIImage instance.
 */
- (UIImage *)imageForField:(NSString *)fieldName;

#pragma mark -


@end


#pragma mark Interface implementation

@implementation SPNPChartBarView


#pragma mark - Initialization and Configuration

+ (instancetype)barWithHolder:(WKInterfaceGroup *)holder value:(WKInterfaceLabel *)value
                          bar:(WKInterfaceGroup *)bar {
    
    return [[self alloc] initWithHolder:holder value:value bar:bar];
}

- (instancetype)initWithHolder:(WKInterfaceGroup *)holder value:(WKInterfaceLabel *)value
                           bar:(WKInterfaceGroup *)bar {
    
    // Check whether initialization was successful or not.
    if ((self = [super init])) {
        
        CGSize screenSize = [WKInterfaceDevice currentDevice].screenBounds.size;
        _orignalBarSize = CGSizeMake(0.0f, screenSize.height - kWKBarValueLabelHeight - kWKBarElementsSpacing);
        
        _holder = holder;
        _value = value;
        _bar = bar;
    }
    
    return self;
}

- (void)setWidth:(CGFloat)barWidth {
    
    self.orignalBarSize = CGSizeMake(barWidth, self.orignalBarSize.height);
    [self.holder setWidth:barWidth];
}

- (void)setColor:(UIColor *)barColor {
    
    [self.value setTextColor:barColor];
    [self.bar setBackgroundColor:barColor];
    [self.bar setAlpha:0.6f];
}

+ (void)clearImageCache {
    
    [[self imageCache] removeAllObjects];
}


#pragma mark - Presentation

- (void)showValue:(NSNumber *)value withTitle:(NSString *)title percent:(CGFloat)percent {
    
    [self.holder setWidth:((title.length == 0) ? 0.0f : self.orignalBarSize.width)];
    if (title.length == 0) {
        
        [self.holder setBackgroundImage:nil];
    }
    else {
        
        [self.bar setHeight:(self.orignalBarSize.height * percent)];
        if (![self.currentFieldName isEqualToString:title]) {
            
            [self.holder setBackgroundImage:[self imageForField:title]];
        }
        [self.value setText:value.description];
    }
    self.currentFieldName = title;
}


#pragma mark - Misc

+ (NSMutableDictionary *)imageCache {
    
    static NSMutableDictionary *_sharedImageCache;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        _sharedImageCache = [NSMutableDictionary new];
    });
    
    return _sharedImageCache;
}

- (UIImage *)imageForField:(NSString *)fieldName {
    
    UIImage *image = [self.class imageCache][fieldName];
    if (!image) {
        
        UIFont *font = [UIFont systemFontOfSize:14.0f];
        CGSize size = [fieldName sizeWithAttributes:@{NSFontAttributeName:font}];
        NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
        paragraphStyle.alignment = NSTextAlignmentLeft;
        
        UIGraphicsBeginImageContext(self.orignalBarSize);
        CGRect titleFrame = CGRectMake(ceilf((self.orignalBarSize.width - size.width) * 0.5f),
                                       ceilf(self.orignalBarSize.height - size.height),
                                       size.width, size.height);
        CGPoint titleCenter = CGPointMake(ceilf(titleFrame.origin.x + size.width * 0.5f),
                                          ceilf(titleFrame.origin.y + size.height * 0.5f));
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSaveGState(context);
        CGContextTranslateCTM(context, titleCenter.x, titleCenter.y);
        CGContextRotateCTM(context, -90.0f * M_PI/180.0f);
        CGContextTranslateCTM(context, -titleCenter.x + size.width * 0.5f, -titleCenter.y - self.orignalBarSize.width * 0.5f);
        CGContextTranslateCTM(context, 0.0f, size.height * 0.5f);
        NSDictionary *attributes = @{ NSFontAttributeName: font,
                                      NSParagraphStyleAttributeName: paragraphStyle,
                                      NSForegroundColorAttributeName: [UIColor colorWithWhite:0.85f alpha:1.0f]};
        [fieldName drawInRect:titleFrame withAttributes:attributes];
        CGContextRestoreGState(context);
        
        CGImageRef imageRef = CGBitmapContextCreateImage(context);
        image = [UIImage imageWithCGImage:imageRef];
        UIGraphicsPopContext();
        UIGraphicsEndImageContext();
        [[self.class imageCache] setValue:image forKey:fieldName];
    }
    
    return image;
}

#pragma mark -


@end
