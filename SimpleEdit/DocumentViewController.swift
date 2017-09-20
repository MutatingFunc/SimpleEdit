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
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		document?.undoManager = documentBodyTextView.undoManager
		document?.open(completionHandler: { (success) in
			if success {
				self.navigationItem.title = self.document?.fileURL.lastPathComponent
				self.documentBodyTextView.text = self.document?.text
			} else {
				UIAlertController(title: "Failed to open document", message: "Document could not be opened as UTF8 text", preferredStyle: .alert)
					.addAction("OK", handler: {[weak self] _ in self?.dismiss(animated: true)})
					.present(in: self, animated: true)
			}
		})
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
		dismiss(animated: true) {
			self.document?.close(completionHandler: nil)
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

