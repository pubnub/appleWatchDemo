/**
 @author Sergey Mamontov
 @copyright © 2009-2015 PubNub, Inc.
 */
#import "SPNPPollDataVerificator.h"
#import <Cocoa/Cocoa.h>


#pragma mark Private interface declaration

@interface SPNPPollDataVerificator () <NSTextFieldDelegate>


#pragma mark - Properties

@property (nonatomic, assign) BOOL valid;

/**
 @brief  Stores reference on text field which can be used by user to specify question.
 */
@property (nonatomic, weak) IBOutlet NSTextField *questionField;

/**
 @brief  Stores reference on text field which can be used by user to specify possible variants to
         answer on question.
 */
@property (nonatomic, weak) IBOutlet NSTextField *variantsField;


#pragma mark - Verification

/**
 @brief  Check inputed values and update \c valid state.
 */
- (void)verifyDataAndUpdateState;

/**
 @brief  Verify whether valid data for poll has been provided or not.
 
 @return \c YES in case if valid data provided and can be used.
 */
- (BOOL)isValidDataProvided;

#pragma mark -


@end


#pragma mark - Interface implementation

@implementation SPNPPollDataVerificator


#pragma mark - Verification

- (void)verifyDataAndUpdateState {
    
    self.valid = [self isValidDataProvided];
}

- (BOOL)isValidDataProvided {
    
    BOOL isValid = NO;
    NSString *question = self.questionField.stringValue;
    NSString *variants = self.variantsField.stringValue;
    isValid = ([question stringByReplacingOccurrencesOfString:@" " withString:@""].length > 0);
    isValid = (isValid && [variants stringByReplacingOccurrencesOfString:@" " withString:@""].length > 0);
    if (isValid) {
        
        NSUInteger variantsCount = 0;
        NSArray *variantsList = [variants componentsSeparatedByString:@","];
        for (NSUInteger variantIdx = 0; variantIdx < variantsList.count; variantIdx++) {
            
            NSString *variant = [variantsList[variantIdx] stringByReplacingOccurrencesOfString:@" "
                                                                                    withString:@""];
            if (variant.length) {
                
                variantsCount++;
            }
        }
        isValid = (variantsList.count >= 2 && variantsCount >= 2 && variantsCount <= 5);
    }
    
    return isValid;
}


#pragma mark - State management

- (void)reset {
    
    self.valid = NO;
}


#pragma mark - Text field delegate methods

- (void)controlTextDidChange:(NSNotification *)obj {
    
    [self verifyDataAndUpdateState];
}

- (BOOL)      control:(NSControl *)control textView:(NSTextView *)textView
  doCommandBySelector:(SEL)commandSelector {
    
    BOOL canHandleSelector = NO;
    if (commandSelector == @selector(insertTab:) || commandSelector == @selector(insertNewline:)) {
        
        [((NSTextField *)control).window makeFirstResponder:((NSTextField *)control).nextValidKeyView];
        canHandleSelector = YES;
    }
    
    return canHandleSelector;
}

#pragma mark -


@end
