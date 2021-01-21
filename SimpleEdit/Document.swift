//
//  Document.swift
//  SimpleEdit
//
//  Created by James Froggatt on 20.09.2017.
//  Copyright © 2017 James Froggatt. All rights reserved.
//

import UIKit

class Document: UIDocument {
	enum Error: Swift.Error {case filePackage, readFailed, encodingFailed}
	
	var text = ""
	
	override func contents(forType typeName: String) throws -> Any {
		guard let encoded = text.data(using: .utf8) else {throw Error.encodingFailed}
		return encoded
	}
	
	override func load(fromContents contents: Any, ofType typeName: String?) throws {
		guard let data = contents as? Data else {throw Error.filePackage}
		guard let string = String(data: data, encoding: .utf8) else {throw Error.readFailed}
		text = string
	}
	
	var activity: NSUserActivity {
		let activity = NSUserActivity(activityType: "SimpleEditActivity")
		do {
			let bookmark = try fileURL.bookmarkData()
			activity.userInfo = ["URL": bookmark].compactMapValues{$0}
		} catch {
			assertionFailure(error.localizedDescription)
		}
		return activity
	}
}

