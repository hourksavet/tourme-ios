//
//  AddNoteViewCell.swift
//  TourMe
//
//  Created by Savet on 7/7/25.
//

import UIKit

class AddNoteViewCell: UITableViewCell, CellID {

	var onEndedEditing: ((String) -> Void)?
	
	lazy var noteTextView: UITextView = {
		let textView = UITextView()
		textView.isUserInteractionEnabled = false
		textView.translatesAutoresizingMaskIntoConstraints = false
		textView.layer.cornerRadius = 8
		textView.font = .default(size: UIFont.normal)
		textView.backgroundColor = UIColor(hexString: "FAFAFA")
		textView.delegate = self
		return textView
	}()
	
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		contentView.addSubview(noteTextView)
		
		NSLayoutConstraint.activate([
			noteTextView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15),
			noteTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
			noteTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
			noteTextView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -15)
		])
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

extension AddNoteViewCell: UITextViewDelegate {
	
	func textViewDidEndEditing(_ textView: UITextView) {
		if textView == self.noteTextView {
			textView.isUserInteractionEnabled = false
			let text = self.noteTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
			textView.text = text
			onEndedEditing?(text)
		}
	}
	
}
