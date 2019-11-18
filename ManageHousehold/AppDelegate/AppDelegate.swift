//
//  AppDelegate.swift
//  ManageHousehold
//
//  Created by Ishida Naoya on 2019/09/23.
//  Copyright © 2019 Ishida Naoya. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        guard let householdView = HouseholdWireframe.assembleModules() else {
            return false
        }
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = householdView
        window?.makeKeyAndVisible()
        return true
    }

}

