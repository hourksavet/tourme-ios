//
//  PaddingLabel.swift
//  TourMe
//
//  Created by Savet on 3/7/25.
//

import UIKit

class PaddingLabel: UILabel {
	
	private var padding = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
	
	init(padding: UIEdgeInsets? = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)) {
		super.init(frame: .zero)
		if padding != nil {
			self.padding = padding!
		}
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func drawText(in rect: CGRect) {
		super.drawText(in: rect.inset(by: padding))
	}
	
	override var intrinsicContentSize: CGSize {
		get {
			var contentSize = super.intrinsicContentSize
			contentSize.height += padding.top + padding.bottom
			contentSize.width += padding.left + padding.right
			return contentSize
		}
	}
}
