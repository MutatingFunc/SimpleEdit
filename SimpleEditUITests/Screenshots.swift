//
//  Screenshots.swift
//  SimpleEditUITests
//
//  Created by James Froggatt on 09/11/2019.
//  Copyright © 2019 James Froggatt. All rights reserved.
//

import XCTest
import UITestAdditions

class Screenshots: XCTestCase {
	func testiPadScreenshots() {
		testScreenshots(idiom: .pad, landscapeSettings: true)
	}
	
	func testiPhoneScreenshots() {
		testScreenshots(idiom: .phone, landscapeSettings: false)
	}
	
	func testSmalliPhoneScreenshots() {
		testScreenshots(idiom: .phone, landscapeSettings: true)
	}
	
	func testScreenshots(idiom: UIUserInterfaceIdiom, landscapeSettings: Bool) {
		withActivity("Screenshots") {activity in
			SettingsRobot()
				.setDarkMode(false)
			SimpleEditRobot()
				.rotate(to: .landscapeLeft)
				.showDocumentBrowser()
				.showBrowse()
				.deleteDocuments()
				.takeScreenshot(activity)
				.addDocument()
				.addText("Hello World")
				.takeScreenshot(activity)
			SettingsRobot()
				.setDarkMode(true)
			SimpleEditRobot()
				.showDocumentBrowser()
				.showBrowse()
				.openDocument(label: "Untitled, txt")
				.addText("")
				.rotate(to: landscapeSettings ? .landscapeLeft : .portrait)
				.showSettings()
				.takeScreenshot(activity)
				.dismiss(idiom: idiom)
				.saveAndClose()
				.deleteDocuments()
		}
	}
}
