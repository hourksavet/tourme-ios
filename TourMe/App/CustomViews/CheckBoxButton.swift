//
//  CheckBoxButton.swift
//  TourMe
//
//  Created by Savet on 7/7/25.
//

import UIKit

class CheckBox: UIControl {
	
	// MARK: - Properties
	final var isChecked: Bool = true {
		didSet {
			updateCheck()
		}
	}
	
	private var checkedImageView: UIImageView = {
		let imageView = UIImageView(image: UIImage(systemName: "checkmark"))
		imageView.translatesAutoresizingMaskIntoConstraints = false
		return imageView
	}()
	
	init() {
		super.init(frame: .zero)
		addSubview(checkedImageView)
		
		checkedImageView.topAnchor.constraint(equalTo: topAnchor, constant: 3).isActive = true
		checkedImageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -3).isActive = true
		checkedImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 3).isActive = true
		checkedImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -3).isActive = true
		
		addTarget(self, action: #selector(clicked), for: .touchUpInside)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		cornerRadius(4)
		layer.borderWidth = 1.5
		layer.borderColor = UIColor.black.cgColor
	}
	
	// MARK: Actions
	private func updateCheck() {
		if isChecked {
			checkedImageView.isHidden = false
		}else {
			checkedImageView.isHidden = true
		}
	}
	
	@objc private func clicked() {
		isChecked = !isChecked
	}
}
