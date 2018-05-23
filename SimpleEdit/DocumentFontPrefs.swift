//
//  DocumentFontPrefs.swift
//  SimpleEdit
//
//  Created by James Froggatt on 23.05.2018.
//  Copyright © 2018 James Froggatt. All rights reserved.
//

import UIKit

import Additions

let keyFont = "font"
let keyFontSize = "font size"
let keyKeyboardType = "keyboard type"

protocol DocumentFontPrefsDelegate: AnyObject {
	func keyboardTypeChanged()
	func fontChanged()
}
weak var fontPrefsDelegate: DocumentFontPrefsDelegate?

let ud = UserDefaults.standard

var fontFamily: String? {
	get {return ud.string(forKey: keyFont)}
	set {ud.set(newValue, forKey: keyFont); fontPrefsDelegate?.fontChanged()}
}
var fontSize: CGFloat? {
	get {return ud.double(forKey: keyFontSize) => {$0 < 0 ? nil : $0} =>? CGFloat.init(_:)}
	set {ud.set(newValue, forKey: keyFontSize); fontPrefsDelegate?.fontChanged()}
}
var keyboardType: UIKeyboardType? {
	get {return ud.integer(forKey: keyKeyboardType) => {$0 < 0 ? nil : $0} =>? UIKeyboardType.init(rawValue:)}
	set {ud.set(newValue?.rawValue, forKey: keyKeyboardType); fontPrefsDelegate?.keyboardTypeChanged()}
}

class DocumentFontPrefsVC: UIViewController {
	@IBOutlet var fontPicker: UIPickerView!
	@IBOutlet var fontSizePicker: UIPickerView!
	@IBOutlet var keyboardTypePicker: UIPickerView!
	
	weak var delegate: DocumentFontPrefsDelegate?
	var sources: [AnyObject] = []
	
	override func viewDidLoad() {
		let fontNames = UIFont.familyNames.sorted()
		self.sources = [
			PickerSource(
				count: fontNames.count + 1,
				getItem: {
					let font = $0 == 0 ? "System" : fontNames[$0-1]
					return NSAttributedString(string: font, attributes: [NSAttributedStringKey.font: UIFont(name: font, size: UIFont.systemFontSize) ?? UIFont.systemFont(ofSize: UIFont.systemFontSize)])
					} as (Int) -> NSAttributedString,
				initialSelection:
				fontFamily =>? fontNames.index =>? {$0 + 1}
					?? 0,
				onSelect: {fontFamily = $0 == 0 ? nil : fontNames[$0-1]}
			).add(to: fontPicker),
			
			PickerSource(
				count: 300,
				getItem: {$0 + 1},
				initialSelection: (fontSize =>? Int.init(_:) ?? 14) - 1,
				onSelect: {fontSize = CGFloat($0 + 1)}
			).add(to: fontSizePicker),
			
			PickerSource(
				count: 12,
				getItem: keyboardTypeName,
				initialSelection: keyboardType?.rawValue ?? UIKeyboardType.default.rawValue,
				onSelect: {keyboardType = UIKeyboardType(rawValue: $0)}
			).add(to: keyboardTypePicker)
		]
	}
	
	
	func keyboardTypeName(forRow row: Int) -> String {
		switch UIKeyboardType(rawValue: row)! {
		case .asciiCapable: return "ASCII"
		case .asciiCapableNumberPad: return "ASCII numpad"
		case .decimalPad: return "decimal pad"
		case .default: return "default"
		case .emailAddress: return "email address"
		case .namePhonePad: return "name phone pad"
		case .numberPad: return "number pad"
		case .numbersAndPunctuation: return "numbers and punctuation"
		case .phonePad: return "phone pad"
		case .twitter: return "Twitter"
		case .URL: return "URL"
		case .webSearch: return "web search"
		}
	}
	
	@IBAction func done() {
		self.dismiss(animated: true, completion: nil)
	}
}

class PickerSource<Type: CustomStringConvertible>: NSObject, UIPickerViewDataSource, UIPickerViewDelegate {
	var count: Int
	var initialSelection: Int
	var item: (_ at: Int) -> Type
	var selected: (_ at: Int) -> ()
	
	init(count: Int, getItem: @escaping (_ at: Int) -> Type, initialSelection: Int, onSelect: @escaping (_ at: Int) -> ()) {
		self.count = count
		self.item = getItem
		self.initialSelection = initialSelection
		self.selected = onSelect
	}
	
	func add(to pickerView: UIPickerView) -> Self {
		pickerView.dataSource = self
		pickerView.delegate = self
		pickerView.selectRow(initialSelection, inComponent: 0, animated: false)
		return self
	}
	
	func numberOfComponents(in pickerView: UIPickerView) -> Int {
		return 1
	}
	func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		return count
	}
	func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
		let item = self.item(row)
		return item as? NSAttributedString ?? NSAttributedString(string: item.description, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: UIFont.systemFontSize)])
	}
	func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		selected(row)
	}
}
