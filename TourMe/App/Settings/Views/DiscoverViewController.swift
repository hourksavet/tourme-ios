//
//  DiscoverViewController.swift
//  TourMe
//
//  Created by Savet on 3/7/25.
//

import UIKit

class DiscoverViewController: UIViewController {

	override func viewDidLoad() {
		super.viewDidLoad()

		title = "discover".localized()
		let textAttributes = [
			NSAttributedString.Key.foregroundColor:UIColor.black,
			NSAttributedString.Key.font: UIFont.defaultMedium(size: UIFont.larg)
		]
		navigationController?.navigationBar.titleTextAttributes = textAttributes
		
		navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "ic_x"), style: .plain, target: self, action: #selector(closeScreen))
		navigationItem.rightBarButtonItem?.tintColor = .black
		view.backgroundColor = .screenBackground
	}
	

	@objc private func closeScreen() {
		dismiss(animated: true)
	}

}
