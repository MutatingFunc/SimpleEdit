//
//  AppDelegate.swift
//  SimpleEdit
//
//  Created by James Froggatt on 20.09.2017.
//  Copyright © 2017 James Froggatt. All rights reserved.
//

import UIKit

import Additions

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
	
	var window: UIWindow?
	
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		// Override point for customization after application launch.
		return true
	}
	
	func application(_ app: UIApplication, open inputURL: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
		guard inputURL.isFileURL else {return false}
		
		var inputURL = inputURL
		
		guard let documentBrowser = window?.rootViewController as? DocumentBrowserViewController else {return false}
		
		let fileManager = FileManager.default
		
		do {
			let docsURL = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
			let remoteDocsURL = docsURL
			/*guard let remoteDocsURL = fileManager.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents", isDirectory: true) else {
				UIAlertController("Import error", message: "Could not load documents store")
					.addAction("OK")
					.present(in: documentBrowser, animated: true)
				return false
			}*/
			
			if options[.openInPlace] as? Bool != true {
				let newURL = remoteDocsURL.appendingPathComponent(inputURL.lastPathComponent)
				try fileManager.renamingCopy(at: inputURL, to: newURL)
				try fileManager.removeItem(at: inputURL)
				inputURL = newURL
			}
			
			let contents = try? fileManager.contentsOfDirectory(at: docsURL, includingPropertiesForKeys: nil, options: .skipsSubdirectoryDescendants)
			if let inboxURL = contents?.first(where: {$0.lastPathComponent == "Inbox"}) {
				for itemURL in (try? fileManager.contentsOfDirectory(at: inboxURL, includingPropertiesForKeys: nil, options: .skipsSubdirectoryDescendants)) ?? [] {
					try? fileManager.renamingCopy(at: itemURL, to: remoteDocsURL.appendingPathComponent(itemURL.lastPathComponent))
					try? fileManager.removeItem(at: itemURL)
				}
			}
		} catch {
			print(error)
			UIAlertController("Import error", message: "\(error)")
				.addAction("OK")
				.present(in: documentBrowser, animated: true)
			return false
		}
		
		documentBrowser.revealDocument(at: inputURL, importIfNeeded: true) {revealedDocumentURL, error in
			if let error = error {
				return UIAlertController(title: "Error", message: "Failed to reveal the document at URL \(inputURL) with error: '\(error)'", preferredStyle: .alert)
					.addAction("OK")
					.present(in: documentBrowser, animated: true)
			}
			documentBrowser.presentDocument(at: revealedDocumentURL!)
		}
		
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

}

