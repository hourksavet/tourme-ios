//
//  MemoriesViewController.swift
//  TourMe
//
//  Created by Savet on 3/7/25.
//

import UIKit
import Photos
import ImagePlayground

class MemoriesViewController: UIViewController {

	var onUpdatedProfile: ((Account) -> Void)?
	
	private lazy var profileImgV: UIImageView = {
		let imgV = UIImageView()
		imgV.contentMode = .scaleAspectFill
		imgV.clipsToBounds = true
		imgV.isUserInteractionEnabled = true
		imgV.image = UIImage(named: "profile-user")
		imgV.tintColor = .imageHint
		imgV.translatesAutoresizingMaskIntoConstraints = false
		imgV.addSubview(cameraBgView)
		imgV.addSubview(cameraButton)
		NSLayoutConstraint.activate([
			cameraBgView.bottomAnchor.constraint(equalTo: imgV.bottomAnchor),
			cameraBgView.leadingAnchor.constraint(equalTo: imgV.leadingAnchor),
			cameraBgView.trailingAnchor.constraint(equalTo: imgV.trailingAnchor),
			cameraBgView.heightAnchor.constraint(equalToConstant: 25),
			cameraButton.centerXAnchor.constraint(equalTo: imgV.centerXAnchor),
			cameraButton.bottomAnchor.constraint(equalTo: imgV.bottomAnchor),
			cameraButton.heightAnchor.constraint(equalToConstant: 25),
		])
		let tap = UITapGestureRecognizer(target: self, action: #selector(addProfile))
		imgV.addGestureRecognizer(tap)
		return imgV
	}()
	
	private lazy var cameraBgView: UIView = {
		let view = UIView()
		view.backgroundColor = .black
		view.alpha = 0.3
		view.translatesAutoresizingMaskIntoConstraints = false
		
		return view
	}()
	
	private lazy var cameraButton: UIButton = {
		let button = UIButton(type: .system)
		button.setImage(UIImage(systemName: "camera.fill"), for: .normal)
		button.isEnabled = false
		button.tintColor = .white
		button.addTarget(self, action: #selector(deleteProfile), for: .touchUpInside)
		button.translatesAutoresizingMaskIntoConstraints = false
		return button
	}()
	
	private lazy var memoriesLabel: UILabel = {
		let label = UILabel()
		label.font = .default(size: UIFont.medium)
		label.text = "your_memories".localized()
		label.numberOfLines = 1
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	private lazy var tableView: UITableView = {
		let tableView = UITableView(frame: .zero, style: .insetGrouped)
		tableView.backgroundColor = .clear
		tableView.register(MemoriesCell.self)
		tableView.register(BigProfileViewCell.self)
		tableView.translatesAutoresizingMaskIntoConstraints = false
		return tableView
	}()
	
	private var profileImg: UIImage? {
		didSet {
			cameraButton.isEnabled = profileImg != nil
		}
	}
	
	private var account: Account!
	
	init(_ account: Account) {
		super.init(nibName: nil, bundle: nil)
		self.account = account
		if account.profile != nil {
			profileImg = UIImage(data: account.profile!)
			profileImgV.image = profileImg
		}else {
			profileImgV.image = account.gender == "F" ? UIImage(named: "ic-default-woman") : UIImage(named: "ic-default-man")
		}
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func loadView() {
		super.loadView()
		view.addSubview(profileImgV)
		view.addSubview(memoriesLabel)
		view.addSubview(tableView)
		
		NSLayoutConstraint.activate([
			profileImgV.widthAnchor.constraint(equalToConstant: 150),
			profileImgV.heightAnchor.constraint(equalToConstant: 150),
			profileImgV.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			profileImgV.topAnchor.constraint(equalTo:view.safeAreaLayoutGuide.topAnchor, constant: 20),
			memoriesLabel.topAnchor.constraint(equalTo: profileImgV.bottomAnchor, constant: 20),
			memoriesLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
			tableView.topAnchor.constraint(equalTo: memoriesLabel.bottomAnchor, constant: 10),
			tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
		])
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		view.backgroundColor = .screenBackground
		tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: view.safeAreaInsets.bottom))
		
		tableView.dataSource = self
		tableView.delegate = self
		
    }

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		profileImgV.cornerRadius()
	}
	
	deinit {
		print("\(self) dead!")
	}
	
	@objc private func saveProfile() throws {
		account.profile = profileImg?.jpegData(compressionQuality: 0.5)
		navigationItem.rightBarButtonItem = nil
		try Const.dataManager.context.save()
		onUpdatedProfile?(account)
		cameraButton.setImage(UIImage(systemName: "camera.fill"), for: .normal)
		cameraButton.tintColor = .white
	}
	
	@objc private func addProfile() {
		showProfileBottomSheet()
	}
	
	private func showProfileBottomSheet() {
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
	
	@objc private func deleteProfile() {
		profileImg = nil
		var image = UIImage(named: "profile-user")
		if account.gender == "M" {
			image = UIImage(named: "ic-default-man")
		}else {
			image = UIImage(named: "ic-default-woman")
		}
		if account.profile != nil {
			account.profile = nil
		}
		profileImgV.image = image
		cameraButton.setImage(UIImage(systemName: "camera.fill"), for: .normal)
		cameraButton.tintColor = .white
	}
	
	private func openCamera() {
		let cameraVC = UIImagePickerController()
		cameraVC.sourceType = .camera
		cameraVC.cameraDevice = .front
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
	
	@available(iOS 18.1, *)
	private func openImagePlayground(_ image: UIImage) {
		guard ImagePlaygroundViewController.isAvailable else {
			Alert.showDefault(
				on: self,
				title: "Image Playground",
				message: "Image Playground is not available on this device. Make sure Apple Intelligence is supported and enabled.",
				button: "ok".localized()
			)
			return
		}

		let imagePlaygroundVC = ImagePlaygroundViewController()
		imagePlaygroundVC.delegate = self
		imagePlaygroundVC.sourceImage = image
		present(imagePlaygroundVC, animated: true)
	}
	
	private func preProcessImage(_ image: UIImage) {
		profileImg = image
		profileImgV.image = image
		cameraButton.setImage(UIImage(systemName: "trash"), for: .normal)
		cameraButton.tintColor = .systemRed
		if #available(iOS 18.1, *) {
			openImagePlayground(image)
		} else {
			Alert.showDefault(
				on: self,
				title: "Image Playground",
				message: "Image Playground requires iOS 18.1 or later.",
				button: "ok".localized()
			)
		}
	}
}

extension MemoriesViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
	
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
		picker.dismiss(animated: true)
		guard let image = info[.originalImage] as? UIImage else {
			print("No image found")
			return
		}
		profileImgV.image = image
		if navigationItem.rightBarButtonItem == nil {
			navigationItem.rightBarButtonItem = UIBarButtonItem(title: "save".localized(), style: .plain, target: self, action: #selector(saveProfile))
		}
		preProcessImage(image)
	}
	
}

@available(iOS 18.1, *)
extension MemoriesViewController: ImagePlaygroundViewController.Delegate {
	
