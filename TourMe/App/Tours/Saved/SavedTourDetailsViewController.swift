//
//  SavedTourDetailsViewController.swift
//  TourMe
//
//  Created by Savet on 7/7/25.
//

import UIKit
import CoreLocation

typealias TourProfileCell = BannerProfileViewCell

class SavedTourDetailsViewController: UIViewController {

	private var enableClose: Bool = false
	private var tour: Tour!
	private var places: [Place] = []
	private var locationManager: CLLocationManager!
	
	private lazy var tableView: UITableView = {
		let tableView = UITableView(frame: .zero, style: .insetGrouped)
		tableView.register(TourProfileCell.self)
		tableView.register(DefaultViewCell.self)
		tableView.register(MapsViewCell.self)
		tableView.register(TourPlaceViewCell.self)
		tableView.register(IconTextViewCell.self)
		tableView.translatesAutoresizingMaskIntoConstraints = false
		return tableView
	}()
	
	private lazy var startTourButton: RoundButton = {
		let button = RoundButton(radius: 55/2, activeColor: .primary, inactiveColor: .lightPrimary)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.setTitle("start_tour".localized(), for: .normal)
		button.titleLabel?.font = .defaultMedium(size: 20)
		button.addTarget(self, action: #selector(startTour), for: .touchUpInside)
		return button
	}()
	
	init(_ tour: Tour, enableClose: Bool = false) {
		super.init(nibName: nil, bundle: nil)
		self.tour = tour
		self.enableClose = enableClose
		if let visitPls = tour.visitPlaces?.compactMap({$0 as? VisitPlace}) {
			for visitPl in visitPls {
				self.places.append(visitPl.place!)
			}
		}
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func loadView() {
		super.loadView()
		view.addSubview(tableView)
		view.addSubview(startTourButton)
		
		NSLayoutConstraint.activate([
			tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
			tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
			startTourButton.heightAnchor.constraint(equalToConstant: 55),
			startTourButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
			startTourButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
			startTourButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
		])
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		title = "review".localized()
		view.backgroundColor = .screenBackground
		
		navigationController?.navigationBar.tintColor = .primary
		navigationItem.largeTitleDisplayMode = .never
		let appearance = UINavigationBarAppearance()
		appearance.configureWithOpaqueBackground()
		appearance.titleTextAttributes = [
			NSAttributedString.Key.foregroundColor:UIColor.primary,
			NSAttributedString.Key.font: UIFont.default(size: UIFont.normal)
		]
		navigationItem.standardAppearance = appearance
		
		if enableClose {
			navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .done, target: self, action: #selector(closeScreen))
		}
		
		tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 55))
		tableView.dataSource = self
		tableView.delegate = self
		
		locationManager = CLLocationManager()
		locationManager.requestWhenInUseAuthorization()
		locationManager.startUpdatingLocation()
    }
	
	deinit {
		print("\(self) deinit")
	}
	
	@objc private func startTour() throws {
		if let location = locationManager.location {
			locationManager.stopUpdatingLocation()
			tour.startDate = Date()
			tour.startLat = location.coordinate.latitude
			tour.startLng = location.coordinate.longitude
			let context = Const.dataManager.context
			try context.save()
			NotificationCenter.default.post(name: Utils.observerName(.statedTour), object: nil, userInfo: [String.tour: tour!])
			dismiss(animated: false)
		}else {
			Alert.showDefault(on: self, message: "can't_get_location", button: "retry".localized())
		}
	}
	
	@objc private func closeScreen() {
		dismiss(animated: true)
	}
}

extension SavedTourDetailsViewController: UITableViewDataSource {
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return 5
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch section {
			case 0, 1, 2:
				return 1
			case 3:
				return places.count
			case 4:
				return 1
			default:
				return 0
		}
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		switch indexPath.section {
			case 0:
				let cell = tableView.dequeue(TourProfileCell.self, for: indexPath)
				cell.setImage(image: tour.banner)
				return cell
			case 1:
				let cell = tableView.dequeue(DefaultViewCell.self, for: indexPath)
				cell.titleLabel.font = .defaultMedium(size: UIFont.medium)
				cell.selectedBackgroundView = UIView()
				cell.titleLabel.text = tour.name
				return cell
			case 2:
				let cell = tableView.dequeue(MapsViewCell.self, for: indexPath)
				cell.configur(places: places)
				cell.selectedBackgroundView = UIView()
				return cell
			case 3:
				let cell = tableView.dequeue(TourPlaceViewCell.self, for: indexPath)
				cell.configure(with: places[indexPath.row])
				return cell
			default:
				let cell = tableView.dequeue(IconTextViewCell.self, for: indexPath)
				let icon = tour.vehicle == "CAR" ? UIImage(named: "ic_car")! : UIImage(named: "ic_motorcycle")!
				let text = tour.vehicle == "CAR" ? "car".localized() : "moto".localized()
				cell.configure(text: text, icon: icon, isSelected: true)
				return cell
		}
	}
	
}

extension SavedTourDetailsViewController: UITableViewDelegate {
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		switch indexPath.section {
			case 0:
				return tableView.frame.width * 3 / 5
			case 1:
				return 60
			case 2:
				return tableView.frame.height * (3 / 4)
			case 3:
				return 90
			default:
				return 60
		}
	}
	
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		switch section {
			case 3:
				return "places".localized()
			case 4:
				return "transport".localized()
			default:
				return nil
		}
	}
}
