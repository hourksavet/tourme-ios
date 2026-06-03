//
//  PlaceDetailsViewController.swift
//  TourMe
//
//  Created by Savet on 3/7/25.
//

import UIKit
import Photos

enum PlaceAction {
	case add
	case edit
	case view
}

class PlaceDetailsViewController: UIViewController {
	
	struct PlaceData {
		var thumnail: Data?
		var name: String = ""
		var note: String = ""
		var lat: Double = 0
		var lng: Double = 0
		var isFavorite: Bool = false
	}
	
	private lazy var tableView: UITableView = {
		let tableView = UITableView(frame: .zero, style: .insetGrouped)
		tableView.register(BannerProfileViewCell.self)
		tableView.register(FavoriteViewCell.self)
		tableView.register(AddLocationViewCell.self)
		tableView.register(AddNameViewCell.self)
		tableView.register(AddNoteViewCell.self)
		tableView.register(DefaultViewCell.self)
		tableView.translatesAutoresizingMaskIntoConstraints = false
		return tableView
	}()
	
	private lazy var savePlaceButton: RoundButton = {
		let button = RoundButton(radius: 55/2, activeColor: .primary, inactiveColor: .lightPrimary)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.setTitle("save".localized(), for: .normal)
		button.titleLabel?.font = .defaultMedium(size: 20)
		button.isEnabled = false
		button.addTarget(self, action: #selector(savePlace), for: .touchUpInside)
		return button
	}()
	
	private var action: PlaceAction = .add
	
	private var place: Place!
	
	private var placeData: PlaceData!
	
	private var bottomAnchorTBL: NSLayoutConstraint!
	
	private var selectedIndexPath: IndexPath!
	
	private var enableClose: Bool = false
	
	init(action: PlaceAction, place: Place? = nil, enableClose: Bool = false) {
		super.init(nibName: nil, bundle: nil)
		self.enableClose = enableClose
		self.action = action
		placeData = PlaceData()
		if place != nil {
			self.place = place!
			placeData.thumnail = place?.thumb
			placeData.name = place?.name ?? ""
			placeData.note = place?.note ?? ""
			placeData.lat = place?.lat ?? 0
			placeData.lng = place?.lng ?? 0
			placeData.isFavorite = place?.isFavorite ?? false
		}
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func loadView() {
		super.loadView()
		view.addSubview(tableView)
		view.addSubview(savePlaceButton)
		NSLayoutConstraint.activate([
			tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
			tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			savePlaceButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
			savePlaceButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
			savePlaceButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
			savePlaceButton.heightAnchor.constraint(equalToConstant: 55)
		])
		bottomAnchorTBL = tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
		bottomAnchorTBL.isActive = true
		
		switch action {
			case .add, .edit:
				savePlaceButton.isHidden = false
				tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 55 + view.safeAreaInsets.bottom))
			default:
				savePlaceButton.isHidden = true
		}
	}
	
	
    override func viewDidLoad() {
        super.viewDidLoad()

		tableView.dataSource = self
		tableView.delegate = self
		tableView.keyboardDismissMode = .onDrag
		
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
			navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .plain, target: self, action: #selector(closeScreen))
		}
		
		switch action {
			case .add:
				title = "add_place".localized()
			case .edit:
				title = "Edit Place".localized()
				tableView.reloadData()
			case .view:
				title = "Place Details".localized()
				tableView.reloadData()
		}
		view.backgroundColor = .screenBackground
		
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
	
	deinit {
		print("\(self) dead!")
	}
	
	@objc private func closeScreen() {
		dismiss(animated: true)
	}
	
	@objc private func keyboardWillShow(notification: NSNotification) {
		if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
			let keyboardRectangle = keyboardFrame.cgRectValue
			let keyboardHeight = keyboardRectangle.height
			
			updateTableViewConstant(keyboardHeight - 55 - view.safeAreaInsets.bottom)
		}
	}
	
	@objc private func keyboardWillHide(notification: NSNotification) {
		updateTableViewConstant(0)
	}
	
	private func updateTableViewConstant(_ constant: CGFloat) {
		bottomAnchorTBL.constant = -constant
		UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
			self.view.layoutIfNeeded()
		}, completion: { _ in
			if self.selectedIndexPath != nil {
				self.tableView.scrollToRow(at: self.selectedIndexPath, at: .bottom, animated: true)
			}
		})
	}
	
	@objc private func savePlace() throws {
		if action == .edit {
			place.thumb = placeData.thumnail
			place.name = placeData.name
			place.lat = placeData.lat
			place.lng = placeData.lng
			place.note = placeData.note
			place.isFavorite = placeData.isFavorite
			try Const.dataManager.context.save()
			NotificationCenter.default.post(name: Utils.observerName(.addPlace), object: nil, userInfo: [String.place: place!])
		}else {
			let context = Const.dataManager.context
			let place = Place(context: context)
			place.isFavorite = placeData.isFavorite
			place.isUserAdd = true
			place.stars = 0
			place.id = UUID()
			place.date = Date()
			place.thumb = placeData.thumnail
			place.name = placeData.name
			place.lat = placeData.lat
			place.lng = placeData.lng
			place.note = placeData.note
			try Const.dataManager.context.save()
			placeData = PlaceData()
			tableView.reloadData()
			NotificationCenter.default.post(name: Utils.observerName(.addPlace), object: nil, userInfo: [String.place: place])
		}
		savePlaceButton.isEnabled = false
	}
	
	private func addPlaceThumbnail() {
		showPickImageBottomSheet()
	}
	
	private func checkToEnableSaveButton() {
		switch action {
			case .add:
				if placeData.thumnail == nil || placeData.name == "" || placeData.lat == 0 || placeData.lng == 0 {
					savePlaceButton.isEnabled = false
					return
				}
				savePlaceButton.isEnabled = true
			case .edit:
				savePlaceButton.isEnabled = true
			default:
				break
		}
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
	
	private func pickLocation() {
		let pickLocationVC = PickLocationViewController(lat: placeData.lat, lng: placeData.lng)
		pickLocationVC.onPickLocation = { [weak self] coor in
			if coor.latitude != self!.placeData.lat || coor.longitude != self!.placeData.lng {
				self?.placeData.lat = coor.latitude
				self?.placeData.lng = coor.longitude
				self?.tableView.reloadSections([1], with: .automatic)
				self?.savePlaceButton.isEnabled = true
			}
		}
		pickLocationVC.modalPresentationStyle = .overFullScreen
		present(pickLocationVC, animated: true)
	}
	
	private func deletePlace() {
		Alert.show(on: self, message: "delete_place_message".localized(), cancelTitle: "cancel".localized(), okTitle: "delete".localized()) {
			self.confirmDetetePlace()
		}
	}
	
	private func confirmDetetePlace() {
		let context = Const.dataManager.context
		context.delete(place)
		do {
			try context.save()
			if self.enableClose {
				self.dismiss(animated: false)
			}else {
				self.navigationController?.popViewController(animated: true)
			}
			NotificationCenter.default.post(name: Utils.observerName(.deletePlace), object: nil, userInfo: [String.place: place!])
		}catch {
			print(error.localizedDescription)
		}
	}
	
}

