//
//  AppDelegate.m
//  PhdChorus
//
//  Created by 梁志鹏 on 16/9/29.
//  Copyright © 2016年 PhdChorus. All rights reserved.
//

#import "AppDelegate.h"

#import "ZivRootViewController.h"
#import "ZivMergeAttendanceTableViewController.h"

#import "ZivDBManager.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [self.window makeKeyAndVisible];
    
    self.window.rootViewController = [[ZivRootViewController alloc] init];
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    
    [[ZivDBManager shareDatabaseManager] saveFile];
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [[ZivDBManager shareDatabaseManager] saveFile];
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [[ZivDBManager shareDatabaseManager] saveFile];
    
}


- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    NSLog(@"file from:%@ in %@", sourceApplication, url);
    
    ZivMergeAttendanceTableViewController *mergeVC = [[ZivMergeAttendanceTableViewController alloc] init];
    mergeVC.attendanceTableData = [NSData dataWithContentsOfURL:url];
    mergeVC.fileName = [url lastPathComponent];
    [self.window.rootViewController presentViewController:[[UINavigationController alloc] initWithRootViewController:mergeVC] animated:YES completion:NULL];
    
    return YES;
}


@end
