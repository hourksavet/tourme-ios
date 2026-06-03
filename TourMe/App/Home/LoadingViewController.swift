//
//  LoadingViewController.swift
//  TourMe
//
//  Created by Savet on 26/6/25.
//

import UIKit

class LoadingViewController: UIViewController {

	private lazy var indicatorView: UIActivityIndicatorView = {
		let indicatorView = UIActivityIndicatorView()
		indicatorView.color = .primary
		indicatorView.translatesAutoresizingMaskIntoConstraints = false
		return indicatorView
	}()
	
	private lazy var loadingLabel: UILabel = {
		let label = UILabel()
		label.textColor = .primary
		label.text = "loading...".localized()
		label.font = .default(size: UIFont.normal)
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	private lazy var versionLb: UILabel = {
		let label = UILabel()
		label.textColor = .primary
		label.text = Bundle.main.releaseVersion
		label.font = .default(size: UIFont.normal)
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	override func loadView() {
		super.loadView()
		let stackView = UIStackView()
		stackView.axis = .horizontal
		stackView.spacing = 5
		stackView.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(stackView)
		view.addSubview(versionLb)
		
		NSLayoutConstraint.activate([
			stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			stackView.bottomAnchor.constraint(equalTo: versionLb.topAnchor, constant: -10),
			versionLb.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			versionLb.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40)
		])
		
		stackView.addArrangedSubview(indicatorView)
		stackView.addArrangedSubview(loadingLabel)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		indicatorView.startAnimating()
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { _ in
			self.checkUserAccount()
		}
		
	}
	
	deinit {
		print("\(self) dead!")
	}
	
	private func checkUserAccount() {
		let account = Const.dataManager.fetchData(Account.self)
		if account.isEmpty {
			let namingVC = NamingViewController().toNavigationController()
			movedToScreen(namingVC)
		}else {
			let homeVC = BaseTourMeViewController()
			movedToScreen(homeVC)
		}
	}
	
	private func movedToScreen(_ vc: UIViewController) {
		indicatorView.stopAnimating()
		
		if let windowScene = UIApplication.shared
			.connectedScenes
			.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
		   let window = windowScene.windows.first(where: { $0.isKeyWindow }) {
			window.rootViewController = vc
		}
	}
}

