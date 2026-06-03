//
//  RadioButton.swift
//  TourMe
//
//  Created by Savet on 27/6/25.
//

import UIKit

class RadioButton: UIControl {

	// MARK: - Properties
	override var isSelected: Bool {
		didSet {
			updateViews()
		}
	}
	
	private lazy var borderView: UIView = {
		let view = UIView()
		view.backgroundColor = .white
		view.isUserInteractionEnabled = false
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()
	
	fileprivate lazy var fillView: UIView = {
		let view = UIView()
		view.backgroundColor = .white
		view.isUserInteractionEnabled = false
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()
	
	fileprivate lazy var titleLabel: UILabel = {
		let label = UILabel()
		label.font = .default(size: 17)
		label.isUserInteractionEnabled = false
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	init(title: String) {
		super.init(frame: .zero)
		titleLabel.text = title
		
		addSubview(borderView)
		borderView.addSubview(fillView)
		addSubview(titleLabel)
		
		borderView.widthAnchor.constraint(equalToConstant: 20).isActive = true
		borderView.heightAnchor.constraint(equalToConstant: 20).isActive = true
		borderView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
		borderView.topAnchor.constraint(equalTo: topAnchor, constant: 10).isActive = true
		borderView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10).isActive = true
		borderView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10).isActive = true
		
		fillView.topAnchor.constraint(equalTo: borderView.topAnchor, constant: 5).isActive = true
		fillView.bottomAnchor.constraint(equalTo: borderView.bottomAnchor, constant: -5).isActive = true
		fillView.leadingAnchor.constraint(equalTo: borderView.leadingAnchor, constant: 5).isActive = true
		fillView.trailingAnchor.constraint(equalTo: borderView.trailingAnchor, constant: -5).isActive = true
		
		titleLabel.leadingAnchor.constraint(equalTo: borderView.trailingAnchor, constant: 15).isActive = true
		titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10).isActive = true
		titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		borderView.cornerRadius()
		fillView.cornerRadius(5)
		borderView.layer.borderWidth = 2
		borderView.layer.borderColor = UIColor.primary.cgColor
	}
	
	// MARK: - Other functions
	fileprivate func updateViews() {
		fillView.backgroundColor = isSelected ? .primary : .clear
	}

}
