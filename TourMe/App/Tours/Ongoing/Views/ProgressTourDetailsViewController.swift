//
//  ProgressTourDetailsViewController.swift
//  TourMe
//
//  Created by Savet on 22/7/25.
//

import UIKit

class ProgressTourDetailsViewController: UIViewController {

	private var tour: Tour!
	private var places: [Place] = []
	private var vehicle: String = ""
	var onTourUpdated: ((Tour) -> Void)?
	
	private lazy var tableView: UITableView = {
		let tableV = UITableView(frame: .zero, style: .insetGrouped)
		tableV.register(TourProfileCell.self)
		tableV.register(DefaultViewCell.self)
		tableV.register(TourPlaceViewCell.self)
		tableV.register(IconTextViewCell.self)
		tableV.translatesAutoresizingMaskIntoConstraints = false
		return tableV
	}()
	
	private lazy var updateTourBtn: RoundButton = {
		let button = RoundButton(radius: 10, activeColor: .primary, inactiveColor: .lightPrimary)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.setTitle("update".localized(), for: .normal)
		button.titleLabel?.font = .defaultMedium(size: 20)
		button.addTarget(self, action: #selector(onUpdateTour), for: .touchUpInside)
		return button
	}()
	
	private lazy var cancelTourBtn: RoundButton = {
		let button = RoundButton(radius: 10, activeColor: .red, inactiveColor: .red)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.setTitle("stop".localized(), for: .normal)
		button.titleLabel?.font = .defaultMedium(size: 20)
		button.addTarget(self, action: #selector(onCancelTour), for: .touchUpInside)
		return button
	}()
	
	private var isPresented: Bool = false
	
	init(_ tour: Tour? = nil, isPresented: Bool = false) {
		super.init(nibName: nil, bundle: nil)
		self.tour = tour
		if tour == nil {
			self.tour = getOngoingTour()
		}
		self.isPresented = isPresented
		if self.tour != nil {
			vehicle = self.tour!.vehicle ?? ""
			if let visitPls = self.tour!.visitPlaces?.compactMap({$0 as? VisitPlace}) {
				for visitPl in visitPls {
					self.places.append(visitPl.place!)
				}
			}
		}
		updateTourBtn.isHidden = self.tour == nil
		cancelTourBtn.isHidden = self.tour == nil
	}
	
	private func getOngoingTour() -> Tour? {
		let predicate = NSPredicate(format: "startDate != nil AND endDate == nil")
		let sortDescriptor = NSSortDescriptor(key: "startDate", ascending: false)
		let tours = Const.dataManager.fetchData(Tour.self, predicate: predicate, sortDescriptors: [sortDescriptor])
		return tours.first
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func loadView() {
		super.loadView()
		
		view.addSubview(tableView)
		view.addSubview(updateTourBtn)
		view.addSubview(cancelTourBtn)
		
		NSLayoutConstraint.activate([
			tableView.topAnchor.constraint(equalTo: view.topAnchor),
			tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
			
			updateTourBtn.heightAnchor.constraint(equalToConstant: 50),
			updateTourBtn.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
			updateTourBtn.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
			
			cancelTourBtn.heightAnchor.constraint(equalToConstant: 50),
			cancelTourBtn.widthAnchor.constraint(equalToConstant: 80),
			cancelTourBtn.centerYAnchor.constraint(equalTo: updateTourBtn.centerYAnchor),
			cancelTourBtn.leadingAnchor.constraint(equalTo: updateTourBtn.trailingAnchor, constant: 16),
			cancelTourBtn.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
		])
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()

		title = "ongoing_tour".localized()
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
		
		if isPresented {
			navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .done, target: self, action: #selector(closeScreen))
		}
		
		tableView.dataSource = self
		tableView.delegate = self
		tableView.keyboardDismissMode = .onDrag
		
		tableView.isEditing = true
		tableView.allowsSelectionDuringEditing = true
		
		tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 55))
		
		updateTourBtn.isEnabled = false
		NotificationCenter.default.addObserver(self, selector: #selector(onStartTour), name: Utils.observerName(.statedTour), object: nil)
    }
	
	@objc private func onStartTour() {
		if tour == nil {
			tour = getOngoingTour()
			if self.tour != nil {
				vehicle = self.tour!.vehicle ?? ""
				if let visitPls = self.tour!.visitPlaces?.compactMap({$0 as? VisitPlace}) {
					for visitPl in visitPls {
						self.places.append(visitPl.place!)
					}
				}
			}
			updateTourBtn.isHidden = self.tour == nil
			cancelTourBtn.isHidden = self.tour == nil
			tableView.reloadData()
		}
	}
	
	@objc private func closeScreen() {
		dismiss(animated: true)
	}
	
	@objc private func onUpdateTour() {
		let orderedSet = NSMutableOrderedSet()
		if let visitPls = tour?.visitPlaces?.compactMap({$0 as? VisitPlace}) {
			var deleteList: [VisitPlace] = []
			for visitPl in visitPls {
				let place = places.first(where: {$0.id?.uuidString == visitPl.place?.id?.uuidString})
				if place == nil {
					deleteList.append(visitPl)
				}
			}
			let context = Const.dataManager.context
			for item in deleteList {
				context.delete(item)
			}
			for place in places {
				if let visitPl = visitPls.first(where: {$0.place?.id?.uuidString == place.id?.uuidString}) {
					orderedSet.add(visitPl)
				}else {
					let visitPlace = VisitPlace(context: Const.dataManager.context)
					visitPlace.place = place
					orderedSet.add(visitPlace)
				}
			}
		}
		tour.visitPlaces = orderedSet
		tour.vehicle = vehicle
		do {
			try Const.dataManager.context.save()
			onTourUpdated?(self.tour)
			updateTourBtn.isEnabled = false
		}catch {
			print(error.localizedDescription)
		}
	}
	
	@objc private func onCancelTour() {
		tour.startDate = nil
		do {
			try Const.dataManager.context.save()
			onTourUpdated?(self.tour)
		}catch {
			print(error.localizedDescription)
		}
		dismiss(animated: false)
		tour = nil
		updateTourBtn.isHidden = true
		cancelTourBtn.isHidden = true
		tableView.reloadData()
		NotificationCenter.default.post(name: Utils.observerName(.endedTour), object: nil)
	}
	
	private func pickPlaces() {
		guard let visitPls = tour?.visitPlaces?.compactMap({$0 as? VisitPlace}) else {
			return
		}
		
		let vc = TabChoosePlacesViewController(chosePlaces: places, visitPlaces: visitPls)
		vc.onChosePlaces = { places in
			self.updateWith(places)
		}
		vc.modalPresentationStyle = .overFullScreen
		present(vc, animated: true)
	}
	
	private func updateWith(_ places: [Place]) {
		self.places = places
		tableView.reloadSections([2], with: .automatic)
		updateTourBtn.isEnabled = true
	}
}

extension ProgressTourDetailsViewController: UITableViewDataSource {
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return tour != nil ? 4 : 0
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch section {
			case 0, 1:
				return 1
			case 2:
				return places.count + 1
			case 3:
				return 2
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
				if indexPath.row == places.count {
					let cell = tableView.dequeue(DefaultViewCell.self, for: indexPath)
					cell.titleLabel.text = "edit".localized()
					cell.titleLabel.textColor = .primary
					cell.titleLabel.textAlignment = .center
					cell.titleLabel.font = .defaultMedium(size: UIFont.normal)
					return cell
				}
				let cell = tableView.dequeue(TourPlaceViewCell.self, for: indexPath)
				cell.configure(with: places[indexPath.row])
				cell.selectedBackgroundView = UIView()
				return cell
			default:
				if indexPath.row == 0 {
					let cell = tableView.dequeue(IconTextViewCell.self, for: indexPath)
					cell.configure(text: "moto".localized(), icon: UIImage(named: "ic_motorcycle")!, isSelected: vehicle == "MOTO")
					return cell
				}else {
					let cell = tableView.dequeue(IconTextViewCell.self, for: indexPath)
					cell.configure(text: "car".localized(), icon: UIImage(named: "ic_car")!, isSelected: vehicle == "CAR")
					return cell
				}
		}
	}
	
}

extension ProgressTourDetailsViewController: UITableViewDelegate {
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		switch indexPath.section {
			case 2:
				if indexPath.row == places.count {
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
					vehicle = "MOTO"
				}else {
					let indexP = IndexPath(row: 0, section: 3)
					let cell = tableView.cellForRow(at: indexP) as! IconTextViewCell
					cell.setSelect(false)
					vehicle = "CAR"
				}
				updateTourBtn.isEnabled = true
			default:
				break
				
		}
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		switch indexPath.section {
			case 0:
				return tableView.frame.width * 3 / 5
			case 1:
				return 60
			case 2:
				if places.count == indexPath.row {
					return 50
				}
				return 90
			default:
				return 60
		}
	}
	
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		switch section {
			case 2:
				return "places".localized()
			case 3:
				return "transport".localized()
			default:
				return nil
		}
	}
	
	func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
		let ingnoreIndex = places.count
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
		if toIndexPath.row == places.count {
			return fromIndexPath
		}
		return toIndexPath
	}
	
	func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
		places.swapAt(sourceIndexPath.row, destinationIndexPath.row)
		updateTourBtn.isEnabled = true
	}
	
	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return CGFloat.leastNormalMagnitude
	}

	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		return UIView(frame: .zero)
	}
}