extension PlaceDetailsViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
	
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
		picker.dismiss(animated: true)
		guard let image = info[.originalImage] as? UIImage else {
			print("No image found")
			return
		}
		let resizeImage = image.resizeImage(maxSize: 1024)
		let compressImage = resizeImage.compressImage(toMaxKB: 300)
		placeData.thumnail = compressImage
		tableView.reloadSections([0], with: .automatic)
		checkToEnableSaveButton()
	}
	
}

extension PlaceDetailsViewController: UITableViewDataSource {
	
	func numberOfSections(in tableView: UITableView) -> Int {
		switch action {
			case .edit, .view:
				return 4
			default:
				return 3
		}
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch section {
			case 1:
				return 3
			default:
				return 1
		}
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		switch indexPath.section {
			case 0:
				let cell = tableView.dequeue(BannerProfileViewCell.self, for: indexPath)
				cell.setImage(image: placeData.thumnail)
				return cell
			case 1:
				if indexPath.row == 0 {
					let cell = tableView.dequeue(AddLocationViewCell.self, for: indexPath)
					cell.isSetLocation = placeData.lat != 0 && placeData.lng != 0
					return cell
				}else if indexPath.row == 1 {
					let cell = tableView.dequeue(AddNameViewCell.self, for: indexPath)
					cell.nameTextField.text = placeData.name
					cell.onEndedEditing = { [weak self] text in
						if text != "" && self?.placeData.name != text {
							self?.placeData.name = text
							self?.checkToEnableSaveButton()
						}
					}
					cell.selectedBackgroundView = UIView()
					return cell
				}else {
					let cell = tableView.dequeue(AddNoteViewCell.self, for: indexPath)
					cell.noteTextView.text = placeData.note
					cell.onEndedEditing = { [weak self] text in
						if text != "" && self?.placeData.name != text {
							self?.placeData.note = text
							self?.checkToEnableSaveButton()
						}
					}
					cell.selectedBackgroundView = UIView()
					return cell
				}
			case 2:
				let cell = tableView.dequeue(FavoriteViewCell.self, for: indexPath)
				cell.isFavorite = placeData.isFavorite
				return cell
			default:
				let cell = tableView.dequeue(DefaultViewCell.self, for: indexPath)
				cell.titleLabel.text = "delete".localized()
				cell.titleLabel.textColor = .systemRed
				cell.titleLabel.font = .default(size: UIFont.normal)
				cell.titleLabel.textAlignment = .center
				return cell
		}
	}
	
}

extension PlaceDetailsViewController: UITableViewDelegate {
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		selectedIndexPath = nil
		switch indexPath.section {
			case 0:
				addPlaceThumbnail()
				view.endEditing(false)
			case 1:
				if indexPath.row == 1 {
					let cell = tableView.cellForRow(at: indexPath) as! AddNameViewCell
					selectedIndexPath = indexPath
					cell.nameTextField.isUserInteractionEnabled = true
					cell.nameTextField.becomeFirstResponder()
				}else if indexPath.row == 2 {
					let cell = tableView.cellForRow(at: indexPath) as! AddNoteViewCell
					selectedIndexPath = indexPath
					cell.noteTextView.isUserInteractionEnabled = true
					cell.noteTextView.becomeFirstResponder()
				}else {
					pickLocation()
					view.endEditing(false)
				}
			case 2:
				view.endEditing(false)
				let cell = tableView.cellForRow(at: indexPath) as! FavoriteViewCell
				cell.isFavorite.toggle()
				placeData.isFavorite = cell.isFavorite
				checkToEnableSaveButton()
			default:
				deletePlace()
		}
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		switch indexPath.section {
			case 0:
				return tableView.frame.width * 3 / 5
			case 1:
				if indexPath.row == 2 {
					return 150
				}
				return 60
			case 3:
				return 40
			default:
				return 60
		}
	}
}
