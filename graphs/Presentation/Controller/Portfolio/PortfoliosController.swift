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

class PortfoliosController: UIViewController {

	//Outlets
	@IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.tableFooterView = UIView(frame: .zero)
        }
    }

	//Variables
	let sections = ["UPLOADED", "PORTFOLIOS"]
	var uploaded: [Portfolio] = []
	var portfolios: [Portfolio] = []

	override func viewDidLoad() {
        super.viewDidLoad()
		tableView.delegate = self
		tableView.dataSource = self

		let headerView = HeaderView(frame: .zero)
		headerView.configure(text: "Upload Files", size: 27)
		tableView.tableHeaderView = headerView

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
					self.portfolios = portfolios
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
}

// MARK: - UITableViewDelegate

extension PortfoliosController: UITableViewDelegate {
	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

		/// Create the view.
		let headerView = UIView()
		headerView.backgroundColor = .clear

		/// Create the label that goes inside the view.
		let headerLabel = UILabel(frame: CGRect(x: 20, y: 0, width: tableView.bounds.size.width, height: 30))
		headerLabel.font = UIFont(name: "Arial", size: 18)
		headerLabel.textColor = UIColor.gray
		headerLabel.text = sections[section]
		headerLabel.sizeToFit()

		/// Add label to the view.
		headerView.addSubview(headerLabel)

		/// Return view.
		return headerView
	}

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		var id = 0
		let keychain = Keychain(service: "swagger")

		if indexPath.section == 0 {
			id = uploaded[indexPath.row].id
		} else {
			id = portfolios[indexPath.row].id
		}

		keychain["id"] = String(id)

		let targetStoryboardName = "main"
		let targetStoryboard = UIStoryboard(name: targetStoryboardName, bundle: nil)
		let portfolioVC = targetStoryboard.instantiateViewController(identifier: "pieChart")
		self.present(portfolioVC, animated: true, completion: nil)
	}

	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 30
	}
}

// MARK: - UITableViewDelegate

extension PortfoliosController: UITableViewDataSource {

	func numberOfSections(in tableView: UITableView) -> Int {
		return sections.count
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if section == 0 {
			return uploaded.count
		} else {
			return portfolios.count
		}
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if let cell = tableView.dequeueReusableCell(withIdentifier: Identifiers.portfolioCell, for: indexPath) as? PortfolioCell {
			if indexPath.section == 0 {
					cell.configure(portfolio: uploaded[indexPath.row])
				} else {
					cell.configure(portfolio: portfolios[indexPath.row])
				}
			return cell
			}
		return UITableViewCell()
	}
}
