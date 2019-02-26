MyViewController *vc = [[MyViewController alloc] init];
UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:vc];

CATransition *transition = [CATransition animation];
transition.duration = 0.35;
transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
transition.type = kCATransitionFade;
transition.subtype = kCATransitionFade;
[self.view.window.layer addAnimation:transition forKey:nil];
[self presentViewController:navigation animated:NO completion:nil];
