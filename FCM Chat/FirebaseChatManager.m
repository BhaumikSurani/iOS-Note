#import "FirebaseChatManager.h"
#import "Constants.h"
#import "CommonUtils.h"
#import "UserDefaultsManager.h"
#import "UIViewController+TopViewController.h"
#import "UserModel.h"
#import "CryptLib.h"
#import "ChatListingViewController.h"
#import "MyConversionViewController.h"
@import UserNotifications;

@interface FirebaseChatManager()

@property (nonatomic) FIRDatabaseReference *usersRef;
@property (nonatomic) FIRDatabaseReference *friendsRef;
@property (nonatomic) FIRDatabaseReference *messageRef;
@property (nonatomic) FIRDatabaseReference *notificationRef;
@property (nonatomic) FIRDatabaseReference *userStatusRef;
@property (strong, nonatomic) NSTimer *timerForUpdateStauts, *timerForDisableHideFirsttimeNotificatoinList;
@property (assign, nonatomic) BOOL isHideFirstNotificationList;

@end

@implementation FirebaseChatManager

NSString * const chatM_DB_Tbl_user          = @"user";
NSString * const chatM_DB_Tbl_Friends       = @"friend";
NSString * const chatM_DB_Tbl_Message       = @"message";
NSString * const chatM_DB_Tbl_Notification  = @"notification";
NSString * const chatM_error_name           = @"error_name";
NSString * const chatM_ERROR_USER_NOT_FOUND = @"ERROR_USER_NOT_FOUND";

static FirebaseChatManager *singleton;

+ (FirebaseChatManager *)sharedManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singleton = [[FirebaseChatManager alloc] init];
    });
    return singleton;
}

+ (id)getCurrentTimeStamp {
    return FIRServerValue.timestamp;
}

+ (NSString *)getFirebaseLoginUserName:(NSString *)username {
    //generate unique email address from username for login fcm
    return [NSString stringWithFormat:@"%@@host.com", username];
}



- (void)loginWithCurrentUser {
    UserModel *userModel = [NSKeyedUnarchiver unarchiveObjectWithData:[[UserDefaultsManager sharedManager] objectForKey:_user]];
    NSString *loginEmail = [FirebaseChatManager getFirebaseLoginUserName:userModel.user_name];
    NSString *password = [[[CryptLib alloc] init] sha1:loginEmail];
    [[FirebaseChatManager sharedManager] loginUserWithEmail:loginEmail password:password success:^(id  _Nonnull value) {
        FCMStatusModel *userStatus = [[FCMStatusModel alloc] init];
        userStatus.isOnline = @(YES);
        userStatus.timestamp = [FirebaseChatManager getCurrentTimeStamp];
        
        FCMUserModel *user = [[FCMUserModel alloc] init];
        user.uid = [NSString stringWithFormat:@"%ld", (long)userModel.user_id];
        user.name = userModel.display_name;
        user.avatar = userModel.user_image;
        user.email = userModel.email;
        user.status = userStatus;
        
        NSDictionary *data = [user toDictionary];
        [[[[FirebaseChatManager sharedManager] usersReferance] child:[[[FIRAuth auth] currentUser] uid]] setValue:data];
        
        [[FirebaseChatManager sharedManager] stopUpdatorUserStatus];
        [[FirebaseChatManager sharedManager] startUpdatorUserStatus];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[FirebaseChatManager sharedManager] setupHidenotificationForFirsttimelist];
            [[FirebaseChatManager sharedManager] setupNotificationListner];
        });
        
    } failuer:^(NSError * _Nonnull error) {
    }];
}

- (void)setUserStatusOff {
    [[FirebaseChatManager sharedManager] stopUpdatorUserStatus];
    if([[[FIRAuth auth] currentUser] uid]!=nil) {
        FCMStatusModel *userStatus = [[FCMStatusModel alloc] init];
        userStatus.isOnline = @(NO);
        userStatus.timestamp = [FirebaseChatManager getCurrentTimeStamp];
        [[[[[[FIRDatabase database] reference] child:chatM_DB_Tbl_user] child:[[[FIRAuth auth] currentUser] uid]] child:_keyStatus] setValue:[userStatus toDictionary]];
    }
}



- (FIRDatabaseReference *)usersReferance {
    if(self.usersRef==nil) {
        self.usersRef = [[[FIRDatabase database] reference] child:chatM_DB_Tbl_user];
    }
    return self.usersRef;
}

- (FIRDatabaseReference *)friendsReferance {
    if(self.friendsRef==nil) {
        self.friendsRef = [[[FIRDatabase database] reference] child:chatM_DB_Tbl_Friends];
    }
    return self.friendsRef;
}

- (FIRDatabaseReference *)messageReferance {
    if(self.messageRef==nil) {
        self.messageRef = [[[FIRDatabase database] reference] child:chatM_DB_Tbl_Message];
    }
    return self.messageRef;
}

- (FIRDatabaseReference *)notificationReferance {
    if(self.notificationRef==nil) {
        self.notificationRef = [[[[FIRDatabase database] reference] child:chatM_DB_Tbl_Notification] child:[[[FIRAuth auth] currentUser] uid]];
    }
    return self.notificationRef;
}

- (void)registerUserWithEmail:(NSString *)email password:(NSString *)password
                      success:(void (^)(id value))success failuer:(void (^)(NSError* error))failuer {
    [[FIRAuth auth] createUserWithEmail:email password:password completion:^(FIRAuthDataResult * _Nullable authResult, NSError * _Nullable error) {
        if(error) {
            PrintLog(@"Error register FCM user : %@", error);
            failuer(error);
        } else {
            PrintLog(@"Registered FCM user");
            success(authResult);
        }
    }];
}

