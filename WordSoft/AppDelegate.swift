//
//  AppDelegate.swift
//  WordSoft
//
//  Created by 张光正 on 7/27/20.
//  Copyright © 2020 张光正. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        //print("In application")
        UserDefaults.standard.register(defaults: ["lastSampledIndex" : -1])
        UserDefaults.standard.register(defaults: ["numSampled" : 0])
        UserDefaults.standard.register(defaults: ["navOffset" : 0])
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        //print("In applicationWillResignActive")
    }

    func applicationWillTerminate(_ application: UIApplication) {
        //print("In applicationWillTerminate")
    }
    
    func applicationDidFinishLaunching(_ application: UIApplication) {
        //print("In applicationDidFinishLaunching")
    }

}

