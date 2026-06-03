//
//  BigProfileViewCell.swift
//  TourMe
//
//  Created by Savet on 1/8/25.
//

import UIKit

class BigProfileViewCell: UITableViewCell {
	
	var onCameraTapped: (() -> Void)?
	var onDeleteProfile: (() -> Void)?
	
	private lazy var profileImgV: UIImageView = {
		let imgV = UIImageView()
		imgV.contentMode = .scaleAspectFill
		imgV.clipsToBounds = true
		imgV.isUserInteractionEnabled = true
		imgV.image = UIImage(named: "profile-user")
		imgV.tintColor = .imageHint
		imgV.translatesAutoresizingMaskIntoConstraints = false
		imgV.addSubview(cameraBgView)
		imgV.addSubview(cameraButton)
		NSLayoutConstraint.activate([
			cameraBgView.bottomAnchor.constraint(equalTo: imgV.bottomAnchor),
			cameraBgView.leadingAnchor.constraint(equalTo: imgV.leadingAnchor),
			cameraBgView.trailingAnchor.constraint(equalTo: imgV.trailingAnchor),
			cameraBgView.heightAnchor.constraint(equalToConstant: 25),
			cameraButton.centerXAnchor.constraint(equalTo: imgV.centerXAnchor),
			cameraButton.bottomAnchor.constraint(equalTo: imgV.bottomAnchor),
			cameraButton.heightAnchor.constraint(equalToConstant: 25),
		])
		let tap = UITapGestureRecognizer(target: self, action: #selector(addProfile))
		imgV.addGestureRecognizer(tap)
		return imgV
	}()
	
	private lazy var cameraBgView: UIView = {
		let view = UIView()
		view.backgroundColor = .black
		view.alpha = 0.3
		view.translatesAutoresizingMaskIntoConstraints = false
		
		return view
	}()
	
	private lazy var cameraButton: UIButton = {
		let button = UIButton(type: .system)
		button.setImage(UIImage(systemName: "camera.fill"), for: .normal)
		button.isEnabled = false
		button.tintColor = .white
		button.addTarget(self, action: #selector(deleteProfile), for: .touchUpInside)
		button.translatesAutoresizingMaskIntoConstraints = false
		return button
	}()

	private var gender: String = ""
	
	func setProfileImage(_ image: UIImage?, gender: String) {
		self.gender = gender
		profileImgV.image = image
		cameraButton.isEnabled = image != nil
		if image == nil {
			profileImgV.image = gender == "F" ? UIImage(named: "ic-default-woman") : UIImage(named: "ic-default-man")
		}
	}
	
	@objc private func addProfile() {
		onCameraTapped?()
	}
	
	@objc private func deleteProfile() {
		onDeleteProfile?()
		var image = UIImage(named: "profile-user")
		if gender == "M" {
			image = UIImage(named: "ic-default-man")
		}else {
			image = UIImage(named: "ic-default-woman")
		}
		profileImgV.image = image
		cameraButton.setImage(UIImage(systemName: "camera.fill"), for: .normal)
		cameraButton.tintColor = .white
	}
}
