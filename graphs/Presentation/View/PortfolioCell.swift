//
//  portfolioCell.swift
//  graphs
//
//  Created by Danila Ferents on 12.04.20.
//  Copyright © 2020 Danila Ferents. All rights reserved.
//

import UIKit

class PortfolioCell: UITableViewCell {

	//Outlets
	@IBOutlet weak var portfolioLbl: UILabel!
	@IBOutlet var portfolioNameLbl: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

	func configure(portfolio: Portfolio) {
		portfolioLbl.text = String(portfolio.id)
		portfolioNameLbl.text = portfolio.name
	}
}
