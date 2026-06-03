//
//  NamingViewController.swift
//  TourMe
//
//  Created by Savet on 27/6/25.
//

import UIKit
import Photos
import ImagePlayground

class NamingViewController: UIViewController {

	private lazy var nameTextField: UITextField = {
		let textField = UITextField()
		textField.placeholder = "enter_name_placeholder".localized()
		textField.borderStyle = .roundedRect
		textField.translatesAutoresizingMaskIntoConstraints = false
		textField.clearButtonMode = .whileEditing
		textField.returnKeyType = .done
		textField.autocorrectionType = .no
		textField.spellCheckingType = .no
		textField.smartInsertDeleteType = .no
		
		let padding: CGFloat = 10
		let imageV = UIImageView(image: UIImage(systemName: "person.crop.circle.fill"))
		imageV.contentMode = .scaleAspectFit
		imageV.tintColor = .lightGray
		let leftView = UIView(frame: CGRect(x: 0, y: 0, width: imageV.frame.width + padding, height: imageV.frame.height))
		imageV.frame = CGRect(x: padding, y: 0, width: imageV.frame.width, height: imageV.frame.height)
		leftView.addSubview(imageV)
		
		textField.leftView = leftView
		textField.leftViewMode = .always
		return textField
	}()
	
	private lazy var amILabel: UILabel = {
		let label = UILabel()
		label.font = .default(size: UIFont.normal)
		label.text = "i_am".localized()
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
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
		button.translatesAutoresizingMaskIntoConstraints = false
		return button
	}()
	
	private lazy var manRadioButton: RadioButton = {
		let button = RadioButton(title: "man".localized())
		button.translatesAutoresizingMaskIntoConstraints = false
		return button
	}()
	
	private lazy var womanRadioButton: RadioButton = {
		let button = RadioButton(title: "woman".localized())
		button.translatesAutoresizingMaskIntoConstraints = false
		return button
	}()
	
	private lazy var appFunctionalHint: UILabel = {
		let label = UILabel()
		label.font = .default(size: UIFont.small)
		label.text = "app_functional_hint".localized()
		label.textColor = .hintText
		label.numberOfLines = 0
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	private lazy var enjoyButton: UIButton = {
		let button = UIButton(type: .system)
		button.setTitle("enjoy".localized(), for: .normal)
		button.setTitleColor(.white, for: .normal)
		button.backgroundColor = .primary
		button.layer.cornerRadius = 6
		button.alpha = 0.5
		button.isEnabled = false
		button.translatesAutoresizingMaskIntoConstraints = false
		return button
	}()
	
	private var profileImg: UIImage? {
		didSet {
			checkToEnableEnjoyButton()
		}
	}
	
	override func loadView() {
		super.loadView()
		
		view.addSubview(nameTextField)
		view.addSubview(amILabel)
		view.addSubview(profileImgV)
		view.addSubview(manRadioButton)
		view.addSubview(womanRadioButton)
		view.addSubview(appFunctionalHint)
		view.addSubview(enjoyButton)
		
		NSLayoutConstraint.activate([
			
			profileImgV.widthAnchor.constraint(equalToConstant: 150),
			profileImgV.heightAnchor.constraint(equalToConstant: 150),
			profileImgV.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			profileImgV.topAnchor.constraint(equalTo:view.safeAreaLayoutGuide.topAnchor),
			
			nameTextField.heightAnchor.constraint(equalToConstant: 50),
			nameTextField.topAnchor.constraint(equalTo: profileImgV.bottomAnchor, constant: 10),
			nameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
			nameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
			
			amILabel.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 20),
			amILabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
			
			manRadioButton.topAnchor.constraint(equalTo: amILabel.bottomAnchor),
			manRadioButton.leadingAnchor.constraint(equalTo: amILabel.leadingAnchor),
			
			womanRadioButton.topAnchor.constraint(equalTo: manRadioButton.topAnchor),
			womanRadioButton.leadingAnchor.constraint(equalTo: manRadioButton.trailingAnchor, constant: 10),
			
			enjoyButton.heightAnchor.constraint(equalToConstant: 40),
			enjoyButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
			enjoyButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
			enjoyButton.bottomAnchor.constraint(equalTo: appFunctionalHint.topAnchor, constant: -20),
			
			appFunctionalHint.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
			appFunctionalHint.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
			appFunctionalHint.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30)
			
		])
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		view.backgroundColor = .screenBackground
		
