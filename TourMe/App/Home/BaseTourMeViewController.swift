//
//  BaseTourMeViewController.swift
//  TourMe
//
//  Created by Savet on 17/7/25.
//

import UIKit
import SVProgressHUD

class BaseTourMeViewController: UITabBarController {
	
    override func viewDidLoad() {
        super.viewDidLoad()

		// Setting up SVProgressView
		SVProgressHUD.setBackgroundColor(.white)
		SVProgressHUD.setForegroundColor(.primary)
		if let windowScene = UIApplication.shared
			.connectedScenes
			.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
		   let window = windowScene.windows.first(where: { $0.isKeyWindow }) {
			SVProgressHUD.setContainerView(window)
		}
		
		tabBar.tintColor = .primary
		setupTabViewControllers()
		
		NotificationCenter.default.addObserver(self, selector: #selector(onStartTour), name: Utils.observerName(.statedTour), object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(onEndedTour), name: Utils.observerName(.endedTour), object: nil)
    }

	private func setupTabViewControllers() {
		viewControllers?.removeAll()
		if let tour = getProgressTours() {
			let trackingVC = TourTrackingViewController(tour: tour)
			trackingVC.tabBarItem = UITabBarItem(
				title: "routing".localized(),
				image: UIImage(named: "road_trip"),
				selectedImage: nil
			)
			
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
			
			viewControllers = [trackingVC, tourTabVC, placesVC, settingsVC]
		}else {
			let mapVC = MapsViewController()
			mapVC.tabBarItem = UITabBarItem(
				title: "maps".localized(),
				image: UIImage(systemName: "map"),
				selectedImage: nil
			)
			
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
			
			viewControllers = [mapVC, tourTabVC, placesVC, settingsVC]
		}
	}
	
	private func getProgressTours() -> Tour! {
		let settings = NSPredicate(format: "startDate != nil AND endDate == nil")
		
		let sortDescriptor = NSSortDescriptor(key: "startDate", ascending: false)
		let tours = Const.dataManager.fetchData(Tour.self, predicate: settings, sortDescriptors: [sortDescriptor])
		if tours.isEmpty { return nil }
		
//		let tour = tours.first
//		tour?.startDate = nil
//		
//		try? Const.dataManager.context.save()
		
		return tours.first
	}
	
	@objc private func onStartTour() {
		if let tour = getProgressTours() {
			viewControllers?.remove(at: 0)
			let trackingVC = TourTrackingViewController(tour: tour)
			trackingVC.tabBarItem = UITabBarItem(title: "routing".localized(), image: UIImage(named: "road_trip"), selectedImage: nil)
			viewControllers?.insert(trackingVC, at: 0)
			selectedIndex = 0
		}
	}
	
	@objc private func onEndedTour() {
		viewControllers?.remove(at: 0)
		let mapVC = MapsViewController()
		mapVC.tabBarItem = UITabBarItem(title: "maps".localized(), image: UIImage(systemName: "map"), selectedImage: nil)
		viewControllers?.insert(mapVC, at: 0)
		selectedIndex = 0
	}
}
