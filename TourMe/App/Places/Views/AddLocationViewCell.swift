//
//  AddLocationViewCell.swift
//  TourMe
//
//  Created by Savet on 7/7/25.
//

import UIKit

class AddLocationViewCell: UITableViewCell, CellID {
	
	private lazy var addLocationLabel: UILabel = {
		let label = UILabel()
		label.text = "add_location".localized()
		label.font = .defaultMedium(size: UIFont.normal)
		label.textColor = .lightGray
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	private lazy var imagV: UIImageView = {
		let imageV = UIImageView()
		imageV.image = UIImage(named: "place_marker")
		imageV.tintColor = .primary
		imageV.isHidden = true
		imageV.translatesAutoresizingMaskIntoConstraints = false
		return imageV
	}()
	
	var isSetLocation: Bool = false {
		didSet {
			imagV.isHidden = !isSetLocation
			addLocationLabel.text = isSetLocation ? "change_location".localized() : "add_location".localized()
			addLocationLabel.textColor = isSetLocation ? .primary : .lightGray
		}
	}
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		
		contentView.addSubview(addLocationLabel)
		contentView.addSubview(imagV)
		
		NSLayoutConstraint.activate([
			addLocationLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 30),
			addLocationLabel.trailingAnchor.constraint(equalTo: imagV.leadingAnchor, constant: -10),
			addLocationLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
			addLocationLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
			imagV.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
			imagV.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
			imagV.widthAnchor.constraint(equalToConstant: 25),
			imagV.heightAnchor.constraint(equalToConstant: 25)
		])
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

}
