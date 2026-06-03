//
//  MemoriesCell.swift
//  TourMe
//
//  Created by Savet on 4/7/25.
//

import UIKit

class MemoriesCell: UITableViewCell, CellID {

	private lazy var memoryImageView: UIImageView = {
		let imageView = UIImageView()
		imageView.translatesAutoresizingMaskIntoConstraints = false
		return imageView
	}()
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
