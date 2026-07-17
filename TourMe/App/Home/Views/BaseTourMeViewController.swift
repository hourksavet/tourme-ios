//
//  BaseTourMeViewController.swift
//  TourMe
//
//  Created by Savet on 17/7/25.
//

import Combine
import UIKit
import SVProgressHUD

class BaseTourMeViewController: UITabBarController {

	private let viewModel = BaseTourMeViewModel()
	private var cancellables = Set<AnyCancellable>()
		
	override func viewDidLoad() {
		super.viewDidLoad()

		SVProgressHUD.setBackgroundColor(.white)
		SVProgressHUD.setForegroundColor(.primary)
		if let windowScene = UIApplication.shared
			.connectedScenes
			.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
		   let window = windowScene.windows.first(where: { $0.isKeyWindow }) {
			SVProgressHUD.setContainerView(window)
		}
			
		tabBar.tintColor = .primary
		bindViewModel()
		viewModel.send(.viewDidLoad)
	}

	private func bindViewModel() {
		viewModel.$state
			.removeDuplicates { $0.ongoingTour?.id == $1.ongoingTour?.id }
			.receive(on: DispatchQueue.main)
			.sink { [weak self] state in
				self?.setupTabViewControllers(ongoingTour: state.ongoingTour)
			}
			.store(in: &cancellables)

		NotificationCenter.default.publisher(for: Utils.observerName(.statedTour))
			.sink { [weak self] _ in
				self?.viewModel.send(.tourStarted)
			}
			.store(in: &cancellables)

		NotificationCenter.default.publisher(for: Utils.observerName(.endedTour))
			.sink { [weak self] _ in
				self?.viewModel.send(.tourEnded)
			}
			.store(in: &cancellables)
	}

	private func setupTabViewControllers(ongoingTour: Tour?) {
		viewControllers?.removeAll()

		let firstTab: UIViewController
		if let ongoingTour {
			let trackingVC = TourTrackingViewController(tour: ongoingTour)
			trackingVC.tabBarItem = UITabBarItem(
				title: "routing".localized(),
				image: UIImage(named: "road_trip"),
				selectedImage: nil
			)
			firstTab = trackingVC
		} else {
			let mapVC = MapsViewController()
			mapVC.tabBarItem = UITabBarItem(
				title: "maps".localized(),
				image: UIImage(systemName: "map"),
				selectedImage: nil
			)
			firstTab = mapVC
		}

		let tourTabVC = TabTourViewController()
		tourTabVC.tabBarItem = UITabBarItem(
			title: "tours".localized(),
			image: UIImage(named: "tours_two_marker"),
			selectedImage: nil
		)
			
		let placesVC = TabPlacesViewController()
		placesVC.tabBarItem = UITabBarItem(
			title: "places".localized(),
			image: UIImage(named: "places"),
			selectedImage: nil
		)
			
		let settingsVC = SettingsViewController().toNavigationController()
		settingsVC.tabBarItem = UITabBarItem(
			title: "settings".localized(),
			image: UIImage(systemName: "gear"),
			selectedImage: nil
		)
			
		viewControllers = [firstTab, tourTabVC, placesVC, settingsVC]
		selectedIndex = 0
	}
}
