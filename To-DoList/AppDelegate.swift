//
//  AppDelegate.swift
//  To-DoList
//
//  Created by Sujata on 19/11/19.
//  Copyright © 2019 Sujata. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import UserNotifications


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

//    override init() {
//        FirebaseApp.configure()
//    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        Database.database().isPersistenceEnabled = true
        
        UNUserNotificationCenter.current().delegate = self
        
        return true
    }

    func applicationWillTerminate(_ application: UIApplication) {
        
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate
{
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void)
    {
        completionHandler([.alert, .badge, .sound])
    }
}
