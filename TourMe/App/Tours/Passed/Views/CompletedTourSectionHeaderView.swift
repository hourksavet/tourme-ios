//
//  CompletedTourSectionHeaderView.swift
//  TourMe
//
//  Created by Savet on 25/5/26.
//

import UIKit

final class CompletedTourSectionHeaderView: UITableViewHeaderFooterView {

	private var onTap: (() -> Void)?

	private lazy var titleLabel: UILabel = {
		let label = UILabel()
		label.font = .default(size: UIFont.medium)
		label.textColor = .secondaryLabel
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()

	private lazy var chevronView: UIImageView = {
		let imageView = UIImageView(image: UIImage(systemName: "chevron.right"))
		imageView.tintColor = .secondaryLabel
		imageView.contentMode = .scaleAspectFit
		imageView.translatesAutoresizingMaskIntoConstraints = false
		return imageView
	}()

	private lazy var badgeLabel: PaddingLabel = {
		let label = PaddingLabel(padding: UIEdgeInsets(top: 4, left: 10, bottom: 4, right: 10))
		label.font = .default(size: UIFont.small)
		label.textColor = .primary
		label.backgroundColor = .lightPrimary
		label.layer.cornerRadius = 4
		label.clipsToBounds = true
		label.isHidden = true
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()

	private lazy var tapButton: UIButton = {
		let button = UIButton(type: .system)
		button.backgroundColor = .clear
		button.translatesAutoresizingMaskIntoConstraints = false
		button.addTarget(self, action: #selector(didTapHeader), for: .touchUpInside)
		return button
	}()

	override init(reuseIdentifier: String?) {
		super.init(reuseIdentifier: reuseIdentifier)
		contentView.addSubview(titleLabel)
		contentView.addSubview(chevronView)
		contentView.addSubview(badgeLabel)
		contentView.addSubview(tapButton)
		NSLayoutConstraint.activate([
			titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
			titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

			chevronView.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 8),
			chevronView.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
			chevronView.widthAnchor.constraint(equalToConstant: 10),
			chevronView.heightAnchor.constraint(equalToConstant: 16),

			badgeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
			badgeLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

			tapButton.topAnchor.constraint(equalTo: contentView.topAnchor),
			tapButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
			tapButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
			tapButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
		])
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	func configure(title: String, badgeText: String? = nil, isExpanded: Bool, onTap: (() -> Void)?) {
		titleLabel.text = title
		badgeLabel.text = badgeText
		badgeLabel.isHidden = badgeText == nil
		self.onTap = onTap
		chevronView.transform = isExpanded ? CGAffineTransform(rotationAngle: .pi / 2) : .identity
	}

	@objc private func didTapHeader() {
		onTap?()
	}
}
