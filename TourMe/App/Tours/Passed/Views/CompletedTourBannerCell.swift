//
//  CompletedTourBannerCell.swift
//  TourMe
//
//  Created by Savet on 25/5/26.
//

import UIKit

final class CompletedTourBannerCell: UITableViewCell, CellID {

	private lazy var bannerImageView: UIImageView = {
		let imageView = UIImageView()
		imageView.contentMode = .scaleAspectFill
		imageView.clipsToBounds = true
		imageView.translatesAutoresizingMaskIntoConstraints = false
		return imageView
	}()

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		contentView.addSubview(bannerImageView)
		NSLayoutConstraint.activate([
			bannerImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
			bannerImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
			bannerImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
			bannerImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
		])
		contentView.backgroundColor = .secondarySystemBackground
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	func configure(imageData: Data?) {
		bannerImageView.image = imageData.flatMap(UIImage.init(data:))
	}
}
