+ (void)checkMikePermissionWithComplition:(void (^)(BOOL granted))complition {
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    if(status == AVAuthorizationStatusAuthorized) {
        complition(YES);
    } else if(status == AVAuthorizationStatusDenied) {
        complition(NO);
    } else if(status == AVAuthorizationStatusNotDetermined) {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
            if(granted) {
                complition(YES);
            }
        }];
    }
}

+ (void)checkVideoPermissionWithComplition:(void (^)(BOOL granted))complition {
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if(status == AVAuthorizationStatusAuthorized) {
        complition(YES);
    } else if(status == AVAuthorizationStatusDenied) {
        complition(NO);
    } else if(status == AVAuthorizationStatusNotDetermined) {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            if(granted) {
                complition(YES);
            }
        }];
    }
}

+ (void)checkPhotosPermissionWithComplition:(void (^)(BOOL granted))complition {
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if(status == AVAuthorizationStatusAuthorized) {
        complition(YES);
    } else if(status == AVAuthorizationStatusDenied) {
        complition(NO);
    } else if(status == AVAuthorizationStatusNotDetermined) {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            switch (status) {
                case PHAuthorizationStatusNotDetermined:
                    break;
                case PHAuthorizationStatusRestricted:
                    break;
                case PHAuthorizationStatusDenied:
                    break;
                case PHAuthorizationStatusAuthorized:
                    complition(YES);
                    break;
            }
        }];
    }
}

+ (void)checkLocationPermissionWithComplition:(void (^)(BOOL granted))complition {
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    if(status==kCLAuthorizationStatusAuthorizedAlways) {
        complition(YES);
    } else if(status==kCLAuthorizationStatusAuthorizedWhenInUse) {
        complition(YES);
    } else if(status==kCLAuthorizationStatusDenied) {
        complition(NO);
    } else if(status==kCLAuthorizationStatusNotDetermined) {
        complition(NO);
    }
}

+ (void)checkNotificationPermissionWithComplition:(void (^)(BOOL granted))complition {
    if (@available(iOS 10.0, *)) {
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings *settings){
            switch (settings.authorizationStatus) {
                case UNAuthorizationStatusAuthorized:
                    complition(YES);
                    break;
                case UNAuthorizationStatusDenied:
                    complition(NO);
                    break;
                case UNAuthorizationStatusNotDetermined:
                    complition(NO);
                    break;
                default:
                    complition(NO);
                    break;
            }
        }];
    } else {
        // Fallback on earlier versions
        UIUserNotificationSettings *grantedSettings = [[UIApplication sharedApplication] currentUserNotificationSettings];
        if (grantedSettings.types == UIUserNotificationTypeNone) {
            complition(NO);
        }
        else if (grantedSettings.types & UIUserNotificationTypeSound & UIUserNotificationTypeAlert ){
            complition(YES);
        }
        else if (grantedSettings.types  & UIUserNotificationTypeAlert){
            complition(YES);
        }
    }
}
