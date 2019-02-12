@interface AppDelegate ()
@property UIBackgroundTaskIdentifier backgroundTask;
@end

@implementation AppDelegate

- (void)applicationDidEnterBackground:(UIApplication *)application {
    self.backgroundTask = [application beginBackgroundTaskWithExpirationHandler:^{
        [application endBackgroundTask:self.backgroundTask];
        self.backgroundTask = UIBackgroundTaskInvalid;
    }];
}
- (void)applicationWillEnterForeground:(UIApplication *)application {
    [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTask];
}

@end