	func imagePlaygroundViewController(_ imagePlaygroundViewController: ImagePlaygroundViewController, didCreateImageAt imageURL: URL) {
		profileImg = UIImage(contentsOfFile: imageURL.path)!
		profileImgV.image = profileImg
		imagePlaygroundViewController.dismiss(animated: true)
	}
	
	func imagePlaygroundViewControllerDidCancel(_ imagePlaygroundViewController: ImagePlaygroundViewController) {
		imagePlaygroundViewController.dismiss(animated: true)
	}
}

extension MemoriesViewController: UITableViewDataSource {
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return 2
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if section == 0 {
			return 1
		}else {
			return 4
		}
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if indexPath.section == 0 {
			let cell = tableView.dequeue(BigProfileViewCell.self, for: indexPath)
			cell.setProfileImage(profileImg, gender: account.gender ?? "F")
			cell.backgroundColor = .clear
			cell.selectedBackgroundView = UIView()
			return cell
		}
		let cell = tableView.dequeue(MemoriesCell.self, for: indexPath)
		cell.accessoryType = .disclosureIndicator
		return cell
	}
	
}

extension MemoriesViewController: UITableViewDelegate {
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
	}
	
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		if section == 1 {
			return "Exported Memories".localized()
		}
		return nil
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		if indexPath.section == 0 {
			return 200
		}else {
			return 60
		}
	}
}
