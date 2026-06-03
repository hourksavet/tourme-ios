//
//  CreateTourViewController.swift
//  TourMe
//
//  Created by Savet on 3/7/25.
//

import UIKit
import Photos

enum TourAction {
	case add
	case edit
	case view
}

class CreateTourViewController: UIViewController {

	struct TourData {
		var banner: Data?
		var name: String = ""
		var places: [Place] = []
		var vehicle: String = ""
		var isFavorite: Bool = false
	}
	
	private lazy var tableView: UITableView = {
		let tableView = UITableView(frame: .zero, style: .insetGrouped)
		tableView.register(BannerProfileViewCell.self)
		tableView.register(AddNameViewCell.self)
		tableView.register(TourPlaceViewCell.self)
		tableView.register(DefaultViewCell.self)
		tableView.register(IconTextViewCell.self)
		tableView.register(FavoriteViewCell.self)
		tableView.translatesAutoresizingMaskIntoConstraints = false
		return tableView
	}()
	
	private lazy var saveTourButton: RoundButton = {
		let button = RoundButton(radius: 55/2, activeColor: .primary, inactiveColor: .lightPrimary)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.setImage(UIImage(systemName: "folder.fill"), for: .normal)
		button.tintColor = .white
		button.isEnabled = false
		button.addTarget(self, action: #selector(saveTour), for: .touchUpInside)
		return button
	}()
	
	private lazy var reviewTourButton: RoundButton = {
		let button = RoundButton(radius: 55/2, activeColor: .primary, inactiveColor: .lightPrimary)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.setTitle("review".localized(), for: .normal)
		button.titleLabel?.font = .defaultMedium(size: 20)
		button.isEnabled = false
		button.addTarget(self, action: #selector(reviewTour), for: .touchUpInside)
		return button
	}()
	
	private var action: TourAction = .add
	
	private var enableClose: Bool = false
	
	private var tour: Tour!
	
	private var tourData: TourData!
	
	init(_ action: TourAction, tour: Tour? = nil, enableClose: Bool = false) {
		super.init(nibName: nil, bundle: nil)
		self.enableClose = enableClose
		self.action = action
		self.tourData = TourData()
		if tour != nil {
			self.tour = tour!
			tourData.banner = tour!.banner
			tourData.name = tour!.name ?? ""
			if let visitPls = tour?.visitPlaces?.compactMap({$0 as? VisitPlace}) {
				for visitPl in visitPls {
					tourData.places.append(visitPl.place!)
				}
			}
			tourData.vehicle = tour!.vehicle ?? ""
		}
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func loadView() {
		super.loadView()
		view.addSubview(tableView)
		view.addSubview(saveTourButton)
		view.addSubview(reviewTourButton)
		NSLayoutConstraint.activate([
			tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
			tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
			tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			saveTourButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
			saveTourButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
			saveTourButton.heightAnchor.constraint(equalToConstant: 55),
			saveTourButton.widthAnchor.constraint(equalToConstant: 55),
			reviewTourButton.leadingAnchor.constraint(equalTo: saveTourButton.trailingAnchor, constant: 15),
			reviewTourButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
			reviewTourButton.bottomAnchor.constraint(equalTo: saveTourButton.bottomAnchor),
			reviewTourButton.heightAnchor.constraint(equalToConstant: 55),
			
		])
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()

		title = "new_tour_title".localized()
		navigationItem.largeTitleDisplayMode = .never
		navigationController?.navigationBar.tintColor = .primary
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
		
		view.backgroundColor = .screenBackground
		
		tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 55))
		tableView.dataSource = self
		tableView.delegate = self
		tableView.keyboardDismissMode = .onDrag
		
		tableView.isEditing = true
		tableView.allowsSelectionDuringEditing = true
	}
	

	@objc private func closeScreen() {
		dismiss(animated: true)
	}

	@objc private func reviewTour() {
		let context = Const.dataManager.context
		let tour = Tour(context: context)
		tour.createdAt = Date()
		tour.id = UUID()
		tour.name = tourData.name
		tour.vehicle = tourData.vehicle
		tour.banner = tourData.banner
		tour.isFavorite = tourData.isFavorite
		
		let orderedSet = NSMutableOrderedSet()
		for place in tourData.places {
			let visitPlace = VisitPlace(context: context)
			visitPlace.place = place
			orderedSet.add(visitPlace)
		}
		tour.visitPlaces = orderedSet
		let savedTour = SavedTourDetailsViewController(tour)
		navigationController?.pushViewController(savedTour, animated: true)
	}
	
	@objc private func saveTour() throws {
		let context = Const.dataManager.context
		if action == .add {
			let tour = Tour(context: context)
			tour.createdAt = Date()
			tour.id = UUID()
			tour.name = tourData.name
			tour.vehicle = tourData.vehicle
			tour.banner = tourData.banner
			tour.isFavorite = tourData.isFavorite
			
			let orderedSet = NSMutableOrderedSet()
			for place in tourData.places {
				let visitPlace = VisitPlace(context: context)
				visitPlace.place = place
				orderedSet.add(visitPlace)
			}
			tour.visitPlaces = orderedSet
			try Const.dataManager.context.save()
			tourData = TourData()
			tableView.reloadData()
			NotificationCenter.default.post(name: Utils.observerName(.addTour), object: nil, userInfo: [String.tour: tour])
		}else {
			tour.name = tourData.name
			tour.vehicle = tourData.vehicle
			tour.banner = tourData.banner
			tour.isFavorite = tourData.isFavorite
			
			if let visitPls = tour?.visitPlaces?.compactMap({$0 as? VisitPlace}) {
				for visitPl in visitPls {
					context.delete(visitPl)
				}
				try context.save()
			}
			let orderedSet = NSMutableOrderedSet()
			for place in tourData.places {
				let visitPlace = VisitPlace(context: context)
				visitPlace.place = place
				orderedSet.add(visitPlace)
			}
			tour.visitPlaces = orderedSet
			try Const.dataManager.context.save()
			NotificationCenter.default.post(name: Utils.observerName(.addTour), object: nil, userInfo: [String.tour: tour!])
		}
		saveTourButton.isEnabled = false
		reviewTourButton.isEnabled = false
		
	}
	
	private func checkToEnableSaveButton() {
		switch action {
			case .add:
				if tourData.banner == nil || tourData.name == "" || tourData.places.count == 0 || tourData.vehicle == "" {
					saveTourButton.isEnabled = false
					reviewTourButton.isEnabled = false
					return
				}
				saveTourButton.isEnabled = true
				reviewTourButton.isEnabled = true
			case .edit:
				saveTourButton.isEnabled = true
				reviewTourButton.isEnabled = true
			default:
				break
		}
	}
	
	private func addTourThumbnail() {
		showPickImageBottomSheet()
	}
	
	private func showPickImageBottomSheet() {
		let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

		alert.addAction(UIAlertAction(title: "camera".localized(), style: .default, handler: { _ in
			self.openCamera()
		}))

		alert.addAction(UIAlertAction(title: "photo_library".localized(), style: .default, handler: { _ in
			self.choosePhotoFromLibrary()
		}))

		alert.addAction(UIAlertAction(title: "cancel".localized(), style: .cancel, handler: nil))
		present(alert, animated: true)
	}
	
	private func openCamera() {
		let cameraVC = UIImagePickerController()
		cameraVC.sourceType = .camera
		cameraVC.cameraDevice = .rear
		cameraVC.cameraFlashMode = .off
		switch AVCaptureDevice.authorizationStatus(for: .video) {
			case .authorized:
				cameraVC.delegate = self
				present(cameraVC, animated: true)
			default:
				if Variable.shared.isRequestedCamera {
					if let url = URL(string:UIApplication.openSettingsURLString) {
						UIApplication.shared.open(url)
					}
				}else {
					Variable.shared.isRequestedCamera = true
					AVCaptureDevice.requestAccess(for: .video) { allowed in
						if allowed {
							DispatchQueue.main.async {
								cameraVC.delegate = self
								self.present(cameraVC, animated: true)
							}
						}
					}
				}
		}
	}
	
	private func choosePhotoFromLibrary() {
		let imagePicker = UIImagePickerController()
		imagePicker.delegate = self
		imagePicker.sourceType = .photoLibrary
		present(imagePicker, animated: true)
	}
	
	private func pickPlaces() {
		let vc = TabChoosePlacesViewController(chosePlaces: tourData.places)
		vc.onChosePlaces = { places in
			self.updateWith(places)
			self.checkToEnableSaveButton()
		}
		vc.modalPresentationStyle = .overFullScreen
		present(vc, animated: true)
		
	}
	
	private func updateWith(_ places: [Place]) {
		tourData.places = places
		self.tableView.reloadSections([2], with: .automatic)
		self.checkToEnableSaveButton()
	}
}

extension CreateTourViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
	
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
		picker.dismiss(animated: true)
		guard let image = info[.originalImage] as? UIImage else {
			print("No image found")
			return
		}
		let resizeImage = image.resizeImage(maxSize: 1024)
		let compressImage = resizeImage.compressImage(toMaxKB: 300)
		tourData.banner = compressImage
		tableView.reloadSections([0], with: .automatic)
		checkToEnableSaveButton()
	}
	
}

