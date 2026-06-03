//
//  SettingViewCell.swift
//  TourMe
//
//  Created by Savet on 1/8/25.
//

import UIKit

class SettingViewCell: UITableViewCell, CellID {

	private lazy var iconImgView: UIImageView = {
		let imgView = UIImageView()
		imgView.tintColor = .primary
		imgView.contentMode = .scaleAspectFit
		imgView.translatesAutoresizingMaskIntoConstraints = false
		return imgView
	}()
	
	private lazy var titleLabel: UILabel = {
		let label = UILabel()
		label.font = .default(size: UIFont.normal)
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		contentView.addSubview(iconImgView)
		contentView.addSubview(titleLabel)
		
		NSLayoutConstraint.activate([
			iconImgView.widthAnchor.constraint(equalToConstant: 25),
			iconImgView.heightAnchor.constraint(equalToConstant: 25),
			iconImgView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
			iconImgView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
			titleLabel.leadingAnchor.constraint(equalTo: iconImgView.trailingAnchor, constant: 10),
			titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
		])
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func configure(text: String, icon: UIImage?) {
		iconImgView.image = icon
		titleLabel.text = text
	}

}
