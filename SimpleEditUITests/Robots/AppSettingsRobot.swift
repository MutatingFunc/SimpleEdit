//
//  AppSettingsRobot.swift
//  SimpleEditUITests
//
//  Created by James Froggatt on 09/11/2019.
//  Copyright © 2019 James Froggatt. All rights reserved.
//

import XCTest
import UITestAdditions

struct AppSettingsRobot<Parent: Robot>: Robot {}

//MARK: - Elements
private extension AppSettingsRobot {
	func doneButton(idiom: UIUserInterfaceIdiom) -> XCUIElement {
		idiom == .pad
			? app.popovers.buttons["Done"]
			: app.buttons.matching(identifier: "Done").allElementsBoundByIndex.last!
	}
}

//MARK: - Navigation
extension AppSettingsRobot {
	@discardableResult
	func dismiss(idiom: UIUserInterfaceIdiom) -> Parent {
		action {
			doneButton(idiom: idiom).tap()
			return .init()
		}
	}
}