extension CreateTourViewController: UITableViewDataSource {
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return 5
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch section {
			case 2:
				return tourData.places.count + 1
			case 3:
				return 2
			default:
				return 1
		}
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		switch indexPath.section {
			case 0:
				let cell = tableView.dequeue(BannerProfileViewCell.self, for: indexPath)
				cell.setImage(image: tourData.banner)
				return cell
			case 1:
				let cell = tableView.dequeue(AddNameViewCell.self, for: indexPath)
				cell.nameTextField.placeholder = "tour_name".localized()
				cell.nameTextField.text = tourData.name
				cell.onEndedEditing = { [weak self] text in
					self?.tourData.name = text
					self?.checkToEnableSaveButton()
				}
				cell.selectedBackgroundView = UIView()
				return cell
			case 2:
				if tourData.places.count == indexPath.row {
					let cell = tableView.dequeue(DefaultViewCell.self, for: indexPath)
					cell.titleLabel.text = "add_place".localized()
					cell.titleLabel.textColor = .primary
					cell.titleLabel.textAlignment = .center
					cell.titleLabel.font = .defaultMedium(size: UIFont.normal)
					return cell
				}
				let cell = tableView.dequeue(TourPlaceViewCell.self, for: indexPath)
				cell.configure(with: tourData.places[indexPath.row])
				cell.selectedBackgroundView = UIView()
				return cell
			case 3:
				if indexPath.row == 0 {
					let cell = tableView.dequeue(IconTextViewCell.self, for: indexPath)
					cell.configure(text: "moto".localized(), icon: UIImage(named: "ic_motorcycle")!, isSelected: tourData.vehicle == "MOTO")
					return cell
				}else {
					let cell = tableView.dequeue(IconTextViewCell.self, for: indexPath)
					cell.configure(text: "car".localized(), icon: UIImage(named: "ic_car")!, isSelected: tourData.vehicle == "CAR")
					return cell
				}
			default:
				let cell = tableView.dequeue(FavoriteViewCell.self, for: indexPath)
				cell.setTitle("your_favorite_tour".localized())
				cell.isFavorite = tourData.isFavorite
				return cell
		}
	}
	
}

