//
//  AppDelegate.m
//  Homepwner
//
//  Created by Kevin Ho on 1/31/15.
//  Copyright (c) 2015 kho. All rights reserved.
//

#import "AppDelegate.h"
#import "KHOItemsViewController.h"
#import "KHOItemStore.h"

NSString * const KHONextItemValuePrefsKey = @"NextItemValue";
NSString * const KHONextItemNamePrefsKey = @"NextItemName";

@implementation AppDelegate

+ (void)initialize
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *factorySettings = @{KHONextItemValuePrefsKey : @75,
                                      KHONextItemNamePrefsKey  : @"Coffee Cup"};
    
    [defaults registerDefaults:factorySettings];
}

- (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    
    return YES;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    // If state restoration did not occur, set up view controller hierarchy
    if (!self.window.rootViewController) {
        KHOItemsViewController *ivc = [[KHOItemsViewController alloc] init];
        
        UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:ivc];
        nc.restorationIdentifier = NSStringFromClass([nc class]);
        
        self.window.rootViewController = nc;
    }
    
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    BOOL success = [[KHOItemStore sharedStore]  saveChanges];
    if (success) {
        NSLog(@"Saved all KHOItems");
    }
    else {
        NSLog(@"Could not saveKHOItems");
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application
shouldSaveApplicationState:(NSCoder *)coder
{
    return YES;
}

- (BOOL)application:(UIApplication *)application
shouldRestoreApplicationState:(NSCoder *)coder
{
    return YES;
}

- (UIViewController *)application:(UIApplication *)application
viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents
                            coder:(NSCoder *)coder
{
    UIViewController *vc = [[UINavigationController alloc] init];
    
    vc.restorationIdentifier = [identifierComponents lastObject];
    
    if ([identifierComponents count] == 1) {
        //If only 1 identifier component, set as rootViewController
        self.window.rootViewController = vc;
    }
    else {
        // Else set as a modal presentation
        vc.modalPresentationStyle = UIModalPresentationFormSheet;
    }
    
    return vc;
}

@end
