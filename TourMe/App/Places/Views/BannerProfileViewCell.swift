//
//  BannerProfileViewCell.swift
//  TourMe
//
//  Created by Savet on 7/7/25.
//

import UIKit

class BannerProfileViewCell: UITableViewCell, CellID {

	private lazy var placeImageView: UIImageView = {
		let imageView = UIImageView()
		imageView.contentMode = .scaleAspectFill
		imageView.translatesAutoresizingMaskIntoConstraints = false
		imageView.clipsToBounds = true
		return imageView
	}()
    
	private lazy var cameraImgV: UIImageView = {
		let imgV = UIImageView()
		imgV.image = UIImage(systemName: "camera.circle.fill")
		imgV.tintColor = .white
		imgV.translatesAutoresizingMaskIntoConstraints = false
		return imgV
	}()
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		
		contentView.addSubview(placeImageView)
		contentView.addSubview(cameraImgV)
		
		NSLayoutConstraint.activate([
			placeImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
			placeImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
			placeImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
			placeImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
			cameraImgV.bottomAnchor.constraint(equalTo: placeImageView.bottomAnchor, constant: -15),
			cameraImgV.trailingAnchor.constraint(equalTo: placeImageView.trailingAnchor, constant: -15),
			cameraImgV.heightAnchor.constraint(equalToConstant: 40),
			cameraImgV.widthAnchor.constraint(equalToConstant: 40)
		])
		contentView.backgroundColor = .lightGray
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func setImage(image: Data?) {
		if image != nil {
			placeImageView.image = UIImage(data: image!)
		}else {
			placeImageView.image = nil
		}
	}
}
