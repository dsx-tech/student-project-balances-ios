//
//  AddFileController.swift
//  graphs
//
//  Created by Danila Ferents on 11.04.20.
//  Copyright © 2020 Danila Ferents. All rights reserved.
//

import UIKit
import CoreServices
import KeychainAccess

class ViewPortfilioItem {
	private var portfolio: Portfolio

	var isSelected = false
	var id: Int {
		return portfolio.id
	}
	var name: String {
		return portfolio.name
	}

	init(portfolio: Portfolio) {
		self.portfolio = portfolio
	}
}

class ViewModel {
	var portfolios: [ViewPortfilioItem] = []
	var filteredPortfolios: [ViewPortfilioItem] = []

	var selectedPortfolios: [ViewPortfilioItem] {
		return portfolios.filter { (portfolio) -> Bool in
			return portfolio.isSelected
		}
	}

	init() {
	}
}

class PortfoliosController: UIViewController {

	//Outlets
	@IBOutlet weak var tableView: UITableView! {
		didSet {
			tableView.tableFooterView = UIView(frame: .zero)
		}
	}
	@IBOutlet weak var addOperationBtn: RoundedButton!

	//Variables
	//	let sections = ["PORTFOLIOS"]
	var viewModel = ViewModel()

	lazy var searchController: UISearchController = {
		let searchController = UISearchController(searchResultsController: nil)
		searchController.searchResultsUpdater = self

		searchController.obscuresBackgroundDuringPresentation = false
		searchController.searchBar.placeholder = "Search portfolio..."
		searchController.searchBar.sizeToFit()
//		searchController.searchBar.scopeButtonTitles = ["All", ""]

		return searchController
	}()

	override func viewDidLoad() {
		super.viewDidLoad()
		tableView.delegate = self
		tableView.dataSource = self
		self.view.backgroundColor = AppColors.Gray
		tableView.backgroundColor = AppColors.Gray
		tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
		tableView.allowsMultipleSelection = true

		navigationItem.searchController = self.searchController
//		let headerView = HeaderView(frame: .zero)
//		headerView.configure(text: "Portfolios", size: 27)
//		tableView.tableHeaderView = headerView

		tableView.register(UINib(nibName: String(describing: PortfolioCell.self), bundle: nil), forCellReuseIdentifier: Identifiers.portfolioCell)
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		PortfolioApi.sharedManager.getAllPortfolios { [weak self] (result, portfolios) in

			guard let self = self else {
				print("No Portfolio Controller more")
				return
			}

			if result {
				if let portfolios = portfolios {
					self.viewModel.portfolios = portfolios.map({ (portfolio) -> ViewPortfilioItem in
						return ViewPortfilioItem(portfolio: portfolio)
					})

					DispatchQueue.main.sync {
						self.tableView.reloadData()
					}
				}
			}
		}
	}

	func updateHeaderViewHeight(for header: UIView?) {
		guard let header = header else { return }
		header.frame.size.height = header.systemLayoutSizeFitting(CGSize(width: view.bounds.width - 32.0, height: 0)).height
	}
	override func viewWillLayoutSubviews() {
		super.viewWillLayoutSubviews()
		updateHeaderViewHeight(for: tableView.tableHeaderView)
	}

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let addFileVC = segue.destination as? AddFileController {
			addFileVC.ids = self.viewModel.selectedPortfolios.map({ (portfilio) -> Int in
				return portfilio.id
			})
		}
	}

	@IBAction func addPortfilioClicked(_ sender: Any) {

		let alert = UIAlertController(title: "Add Portfolio", message: "Please input portfolio name", preferredStyle: UIAlertController.Style.alert )

		let cancel = UIAlertAction(title: "Cancel", style: .default) { (_) in }
		alert.addAction(cancel)

		let save = UIAlertAction(title: "Save", style: .default) { (_) in

			guard let textFields = alert.textFields else {
				print("No text Field")
				return
			}

			let textField = textFields[0] as UITextField

			if textField.text != "" {
				if let text = textField.text {
					let randomInt = Int.random(in: 0..<20000)

					PortfolioApi.sharedManager.addPortfolio(portfolio: Portfolio(id: randomInt, name: text)) { [weak self] (result, portfolio) in
						guard let self = self else {
							print("No Portfolio Controller more")
							return
						}
						if result {
							if let portfolio = portfolio {
								DispatchQueue.main.async {
									self.viewModel.portfolios.append(ViewPortfilioItem(portfolio: portfolio))
									self.tableView.reloadData()
								}
							}
						} else {
							DispatchQueue.main.async {
								self.simpleAlert(title: "Error.", msg: "Try again please")
							}
						}
					}
				}
			} else {
				print("TF is Empty...")
			}
		}

		alert.addTextField { (textField) in
			textField.placeholder = "Portfolio Name"
		}

		alert.addAction(save)

		self.present(alert, animated: true, completion: nil)
	}
}

