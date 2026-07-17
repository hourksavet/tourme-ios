//
//  TabPlacesViewController.swift
//  TourMe
//
//  Created by Savet on 18/5/26.
//

import UIKit

private enum PlaceTab: Int {
	case all
	case saved
	case visited
}

class TabPlacesViewController: UIViewController {

	private lazy var segmentV: UISegmentedControl = {
		let seg = UISegmentedControl(items: ["all".localized(), "saved".localized(), "visited".localized()])
		seg.selectedSegmentIndex = PlaceTab.all.rawValue
		seg.setTitleTextAttributes([
			NSAttributedString.Key.font: UIFont.default(size: UIFont.normal),
			NSAttributedString.Key.foregroundColor: UIColor.primary
		], for: .normal)
		seg.setTitleTextAttributes([
			NSAttributedString.Key.font: UIFont.default(size: UIFont.normal),
			NSAttributedString.Key.foregroundColor: UIColor.primary
		], for: .selected)
		seg.backgroundColor = .secondary
		seg.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
		seg.translatesAutoresizingMaskIntoConstraints = false
		return seg
	}()

	private lazy var containerView: UIView = {
		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	private lazy var addPlaceButton: UIButton = {
		let button = UIButton(type: .system)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.tintColor = .white
		button.backgroundColor = .primary
		button.setImage(UIImage(systemName: "plus"), for: .normal)
		button.layer.cornerRadius = 28
		button.layer.shadowColor = UIColor.lightGray.cgColor
		button.layer.shadowOpacity = 0.35
		button.layer.shadowOffset = CGSize(width: 0, height: 4)
		button.layer.shadowRadius = 6
		button.addTarget(self, action: #selector(addNewPlace), for: .touchUpInside)
		return button
	}()

	private lazy var allVC = AllPlacesViewController()
	private lazy var savedVC = SavedPlacesViewController()
	private lazy var visitedVC = VisitedPlacesViewController()
	private lazy var pageController: UIPageViewController = {
		let controller = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
		controller.dataSource = self
		controller.delegate = self
		return controller
	}()
	private lazy var pages: [UIViewController] = [allVC, savedVC, visitedVC]
	private var currentTab: PlaceTab = .all

	override func loadView() {
		super.loadView()

		view.addSubview(segmentV)
		view.addSubview(containerView)
		view.addSubview(addPlaceButton)

		NSLayoutConstraint.activate([
			segmentV.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
			segmentV.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
			segmentV.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
			segmentV.heightAnchor.constraint(equalToConstant: 40),

			containerView.topAnchor.constraint(equalTo: segmentV.bottomAnchor, constant: 10),
			containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

			addPlaceButton.widthAnchor.constraint(equalToConstant: 56),
			addPlaceButton.heightAnchor.constraint(equalToConstant: 56),
			addPlaceButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
			addPlaceButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
		])

		addChild(pageController)
		containerView.addSubview(pageController.view)
		pageController.view.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			pageController.view.topAnchor.constraint(equalTo: containerView.topAnchor),
			pageController.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
			pageController.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
			pageController.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
		])
		pageController.didMove(toParent: self)
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		title = "places".localized()
		view.backgroundColor = .screenBackground

		navigationItem.largeTitleDisplayMode = .never
		navigationController?.navigationBar.tintColor = .primary
		let appearance = UINavigationBarAppearance()
		appearance.configureWithOpaqueBackground()
		appearance.titleTextAttributes = [
			NSAttributedString.Key.foregroundColor: UIColor.primary,
			NSAttributedString.Key.font: UIFont.default(size: UIFont.normal)
		]
		navigationItem.standardAppearance = appearance

		switchToTab(.all)
	}

	@objc private func segmentChanged(_ sender: UISegmentedControl) {
		guard let tab = PlaceTab(rawValue: sender.selectedSegmentIndex) else { return }
		switchToTab(tab)
	}

	@objc private func addNewPlace() {
		let addPlaceVC = PlaceDetailsViewController(action: .add, enableClose: true).toNavigationController()
		addPlaceVC.modalPresentationStyle = .overFullScreen
		present(addPlaceVC, animated: true)
	}

	private func switchToTab(_ tab: PlaceTab) {
		let nextViewController = pages[tab.rawValue]
		let direction: UIPageViewController.NavigationDirection = tab.rawValue >= currentTab.rawValue ? .forward : .reverse
		segmentV.selectedSegmentIndex = tab.rawValue
		guard pageController.viewControllers?.first !== nextViewController else { return }
		currentTab = tab
		pageController.setViewControllers([nextViewController], direction: direction, animated: true)
	}
	
}

extension TabPlacesViewController: UIPageViewControllerDataSource {

	func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
		guard let index = pages.firstIndex(of: viewController), index > 0 else { return nil }
		return pages[index - 1]
	}

	func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
		guard let index = pages.firstIndex(of: viewController), index < pages.count - 1 else { return nil }
		return pages[index + 1]
	}
}

extension TabPlacesViewController: UIPageViewControllerDelegate {

	func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
		guard completed, let currentVC = pageViewController.viewControllers?.first, let index = pages.firstIndex(of: currentVC), let tab = PlaceTab(rawValue: index) else {
			return
		}
		currentTab = tab
		segmentV.selectedSegmentIndex = index
	}
}

