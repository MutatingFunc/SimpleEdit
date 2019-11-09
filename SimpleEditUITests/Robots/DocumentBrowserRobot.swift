//
//  DocumentBrowserRobot.swift
//  SimpleEditUITests
//
//  Created by James Froggatt on 09/11/2019.
//  Copyright © 2019 James Froggatt. All rights reserved.
//

import XCTest
import UITestAdditions

protocol DocumentBrowserRobot: Robot {}

extension DocumentBrowserRobot {
	func onInit() {
		XCTAssert(app.wait(for: .runningForeground, timeout: 3))
	}
}

//MARK: - Elements
private extension DocumentBrowserRobot {
	var addButton: XCUIElement {
		app.buttons["Add"]
	}
	
	var recentsTab: XCUIElement {
		app.buttons["Recents"]
	}
	
	var browseTab: XCUIElement {
		app.buttons["Browse"]
	}
}

//MARK: - Navigation
extension DocumentBrowserRobot {
	@discardableResult
	func showRecents() -> DocumentBrowserRecentsRobot {
		action {
			recentsTab.tap()
			return .init()
		}
	}
	
	@discardableResult
	func showBrowse() -> DocumentBrowserBrowseRobot {
		action {
			if browseTab.isSelected == false {
				browseTab.tap()
			}
			return .init()
		}
	}
	
	@discardableResult
	func addDocument() -> DocumentEditorRobot<Self> {
		action {
			addButton.tap()
			return .init()
		}
	}
	
	@discardableResult
	func openDocument(label: String) -> DocumentEditorRobot<Self> {
		action {
			app.cells[label].tap()
			return .init()
		}
	}
	
	@discardableResult
	func deleteDocuments() -> Self {
		action {
			app.buttons["Select"].tap()
			let selectAll = app.buttons["Select All"]
			if selectAll.exists {
				// Files are present
				selectAll.tap()
				app.buttons["Delete"].tap()
			} else {
				app.buttons["Done"].tap()
			}
			return self
		}
	}
}

struct DocumentBrowserRootRobot: DocumentBrowserRobot {
	init() {onInit()}
}
struct DocumentBrowserRecentsRobot: DocumentBrowserRobot {
	init() {onInit()}
}
struct DocumentBrowserBrowseRobot: DocumentBrowserRobot {
	init() {onInit()}
}
