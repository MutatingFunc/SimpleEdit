//
//  DocumentEditorRobot.swift
//  SimpleEditUITests
//
//  Created by James Froggatt on 09/11/2019.
//  Copyright © 2019 James Froggatt. All rights reserved.
//

import XCTest
import UITestAdditions

struct DocumentEditorRobot<Parent: Robot>: Robot {
	init() {
		textView.wait(for: \.isHittable)
	}
}

//MARK: - Elements
private extension DocumentEditorRobot {
	var textView: XCUIElement {
		app.textViews["DocumentBodyTextView"]
	}
	var settingsButton: XCUIElement {
		app.buttons["Settings"]
	}
	var doneButton: XCUIElement {
		app.buttons["Done"]
	}
}

//MARK: - Interaction
extension DocumentEditorRobot {
	@discardableResult
	func addText(_ text: String) -> Self {
		action {
			app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
			textView.typeText(text)
			return self
		}
	}
	
	@discardableResult
	func saveAndClose() -> Parent {
		action {
			doneButton.tap()
			return .init()
		}
	}
	
	@discardableResult
	func showSettings() -> AppSettingsRobot<Self> {
		action {
			settingsButton.tap()
			return .init()
		}
	}
}
