//
//  ProfileTableViewCell.swift
//  TourMe
//
//  Created by Savet on 1/7/25.
//

import UIKit

class ProfileTableViewCell: UITableViewCell, CellID {

	private lazy var profileImV: UIImageView = {
		let imV = UIImageView()
		imV.translatesAutoresizingMaskIntoConstraints = false
		return imV
	}()
	
	private lazy var nameLabel: UILabel = {
		let label = UILabel()
		label.font = .defaultBold(size: UIFont.larg)
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	private lazy var memoriesLabel: UILabel = {
		let label = UILabel()
		label.font = .default(size: UIFont.normal)
		label.text = "your_memories".localized()
		label.textColor = .hintText
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		contentView.addSubview(profileImV)
		contentView.addSubview(nameLabel)
		contentView.addSubview(memoriesLabel)
		
		NSLayoutConstraint.activate([
			profileImV.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
			profileImV.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
			profileImV.widthAnchor.constraint(equalToConstant: 60),
			profileImV.heightAnchor.constraint(equalToConstant: 60),
			
			nameLabel.leadingAnchor.constraint(equalTo: profileImV.trailingAnchor, constant: 10),
			nameLabel.bottomAnchor.constraint(equalTo: profileImV.centerYAnchor, constant: -3),
			
			memoriesLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
			memoriesLabel.topAnchor.constraint(equalTo: profileImV.centerYAnchor, constant: 3),
		])
		profileImV.cornerRadius(30)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func configer(_ data: Account) {
		if data.profile != nil {
			profileImV.image = UIImage(data: data.profile!)
		}else {
			profileImV.image = data.gender == "F" ? UIImage(named: "ic-default-woman") : UIImage(named: "ic-default-man")
		}
		nameLabel.text = data.name
	}
}
