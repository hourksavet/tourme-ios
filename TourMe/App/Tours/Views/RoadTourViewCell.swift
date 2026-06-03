//
//  RoadTourViewCell.swift
//  TourMe
//
//  Created by Savet on 23/7/25.
//

import UIKit

class RoadTourViewCell: UITableViewCell, CellID {

	private var tour: Tour!
	
	private lazy var roadDashedView: DashedLineView = {
		let view = DashedLineView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()
	
	private lazy var vehicleImgV: UIImageView = {
		let imgV = UIImageView()
		imgV.contentMode = .scaleAspectFit
		imgV.tintColor = .primary
		imgV.image = UIImage(named: "ic_car")?.withRenderingMode(.alwaysTemplate)
		imgV.translatesAutoresizingMaskIntoConstraints = false
		return imgV
	}()
	
	private lazy var placeImgV: UIImageView = {
		let imgV = UIImageView()
		imgV.contentMode = .scaleAspectFill
		imgV.backgroundColor = .gray
		imgV.translatesAutoresizingMaskIntoConstraints = false
		return imgV
	}()
	
	private lazy var placeMarkerImgV: UIImageView = {
		let imgV = UIImageView()
		imgV.contentMode = .scaleAspectFit
		imgV.image = UIImage(named: "ic_place_marker")
		imgV.translatesAutoresizingMaskIntoConstraints = false
		
		imgV.addSubview(placeImgV)
		NSLayoutConstraint.activate([
			placeImgV.topAnchor.constraint(equalTo: imgV.topAnchor, constant: 8),
			placeImgV.centerXAnchor.constraint(equalTo: imgV.centerXAnchor),
			placeImgV.widthAnchor.constraint(equalToConstant: 25),
			placeImgV.heightAnchor.constraint(equalTo: placeImgV.widthAnchor)
		])
		return imgV
	}()
	
	private lazy var profileImgV: UIImageView = {
		let imgV = UIImageView()
		imgV.contentMode = .scaleAspectFit
		imgV.backgroundColor = .gray
		imgV.translatesAutoresizingMaskIntoConstraints = false
		return imgV
	}()
	
	private lazy var profileMarkerImgV: UIImageView = {
		let imgV = UIImageView()
		imgV.contentMode = .scaleAspectFit
		imgV.tintColor = .primary
		imgV.image = UIImage(named: "ballon")?.withRenderingMode(.alwaysTemplate)
		imgV.translatesAutoresizingMaskIntoConstraints = false
		imgV.addSubview(profileImgV)
		NSLayoutConstraint.activate([
			profileImgV.topAnchor.constraint(equalTo: imgV.topAnchor, constant: 4),
			profileImgV.leadingAnchor.constraint(equalTo: imgV.leadingAnchor, constant: 4),
			profileImgV.widthAnchor.constraint(equalToConstant: 32),
			profileImgV.heightAnchor.constraint(equalTo: profileImgV.widthAnchor)
		])
		return imgV
	}()
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		let stView = UIView()
		stView.backgroundColor = .primary
		stView.translatesAutoresizingMaskIntoConstraints = false
		
		let endView = UIView()
		endView.backgroundColor = .primary
		endView.translatesAutoresizingMaskIntoConstraints = false
		
		contentView.addSubview(stView)
		contentView.addSubview(vehicleImgV)
		contentView.addSubview(roadDashedView)
		contentView.addSubview(endView)
		contentView.addSubview(placeMarkerImgV)
		contentView.addSubview(profileMarkerImgV)
		
		NSLayoutConstraint.activate([
			stView.widthAnchor.constraint(equalToConstant: 10),
			stView.heightAnchor.constraint(equalToConstant: 10),
			stView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
			stView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -15),
			vehicleImgV.widthAnchor.constraint(equalToConstant: 30),
			vehicleImgV.heightAnchor.constraint(equalToConstant: 30),
			vehicleImgV.centerYAnchor.constraint(equalTo: roadDashedView.topAnchor, constant: -8),
			
			vehicleImgV.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
			
			roadDashedView.leadingAnchor.constraint(equalTo: stView.trailingAnchor),
			roadDashedView.trailingAnchor.constraint(equalTo: endView.leadingAnchor),
			roadDashedView.centerYAnchor.constraint(equalTo: stView.centerYAnchor),
			roadDashedView.heightAnchor.constraint(equalToConstant: 2),
			
			endView.widthAnchor.constraint(equalToConstant: 10),
			endView.heightAnchor.constraint(equalToConstant: 10),
			endView.centerXAnchor.constraint(equalTo: placeMarkerImgV.centerXAnchor),
			endView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -15),
			
			placeMarkerImgV.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
			placeMarkerImgV.bottomAnchor.constraint(equalTo: endView.topAnchor),
			placeMarkerImgV.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor, constant: 15),
			placeMarkerImgV.widthAnchor.constraint(equalToConstant: 60),
			placeMarkerImgV.heightAnchor.constraint(equalToConstant: 60),
			
			profileMarkerImgV.trailingAnchor.constraint(equalTo: vehicleImgV.centerXAnchor),
			profileMarkerImgV.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor, constant: 0),
			profileMarkerImgV.bottomAnchor.constraint(equalTo: vehicleImgV.centerYAnchor),
			profileMarkerImgV.widthAnchor.constraint(equalToConstant: 50),
			profileMarkerImgV.heightAnchor.constraint(equalToConstant: 50),
			
		])
		stView.cornerRadius(5)
		endView.cornerRadius(5)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	
	override func layoutSubviews() {
		super.layoutSubviews()
		placeImgV.cornerRadius()
		profileImgV.cornerRadius()
	}

	func configer(_ tour: Tour, account: Account) {
		self.tour = tour
		if account.profile != nil {
			profileImgV.image = UIImage(data: account.profile!)
		}else {
			profileImgV.image = account.gender == "F" ? UIImage(named: "ic-default-woman") : UIImage(named: "ic-default-man")
		}
		placeImgV.image = UIImage(data: tour.banner!)
	}
}
