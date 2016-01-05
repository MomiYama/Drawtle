//
//  AppDelegate.swift
//  tableviewtest
//
//  Created by sensei on 2015/08/30.
//  Copyright (c) 2015年 senseiswift. All rights reserved.
//

import UIKit
import Alamofire

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var storage: NSUserDefaults = NSUserDefaults()
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        // なりすまし
        //self.storage.setObject(2, forKey: "user_id")
        // しますりな
        print("my user_id is ")
        println(storage.objectForKey("user_id"))
        
        if storage.objectForKey("user_id") == nil {
            Alamofire.request(
                .GET,
                "http://133.242.234.139/api/register_new_user.php"
            ).responseJSON { (request, response, JSON, error) in
                println(JSON)
                if JSON != nil && JSON!["user_id"] != nil {
                    let user_id = JSON!["user_id"]! as! Int
                    self.storage.setObject(user_id, forKey: "user_id")
                }
            }
        }
        
        if storage.objectForKey("boot_count") == nil {
            self.storage.setObject(0, forKey: "boot_count")
        }
        let a = self.storage.integerForKey("boot_count")
        self.storage.setObject(1 + a, forKey: "boot_count")
        return true
    }
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