- (void)loginUserWithEmail:(NSString *)email password:(NSString *)password
                   success:(void (^)(id value))success failuer:(void (^)(NSError* error))failuer {
    [[FIRAuth auth] signInWithEmail:email password:password completion:^(FIRAuthDataResult * _Nullable authResult, NSError * _Nullable error) {
        if(error) {
            PrintLog(@"Error login FCM user : %@", error);
            if([[error.userInfo objectForKey:FIRAuthErrorUserInfoNameKey] isEqualToString:chatM_ERROR_USER_NOT_FOUND]) {
                //Register User
                [self registerUserWithEmail:email password:password success:success failuer:failuer];
            } else {
                failuer(error);
            }
        } else {
            PrintLog(@"login FCM user");
            success(authResult);
        }
    }];
}

- (void)addUserToFriendListWithUserUID:(NSString *)friendUid success:(void (^)(id value))success failuer:(void (^)(NSError* error))failuer {
    FIRDatabaseReference *userFriendRef = [[[[FIRDatabase database] reference] child:chatM_DB_Tbl_Friends] child:[[[FIRAuth auth] currentUser] uid]];
    [[userFriendRef childByAutoId] setValue:friendUid withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
        if(error) {
            PrintLog(@"Error add to Friend : %@", error);
            failuer(error);
        } else {
            PrintLog(@"Added to friend");
            success(ref);
        }
    }];
}

- (void)logout {
    [[FIRAuth auth] signOut:nil];
}

#pragma mark - Firebase Status update

- (void)startUpdatorUserStatus {
    [self.timerForUpdateStauts invalidate];
    if([[[FIRAuth auth] currentUser] uid]!=nil) {
        self.userStatusRef = [[[[[FIRDatabase database] reference] child:chatM_DB_Tbl_user] child:[[[FIRAuth auth] currentUser] uid]] child:_keyStatus];
        
        [self updateUserstatusOnFIRDB];
        self.timerForUpdateStauts = [NSTimer scheduledTimerWithTimeInterval:120.0f target:self selector:@selector(updateUserstatusOnFIRDB) userInfo:nil repeats:YES];
    }
}

- (void)stopUpdatorUserStatus {
    [self.timerForUpdateStauts invalidate];
    [self.userStatusRef removeAllObservers];
    self.userStatusRef = nil;
}

- (void)updateUserstatusOnFIRDB {
    FCMStatusModel *userStatus = [[FCMStatusModel alloc] init];
    userStatus.isOnline = @(YES);
    userStatus.timestamp = [FirebaseChatManager getCurrentTimeStamp];
    
    [self.userStatusRef setValue:[userStatus toDictionary]];
}

- (void)setupHidenotificationForFirsttimelist {
    self.isHideFirstNotificationList = YES;
}

- (void)setFinishHideNotificationForDirsttimelist {
    self.isHideFirstNotificationList = NO;
}

//Firebase Database Notification
#pragma mark - Firebase Database Notification

- (void)removeNotificationListner {
    [self.notificationRef removeAllObservers];
    self.notificationRef = nil;
}

- (void)setupNotificationListner {
    if(self.isHideFirstNotificationList) {
        self.timerForDisableHideFirsttimeNotificatoinList = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(setFinishHideNotificationForDirsttimelist) userInfo:nil repeats:NO];
    }
    
    [[self notificationReferance] observeEventType:FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        if(![[snapshot value] isKindOfClass:[NSNull class]]) {
            PrintLog(@"%@", [snapshot value]);
            
            UIViewController *topViewController = [[[[UIApplication sharedApplication] keyWindow] rootViewController] topViewController];
            
            BOOL isDisplayNotificaiton = YES;
            //BOOL isDisplayNotificaiton = [[UserDefaultsManager sharedManager] boolForKey:_preferanceReceivePushNotifications];
            if([topViewController isKindOfClass:[ChatListingViewController class]]) {
                isDisplayNotificaiton = NO;
            } else if([topViewController isKindOfClass:[MyConversionViewController class]]) {
                MyConversionViewController *myConversionViewController = (MyConversionViewController *)topViewController;
                if([[myConversionViewController getReceiverUIDFromChat] isEqualToString:[[snapshot value] objectForKey:@"sender"]]) {
                    isDisplayNotificaiton = NO;
                }
            }
            
            if(isDisplayNotificaiton && !self.isHideFirstNotificationList) {
                UNMutableNotificationContent *notificationContent = [[UNMutableNotificationContent alloc] init];
                notificationContent.title =[[snapshot value] objectForKey:@"senderName"];
                notificationContent.body = [[snapshot value] objectForKey:@"msgText"];
                notificationContent.sound = [UNNotificationSound defaultSound];
                notificationContent.userInfo = @{_remoteNotificationClick_action:_keyMessage, _keyUId:[[snapshot value] objectForKey:@"sender"]};
                UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger
                                                              triggerWithTimeInterval:1.0f
                                                              repeats:NO];
                UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:@"loginReminder"
                                                                                    content:notificationContent
                                                                                    trigger:trigger];
                UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
                [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
                    if (!error) {
                        NSLog(@"add NotificationRequest succeeded!");
                    }
                }];
            }
            
            if(self.isHideFirstNotificationList) {
                [self.timerForDisableHideFirsttimeNotificatoinList invalidate];
                self.timerForDisableHideFirsttimeNotificatoinList = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(setFinishHideNotificationForDirsttimelist) userInfo:nil repeats:NO];
            }
            
            //Remove Notification object from FCM DB
            [[snapshot ref] removeValue];
        }
    } withCancelBlock:^(NSError * _Nonnull error) {
        PrintLog(@"Error on FCM DB notification :- %@", error);
    }];
}

@end
