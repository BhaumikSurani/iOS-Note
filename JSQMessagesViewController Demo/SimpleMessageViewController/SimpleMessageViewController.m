#import "SimpleMessageViewController.h"
#import "JSQMessage.h"
#import <JSQMessagesBubbleImageFactory.h>
#import <JSQMessagesAvatarImageFactory.h>

@interface SimpleMessageViewController () <JSQMessagesCollectionViewDataSource, JSQMessagesCollectionViewDelegateFlowLayout, UICollectionViewDelegateFlowLayout>

@property NSMutableArray<JSQMessage *> *messages;
@property JSQMessagesBubbleImage *outgoingBubbleImageView;
@property JSQMessagesBubbleImage *incomingBubbleImageView;
@property JSQMessagesAvatarImage *outgoingAvtarImage;
@property JSQMessagesAvatarImage *incomingAvtarImage;

@end

@implementation SimpleMessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.incomingBubbleImageView = [self setupIncomingBubble];
    self.outgoingBubbleImageView = [self setupOutgoingBubble];
    self.incomingAvtarImage = [JSQMessagesAvatarImageFactory avatarImageWithImage:[UIImage imageNamed:@"placeholderUser"] diameter:100];
    self.outgoingAvtarImage = [JSQMessagesAvatarImageFactory avatarImageWithImage:[UIImage imageNamed:@"placeholderUser"] diameter:100];
    
    //set avtar image size
    self.collectionView.collectionViewLayout.incomingAvatarViewSize=CGSizeMake(35, 35);
    self.collectionView.collectionViewLayout.outgoingAvatarViewSize=CGSizeMake(35, 35);
    
    //Customize input toolbar
    /*self.inputToolbar.contentView.backgroundColor = [UIColor blackColor];
    [self.inputToolbar.contentView.rightBarButtonItem setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.inputToolbar.contentView.rightBarButtonItem setTitleColor:[[UIColor whiteColor] colorWithAlphaComponent:0.8] forState:UIControlStateHighlighted];
    self.inputToolbar.contentView.rightBarButtonItem.tintColor =
    self.inputToolbar.contentView.textView.textColor =
    self.inputToolbar.contentView.textView.tintColor = [UIColor whiteColor];
    self.inputToolbar.contentView.textView.keyboardAppearance = UIKeyboardAppearanceDark;
    [self.inputToolbar.contentView.textView setReturnKeyType:UIReturnKeyDone];
    self.inputToolbar.contentView.textView.backgroundColor = [UIColor clearColor];
    self.inputToolbar.contentView.textView.layer.borderWidth = 0.0f;
    [self.inputToolbar.contentView.textView setPlaceHolder:@"Type your message..."];
    [self.inputToolbar.contentView layoutIfNeeded];*/
    [self fillStaticData];
}

- (JSQMessagesBubbleImage*)setupOutgoingBubble {
    //set Default Bubble Image
    JSQMessagesBubbleImageFactory *bubbleFactory = [[JSQMessagesBubbleImageFactory alloc] init];
    return [bubbleFactory outgoingMessagesBubbleImageWithColor:[UIColor greenColor]];
    
    //set custom bubble Image
    /*JSQMessagesBubbleImageFactory *bubbleFactory = [[JSQMessagesBubbleImageFactory alloc] initWithBubbleImage:[UIImage imageNamed:@"chat"] capInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    JSQMessagesBubbleImage *image = [bubbleFactory incomingMessagesBubbleImageWithColor:_colorBlueLightVideo];
    return image;*/
}

- (JSQMessagesBubbleImage*)setupIncomingBubble {
    //set Default Bubble Image
    JSQMessagesBubbleImageFactory *bubbleFactory = [[JSQMessagesBubbleImageFactory alloc] init];
    return [bubbleFactory incomingMessagesBubbleImageWithColor:[UIColor blueColor]];
    
    //set custome bubble Image
    /*JSQMessagesBubbleImageFactory *bubbleFactory = [[JSQMessagesBubbleImageFactory alloc] initWithBubbleImage:[UIImage imageNamed:@"chat"] capInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    JSQMessagesBubbleImage *image = [bubbleFactory incomingMessagesBubbleImageWithColor:_colorBlueSurface];
    return image;*/
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

- (id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath {
    JSQMessage *message = [_messages objectAtIndex:indexPath.item];
    if ([message.senderId isEqualToString:self.senderId]) {
        return self.outgoingBubbleImageView;
    } else {
        return self.incomingBubbleImageView;
    }
}

- (id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath {
    JSQMessage *message = [_messages objectAtIndex:indexPath.item];
    if ([message.senderId isEqualToString:self.senderId]) {
        return self.outgoingAvtarImage;
    } else {
        return self.incomingAvtarImage;
    }
    return nil;
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
    JSQMessagesCollectionViewCell *cell = [super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    return cell;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 16;
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
    message = [[JSQMessage alloc] initWithSenderId:@"receiverId" senderDisplayName:@"Receiver" date:[NSDate date] text:@"Fine"];
    [self.messages addObject:message];
}

@end
