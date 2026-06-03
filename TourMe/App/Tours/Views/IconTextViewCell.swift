//
//  IconTextViewCell.swift
//  TourMe
//
//  Created by Savet on 7/7/25.
//

import UIKit

class IconTextViewCell: UITableViewCell, CellID {

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
	
	private lazy var iconCheckImgV: UIImageView = {
		let imgView = UIImageView()
		imgView.contentMode = .scaleAspectFit
		imgView.isHidden = true
		imgView.image = UIImage(systemName: "checkmark.circle.fill")
		imgView.tintColor = .primary
		imgView.translatesAutoresizingMaskIntoConstraints = false
		return imgView
	}()
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		contentView.addSubview(iconImgView)
		contentView.addSubview(titleLabel)
		contentView.addSubview(iconCheckImgV)
		
		NSLayoutConstraint.activate([
			iconImgView.widthAnchor.constraint(equalToConstant: 35),
			iconImgView.heightAnchor.constraint(equalToConstant: 35),
			iconImgView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
			iconImgView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
			titleLabel.leadingAnchor.constraint(equalTo: iconImgView.trailingAnchor, constant: 15),
			titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
			iconCheckImgV.heightAnchor.constraint(equalToConstant: 20),
			iconCheckImgV.widthAnchor.constraint(equalToConstant: 20),
			iconCheckImgV.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
			iconCheckImgV.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
		])
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func configure(text: String, icon: UIImage, isSelected: Bool) {
		iconImgView.image = icon
		iconCheckImgV.isHidden = !isSelected
		titleLabel.text = text
	}
	
	func setSelect(_ isSelect: Bool) {
		iconCheckImgV.isHidden = !isSelect
	}
}
