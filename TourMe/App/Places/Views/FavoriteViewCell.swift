//
//  FavoriteViewCell.swift
//  TourMe
//
//  Created by Savet on 7/7/25.
//

import UIKit

class FavoriteViewCell: UITableViewCell, CellID {

	private lazy var titleLabel: UILabel = {
		let label = UILabel()
		label.font = .default(size: UIFont.normal)
		label.text = "your_favorite_place".localized()
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	private lazy var heartButton: UIButton = {
		let button = UIButton(type: .system)
		button.setImage(UIImage(systemName: "heart"), for: .normal)
		button.tintColor = .red
		button.isUserInteractionEnabled = false
		button.translatesAutoresizingMaskIntoConstraints = false
		return button
	}()
	
	var isFavorite: Bool = false {
		didSet {
			updateView()
		}
	}
	private var view: UIView!
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		contentView.addSubview(titleLabel)
		contentView.addSubview(heartButton)
		
		view = UIView()
		view.backgroundColor = .white
		view.translatesAutoresizingMaskIntoConstraints = false
		addSubview(view)
		
		NSLayoutConstraint.activate([
			
			titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
			titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 30),
			
			heartButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
			heartButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
			heartButton.widthAnchor.constraint(equalToConstant: 30),
			heartButton.heightAnchor.constraint(equalToConstant: 30),
			
			view.topAnchor.constraint(equalTo: topAnchor),
			view.leadingAnchor.constraint(equalTo: contentView.trailingAnchor),
			view.trailingAnchor.constraint(equalTo: trailingAnchor),
			view.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10)
		])
		
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		bringSubviewToFront(view)
	}
	
	private func updateView() {
		let image = UIImage(systemName: isFavorite ? "heart.fill" : "heart")
		heartButton.setImage(image, for: .normal)
	}
	
	func setTitle(_ title: String) {
		titleLabel.text = title
	}
}