		manRadioButton.addTarget(self, action: #selector(tapOnManButton), for: .touchUpInside)
		womanRadioButton.addTarget(self, action: #selector(tapOnWomanButton), for: .touchUpInside)
		enjoyButton.addTarget(self, action: #selector(tapEnjoyButton), for: .touchUpInside)
		cameraButton.addTarget(self, action: #selector(deleteProfile), for: .touchUpInside)
		
		nameTextField.delegate = self
    }

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		profileImgV.cornerRadius()
	}
	
	deinit {
		print("\(self) dead!")
	}
	
	private func checkToEnableEnjoyButton() {
		if nameTextField.text != "" && (manRadioButton.isSelected || womanRadioButton.isSelected) {
			enjoyButton.isEnabled = true
			enjoyButton.alpha = 1
		}
	}
	
	@objc private func tapOnManButton() {
		manRadioButton.isSelected = true
		womanRadioButton.isSelected = false
		if profileImg == nil {
			profileImgV.image = UIImage(named: "ic-default-man")
		}
		checkToEnableEnjoyButton()
	}
	
	@objc private func tapOnWomanButton() {
		womanRadioButton.isSelected = true
		manRadioButton.isSelected = false
		if profileImg == nil {
			profileImgV.image = UIImage(named: "ic-default-woman")
		}
		checkToEnableEnjoyButton()
	}
	
	@objc private func tapEnjoyButton() throws {
		try Const.dataManager.saveOrUpdate(type: Account.self, predicate: nil) { account in
			account.name = nameTextField.text ?? ""
			account.gender = manRadioButton.isSelected ? "M" : "F"
			account.id = UUID()
			if profileImg != nil {
				account.profile = profileImg?.jpegData(compressionQuality: 0.5)
			}
		}
		moveToHome()
	}
	
	private func moveToHome() {
		let namingVC = BaseTourMeViewController()
		let nvc = UINavigationController(rootViewController: namingVC)
		
		if let windowScene = UIApplication.shared
			.connectedScenes
			.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
		   let window = windowScene.windows.first(where: { $0.isKeyWindow }) {
			window.rootViewController = nvc
		}
	}
	
	@objc private func deleteProfile() {
		profileImg = nil
		var image = UIImage(named: "profile-user")
		if manRadioButton.isSelected {
			image = UIImage(named: "ic-default-man")
		}
		if womanRadioButton.isSelected {
			image = UIImage(named: "ic-default-woman")
		}
		profileImgV.image = image
		cameraButton.setImage(UIImage(systemName: "camera.fill"), for: .normal)
		cameraButton.tintColor = .white
		checkToEnableEnjoyButton()
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

extension NamingViewController: UITextFieldDelegate {
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		textField.resignFirstResponder()
		checkToEnableEnjoyButton()
		return true
	}
}

extension NamingViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
	
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
		picker.dismiss(animated: true)
		guard let image = info[.originalImage] as? UIImage else {
			print("No image found")
			return
		}
		preProcessImage(image)
	}
	
}

@available(iOS 18.1, *)
extension NamingViewController: ImagePlaygroundViewController.Delegate {
	
	func imagePlaygroundViewController(_ imagePlaygroundViewController: ImagePlaygroundViewController, didCreateImageAt imageURL: URL) {
		profileImg = UIImage(contentsOfFile: imageURL.path)!
		profileImgV.image = profileImg
		imagePlaygroundViewController.dismiss(animated: true)
	}
	
	func imagePlaygroundViewControllerDidCancel(_ imagePlaygroundViewController: ImagePlaygroundViewController) {
		imagePlaygroundViewController.dismiss(animated: true)
	}
}
