//
//  AddNameViewCell.swift
//  TourMe
//
//  Created by Savet on 7/7/25.
//

import UIKit

class AddNameViewCell: UITableViewCell, CellID {

	var onEndedEditing: ((String) -> Void)?
	
	lazy var nameTextField: UITextField = {
		let textField = UITextField()
		textField.isUserInteractionEnabled = false
		textField.font = .defaultMedium(size: UIFont.normal)
		textField.attributedPlaceholder = NSAttributedString(
			string: "place_name".localized(),
			attributes: [
				.font: UIFont.defaultMedium(size: UIFont.normal),
				.foregroundColor: UIColor.lightGray
			]
		)
		textField.clearButtonMode = .whileEditing
		textField.translatesAutoresizingMaskIntoConstraints = false
		textField.delegate = self
		return textField
	}()
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		
		contentView.addSubview(nameTextField)
		NSLayoutConstraint.activate([
			nameTextField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
			nameTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 30),
			nameTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -30),
			nameTextField.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
		])
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

extension AddNameViewCell: UITextFieldDelegate {
	
	func textFieldDidEndEditing(_ textField: UITextField) {
		if textField == self.nameTextField {
			textField.isUserInteractionEnabled = false
			let text = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
			textField.text = text
			onEndedEditing?(text ?? "")
		}
	}
}
