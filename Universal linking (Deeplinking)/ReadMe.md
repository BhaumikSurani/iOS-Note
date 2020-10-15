Upload below file in you server root directory (this file content should be parsable in JSON)

File Name (without any extension):- apple-app-site-association
File Content should be below
```
{
  "applinks": {
    "apps": [],
    "details": [
    	{
			"appID": "TeamId.Package",
			"paths": [ "*" ]
		}
    ]
  }
}
```

In you project:-

Add "Associated Domains"  
project -> signing and capability  


contsints of "Associated Domains" is like following  
```
applinks:yourdomain.com
applinks:www.yourdomain.com
```


Implement method in Appdelegate file

```
//when tap on link this method is call
- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray<id<UIUserActivityRestoring>> * _Nullable))restorationHandler {
    if ([userActivity.activityType isEqualToString:NSUserActivityTypeBrowsingWeb]) {
        NSURL *url= userActivity.webpageURL;
        PrintLog(@"Deeplink URL:%@",url);
		//present or push new screen
		
		//if your app is close on open app user this link and show detail screen after loading screen so you need implement code in "application:didFinishLaunchingWithOptions" method
	}
	return YES;
}

//Optional code
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	NSDictionary *userActivityDictionary = launchOptions[UIApplicationLaunchOptionsUserActivityDictionaryKey];
    if (userActivityDictionary) {
		NSUserActivity *userActivity = [userActivityDictionary valueForKey:@"UIApplicationLaunchOptionsUserActivityKey"];
        if (userActivity) {
            NSURL *url = userActivity.webpageURL;
            [[UserDefaultsManager sharedManager]setObject:url.absoluteString forKey:@"userActivityURL"];
            [[UserDefaultsManager sharedManager] setBool:YES forKey:@"isLaunchedFromURL"];
            return YES;
        }
    } else {
        [[UserDefaultsManager sharedManager] setBool:NO forKey:@"isLaunchedFromURL"];
    }
}
```
