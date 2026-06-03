//
//  TabChoosePlacesViewController.swift
//  TourMe
//
//  Created by Savet on 2/7/25.
//

import UIKit

enum PlaceType {
	case all
	case saved
	case visited
}

class TabChoosePlacesViewController: UIPageViewController {
	
	var onChosePlaces: (([Place]) -> Void)?
	
	private lazy var searchView: UISearchTextField = {
		let view = UISearchTextField()
		view.placeholder = "search".localized()
		view.backgroundColor = .secondarySystemBackground
		view.layer.cornerRadius = 8
		view.leftViewMode = .always
		view.returnKeyType = .done
		view.translatesAutoresizingMaskIntoConstraints = false
		let searchIcon = UIImage(systemName: "magnifyingglass")
		view.leftView = UIImageView(image: searchIcon)
		view.tintColor = .lightGray
		view.leftViewMode = .always
		view.attributedPlaceholder = NSAttributedString(string: "search".localized(), attributes: [
			.foregroundColor: UIColor.lightGray,
			.font: UIFont.default(size: UIFont.normal)
		])
		view.delegate = self
		return view
	}()
	
	private lazy var segmentV: UISegmentedControl = {
		let seg = UISegmentedControl(items: ["all".localized(), "saved".localized(), "visited".localized()])
		seg.selectedSegmentIndex = 0
		seg.setTitleTextAttributes([
			NSAttributedString.Key.font : UIFont.default(size: UIFont.normal),
			NSAttributedString.Key.foregroundColor : UIColor.primary
		], for: .normal)
		seg.setTitleTextAttributes([
			NSAttributedString.Key.font : UIFont.default(size: UIFont.normal),
			NSAttributedString.Key.foregroundColor : UIColor.primary
		], for: .selected)
		seg.backgroundColor = .secondary
		seg.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
		seg.translatesAutoresizingMaskIntoConstraints = false
		return seg
	}()
	
