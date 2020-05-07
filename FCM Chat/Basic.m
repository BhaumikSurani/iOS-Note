//Search User on FCM Database From our Application userId

/*Firebase User Database Model
	MyUserDatabase : {
		FCM_UserID : {
			Name: UserName,
			ApplicationUserId: 100
		},
		…
		FCM_UserID : {
			Name: UserName,
			ApplicationUserId: 110
		}
	}
*/

[[[[[FirebaseChatManager sharedManager] usersDatabaseReferance] queryOrderedByChild:@“ApplicationUserId”] queryEqualToValue:@“100”] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
    if(![[snapshot value] isKindOfClass:[NSNull class]]) {
        NSString *FCM_UserID = [[snapshot value] allKeys].firstObject;
        NSError *error;
		//MyUserModel is Class that subclass of “JSONModel”
        MyUserModel *user = [[MyUserModel alloc] initWithDictionary:[[snapshot value] valueForKey:receiverUserFCMUid] error:&error];
        if(error) {
        } else {
            NSString *roomId;
            if([[[[FIRAuth auth] currentUser] uid] compare:FCM_UserID] > 0) {
                //current user uid is large
                roomId = [NSString stringWithFormat:@"%@%@", [[[FIRAuth auth] currentUser] uid], FCM_UserID];
            } else {
                roomId = [NSString stringWithFormat:@"%@%@", FCM_UserID, [[[FIRAuth auth] currentUser] uid]];
            }
            user.roomId = roomId;
            
            [self.userInforDictonary setObject:user forKey:FCM_UserID];
        }
    }
} withCancelBlock:^(NSError * _Nonnull error) {
}];




//send message to user
/*Firebase Message Database Model
	ApplicationMessageDatabase : {
		roomId1 : {
			autogeneratedChild {
				senderId: FCM_UserID_Sender,
				receiverId: FCM_UserID_Receiver,
				message: text Message,
				timestamp: 1500002456
			},
			…
		},
		…
		roomId2 : {
		}
	}
*/


//MyUserModel is Class that subclass of “JSONModel”
MyUserModel *user = (MyUserModel *)[self.userInforDictonary objectForKey:receiverFCM_UID];

FIRDatabaseReference *message = [[[[FirebaseChatManager sharedManager] messageDatabaseReferance] child:user.roomId] childByAutoId];
//MyMessageModel is Class that subclass of “JSONModel”
MyMessageModel *msg = [[MyMessageModel alloc] init];
msg.senderId = [[[FIRAuth auth] currentUser] uid];
msg.receiverId = receiverFCM_UID;
msg.message = “msgText”;
msg.timestamp = FIRServerValue.timestamp;

//following block add(push) message to Firebase database then after update User’s Friend list (For last message display on FriendList)
[message setValue:msg.toDictionary withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
    if(error) {
        NSLog(@“Error on send message User %@", error);
    } else {

/*Firebase Friend Database Model
	FriendsDatabase : {
		autogeneratedChild : {
			lastMessage: lstmessgae,
			timestamp: 1500000000
			FCM_UserID : FirebaseUserId
		},
		…
	}
*/
		//check receiver is already friend on senders Firend list
        [[[[[[FirebaseChatManager sharedManager] friendsDatabseReferance] child:[[[FIRAuth auth] currentUser] uid]] queryOrderedByChild:_keyFCMUId] queryEqualToValue: receiverFCM_UID] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
            if(![[snapshot value] isKindOfClass:[NSNull class]]) {
                NSString *reciverFriendIdOnFriendTable = [[[snapshot value] allKeys] firstObject];
                
                //update on table
                NSDictionary *friendSender = @{@“lastMessage”:msg.text, @“timestamp”:msg.timestamp};
                [[[[[FirebaseChatManager sharedManager] friendsDatabseReferance] child:[[[FIRAuth auth] currentUser] uid]] child:reciverFriendIdOnFriendTable] updateChildValues:friendSender withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
                    if(error) {
                        NSLog(@"Error add msgdata to sender: %@", error);
                    }
                }];
            } else {
                //create on table
                NSDictionary *friend = @{@“FCM_UserID”: receiverFCM_UID, @“lastMessage”:msg.text, @“timestamp”:msg.timestamp};
                [[[[[FirebaseChatManager sharedManager] friendsDatabseReferance] child:[[[FIRAuth auth] currentUser] uid]] childByAutoId] setValue:friend withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
                    if(error) {
                        NSLog(@"Error add to sender friend : %@", error);
                    }
                }];
            }
        } withCancelBlock:^(NSError * _Nonnull error) {
            NSLog(@"Error :- %@", error);
        }];

		//same above process do for
		//check sender is already friend on receivers Friend list
	}
}];



//Note Observer 
EX:- observeEventType : FIRDataEventTypeValue 

observeEventType				///Every time listen
observeSingleEventOfType		///Only listen single time

FIRDataEventTypeChildAdded		/// A new child node is added to a location.
FIRDataEventTypeChildRemoved		/// A child node is removed from a location.
FIRDataEventTypeChildChanged		/// A child node at a location changes.
FIRDataEventTypeChildMoved		/// A child node moves relative to the other child nodes at a location.
FIRDataEventTypeValue			/// Any data changes at a location or, recursively, at any child node.

	  
Firebase Security rule :- 	      
{
  /* Visit https://firebase.google.com/docs/database/security to learn more about security rules. */
  "rules": {
    ".read": true,
    ".write": true,
    "message": {
      "$messageId" :{
        ".indexOn":"timestamp"
      }
    },
    "friend": {
        "$friendId":{
          ".indexOn":["uid","timestamp"]
        }
    },
    "user":{
      ".indexOn":["uid"]
    }
  }
}
