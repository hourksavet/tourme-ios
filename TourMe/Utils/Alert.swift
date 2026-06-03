//
//  Alert.swift
//  TourMe
//
//  Created by Savet on 11/7/25.
//

import UIKit

struct Alert {
	
	static func showDefault(on viewController: UIViewController, title: String? = nil, message: String? = nil, button: String) {
		let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: button, style: .default, handler: nil))
		viewController.present(alert, animated: true, completion: nil)
	}
	
	static func show(on viewController: UIViewController, title: String? = nil, message: String? = nil, cancelTitle: String? = nil, okTitle: String, completion: @escaping () -> Void) {
		let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: okTitle, style: .default, handler: { _ in
			completion()
		}))
		if cancelTitle != nil {
			alert.addAction(UIAlertAction(title: cancelTitle, style: .cancel, handler: nil))
		}
		viewController.present(alert, animated: true, completion: nil)
	}
	
	static func show(on viewController: UIViewController, title: String? = nil, message: String? = nil, cancelTitle: String?, failure: @escaping () -> Void, okTitle: String, completion: @escaping () -> Void) {
		let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: okTitle, style: .default, handler: { _ in
			completion()
		}))
		if cancelTitle != nil {
			alert.addAction(UIAlertAction(title: cancelTitle, style: .cancel, handler: { _ in
				failure()
			}))
		}
		viewController.present(alert, animated: true, completion: nil)
	}
	
	static func autoDismiss(on viewController: UIViewController, title: String? = nil, message: String? = nil, completion: (() -> Void)? = nil) {
		let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
		viewController.present(alert, animated: true) {
			Timer.scheduledTimer(withTimeInterval: 1, repeats: false, block: { _ in
				viewController.dismiss(animated: true, completion: completion)
			})
		}
	}
}