// MARK: - UITableViewDelegate

extension PortfoliosController: UITableViewDelegate {
	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

		/// Create the view.
		let headerView = UIView()
		headerView.backgroundColor = .clear

		/// Return view.
		return headerView
	}

	func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
		if viewModel.portfolios[indexPath.section].isSelected {
			self.deselect(indexPath: indexPath)
			return nil
		} else {
			return indexPath
		}
	}

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

		let choiceAlertController = UIAlertController(title: "Choose: ", message: nil, preferredStyle: .actionSheet)

		choiceAlertController.addAction(UIAlertAction(title: "Graphs", style: .default, handler: { _ in
			var id = 0
			let keychain = Keychain(service: "swagger")

			id = self.viewModel.portfolios[indexPath.row].id

			keychain["id"] = String(id)

			let targetStoryboardName = "main"
			let targetStoryboard = UIStoryboard(name: targetStoryboardName, bundle: nil)
			if let portfolioVC = targetStoryboard.instantiateViewController(identifier: "graph") as? UITabBarController {
				portfolioVC.modalPresentationStyle = .fullScreen
				portfolioVC.selectedIndex = 0
				self.present(portfolioVC, animated: true, completion: nil)
			}
		}))

		choiceAlertController.addAction(UIAlertAction(title: "Select", style: .default, handler: { _ in
			self.viewModel.portfolios[indexPath.section].isSelected = true
			self.addOperationBtn.isEnabled = !self.viewModel.selectedPortfolios.isEmpty
			tableView.reloadRows(at: [indexPath], with: .fade)
		}))

		choiceAlertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

		//present controller
		choiceAlertController.pruneNegativeWidthConstraints()
		self.present(choiceAlertController, animated: true, completion: nil)
	}

	func deselect(indexPath: IndexPath) {

		let choiceAlertController = UIAlertController(title: "Choose: ", message: nil, preferredStyle: .actionSheet)

		choiceAlertController.addAction(UIAlertAction(title: "Graphs", style: .default, handler: { _ in
			var id = 0
			let keychain = Keychain(service: "swagger")

			id = self.viewModel.portfolios[indexPath.row].id

			keychain["id"] = String(id)

			let targetStoryboardName = "main"
			let targetStoryboard = UIStoryboard(name: targetStoryboardName, bundle: nil)
			let portfolioVC = targetStoryboard.instantiateViewController(identifier: "pieChart")
			self.present(portfolioVC, animated: true, completion: nil)
		}))

		choiceAlertController.addAction(UIAlertAction(title: "Deselect", style: .default, handler: { _ in
			self.viewModel.portfolios[indexPath.section].isSelected = false
			self.addOperationBtn.isEnabled = !self.viewModel.selectedPortfolios.isEmpty
			self.tableView.reloadRows(at: [indexPath], with: .fade)
		}))

		choiceAlertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

		choiceAlertController.pruneNegativeWidthConstraints()
		self.present(choiceAlertController, animated: true, completion: nil)

	}

	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 10
	}

	func filterContentForSearchText(searchText: String) {
		self.viewModel.filteredPortfolios = viewModel.portfolios.filter({ (portfolio) -> Bool in
			if isSearchBarEmpty() {
				return true
			} else {
				return portfolio.name.lowercased().contains(searchText.lowercased())
			}
		})

		tableView.reloadData()
	}

	func isSearchBarEmpty() -> Bool {
		return searchController.searchBar.text?.isEmpty ?? true
	}

	func isFiltering() -> Bool {
		return searchController.isActive && !isSearchBarEmpty()
	}
}

