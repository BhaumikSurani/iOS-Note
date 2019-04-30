#import "CustomMessageCell.h"

@implementation CustomMessageCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.lblMessage.superview.layer.masksToBounds = YES;
    self.lblMessage.superview.layer.cornerRadius = 10.0f;
}

@end
