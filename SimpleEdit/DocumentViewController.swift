//
//  DocumentViewController.swift
//  SimpleEdit
//
//  Created by James Froggatt on 20.09.2017.
//  Copyright © 2017 James Froggatt. All rights reserved.
//

import UIKit

import Additions

class DocumentViewController: UIViewController, UITextViewDelegate, UIDocumentInteractionControllerDelegate {
	@IBOutlet var undoButtons: [UIBarButtonItem]!
	@IBOutlet var shareButton: UIBarButtonItem!
	@IBOutlet var documentBodyTextView: UITextView!
	
	var document: Document?
	
	override func viewDidLoad() {
		self.observeKeyboardNotifications()
		document?.open { (success) in
			if success {
				self.document?.undoManager = self.documentBodyTextView.undoManager
				self.navigationItem.title = self.document?.fileURL.lastPathComponent
				self.documentBodyTextView.text = self.document?.text
			} else {
				UIAlertController(title: "Failed to open document", message: "Document could not be opened as UTF8 text", preferredStyle: .alert)
					.addAction("OK", handler: {[weak self] _ in self?.dismiss(animated: true)})
					.present(in: self, animated: true)
			}
		}
	}
	deinit {
		document?.close(completionHandler: nil)
	}
	
	override func didMove(toParent parent: UIViewController?) {
		super.didMove(toParent: parent)
		NotificationCenter.default.addObserver(self, selector: #selector(userDefaultsChanged), name: UserDefaults.didChangeNotification, object: nil)
		userDefaultsChanged()
	}
	
	override func willMove(toParent parent: UIViewController?) {
		super.willMove(toParent: parent)
		NotificationCenter.default.removeObserver(self)
	}
	
	@objc func userDefaultsChanged() {
		DispatchQueue.main.async { [self] in
			editModeChanged()
			fontChanged()
			keyboardTypeChanged()
		}
	}
	
	var observation: NSKeyValueObservation?
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		self.userActivity = document?.activity
		if let windowScene = self.view.window?.windowScene {
			windowScene.title = userActivity?.title
			windowScene.userActivity = userActivity
		}
		observation = document?.observe(\.text) { document, change in
			if !self.documentBodyTextView.isFirstResponder {
				self.documentBodyTextView.text = document.text
			}
		}
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		observation = nil
		userActivity = nil
		if let windowScene = self.view.window?.windowScene {
			windowScene.title = nil
			windowScene.userActivity = nil
		}
	}
	
	var timer: Timer?
	func textViewDidChange(_ textView: UITextView) {
		guard let document = self.document else {return}
		document.text = documentBodyTextView.text
		self.undoButtons.forEach{$0.isEnabled = true}
	}
	
	@IBAction func undo() {
		guard let document = self.document else {return}
		document.undoManager.undo()
		document.text = documentBodyTextView.text
		if !document.undoManager.canUndo {
			self.undoButtons.forEach{$0.isEnabled = false}
		}
	}
	
	@IBAction func fontPrefs(_ sender: UIBarButtonItem) {
		let navVC = storyboard!.instantiateViewController(withIdentifier: "\(DocumentFontPrefsVC.self)") as! UINavigationController
		navVC.present(in: self, from: sender, animated: true)
	}
	func editModeChanged() {
		self.documentBodyTextView.isEditable = editMode
	}
	func fontChanged() {
		let size = fontSize ?? UIFont.systemFontSize
		self.documentBodyTextView.font = fontFamily =>? {UIFont(name: $0, size: size)} ?? UIFont.systemFont(ofSize: size)
	}
	func keyboardTypeChanged() {
		self.documentBodyTextView.keyboardType = keyboardType ?? .default
		if self.documentBodyTextView.isFirstResponder {
			self.documentBodyTextView.resignFirstResponder()
			self.documentBodyTextView.becomeFirstResponder()
		}
	}
	
	var documentInteractionController: UIDocumentInteractionController?
	@IBAction func share() {
		guard let document = self.document else {return}
		let doc = UIDocumentInteractionController(url: document.fileURL)
		doc.delegate = self
		doc.presentOptionsMenu(from: shareButton, animated: true)
		self.documentInteractionController = doc
	}
	func documentInteractionController(_ controller: UIDocumentInteractionController, didEndSendingToApplication application: String?) {
		self.documentInteractionController = nil
	}
	
	@IBAction func close() {
		if presentingViewController == nil, let scene = view.window?.windowScene {
			let options = UIWindowSceneDestructionRequestOptions()
			options.windowDismissalAnimation = .commit
			UIApplication.shared.requestSceneSessionDestruction(scene.session, options: options)
		} else {
			dismiss(animated: true) {
				self.document?.close(completionHandler: nil)
			}
		}
	}
	func performRevert() {
		guard let document = self.document else {return}
		while document.undoManager.canUndo {
			document.undoManager.undo()
		}
		documentBodyTextView.text = document.text
		self.undoButtons.forEach{$0.isEnabled = false}
	}
	@IBAction func revert() {
		UIAlertController(title: "Are you sure?", message: "This will discard all changes.", preferredStyle: .alert)
			.addAction("Cancel", style: .cancel, handler: nil)
			.addAction("Revert", style: .destructive) {[weak self] _ in
				self?.performRevert()
			}
			.present(in: self, animated: true)
	}
}

extension DocumentViewController: KeyboardInsetHelpers {
	var viewsObscuredByKeyboard: [UIScrollView] {
		return [documentBodyTextView]
	}
	func keyboardWasShown(_ notification: NSNotification) {
		helper_keyboardWasShown(notification)
	}
	func keyboardWillBeHidden(_ notification: NSNotification) {
		helper_keyboardWillBeHidden(notification)
	}
}
