//
//  AddIInstrumentVC.swift
//  graphs
//
//  Created by Danila Ferents on 18.02.20.
//  Copyright © 2020 Danila Ferents. All rights reserved.
//

import UIKit

class AddIInstrumentVC: UIViewController {

	//Outlets
	@IBOutlet weak var datePicker: UIDatePicker!
	@IBOutlet weak var firstInstrumentPicker: UIPickerView!
	@IBOutlet weak var secondInstrumentPicker: UIPickerView!
	@IBOutlet weak var periodPicker: UIPickerView!

	//Variables
	var firstInstrument: String!
	var secondInstrument: String!
	var firstinstrumentData = instruments
	var secondinstrumentData = instruments
	var period: durationQuotes!
	var vc: CorrelationVC!
	var basecurrency = "usd"

    override func viewDidLoad() {
        super.viewDidLoad()
		firstInstrumentPicker.delegate = self
		secondInstrumentPicker.delegate = self
		periodPicker.delegate = self
		firstinstrumentData.sort()
		firstInstrumentPicker.dataSource = self
		secondInstrumentPicker.dataSource = self
		periodPicker.dataSource = self
		datePicker.datePickerMode = .date
		let formatter = DateFormatter()

		formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"

		let start = formatter.date(from: "2019-01-01T00:59:59")
		datePicker.setDate(start!, animated: true)
    }
	@IBAction func savePicked(_ sender: Any) {
		vc.callculatecorrelation(firstinstrument: firstInstrument ?? instruments[0], secondinstrument: secondInstrument ?? instruments[0], startDate: datePicker.date, duration: period ?? .month)
		self.dismiss(animated: true, completion: nil)
	}
}

extension AddIInstrumentVC: UIPickerViewDelegate, UIPickerViewDataSource {
	func numberOfComponents(in pickerView: UIPickerView) -> Int {
		return 1
	}

	func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		if pickerView == firstInstrumentPicker  {
			return firstinstrumentData.count
		} else if pickerView == secondInstrumentPicker {
			return secondinstrumentData.filter({ (instrument) -> Bool in
				return instrument.hasSuffix(basecurrency)
			}).count
		} else if pickerView == periodPicker {
			return durationQuotes.allvalues.count
		}
		return 0
	}

	func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
		if pickerView == firstInstrumentPicker  {
			return firstinstrumentData[row]
		} else if pickerView == secondInstrumentPicker {
			return secondinstrumentData.filter({ (instrument) -> Bool in
				return instrument.hasSuffix(basecurrency)
			})[row]
		} else if pickerView == periodPicker {
			return durationQuotes.allvalues[row]
		}
		return ""
	}

	func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		if pickerView == firstInstrumentPicker {
			firstInstrument = firstinstrumentData[row]
			basecurrency = String(firstInstrument.split(separator: "-")[1])
			secondInstrumentPicker.reloadAllComponents()
		} else if pickerView == periodPicker {
			switch row {
			case 0:
				period = .month
			case 1:
				period = .threemonths
			case 2:
				period = .sixmonths
			case 3:
				period = .year
			default:
				period = .month
			}
		} else if pickerView == secondInstrumentPicker {
			secondInstrument = instruments[row]
		}
	}

}

