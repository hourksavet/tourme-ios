//
//  FavoriteButton.swift
//  TourMe
//
//  Created by Savet on 18/5/26.
//
import UIKit

class FavoriteButton: UIControl {
	
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
	
	init(title: String) {
		super.init(frame: .zero)
		addSubview(titleLabel)
		addSubview(heartButton)
		
		NSLayoutConstraint.activate([
			
			titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
			titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
			
			heartButton.centerYAnchor.constraint(equalTo: centerYAnchor),
			heartButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
			heartButton.widthAnchor.constraint(equalToConstant: 30),
			heartButton.heightAnchor.constraint(equalToConstant: 30),
		])
		titleLabel.text = title
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	private func updateView() {
		let image = UIImage(systemName: isFavorite ? "heart.fill" : "heart")
		heartButton.setImage(image, for: .normal)
	}
}
