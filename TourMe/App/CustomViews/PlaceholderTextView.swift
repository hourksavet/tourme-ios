//
//  PlaceholderTextView.swift
//  TourMe
//
//  Created by Savet on 7/7/25.
//

import UIKit

class PlaceholderTextView: UITextView {
	let placeholderLeftMargin: CGFloat = 10.0
	let placeholderTopMargin: CGFloat = 5.0
	
	lazy var placeholderLabel: UILabel = {
		let label = UILabel()
		label.lineBreakMode = .byWordWrapping
		label.numberOfLines = 0
		label.backgroundColor = .clear
		label.alpha = 1.0
		return label
	}()
	
	@IBInspectable
	var placeholderColor: UIColor = .lightGray {
		didSet {
			placeholderLabel.textColor = placeholderColor
		}
	}
	
	@IBInspectable
	var placeholder: String = "" {
		didSet {
			placeholderLabel.text = placeholder
			placeholderSizeToFit()
		}
	}
	
	override var text: String! {
		didSet {
			textChanged(nil)
		}
	}
	
	override var font: UIFont? {
		didSet {
			placeholderLabel.font = font
			placeholderSizeToFit()
		}
	}
	
	private func placeholderSizeToFit() {
		placeholderLabel.frame = CGRect(
			x: placeholderLeftMargin,
			y: placeholderTopMargin,
			width: frame.width - placeholderLeftMargin * 2,
			height: 0.0
		)
		placeholderLabel.sizeToFit()
	}
	
	private func setup() {
		contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0);
		font = UIFont.systemFont(ofSize: 12.0)
		
		placeholderLabel.font = self.font
		placeholderLabel.textColor = placeholderColor
		placeholderLabel.text = placeholder
		placeholderSizeToFit()
		addSubview(placeholderLabel)
		
		sendSubviewToBack(placeholderLabel)
		
		let center = NotificationCenter.default
		center.addObserver(
			self,
			selector: #selector(PlaceholderTextView.textChanged(_:)),
			name: UITextView.textDidChangeNotification,
			object: nil
		)
		
		textChanged(nil)
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		setup()
	}
	
	override init(frame: CGRect, textContainer: NSTextContainer?) {
		super.init(frame: frame, textContainer: textContainer)
		setup()
	}
	
	convenience init() {
		self.init(frame: CGRect.zero, textContainer: nil)
		setup()
	}
	
	convenience init(frame: CGRect) {
		self.init(frame: frame, textContainer: nil)
		//    setup()
	}
	
	deinit {
		NotificationCenter.default.removeObserver(self)
	}
	
	override func awakeFromNib() {
		super.awakeFromNib()
		//    setup()
	}
	
	@objc func textChanged(_ notification:Notification?) {
		placeholderLabel.alpha = text.isEmpty ? 1.0 : 0.0
	}
}