extension CreateTourViewController: UITableViewDelegate {
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		switch indexPath.section {
			case 0:
				addTourThumbnail()
				view.endEditing(false)
			case 1:
				let cell = tableView.cellForRow(at: indexPath) as! AddNameViewCell
				cell.nameTextField.isUserInteractionEnabled = true
				cell.nameTextField.becomeFirstResponder()
			case 2:
				tableView.deselectRow(at: indexPath, animated: true)
				if indexPath.row == tourData.places.count {
					pickPlaces()
				}
			case 3:
				tableView.deselectRow(at: indexPath, animated: true)
				let cell = tableView.cellForRow(at: indexPath) as! IconTextViewCell
				cell.setSelect(true)
				if indexPath.row == 0 {
					let indexP = IndexPath(row: 1, section: 3)
					let cell = tableView.cellForRow(at: indexP) as! IconTextViewCell
					cell.setSelect(false)
					tourData.vehicle = "MOTO"
				}else {
					let indexP = IndexPath(row: 0, section: 3)
					let cell = tableView.cellForRow(at: indexP) as! IconTextViewCell
					cell.setSelect(false)
					tourData.vehicle = "CAR"
				}
			default:
				tableView.deselectRow(at: indexPath, animated: true)
				view.endEditing(false)
				let cell = tableView.cellForRow(at: indexPath) as! FavoriteViewCell
				cell.isFavorite.toggle()
				tourData.isFavorite = cell.isFavorite
		}
		checkToEnableSaveButton()
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		switch indexPath.section {
			case 0:
				return tableView.frame.width * 3 / 5
			case 2:
				if tourData.places.count == indexPath.row {
					return 50
				}
				return 90
			default:
				return 60
		}
	}
	
	func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
		let ingnoreIndex = tourData.places.count
		if indexPath.section == 2 && indexPath.row != ingnoreIndex {
			return true
		}
		return false
	}
	
	func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		if indexPath.section == 2 {
			return true
		}
		return false
	}
	
	func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
	  return .none
	}
	
	func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
	  return false
	}
	
	func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
		
		let toIndexPath = proposedDestinationIndexPath
		let fromIndexPath = sourceIndexPath
		if toIndexPath.section != 2 {
			return fromIndexPath
		}
		if toIndexPath.row == tourData.places.count {
			return fromIndexPath
		}
		return toIndexPath
	}
	
	func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
		tourData.places.swapAt(sourceIndexPath.row, destinationIndexPath.row)
	}
}