	private lazy var actionButton: RoundButton = {
		let button = RoundButton(radius: 55/2, activeColor: .primary, inactiveColor: .lightPrimary)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.titleLabel?.font = .defaultMedium(size: 20)
		button.addTarget(self, action: #selector(tabOnActionButton), for: .touchUpInside)
		return button
	}()
	
	private lazy var closeButton: UIButton = {
		let btn = UIButton(type: .system)
		btn.titleLabel?.font = .defaultBold(size: UIFont.medium)
		btn.setImage(UIImage(systemName: "xmark"), for: .normal)
		btn.backgroundColor = .red
		btn.setTitleColor(.white, for: .normal)
		btn.translatesAutoresizingMaskIntoConstraints = false
		btn.tintColor = .white
		btn.addTarget(self, action: #selector(closeSelection), for: .touchUpInside)
		btn.addShadow(radius: 55/2)
		return btn
	}()
	
	private var pages: [UIViewController] = []
	
	private var type: PlaceType = .all
	
	private var chosePlaces: [Place] = []
	private var visitPlaces: [VisitPlace] = []
	
	init(chosePlaces: [Place] = [], visitPlaces: [VisitPlace] = []) {
		super.init(transitionStyle: .scroll, navigationOrientation: .horizontal)
		self.chosePlaces = chosePlaces
		self.visitPlaces = visitPlaces
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func loadView() {
		super.loadView()
		view.addSubview(searchView)
		view.addSubview(segmentV)
		view.addSubview(actionButton)
		view.addSubview(closeButton)
		
		NSLayoutConstraint.activate([
			searchView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
			searchView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
			searchView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
			searchView.heightAnchor.constraint(equalToConstant: 44),
			
			segmentV.topAnchor.constraint(equalTo: searchView.bottomAnchor, constant: 10),
			segmentV.leadingAnchor.constraint(equalTo: searchView.leadingAnchor),
			segmentV.trailingAnchor.constraint(equalTo: searchView.trailingAnchor),
			segmentV.heightAnchor.constraint(equalToConstant: 40),
			
			actionButton.heightAnchor.constraint(equalToConstant: 55),
			actionButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
			actionButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
			
			closeButton.widthAnchor.constraint(equalToConstant: 55),
			closeButton.heightAnchor.constraint(equalToConstant: 55),
			closeButton.centerYAnchor.constraint(equalTo: actionButton.centerYAnchor),
			closeButton.leadingAnchor.constraint(equalTo: actionButton.trailingAnchor, constant: 16),
			closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
		])
		
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()

		title = "places".localized()
		let textAttributes = [
			NSAttributedString.Key.foregroundColor:UIColor.black,
			NSAttributedString.Key.font: UIFont.defaultMedium(size: UIFont.larg)
		]
		navigationController?.navigationBar.titleTextAttributes = textAttributes
		navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "ic_x"), style: .plain, target: self, action: #selector(closeScreen))
		navigationItem.rightBarButtonItem?.tintColor = .black
		view.backgroundColor = .screenBackground
		
		delegate = self
		dataSource = self
		let numberChosePlaces = max(chosePlaces.count, visitPlaces.count)
		
		actionButton.setTitle("\("done".localized()) (\(numberChosePlaces))", for: .normal)
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		if pages.isEmpty {
			var topPadding: CGFloat = view.safeAreaInsets.top
			topPadding += searchView.bounds.maxY + searchView.bounds.height + 20
			let padding = UIEdgeInsets(top: topPadding, left: 0, bottom: 60, right: 0)
			let allPlacesVC = AllChoosePlacesViewController(padding)
			let savedPlacesVC = ChooseSavedPlacesViewController(padding)
			let visitedPlacesVC = ChooseVisitedPlacesViewController(padding)
			
			allPlacesVC.chosePlaces = self.chosePlaces
			allPlacesVC.visitPlaces = self.visitPlaces
			allPlacesVC.onUpdatedChosePlace = { [weak self] places in
				savedPlacesVC.chosePlaces = places
				visitedPlacesVC.chosePlaces = places
				self?.chosePlaces = places
				self?.actionButton.setTitle("\("done".localized()) (\(places.count))", for: .normal)
			}
			
			savedPlacesVC.chosePlaces = self.chosePlaces
			savedPlacesVC.visitPlaces = self.visitPlaces
			savedPlacesVC.onUpdatedChosePlace = { [weak self] places in
				allPlacesVC.chosePlaces = places
				visitedPlacesVC.chosePlaces = places
				self?.chosePlaces = places
				self?.actionButton.setTitle("\("done".localized()) (\(places.count))", for: .normal)
			}
			
			visitedPlacesVC.chosePlaces = self.chosePlaces
			visitedPlacesVC.visitPlaces = self.visitPlaces
			visitedPlacesVC.onUpdatedChosePlace = { [weak self] places in
				allPlacesVC.chosePlaces = places
				savedPlacesVC.chosePlaces = places
				self?.chosePlaces = places
				self?.actionButton.setTitle("\("done".localized()) (\(places.count))", for: .normal)
			}
			
			pages = [allPlacesVC, savedPlacesVC, visitedPlacesVC]
			
			type = .all
			setViewControllers([pages[0]], direction: .forward, animated: false)
		}
	}

	@objc private func closeScreen() {
		dismiss(animated: true)
	}

	@objc private func tabOnActionButton() {
		onChosePlaces?(chosePlaces)
		closeScreen()
	}
	
	@objc private func closeSelection() {
		dismiss(animated: true)
	}
	
	@objc func segmentChanged(_ sender: UISegmentedControl) {
		var direction: NavigationDirection = .forward
		switch type {
			case .saved:
				if sender.selectedSegmentIndex == 0 {
					direction = .reverse
				}
			case .visited:
				direction = .reverse
			default:
				break
		}
		switch sender.selectedSegmentIndex {
			case 0:
				type = .all
			case 1:
				type = .saved
			case 2:
				type = .visited
			default:
				break
		}
		setViewControllers([pages[sender.selectedSegmentIndex]], direction: direction, animated: true)
	}
	
	private func updateTabsSelectedAt(index: Int) {
		switch index {
			case 0:
				type = .all
			case 1:
				type = .saved
			default:
				type = .visited
				
		}
		segmentV.selectedSegmentIndex = index
	}
}

extension TabChoosePlacesViewController: UIPageViewControllerDataSource {
	
	func presentationCount(for pageViewController: UIPageViewController) -> Int {
		return pages.count
	}
	
	func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
		guard let index = pages.firstIndex(of: viewController), index > 0 else { return nil }
		return pages[index - 1]
	}
	
	func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
		guard let index = pages.firstIndex(of: viewController), index < pages.count - 1 else { return nil }
		return pages[index + 1]
	}
}

extension TabChoosePlacesViewController: UIPageViewControllerDelegate {
	
	func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
		if completed {
			if let currentVC = pageViewController.viewControllers?.first {
				if let index = pages.firstIndex(of: currentVC) {
					updateTabsSelectedAt(index: index)
				}
			}
		}
	}
	
}

extension TabChoosePlacesViewController: UISearchTextFieldDelegate {
	
	func textFieldDidChangeSelection(_ textField: UITextField) {
		let text = (textField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
		if let vc = pages[0] as? AllChoosePlacesViewController {
			vc.textSearch = text
		}
		if let vc = pages[1] as? ChooseSavedPlacesViewController {
			vc.textSearch = text
		}
		if let vc = pages[2] as? ChooseVisitedPlacesViewController {
			vc.textSearch = text
		}
		
	}
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		textField.resignFirstResponder()
		return true
	}
}
