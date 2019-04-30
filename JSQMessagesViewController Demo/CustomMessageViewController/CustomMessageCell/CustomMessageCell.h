#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CustomMessageCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *lblMessage;
@property (assign) BOOL isSenderCell;

@end

NS_ASSUME_NONNULL_END
