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
		
		var inputURL = inputURL
		
		guard let documentBrowser = window?.rootViewController as? DocumentBrowserViewController else {return false}
		
		let fileManager = FileManager.default
		
		do {
			let docsURL = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
			let remoteDocsURL = docsURL
			/*guard let remoteDocsURL = fileManager.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents", isDirectory: true) else {
				UIAlertController("Import error", detail: "Could not load documents store")
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
				for itemURL in try? fileManager.contentsOfDirectory(at: inboxURL, includingPropertiesForKeys: nil, options: .skipsSubdirectoryDescendants) {
					try? fileManager.renamingCopy(at: itemURL, to: remoteDocsURL.appendingPathComponent(itemURL.lastPathComponent))
					try? fileManager.removeItem(at: itemURL)
				}
			}
		} catch {
			print(error)
			UIAlertController("Import error", detail: "\(error)")
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
	
	
}

