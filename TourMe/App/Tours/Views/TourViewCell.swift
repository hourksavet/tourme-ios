//
//  TourViewCell.swift
//  TourMe
//
//  Created by Savet on 7/7/25.
//

import UIKit

class TourViewCell: UITableViewCell, CellID {

	private var tour: Tour!
	
	private lazy var thumbImageV: UIImageView = {
		let imgV = UIImageView()
		imgV.contentMode = .scaleAspectFill
		imgV.clipsToBounds = true
		imgV.layer.cornerRadius = 10
		imgV.backgroundColor = .lightGray
		imgV.translatesAutoresizingMaskIntoConstraints = false
		return imgV
	}()

	private lazy var starImgV: UIImageView = {
		let imgV = UIImageView()
		imgV.contentMode = .scaleAspectFit
		imgV.image = UIImage(systemName: "star.fill")
		imgV.tintColor = .primary
		imgV.translatesAutoresizingMaskIntoConstraints = false
		return imgV
	}()
	
	private lazy var titleLabel: UILabel = {
		let label = UILabel()
		label.font = .defaultMedium(size: UIFont.normal)
		label.numberOfLines = 1
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	private lazy var placeCountLabel: UILabel = {
		let label = UILabel()
		label.font = .default(size: UIFont.normal)
		label.numberOfLines = 1
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	private lazy var favoriteBtn: UIButton = {
		let btn = UIButton(type: .system)
		btn.setImage(UIImage(systemName: "heart"), for: .normal)
		btn.tintColor = .red
		btn.addTarget(self, action: #selector(clickedFavoriteBtn), for: .touchUpInside)
		btn.translatesAutoresizingMaskIntoConstraints = false
		return btn
	}()
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		contentView.addSubview(thumbImageV)
		contentView.addSubview(starImgV)
		contentView.addSubview(titleLabel)
		contentView.addSubview(placeCountLabel)
		contentView.addSubview(favoriteBtn)
		
		NSLayoutConstraint.activate([
			thumbImageV.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor, constant: 15),
			thumbImageV.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15),
			thumbImageV.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -15),
			thumbImageV.widthAnchor.constraint(equalToConstant: 90),
			thumbImageV.heightAnchor.constraint(equalToConstant: 90 * 3 / 5),
			titleLabel.leadingAnchor.constraint(equalTo: thumbImageV.trailingAnchor, constant: 15),
			titleLabel.bottomAnchor.constraint(equalTo: thumbImageV.centerYAnchor, constant: -4),
			starImgV.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 10),
			starImgV.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
			placeCountLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
			placeCountLabel.topAnchor.constraint(equalTo: thumbImageV.centerYAnchor, constant: 4),
			favoriteBtn.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
			favoriteBtn.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
		])
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func configer(_ tour: Tour) {
		self.tour = tour
		thumbImageV.image = UIImage(data: tour.banner!)
		titleLabel.text = tour.name
		placeCountLabel.text = "\(tour.visitPlaces?.count ?? 0) \("places".localized())"
		let image = tour.isFavorite ? UIImage(systemName: "heart.fill") : UIImage(systemName: "heart")
		favoriteBtn.setImage(image, for: .normal)
	}
	
	@objc private func clickedFavoriteBtn() throws {
		if tour == nil {
			return
		}
		tour.isFavorite.toggle()
		try Const.dataManager.context.save()
		configer(tour)
		NotificationCenter.default.post(name: Utils.observerName(.addTour), object: nil, userInfo: [String.tour: tour!])
	}
}
