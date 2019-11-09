//
//  SimpleEditRobot.swift
//  SimpleEditUITests
//
//  Created by James Froggatt on 09/11/2019.
//  Copyright © 2019 James Froggatt. All rights reserved.
//

import XCTest
import UITestAdditions

struct SimpleEditRobot: Robot {
	init() {
		app.launch()
		XCTAssert(app.wait(for: .runningForeground, timeout: 3))
	}
	
	func showDocumentBrowser() -> DocumentBrowserRootRobot {
		action {
			DocumentBrowserRootRobot()
		}
	}
}

extension Robot {
	func launchApp() -> SimpleEditRobot {
		action {
			SimpleEditRobot()
		}
	}
}
