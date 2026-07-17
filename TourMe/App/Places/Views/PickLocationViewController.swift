//
//  PickLocationViewController.swift
//  TourMe
//
//  Created by Savet on 9/7/25.
//

import UIKit
import MapLibre

class PickLocationViewController: UIViewController {

	var onPickLocation: ((CLLocationCoordinate2D) -> Void)?
	
	private lazy var mapView: ToureMeMapView = {
		let mapV = ToureMeMapView()
		mapV.showsUserLocation = false
		mapV.isRotateEnabled = false
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
	
	private lazy var doneButton: UIButton = {
		let btn = UIButton(type: .system)
		btn.setTitle("done".localized(), for: .normal)
		btn.titleLabel?.font = .defaultBold(size: UIFont.medium)
		btn.backgroundColor = .primary
		btn.setTitleColor(.white, for: .normal)
		btn.translatesAutoresizingMaskIntoConstraints = false
		btn.tintColor = .primary
		return btn
	}()
	
	private lazy var closeButton: UIButton = {
		let btn = UIButton(type: .system)
		btn.titleLabel?.font = .defaultBold(size: UIFont.medium)
		btn.setImage(UIImage(systemName: "xmark"), for: .normal)
		btn.backgroundColor = .primary
		btn.setTitleColor(.white, for: .normal)
		btn.translatesAutoresizingMaskIntoConstraints = false
		btn.tintColor = .white
		return btn
	}()
	
	private lazy var locationBtn: UIButton = {
		let button = UIButton(type: .system)
		button.tintColor = .white
		button.backgroundColor = .primary
		button.setImage(UIImage(systemName: "location.fill"), for: .normal)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.addTarget(self, action: #selector(onClickLocationBtn), for: .touchUpInside)
		return button
	}()
	
	private lazy var markerImgV: UIImageView = {
		let imgV = UIImageView(image: UIImage(named: "places")?.withRenderingMode(.alwaysTemplate))
		imgV.tintColor = .red
		imgV.contentMode = .scaleAspectFit
		imgV.translatesAutoresizingMaskIntoConstraints = false
		return imgV
	}()
	
	private lazy var markerCirleView: UIView = {
		let view = UIView()
		view.backgroundColor = .red
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()
	
	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent
	}
	
	private var isMovedToDefaultCoordinate: Bool = false
	
	private var bottomMarkerConstraint: NSLayoutConstraint!
	private var defaultCoordinate: CLLocationCoordinate2D?
	
	init(lat: Double = 0, lng: Double = 0) {
		super.init(nibName: nil, bundle: nil)
		if lat != 0 && lng != 0 {
			let coor = CLLocationCoordinate2D(latitude: lat, longitude: lng)
			defaultCoordinate = coor
		}
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func loadView() {
		super.loadView()
		view.addSubview(mapView)
		view.addSubview(markerImgV)
		view.addSubview(markerCirleView)
		view.addSubview(bkStatusView)
		view.addSubview(locationBtn)
		view.addSubview(doneButton)
		view.addSubview(closeButton)
		bkStatusView.addSubview(statusEffectView)
		
		bottomMarkerConstraint = markerImgV.bottomAnchor.constraint(equalTo: markerCirleView.topAnchor, constant: 0)
		
		NSLayoutConstraint.activate([
			mapView.topAnchor.constraint(equalTo: view.topAnchor),
			mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
			mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			
			markerCirleView.widthAnchor.constraint(equalToConstant: 8),
			markerCirleView.heightAnchor.constraint(equalToConstant: 8),
			markerCirleView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			markerCirleView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 10),
			
			bottomMarkerConstraint,
			markerImgV.centerXAnchor.constraint(equalTo: markerCirleView.centerXAnchor),
			markerImgV.widthAnchor.constraint(equalToConstant: 50),
			markerImgV.heightAnchor.constraint(equalToConstant: 50),
			
			bkStatusView.topAnchor.constraint(equalTo: view.topAnchor),
			bkStatusView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			bkStatusView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			bkStatusView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),

			statusEffectView.topAnchor.constraint(equalTo: bkStatusView.topAnchor),
			statusEffectView.leadingAnchor.constraint(equalTo: bkStatusView.leadingAnchor),
			statusEffectView.trailingAnchor.constraint(equalTo: bkStatusView.trailingAnchor),
			statusEffectView.bottomAnchor.constraint(equalTo: bkStatusView.bottomAnchor),
			
			locationBtn.widthAnchor.constraint(equalToConstant: 50),
			locationBtn.heightAnchor.constraint(equalToConstant: 50),
			locationBtn.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
			locationBtn.bottomAnchor.constraint(equalTo: doneButton.topAnchor, constant: -20),
			
			doneButton.heightAnchor.constraint(equalToConstant: 50),
			doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
			doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
			
			closeButton.widthAnchor.constraint(equalToConstant: 50),
			closeButton.heightAnchor.constraint(equalToConstant: 50),
			closeButton.centerYAnchor.constraint(equalTo: doneButton.centerYAnchor),
			closeButton.leadingAnchor.constraint(equalTo: doneButton.trailingAnchor, constant: 16),
			closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
		])
		markerCirleView.cornerRadius(8 / 2)
		doneButton.addShadow(radius: 50 / 2)
		closeButton.addShadow(radius: 50 / 2)
		
		locationBtn.addShadow(radius: 50 / 2)
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		mapView.delegate = self
		if defaultCoordinate != nil {
			mapView.setCenter(defaultCoordinate!, zoomLevel: 17, animated: false)
		}else {
			if let coor = mapView.userLocation?.coordinate {
				defaultCoordinate = coor
				mapView.setCenter(defaultCoordinate!, zoomLevel: 17, animated: false)
			}else {
				let locationManager = CLLocationManager()
				locationManager.requestWhenInUseAuthorization()
				locationManager.startUpdatingLocation()
				defaultCoordinate = locationManager.location?.coordinate
				locationManager.stopUpdatingLocation()
				mapView.setCenter(defaultCoordinate!, zoomLevel: 17, animated: false)
			}
		}
		
		doneButton.addTarget(self, action: #selector(onChanged), for: .touchUpInside)
		closeButton.addTarget(self, action: #selector(onClose), for: .touchUpInside)
    }

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()

		statusFadeMask.frame = bkStatusView.bounds
		statusFadeMask.colors = [
			UIColor.black.cgColor,
			UIColor.clear.cgColor
		]
		statusFadeMask.startPoint = CGPoint(x: 0.5, y: 0.0)
		statusFadeMask.endPoint = CGPoint(x: 0.5, y: 1.0)
		statusEffectView.layer.mask = statusFadeMask
	}
	
	deinit {
		print("\(self) dead!")
	}
	
	@objc private func onClickLocationBtn() {
		if defaultCoordinate != nil {
			let camera = MLNMapCamera(lookingAtCenter: defaultCoordinate!, altitude: mapView.camera.altitude, pitch: 0, heading: 0)
			mapView.setCamera(camera, animated: true)
		}
	}
	
	@objc private func onChanged() {
		onPickLocation?(mapView.centerCoordinate)
		dismiss(animated: true)
	}
	
	@objc private func onClose() {
		dismiss(animated: true)
	}
	
	private func animateMarker(constant: CGFloat) {
		bottomMarkerConstraint.constant = constant
		UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
			self.view.layoutIfNeeded()
		}, completion: nil)
	}
}

extension PickLocationViewController: MLNMapViewDelegate {
	
	func mapView(_ mapView: MLNMapView, didFinishLoading style: MLNStyle) {
		
	}
	
	func mapView(_ mapView: MLNMapView, regionIsChangingWith reason: MLNCameraChangeReason) {
		animateMarker(constant: -8)
	}
	
	func mapView(_ mapView: MLNMapView, regionDidChangeAnimated animated: Bool) {
		animateMarker(constant: 0)
		if defaultCoordinate != nil && !isMovedToDefaultCoordinate {
			isMovedToDefaultCoordinate = true
			mapView.userTrackingMode = .none
			let camera = MLNMapCamera(lookingAtCenter: defaultCoordinate!, altitude: mapView.camera.altitude, pitch: 0, heading: 0)
			mapView.setCamera(camera, animated: true)
		}
	}
}
