//
//  PlaceTableViewCell.swift
//  TourMe
//
//  Created by Savet on 1/7/25.
//

import UIKit

class PlaceTableViewCell: UITableViewCell, CellID {
	
	private var placeModel: PlaceListModel!
	
	private lazy var chosedIndexLabel: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.font = .default(size: UIFont.small)
		label.textAlignment = .center
		label.adjustsFontSizeToFitWidth = true
		label.textColor = .white
		return label
	}()
	
	private lazy var statusChooseView: UIView = {
		let view = UIView()
		view.backgroundColor = .primary
		view.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(chosedIndexLabel)
		chosedIndexLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 2).isActive = true
		chosedIndexLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 2).isActive = true
		chosedIndexLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -2).isActive = true
		chosedIndexLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -2).isActive = true
		view.cornerRadius(10)
		view.isHidden = true
		return view
	}()
	
	private lazy var thumbnailImgV: UIImageView = {
		let imgV = UIImageView()
		imgV.contentMode = .scaleAspectFill
		imgV.translatesAutoresizingMaskIntoConstraints = false
		return imgV
	}()
	
	private lazy var nameLabel: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.font = .defaultMedium(size: UIFont.normal)
		return label
	}()
	
	private lazy var visitLabel: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.font = .default(size: UIFont.small)
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
	
	private var leadingThumbnail: NSLayoutConstraint!
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		contentView.addSubview(statusChooseView)
		contentView.addSubview(thumbnailImgV)
		contentView.addSubview(nameLabel)
		contentView.addSubview(visitLabel)
		contentView.addSubview(favoriteBtn)
		
		leadingThumbnail = thumbnailImgV.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16)
		leadingThumbnail.isActive = true
		
		NSLayoutConstraint.activate([
			statusChooseView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
			statusChooseView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
			statusChooseView.widthAnchor.constraint(equalToConstant: 20),
			statusChooseView.heightAnchor.constraint(equalToConstant: 20),
			thumbnailImgV.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
			thumbnailImgV.widthAnchor.constraint(equalToConstant: 90),
			thumbnailImgV.heightAnchor.constraint(equalToConstant: 60),
			nameLabel.leadingAnchor.constraint(equalTo: thumbnailImgV.trailingAnchor, constant: 10),
			nameLabel.bottomAnchor.constraint(equalTo: thumbnailImgV.centerYAnchor, constant: -3),
			visitLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
			visitLabel.topAnchor.constraint(equalTo: thumbnailImgV.centerYAnchor, constant: 4),
			visitLabel.trailingAnchor.constraint(equalTo: favoriteBtn.leadingAnchor, constant: -10),
			favoriteBtn.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
			favoriteBtn.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
			favoriteBtn.widthAnchor.constraint(equalToConstant: 30),
			favoriteBtn.heightAnchor.constraint(equalToConstant: 30)
		])
		thumbnailImgV.cornerRadius(10)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func configure(with placeModel: PlaceListModel) {
		self.placeModel = placeModel
		thumbnailImgV.image = UIImage(data: placeModel.place.thumb ?? Data())
		nameLabel.text = placeModel.place.name
		visitLabel.text = "\(placeModel.place.visitCount) \("visit".localized())"
		let image = placeModel.place.isFavorite ? UIImage(systemName: "heart.fill") : UIImage(systemName: "heart")
		favoriteBtn.setImage(image, for: .normal)
		statusChooseView.isHidden = !placeModel.isChose
		leadingThumbnail.constant = placeModel.isChose ? 46 : 16
		chosedIndexLabel.text = "\(placeModel.choseOrder + 1)"
	}
	
	@objc private func clickedFavoriteBtn() throws {
		placeModel.place.isFavorite.toggle()
		try Const.dataManager.context.save()
		configure(with: placeModel)
		NotificationCenter.default.post(name: Utils.observerName(.addPlace), object: nil, userInfo: [String.place: placeModel.place])
	}
}
