#import <Foundation/Foundation.h>
#import <Firebase/Firebase.h>
#import <FirebaseDatabase/FirebaseDatabase.h>
#import <FirebaseAuth/FirebaseAuth.h>
#import "FirebaseChatModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface FirebaseChatManager : NSObject

extern NSString * __nonnull const chatM_DB_Tbl_user;
extern NSString * __nonnull const chatM_DB_Tbl_Friends;
extern NSString * __nonnull const chatM_DB_Tbl_Message;
extern NSString * __nonnull const chatM_DB_Tbl_Notification;

+ (FirebaseChatManager *)sharedManager;
+ (id)getCurrentTimeStamp;
+ (NSString *)getFirebaseLoginUserName:(NSString *)username;
- (FIRDatabaseReference *)usersReferance;
- (FIRDatabaseReference *)friendsReferance;
- (FIRDatabaseReference *)messageReferance;
- (FIRDatabaseReference *)notificationReferance;

- (void)loginWithCurrentUser;
- (void)setUserStatusOff;

- (void)registerUserWithEmail:(NSString *)email password:(NSString *)password success:(void (^)(id value))success failuer:(void (^)(NSError* error))failuer;
- (void)loginUserWithEmail:(NSString *)email password:(NSString *)password success:(void (^)(id value))success failuer:(void (^)(NSError* error))failuer;
- (void)logout;

- (void)startUpdatorUserStatus;
- (void)stopUpdatorUserStatus;

- (void)setupNotificationListner;
- (void)removeNotificationListner;

- (void)setupHidenotificationForFirsttimelist;
- (void)addUserToFriendListWithUserUID:(NSString *)friendUid success:(void (^)(id value))success failuer:(void (^)(NSError* error))failuer;

@end

NS_ASSUME_NONNULL_END
