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
	
	func application(_ app: UIApplication, open inputURL: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
		guard inputURL.isFileURL else {return false}
		
		guard let documentBrowser = window?.rootViewController as? DocumentBrowserViewController else {return false}
		
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
	
	
}

