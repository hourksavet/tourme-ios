//
//  CompletedTourActionCell.swift
//  TourMe
//
//  Created by Savet on 25/5/26.
//

import UIKit

final class CompletedTourActionCell: UITableViewCell, CellID {

	private var onTap: (() -> Void)?

	private lazy var actionButton: RoundButton = {
		let button = RoundButton(radius: 10, activeColor: .primary, inactiveColor: .lightPrimary)
		button.tintColor = .white
		button.titleLabel?.font = .defaultMedium(size: UIFont.medium)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.addTarget(self, action: #selector(didTapAction), for: .touchUpInside)
		return button
	}()

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		backgroundColor = .clear
		contentView.backgroundColor = .clear
		contentView.addSubview(actionButton)
		NSLayoutConstraint.activate([
			actionButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
			actionButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
			actionButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
			actionButton.heightAnchor.constraint(equalToConstant: 50)
		])
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	func configure(title: String, image: UIImage?, onTap: (() -> Void)?) {
		self.onTap = onTap
		actionButton.setTitle(title, for: .normal)
		actionButton.setTitleColor(.white, for: .normal)
		actionButton.setImage(image, for: .normal)
		actionButton.imageView?.contentMode = .scaleAspectFit
		actionButton.semanticContentAttribute = .forceLeftToRight
		actionButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -8, bottom: 0, right: 8)
	}

	@objc private func didTapAction() {
		onTap?()
	}
}
