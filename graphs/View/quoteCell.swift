//
//  quoteCell.swift
//  graphs
//
//  Created by Danila Ferents on 17.02.20.
//  Copyright © 2020 Danila Ferents. All rights reserved.
//

import UIKit

extension Double {
    func format(f: String) -> String {
        return String(format: "%\(f)f", self)
    }
}

protocol quoteCellDeleteDelegate {
	func deleteCell(instrument: String)
}

class quoteCell: UITableViewCell {

	//Outlets
	@IBOutlet weak var firstQuotesImg: UIImageView!
	@IBOutlet weak var secondQuotesImg: UIImageView!
	@IBOutlet weak var correlationLbl: UILabel!
	@IBOutlet weak var instrumentLbl: UILabel!
	@IBOutlet weak var deleteBtn: UIButton!
	@IBOutlet weak var timePeriodLbl: UILabel!

	var delegate: quoteCellDeleteDelegate!
	var instrument: instrumentCorrelation!
//	var id: String!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

	@IBAction func toGraph(_ sender: Any) {
		
	}
	override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
	
	@IBAction func deleteCell(_ sender: Any) {
		delegate.deleteCell(instrument: instrument.instrument)
	}

	func configureCell(instrumentcor: instrumentCorrelation) {

		self.instrument = instrumentcor

		//put values in outlets
		let doubleFormat = ".3"
		correlationLbl.text = "\((instrumentcor.correlation).format(f: doubleFormat))"
		timePeriodLbl.text = instrumentcor.timePeriod
		instrumentLbl.text = instrumentcor.firstCurrency + "-" + instrumentcor.secondCurrency
		if instrumentcor.correlation > 0 {
			correlationLbl.textColor = AppColors.Green
		} else if instrumentcor.correlation < 0 {
			correlationLbl.textColor = AppColors.Red
		} else {
			correlationLbl.textColor = AppColors.Default
		}

		firstQuotesImg.image = UIImage(named: instrumentcor.firstCurrency)

		secondQuotesImg.image = UIImage(named: instrumentcor.secondCurrency)

	}
}
