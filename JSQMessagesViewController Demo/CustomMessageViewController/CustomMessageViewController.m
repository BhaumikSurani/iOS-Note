#import "CustomMessageViewController.h"
#import "JSQMessage.h"
#import <JSQMessagesBubbleImageFactory.h>
#import <JSQMessagesAvatarImageFactory.h>
#import "CustomMessageCell.h"

@interface CustomMessageViewController ()<JSQMessagesCollectionViewDataSource, JSQMessagesCollectionViewDelegateFlowLayout, UICollectionViewDelegateFlowLayout>

@property NSMutableArray<JSQMessage *> *messages;

@end

@implementation CustomMessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"CustomMessageCell" bundle:nil] forCellWithReuseIdentifier:@"CustomMessageCell"];
    
    [self fillStaticData];
}


#pragma mark - JSQMessagesCollectionViewDataSource

- (NSString *)senderDisplayName {
    return @"senderDisplayName";
}

- (NSString *)senderId {
    return @"senderId";
}

- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [self.messages objectAtIndex:indexPath.item];
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didDeleteMessageAtIndexPath:(NSIndexPath *)indexPath {
}

//Message collection View
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.messages.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CustomMessageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CustomMessageCell" forIndexPath:indexPath];
    JSQMessage *msgData = [self.messages objectAtIndex:indexPath.row];
    cell.isSenderCell = [msgData.senderId isEqualToString:[self senderId]];
    cell.lblMessage.text = msgData.text;
    cell.lblMessage.superview.backgroundColor = cell.isSenderCell?[UIColor greenColor]:[UIColor blueColor];
    cell.lblMessage.textColor = cell.isSenderCell?[UIColor blackColor]:[UIColor whiteColor];
    if(cell.isSenderCell) {
        cell.transform = CGAffineTransformMakeRotation(M_PI);
        cell.lblMessage.superview.transform = CGAffineTransformMakeRotation(M_PI);
    } else {
        cell.transform = CGAffineTransformMakeRotation(0);
        cell.lblMessage.superview.transform = CGAffineTransformMakeRotation(0);
    }
    return cell;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 8.0f;
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    JSQMessage *msgData = [self.messages objectAtIndex:indexPath.row];
    CGRect textFrame = [msgData.text boundingRectWithSize:CGSizeMake([UIScreen mainScreen].bounds.size.width - 64, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17.0f]} context:nil];
    return CGSizeMake([UIScreen mainScreen].bounds.size.width, textFrame.size.height+32.5f);
}


//Add new Message
- (void)didPressSendButton:(UIButton *)button withMessageText:(NSString *)text senderId:(NSString *)senderId senderDisplayName:(NSString *)senderDisplayName date:(NSDate *)date {
    [self addMessageWithId:@"senderId" name:@"" text:text date:[NSDate date]];
}

- (void)addMessageWithId:(NSString*)senderId name:(NSString*)name text:(NSString*)text date:(NSDate*)date {
    JSQMessage *message = [[JSQMessage alloc] initWithSenderId:senderId senderDisplayName:name date:[NSDate date] text:text];
    if (!self.messages) {
        self.messages = [NSMutableArray array];
    }
    [self.messages addObject:message];
    [self finishReceivingMessage];
}

//Fill static Data
- (void)fillStaticData {
    self.messages = [[NSMutableArray alloc] init];
    JSQMessage *message = [[JSQMessage alloc] initWithSenderId:@"senderId" senderDisplayName:@"Sender" date:[NSDate date] text:@"Hii"];
    [self.messages addObject:message];
    message = [[JSQMessage alloc] initWithSenderId:@"receiverId" senderDisplayName:@"Receiver" date:[NSDate date] text:@"Hello"];
    [self.messages addObject:message];
    message = [[JSQMessage alloc] initWithSenderId:@"senderId" senderDisplayName:@"Sender" date:[NSDate date] text:@"How r you"];
    [self.messages addObject:message];
    message = [[JSQMessage alloc] initWithSenderId:@"receiverId" senderDisplayName:@"Receiver" date:[NSDate date] text:@"I am Fine."];
    [self.messages addObject:message];
}

@end
