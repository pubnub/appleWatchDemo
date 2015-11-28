/**
 @author Sergey Mamontov
 @copyright © 2009-2015 PubNub, Inc.
 */
#import "SPNPStatisticsLegendView.h"
#import "SPNPStatisticsLegendCell.h"


#pragma mark Static

/**
 @brief  Stores reference on legend cell identifier which should be shown in table.
 */
static NSString * const kSPNPLegendCellIdentifier = @"SPNPStatisticsLegendCell";


#pragma mark Private interface declaration

@interface SPNPStatisticsLegendView () <UITableViewDelegate, UITableViewDataSource>


#pragma mark - Properties

/**
 @brief  Stores reference on table used for legend entries presentation.
 */
@property (nonatomic, weak) IBOutlet UITableView *legendTable;

/**
 @brief  Stores array with colors for legend entries sorted to correspond to bar colors.
 */
@property (nonatomic) NSArray *legendColors;

/**
 @brief  Stores array of legend entries title to show up in table.
 */
@property (nonatomic) NSArray *legendTitles;


#pragma mark - Misc

/**
 @brief  Fill up colors array.
 */
- (void)prepareColors;

#pragma mark -


@end


#pragma mark - Interface implementation

@implementation SPNPStatisticsLegendView


#pragma mark - View life-cycle

- (void)awakeFromNib {
    
    // Forward method call to the super class.
    [super awakeFromNib];
    
    [self prepareColors];
}


#pragma mark - Configuration

- (void)setupWithResponses:(NSArray *)pollResponses {
    
    self.legendTitles = [pollResponses valueForKey:@"response"];
    [self.legendTable reloadData];
}


#pragma mark - UITableView delegate methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.legendTitles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return [tableView dequeueReusableCellWithIdentifier:kSPNPLegendCellIdentifier];
}

- (void)  tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell
  forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [(SPNPStatisticsLegendCell *)cell updateWithTitle:self.legendTitles[indexPath.row]
                                                color:self.legendColors[indexPath.row]];
}


#pragma mark - Misc

- (void)prepareColors {
    
    self.legendColors = @[[UIColor colorWithRed:(38.0/255.0) green:(120.0/255.0) blue:(178.0/255.0) alpha:1.0],
                          [UIColor colorWithRed:(253.0/255.0) green:(127.0/255.0) blue:(40.0/255.0) alpha:1.0],
                          [UIColor colorWithRed:(51.0/255.0) green:(159.0/255.0) blue:(52.0/255.0) alpha:1.0],
                          [UIColor colorWithRed:(212.0/255.0) green:(42.0/255.0) blue:(47.0/255.0) alpha:1.0],
                          [UIColor colorWithRed:(58.0/255.0) green:(148.0/255.0) blue:(90.0/255.0) alpha:1.0]];
}

#pragma mark -


@end
