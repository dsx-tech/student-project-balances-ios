//
//  portfolioCell.swift
//  graphs
//
//  Created by Danila Ferents on 12.04.20.
//  Copyright © 2020 Danila Ferents. All rights reserved.
//

import UIKit

protocol CheckButton {
	func ckeckBtn()
}

class PortfolioCell: UITableViewCell {

	//Outlets
	@IBOutlet var portfolioNameLbl: UILabel!
	@IBOutlet weak var isSelectedBtn: UIButton!

	//Variables
	var portfolio: ViewPortfilioItem? {
		didSet {
			if let portfolio = portfolio {
				portfolioNameLbl.text = portfolio.name
			}
		}
	}

    override func awakeFromNib() {
        super.awakeFromNib()
    }

	override func setSelected(_ selected: Bool, animated: Bool) {
		super.setSelected(selected, animated: animated)

		if let portfolio = self.portfolio {
			isSelectedBtn.isHidden = !portfolio.isSelected
		}
	}
}
