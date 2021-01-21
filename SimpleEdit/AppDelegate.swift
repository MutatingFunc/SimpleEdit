//
//  AppDelegate.swift
//  SimpleEdit
//
//  Created by James Froggatt on 20.09.2017.
//  Copyright © 2017 James Froggatt. All rights reserved.
//

import UIKit

import Additions

extension UIApplication {
	func resumeSession(document: Document) {
		if let session = openSessions.first(where: {$0.stateRestorationActivity?.simpleEditBookmark == document.fileURL}) {
			requestSceneSessionActivation(session, userActivity: nil, options: nil)
		} else {
			requestSceneSessionActivation(nil, userActivity: document.activity, options: nil)
		}
	}
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
	
	var window: UIWindow?
	
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		// Override point for customization after application launch.
		return true
	}
	
	// MARK: UISceneSession Lifecycle

	func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
		// Called when a new scene session is being created.
		// Use this method to select a configuration to create the new scene with.
		if !options.urlContexts.isEmpty || !options.userActivities.isEmpty {
			return UISceneConfiguration(name: "Auxiliary Configuration", sessionRole: connectingSceneSession.role)
		}
		return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
	}

	func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
		// Called when the user discards a scene session.
		// If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
		// Use this method to release any resources that were specific to the discarded scenes, as they will not return.
	}

}