// MARK: - UITableViewDelegate

extension PortfoliosController: UISearchResultsUpdating {
	func updateSearchResults(for searchController: UISearchController) {
		if let text = searchController.searchBar.text {
			filterContentForSearchText(searchText: text)
		}
	}
}
// MARK: - UITableViewDelegate

extension PortfoliosController: UITableViewDataSource {

	func numberOfSections(in tableView: UITableView) -> Int {
		if isFiltering() {
			return viewModel.filteredPortfolios.count
		}
		return viewModel.portfolios.count
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 1
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if let cell = tableView.dequeueReusableCell(withIdentifier: Identifiers.portfolioCell, for: indexPath) as? PortfolioCell {
			if isFiltering() {
				cell.portfolio = viewModel.filteredPortfolios[indexPath.section]
			} else {
				cell.portfolio = viewModel.portfolios[indexPath.section]
			}
			cell.backgroundColor = AppColors.Gray
			return cell
		}
		return UITableViewCell()
	}

	func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

		let deleteItem = UIContextualAction(style: .destructive, title: "Delete") { (_, _, _) in

			let portfolio = self.viewModel.portfolios[indexPath.section]
			PortfolioApi.sharedManager.deletePortfolio(id: portfolio.id) { [weak self] (result) in

				guard let self = self else {
					print("No Portfolio Controller more")
					return
				}

				if result {
					DispatchQueue.main.async {
						self.viewModel.portfolios.remove(at: indexPath.section)
						self.tableView.reloadData()
					}
				} else {
					self.simpleAlert(title: "Error.", msg: "Try again please!")
				}
			}

		}

		let changeItem = UIContextualAction(style: .normal, title: "Change") { (_, _, _) in
			let portfolio = self.viewModel.portfolios[indexPath.section]

			let alert = UIAlertController(title: "Change Portfolio", message: "Please input new portfolio name", preferredStyle: UIAlertController.Style.alert )

			let cancel = UIAlertAction(title: "Cancel", style: .default) { (_) in }
			alert.addAction(cancel)

			let save = UIAlertAction(title: "Save", style: .default) { (_) in

				guard let textFields = alert.textFields else {
					print("No text Field")
					return
				}

				let textField = textFields[0] as UITextField

				if textField.text != "" {
					if let text = textField.text {
						let randomInt = Int.random(in: 0..<20000)

						PortfolioApi.sharedManager.updatePortfolio(id: portfolio.id, portfolio: Portfolio(id: randomInt, name: text)) { [weak self] (result, portfolio) in

							guard let self = self else {
								print("No Portfolio Controller more")
								return
							}

							if result {
								if let portfolio = portfolio {
									DispatchQueue.main.async {
										self.viewModel.portfolios.remove(at: indexPath.section)
										self.viewModel.portfolios.append(ViewPortfilioItem(portfolio: portfolio))
										self.tableView.reloadData()
									}
								}
							} else {
								DispatchQueue.main.async {
									self.simpleAlert(title: "Error.", msg: "Try again please")
								}
							}
						}
					}
				} else {
					print("TF is Empty...")
				}
			}

			alert.addTextField { (textField) in
				textField.placeholder = "Portfolio Name"
			}

			alert.addAction(save)

			self.present(alert, animated: true, completion: nil)

		}
		let swipeActions = UISwipeActionsConfiguration(actions: [deleteItem, changeItem])
		return swipeActions
	}
}

//to avoid strange allerts with constraints bug
extension UIAlertController {
	func pruneNegativeWidthConstraints() {
		for subView in self.view.subviews {
			for constraint in subView.constraints where constraint.debugDescription.contains("width == - 16") {
				subView.removeConstraint(constraint)
			}
		}
	}
}
