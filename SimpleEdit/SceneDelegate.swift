//
//  SceneDelegate.swift
//  Test
//
//  Created by James Froggatt on 30/12/2020.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

	var window: UIWindow?
	
	func documentBrowser(for scene: UIScene) -> DocumentBrowserViewController? {
		(scene as? UIWindowScene)?.windows.first?.rootViewController as? DocumentBrowserViewController
	}
	func document(for scene: UIScene) -> UIDocument? {
		((documentBrowser(for: scene)?.presentedViewController as? UINavigationController)?.viewControllers.first as? DocumentViewController)?.document
	}

	func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
		for openURLContext in URLContexts {
			var inputURL = openURLContext.url
			guard inputURL.isFileURL else {return}
			
			guard let documentBrowser = documentBrowser(for: scene) else {return}
			
			let fileManager = FileManager.default
			
			do {
				let docsURL = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
				let remoteDocsURL = docsURL
				
				if !openURLContext.options.openInPlace {
					let newURL = remoteDocsURL.appendingPathComponent(inputURL.lastPathComponent)
					try fileManager.renamingCopy(at: inputURL, to: newURL)
					try fileManager.removeItem(at: inputURL)
					inputURL = newURL
				}
			} catch {
				print(error)
				UIAlertController("Import error", message: "\(error)")
					.addAction("OK")
					.present(in: documentBrowser, animated: true)
			}
			
			DispatchQueue.main.async {
				documentBrowser.dismiss(animated: true) {
					documentBrowser.revealDocument(at: inputURL, importIfNeeded: true) {revealedDocumentURL, error in
						if let error = error {
							return UIAlertController(title: "Error", message: "Failed to reveal the document at URL \(inputURL) with error: '\(error)'", preferredStyle: .alert)
								.addAction("OK")
								.present(in: documentBrowser, animated: true)
						}
						documentBrowser.presentDocument(at: revealedDocumentURL!)
					}
				}
			}
		}
	}
	
	func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
		// Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
		// If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
		// This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
		guard let _ = (scene as? UIWindowScene) else { return }
		
		if !connectionOptions.urlContexts.isEmpty {
			self.scene(scene, openURLContexts: connectionOptions.urlContexts)
			return
		}
		
		if let activity = connectionOptions.userActivities.first ?? session.stateRestorationActivity, // Use activity from systems like handoff before restoration
		   let bookmark = activity.userInfo?["URL"] as? Data {
			var isStale = false
			do {
				let url = try URL(resolvingBookmarkData: bookmark, bookmarkDataIsStale: &isStale)
				guard !isStale else {
				 return assertionFailure()
			 }
				documentBrowser(for: scene)?.presentDocument(at: url, animated: false)
			} catch {
				assertionFailure(error.localizedDescription)
			}
		}
	}

	func sceneDidDisconnect(_ scene: UIScene) {
		// Called as the scene is being released by the system.
		// This occurs shortly after the scene enters the background, or when its session is discarded.
		// Release any resources associated with this scene that can be re-created the next time the scene connects.
		// The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
	}

	func sceneDidBecomeActive(_ scene: UIScene) {
		// Called when the scene has moved from an inactive state to an active state.
		// Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
	}

	func sceneWillResignActive(_ scene: UIScene) {
		// Called when the scene will move from an active state to an inactive state.
		// This may occur due to temporary interruptions (ex. an incoming phone call).
	}

	func sceneWillEnterForeground(_ scene: UIScene) {
		// Called as the scene transitions from the background to the foreground.
		// Use this method to undo the changes made on entering the background.
	}

	func sceneDidEnterBackground(_ scene: UIScene) {
		// Called as the scene transitions from the foreground to the background.
		// Use this method to save data, release shared resources, and store enough scene-specific state information
		// to restore the scene back to its current state.
	}
	
	func stateRestorationActivity(for scene: UIScene) -> NSUserActivity? {
		scene.userActivity
	}

}

