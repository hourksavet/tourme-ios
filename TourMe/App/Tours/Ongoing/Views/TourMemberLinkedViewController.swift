//
//  TourMemberLinkedViewController.swift
//  TourMe
//
//  Created by Savet on 21/5/26.
//

import UIKit
import CoreLocation

class TourMemberLinkedViewController: UIViewController {

	private var memberCount: Int = 1 {
		didSet {
			memberCountLabel.text = "\(memberCount)"
		}
	}
	
	private lazy var mapView: ToureMeMapView = {
		let mapV = ToureMeMapView()
		mapV.minimumZoomLevel = 6
		mapV.maximumZoomLevel = 18
		mapV.isRotateEnabled = false
		mapV.showsUserLocation = true
		mapV.compassViewPosition = .topRight
		mapV.compassView.isUserInteractionEnabled = false
		mapV.automaticallyAdjustsContentInset = false
		mapV.translatesAutoresizingMaskIntoConstraints = false
		return mapV
	}()

	private lazy var bkStatusView: UIView = {
		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	private lazy var statusEffectView: UIVisualEffectView = {
		let effect = UIBlurEffect(style: .systemMaterialLight)
		let view = UIVisualEffectView(effect: effect)
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	private let statusFadeMask = CAGradientLayer()
	
	private lazy var closeButton: UIButton = {
		let button = UIButton(type: .system)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.tintColor = .white
		button.backgroundColor = .primary
		button.setImage(UIImage(systemName: "xmark"), for: .normal)
		button.layer.cornerRadius = 20
		button.layer.shadowColor = UIColor.lightGray.cgColor
		button.layer.shadowOpacity = 0.35
		button.layer.shadowOffset = CGSize(width: 0, height: 4)
		button.layer.shadowRadius = 6
		button.addTarget(self, action: #selector(onClose), for: .touchUpInside)
		return button
	}()

	private lazy var memberContentView: UIView = {
		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.backgroundColor = .white
		view.alpha = 0.92
		view.layer.cornerRadius = 22
		return view
	}()

	private lazy var memberIconView: UIImageView = {
		let imageView = UIImageView(image: UIImage(systemName: "person.2.fill"))
		imageView.translatesAutoresizingMaskIntoConstraints = false
		imageView.tintColor = .primary
		imageView.contentMode = .scaleAspectFit
		return imageView
	}()

	private lazy var memberCountLabel: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.font = .defaultBold(size: 18)
		label.textColor = .primary
		label.text = "\(memberCount)"
		return label
	}()

	private lazy var addMemberButton: UIButton = {
		let button = UIButton(type: .system)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.tintColor = .white
		button.backgroundColor = .primary
		button.setImage(UIImage(systemName: "plus"), for: .normal)
		button.layer.cornerRadius = 22
		button.layer.shadowColor = UIColor.lightGray.cgColor
		button.layer.shadowOpacity = 0.35
		button.layer.shadowOffset = CGSize(width: 0, height: 4)
		button.layer.shadowRadius = 6
		button.addTarget(self, action: #selector(onAddMember), for: .touchUpInside)
		return button
	}()
	
	override func loadView() {
		super.loadView()
		view.addSubview(mapView)
		view.addSubview(bkStatusView)
		view.addSubview(closeButton)
		view.addSubview(memberContentView)
		view.addSubview(addMemberButton)
		bkStatusView.addSubview(statusEffectView)
		memberContentView.addSubview(memberIconView)
		memberContentView.addSubview(memberCountLabel)
		
		NSLayoutConstraint.activate([
			mapView.topAnchor.constraint(equalTo: view.topAnchor),
			mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
			mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

			bkStatusView.topAnchor.constraint(equalTo: view.topAnchor),
			bkStatusView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			bkStatusView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			bkStatusView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),

			statusEffectView.topAnchor.constraint(equalTo: bkStatusView.topAnchor),
			statusEffectView.leadingAnchor.constraint(equalTo: bkStatusView.leadingAnchor),
			statusEffectView.trailingAnchor.constraint(equalTo: bkStatusView.trailingAnchor),
			statusEffectView.bottomAnchor.constraint(equalTo: bkStatusView.bottomAnchor),
			
			closeButton.widthAnchor.constraint(equalToConstant: 40),
			closeButton.heightAnchor.constraint(equalToConstant: 40),
			closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
			closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

			memberContentView.heightAnchor.constraint(equalToConstant: 44),
			memberContentView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
			memberContentView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),

			memberIconView.widthAnchor.constraint(equalToConstant: 20),
			memberIconView.heightAnchor.constraint(equalToConstant: 20),
			memberIconView.leadingAnchor.constraint(equalTo: memberContentView.leadingAnchor, constant: 16),
			memberIconView.centerYAnchor.constraint(equalTo: memberContentView.centerYAnchor),

			memberCountLabel.leadingAnchor.constraint(equalTo: memberIconView.trailingAnchor, constant: 10),
			memberCountLabel.trailingAnchor.constraint(equalTo: memberContentView.trailingAnchor, constant: -16),
			memberCountLabel.centerYAnchor.constraint(equalTo: memberContentView.centerYAnchor),

			addMemberButton.widthAnchor.constraint(equalToConstant: 44),
			addMemberButton.heightAnchor.constraint(equalToConstant: 44),
			addMemberButton.leadingAnchor.constraint(equalTo: memberContentView.trailingAnchor, constant: 12),
			addMemberButton.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -20),
			addMemberButton.centerYAnchor.constraint(equalTo: memberContentView.centerYAnchor)
		])
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		let locationManager = CLLocationManager()
		locationManager.requestWhenInUseAuthorization()
		locationManager.startUpdatingLocation()
		if let location = locationManager.location {
			mapView.setCenter(location.coordinate, zoomLevel: 16, animated: false)
		}
		locationManager.stopUpdatingLocation()
	}

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		memberContentView.addShadow(radius: 22)

		statusFadeMask.frame = bkStatusView.bounds
		statusFadeMask.colors = [
			UIColor.black.cgColor,
			UIColor.clear.cgColor
		]
		statusFadeMask.startPoint = CGPoint(x: 0.5, y: 0.0)
		statusFadeMask.endPoint = CGPoint(x: 0.5, y: 1.0)
		statusEffectView.layer.mask = statusFadeMask
	}
	
	@objc private func onClose() {
		dismiss(animated: true)
	}

	@objc private func onAddMember() {
		memberCount += 1
	}
}
