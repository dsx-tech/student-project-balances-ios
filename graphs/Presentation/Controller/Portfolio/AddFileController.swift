//
//  AddFileController.swift
//  graphs
//
//  Created by Danila Ferents on 12.04.20.
//  Copyright © 2020 Danila Ferents. All rights reserved.
//

import UIKit
import CoreServices

class AddFileController: UIViewController {

	//Outlets
	@IBOutlet weak var addBtn: UIButton!
	@IBOutlet weak var fileTableView: UITableView!
	@IBOutlet weak var progressBar: UIProgressView!
	@IBOutlet weak var procentLbl: UILabel!
	@IBOutlet weak var sizeLbl: UILabel!

	//Variables
	var ids: [Int]!
	var isTrades: Bool!

	override func viewDidLoad() {
		super.viewDidLoad()
	}

	@IBAction func AddTransactionsBtnClicked(_ sender: Any) {
		let picker = UIDocumentPickerViewController(documentTypes: [kUTTypeCommaSeparatedText as String], in: .open)
		picker.delegate = self

		self.isTrades = false
		present(picker, animated: true, completion: nil)
	}

	@IBAction func AddTradesBtnClicked(_ sender: Any) {
		let picker = UIDocumentPickerViewController(documentTypes: [kUTTypeCommaSeparatedText as String], in: .open)
		picker.delegate = self

		self.isTrades = true
		present(picker, animated: true, completion: nil)
	}
	
}

// MARK: - UIDocumentPickerDelegate

extension AddFileController: UIDocumentPickerDelegate {
	func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
		guard let isTrades = self.isTrades, let ids = self.ids, let url = urls.first else {
			simpleAlert(title: "Error.", msg: "Error in uploading")
			return
		}

		ids.forEach { (id) in
			if isTrades {
				PortfolioApi.sharedManager.uploadTransactions(id: id, fileUrl: url) { [weak self] (result) in

					guard let self = self else {
						print("No Instance more!")
						return
					}

					self.presentError(result: result)
				}
			} else {
				PortfolioApi.sharedManager.uploadTrades(id: id, fileUrl: url) { [weak self] (result) in

					guard let self = self else {
						print("No Instance more!")
						return
					}
					self.presentError(result: result)
				}
			}
		}
	}

	func presentError(result: Bool) {
		DispatchQueue.main.async {
			if result {
				self.simpleAlert(title: "Success!", msg: "Uploaded.")
			} else {
				self.simpleAlert(title: "Error.", msg: "Error in uploading")
			}
		}
	}
}
