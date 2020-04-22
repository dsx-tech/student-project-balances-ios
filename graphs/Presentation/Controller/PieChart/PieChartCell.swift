//
//  PieChartCell.swift
//  graphs
//
//  Created by Danila Ferents on 21.04.20.
//  Copyright © 2020 Danila Ferents. All rights reserved.
//

import UIKit

class PieChartCell: UITableViewCell {

	//Outlets
	@IBOutlet weak var asset: UILabel!
	@IBOutlet weak var value: UILabel!
	@IBOutlet weak var view: RoundedView!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

	func configureCell(asset: String, value: Double) {
		let formatter = NumberFormatter()
		formatter.numberStyle = .none
		formatter.maximumFractionDigits = 3

		self.asset.text = asset + ":"
		self.value.text = formatter.string(from: NSNumber(value: value))
		self.view.backgroundColor = AppColors.Gray
	}
}
