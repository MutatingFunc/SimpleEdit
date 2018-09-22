//
//  KeyboardInsetting.swift
//  SimpleEdit
//
//  Created by James Froggatt on 22.09.2018.
//  Copyright © 2018 James Froggatt. All rights reserved.
//

import UIKit

@objc protocol KeyboardInsetHelpers where Self: UIViewController {
	var viewsObscuredByKeyboard: [UIScrollView] {get}
	@objc func keyboardWasShown(_ notification: NSNotification)
	@objc func keyboardWillBeHidden(_ notification: NSNotification)
}

extension KeyboardInsetHelpers {
	func observeKeyboardNotifications() {
		let nc = NotificationCenter.default
		nc.addObserver(self, selector: #selector(keyboardWasShown), name: UIResponder.keyboardDidShowNotification, object: nil)
		nc.addObserver(self, selector: #selector(keyboardWillBeHidden), name: UIResponder.keyboardWillHideNotification, object: nil)
	}
	
	func helper_keyboardWasShown(_ notification: NSNotification) {
		let info = notification.userInfo
		let infoNSValue = info![UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue
		let kbSize = infoNSValue.cgRectValue.size
		let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: kbSize.height, right: 0.0)
		viewsObscuredByKeyboard.forEach {
			$0.contentInset = contentInsets
			$0.scrollIndicatorInsets = contentInsets
		}
	}
	
	func helper_keyboardWillBeHidden(_ notification: NSNotification) {
		let contentInsets = UIEdgeInsets.zero
		viewsObscuredByKeyboard.forEach {
			$0.contentInset = contentInsets
			$0.scrollIndicatorInsets = contentInsets
		}
	}
}
