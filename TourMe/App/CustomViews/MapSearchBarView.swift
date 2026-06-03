//
//  MapSearchBarView.swift
//  TourMe
//
//  Created by Savet on 3/7/25.
//

import UIKit

final class MapSearchBarView: UIView {

	var onBeginEditing: (() -> Void)?
	var onEndEditing: (() -> Void)?
	var onSearch: (() -> Void)?
	var onClose: (() -> Void)?

	var text: String? {
		get { searchBar.text }
		set { searchBar.text = newValue }
	}

	private lazy var searchContainerView: UIView = {
		let view = UIView()
		view.backgroundColor = .white
		view.alpha = 0.95
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	private lazy var searchBar: UISearchBar = {
		let bar = UISearchBar()
		bar.searchBarStyle = .minimal
		bar.placeholder = "search".localized()
		bar.returnKeyType = .search
		bar.autocorrectionType = .no
		bar.autocapitalizationType = .words
		bar.translatesAutoresizingMaskIntoConstraints = false
		bar.delegate = self
		bar.backgroundImage = UIImage()
		let textField = bar.searchTextField
		textField.backgroundColor = .clear
		textField.borderStyle = .none
		textField.clearButtonMode = .never
		textField.textColor = .primary
		textField.tintColor = .primary
		textField.font = .default(size: UIFont.normal)
		textField.attributedPlaceholder = NSAttributedString(string: "search".localized(), attributes: [
			.foregroundColor: UIColor.lightGray,
			.font: UIFont.default(size: UIFont.normal)
		])
		let micImageView = UIImageView(image: UIImage(systemName: "mic.fill"))
		micImageView.tintColor = .black
		micImageView.contentMode = .scaleAspectFit
		micImageView.frame = CGRect(x: 0, y: 0, width: 18, height: 18)
		textField.rightView = micImageView
		textField.rightViewMode = .always
		return bar
	}()

	private lazy var closeButton: UIButton = {
		let button = UIButton(type: .system)
		button.tintColor = .black
		button.backgroundColor = .white
		button.alpha = 0
		button.isHidden = true
		button.setImage(UIImage(systemName: "xmark"), for: .normal)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
		return button
	}()

	private var closeButtonWidthAnchor: NSLayoutConstraint?

	override init(frame: CGRect) {
		super.init(frame: frame)
		translatesAutoresizingMaskIntoConstraints = false
		backgroundColor = .clear
		addSubview(searchContainerView)
		addSubview(closeButton)
		searchContainerView.addSubview(searchBar)

		NSLayoutConstraint.activate([
			searchContainerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
			searchContainerView.topAnchor.constraint(equalTo: topAnchor),
			searchContainerView.bottomAnchor.constraint(equalTo: bottomAnchor),

			searchBar.topAnchor.constraint(equalTo: searchContainerView.topAnchor, constant: 4),
			searchBar.leadingAnchor.constraint(equalTo: searchContainerView.leadingAnchor, constant: 10),
			searchBar.trailingAnchor.constraint(equalTo: searchContainerView.trailingAnchor, constant: -10),
			searchBar.bottomAnchor.constraint(equalTo: searchContainerView.bottomAnchor, constant: -4),

			closeButton.leadingAnchor.constraint(equalTo: searchContainerView.trailingAnchor, constant: 12),
			closeButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
			closeButton.centerYAnchor.constraint(equalTo: searchContainerView.centerYAnchor),
			closeButton.heightAnchor.constraint(equalToConstant: 54),
			searchContainerView.trailingAnchor.constraint(equalTo: closeButton.leadingAnchor, constant: -12)
		])

		closeButtonWidthAnchor = closeButton.widthAnchor.constraint(equalToConstant: 0)
		closeButtonWidthAnchor?.isActive = true
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func layoutSubviews() {
		super.layoutSubviews()
		searchContainerView.addShadow(radius: searchContainerView.bounds.height / 2)
		searchContainerView.cornerRadius()
		closeButton.addShadow(radius: closeButton.bounds.height / 2)
		closeButton.cornerRadius()
	}

	func resignSearch() {
		searchBar.resignFirstResponder()
	}

	private func setEditing(_ isEditing: Bool) {
		closeButtonWidthAnchor?.constant = isEditing ? 54 : 0
		if isEditing {
			closeButton.isHidden = false
		}
		UIView.animate(withDuration: 0.2, delay: 0, options: [.beginFromCurrentState, .curveEaseOut], animations: {
			self.closeButton.alpha = isEditing ? 1 : 0
			self.layoutIfNeeded()
		}, completion: { _ in
			self.closeButton.isHidden = !isEditing
		})
	}

	@objc private func closeTapped() {
		searchBar.text = nil
		searchBar.resignFirstResponder()
		onClose?()
	}
}

extension MapSearchBarView: UISearchBarDelegate {

	func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
		setEditing(true)
		onBeginEditing?()
	}

	func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
		setEditing(false)
		onEndEditing?()
	}

	func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
		onSearch?()
	}

	func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
		closeTapped()
	}
}