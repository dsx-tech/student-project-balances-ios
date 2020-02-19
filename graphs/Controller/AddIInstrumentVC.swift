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
	var period: durationQuotes!
	var vc: CorrelationVC!

    override func viewDidLoad() {
        super.viewDidLoad()
		firstInstrumentPicker.delegate = self
		secondInstrumentPicker.delegate = self
		periodPicker.delegate = self

		firstInstrumentPicker.dataSource = self
		secondInstrumentPicker.dataSource = self
		periodPicker.dataSource = self
		datePicker.datePickerMode = .date
    }
	@IBAction func savePicked(_ sender: Any) {
		vc.callculatecorrelation(firstinstrument: firstInstrument, secondinstrument: secondInstrument, startDate: datePicker.date, duration: period ?? .month)
		self.dismiss(animated: true, completion: nil)
	}
}

extension AddIInstrumentVC: UIPickerViewDelegate, UIPickerViewDataSource {
	func numberOfComponents(in pickerView: UIPickerView) -> Int {
		return 1
	}

	func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		if pickerView == firstInstrumentPicker || pickerView == secondInstrumentPicker {
			return instruments.count
		} else if pickerView == periodPicker {
			return durationQuotes.allvalues.count
		}
		return 0
	}

	func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
		if pickerView == firstInstrumentPicker || pickerView == secondInstrumentPicker {
			return instruments[row]
		} else if pickerView == periodPicker {
			return durationQuotes.allvalues[row]
		}
		return ""
	}

	func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		if pickerView == firstInstrumentPicker {
			firstInstrument = instruments[row]
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

