//
//  SettingsRobot.swift
//  SimpleEditUITests
//
//  Created by James Froggatt on 09/11/2019.
//  Copyright © 2019 James Froggatt. All rights reserved.
//

import XCTest
import UITestAdditions

extension SettingsRobot {
	@discardableResult
	func setDarkMode(_ enabled: Bool) -> Self {
		action {
			let developerButton = app.cells["Developer"]
			developerButton.scrollTo(in: app)
			developerButton.tap()
			let darkModeSwitch = app.switches["Dark Appearance"]
			if (darkModeSwitch.value as? String == "1") != enabled {
				darkModeSwitch.tap()
			}
			return self
		}
	}
}

public enum TestSwipeDirections {
    case up
    case down
    case left
    case right
}

public extension TestSwipeDirections {
    var vector: (begin: CGVector, end: CGVector) {
        switch self {
        case .up:
            return (begin: CGVector(dx: 0.0, dy: Double.random(in: 0.7...0.9)),
                    end:   CGVector(dx: 0.0, dy: Double.random(in: 0.1...0.3)))
        case .down:
            return (begin: CGVector(dx: 0.0, dy: Double.random(in: 0.1...0.3)),
                    end:   CGVector(dx: 0.0, dy: Double.random(in: 0.7...0.9)))
        case .left:
            return (begin: CGVector(dx: Double.random(in: 0.7...0.9), dy: 0.5),
                    end:   CGVector(dx: Double.random(in: 0.1...0.3), dy: 0.5))
        case .right:
            return (begin: CGVector(dx: Double.random(in: 0.1...0.3), dy: 0.5),
                    end:   CGVector(dx: Double.random(in: 0.7...0.9), dy: 0.5))
        }
    }
}

public extension XCUIElement {
    @discardableResult
    func scrollTo(
			direction: TestSwipeDirections = .up,
			swipeLimit: Int = 5,
			until shouldStop: KeyPath<XCUIElement, Bool> = \.exists,
			in app: XCUIApplication = .init()
		) -> Bool {
        return app.scroll(direction, swipeLimit: swipeLimit, until: { self[keyPath: shouldStop] })
    }
}

extension XCUIApplication {
    @discardableResult
    fileprivate func scroll(
			_ direction: TestSwipeDirections,
			swipeLimit: Int,
			until: () -> Bool
		) -> Bool {
        let begining = coordinate(withNormalizedOffset: direction.vector.begin)
        let ending = coordinate(withNormalizedOffset: direction.vector.end)

        var swipesRemaining = swipeLimit
        while !until() && swipesRemaining > 0 {
            begining.press(forDuration: 0.0, thenDragTo: ending)
            swipesRemaining -= 1
        }
        return until()
    }
}
