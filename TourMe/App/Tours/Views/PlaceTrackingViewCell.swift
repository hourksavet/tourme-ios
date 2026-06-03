//
//  PlaceTrackingViewCell.swift
//  TourMe
//
//  Created by Savet on 13/11/25.
//

import UIKit

class PlaceTrackingViewCell: UICollectionViewCell, CellID {
	
	private lazy var placeImgV: UIImageView = {
		let imgV = UIImageView()
		imgV.contentMode = .scaleToFill
		imgV.clipsToBounds = true
		imgV.layer.cornerRadius = 8
		imgV.backgroundColor = .lightGray
		imgV.translatesAutoresizingMaskIntoConstraints = false
		return imgV
	}()
	
	private lazy var placeNameLbl: UILabel = {
		let lbl = UILabel()
		lbl.font = .defaultMedium(size: 15)
		lbl.numberOfLines = 2
		lbl.translatesAutoresizingMaskIntoConstraints = false
		return lbl
	}()
	
	private lazy var statusLabel: PaddingLabel = {
		let lbl = PaddingLabel()
		lbl.font = .default(size: 13)
		lbl.textColor = .white
		lbl.backgroundColor = .primary
		lbl.textAlignment = .center
		lbl.layer.cornerRadius = 4
		lbl.translatesAutoresizingMaskIntoConstraints = false
		return lbl
	}()
	
	private lazy var placeIndexLabel: UILabel = {
		let lbl = UILabel()
		lbl.font = .defaultMedium(size: 12)
		lbl.textColor = .white
		lbl.backgroundColor = .primary
		lbl.textAlignment = .center
		lbl.translatesAutoresizingMaskIntoConstraints = false
		return lbl
	}()
	
	private lazy var arrivalTimeLabel: UILabel = {
		let lbl = UILabel()
		lbl.font = .default(size: 15)
		lbl.translatesAutoresizingMaskIntoConstraints = false
		return lbl
	}()
	
	private lazy var distanceLabel: UILabel = {
		let lbl = UILabel()
		lbl.font = .defaultMedium(size: 15)
		lbl.translatesAutoresizingMaskIntoConstraints = false
		return lbl
	}()

	private static let etaFormatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateFormat = "h:mm a"
		return formatter
	}()
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		setupViews()
		
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		setupViews()
	}
	
	private func setupViews() {
		backgroundColor = .white
		contentView.addSubview(placeImgV)
		contentView.addSubview(placeNameLbl)
		contentView.addSubview(statusLabel)
		contentView.addSubview(placeIndexLabel)
		contentView.addSubview(arrivalTimeLabel)
		contentView.addSubview(distanceLabel)
		NSLayoutConstraint.activate([
			placeImgV.widthAnchor.constraint(equalToConstant: 120),
			placeImgV.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
			placeImgV.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
			placeImgV.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
			
			placeNameLbl.bottomAnchor.constraint(equalTo: placeImgV.centerYAnchor, constant: -8),
			placeNameLbl.leadingAnchor.constraint(equalTo: placeImgV.trailingAnchor, constant: 10),
			
			statusLabel.centerYAnchor.constraint(equalTo: placeNameLbl.centerYAnchor),
			statusLabel.leadingAnchor.constraint(equalTo: placeNameLbl.trailingAnchor, constant: 15),
			
			placeIndexLabel.widthAnchor.constraint(equalToConstant: 22),
			placeIndexLabel.heightAnchor.constraint(equalToConstant: 22),
			placeIndexLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
			placeIndexLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
			
			arrivalTimeLabel.topAnchor.constraint(equalTo: placeImgV.centerYAnchor, constant: 8),
			arrivalTimeLabel.leadingAnchor.constraint(equalTo: placeNameLbl.leadingAnchor),
			
			distanceLabel.centerYAnchor.constraint(equalTo: arrivalTimeLabel.centerYAnchor),
			distanceLabel.leadingAnchor.constraint(equalTo: arrivalTimeLabel.trailingAnchor, constant: 30)
		])
		placeIndexLabel.clipsToBounds = true
		statusLabel.clipsToBounds = true
		placeIndexLabel.layer.cornerRadius = 11
	}
	
	func configure(with visitPlace: VisitPlace, index: Int) {
		statusLabel.text = ""
		arrivalTimeLabel.text = "--:--"
		distanceLabel.text = "\(Utils.toDistance(meters: Int(visitPlace.distance)))"
		
		placeIndexLabel.text = "\(index + 1)"
		placeImgV.image = UIImage(data: visitPlace.place!.thumb ?? Data())
		placeNameLbl.text = visitPlace.place!.name
		layer.borderWidth = 0
		layer.borderColor = UIColor.clear.cgColor
		backgroundColor = .white
		switch visitPlace.status {
		case .waiting:
			statusLabel.text = "waiting".localized()
		case .onging:
			statusLabel.text = "ongoing".localized()
			layer.borderWidth = 2
			layer.borderColor = UIColor.primary.cgColor
			backgroundColor = UIColor(hexString: "CAE4ED")
			if visitPlace.duration != 0 {
				let estimatedArrival = Date().addingTimeInterval(visitPlace.duration / 1000)
				arrivalTimeLabel.text = Self.etaFormatter.string(from: estimatedArrival)
			}
		case .arrived:
			statusLabel.text = "visiting".localized()
			layer.borderWidth = 2
			layer.borderColor = UIColor.primary.cgColor
			backgroundColor = UIColor(hexString: "CAE4ED")
		case .visited:
			let minutes = Calendar.current.dateComponents([.minute], from: visitPlace.arrived_date!, to: visitPlace.ended_date!).minute!
			statusLabel.text = "visited".localized()
			arrivalTimeLabel.text = "\(minutes) \("minute".localized())"
		}
	}
}
